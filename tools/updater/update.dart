// Khmer Calendar updater (Windows: update-windows.exe, Linux: update-linux-<arch>).
//
// Flow:
//   1. app finishes download and starts this program (its own task)
//   2. recheck whether the app is still running; if it is, end that task
//   3. after the app is gone, unpack the package and replace files
//   4. write the stamp file, start the new app, then this task exits
// If anything fails it logs why and still tries to restart the old app.
// Log: <temp>/khmer_update.log
//
//   update --pid 123 --app-dir <dir> --exe khmer_calendar[.exe] --archive <file>
//          [--stamp <file> --built-at <iso time> --sha <commit>]
//
// Plain Dart, no packages: `dart compile exe tools/updater/update.dart -o update-windows.exe`
import 'dart:io';

final _sep = Platform.pathSeparator;
final _log = File('${Directory.systemTemp.path}${_sep}khmer_update.log');

void _say(String m) {
  try {
    _log.writeAsStringSync('${DateTime.now().toIso8601String()} $m\n', mode: FileMode.append);
  } catch (_) {}
}

Map<String, String> _parse(List<String> args) {
  final out = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    if (args[i].startsWith('--')) out[args[i].substring(2)] = args[i + 1];
  }
  return out;
}

Future<bool> _alive(int watchPid) async {
  if (watchPid <= 0 || watchPid == pid) return false;
  if (Platform.isWindows) {
    // tasklist is the wrong tool here: its text is localized and often still
    // lists a process that End Task already closed (or the reverse). Ask Windows.
    final r = await Process.run(_powershell, [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      'if (Get-Process -Id $watchPid -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }',
    ]);
    return r.exitCode == 0;
  }
  return (await Process.run('kill', ['-0', '$watchPid'])).exitCode == 0;
}

String get _systemRoot {
  final root = Platform.environment['SystemRoot'];
  if (root != null && root.isNotEmpty) return root;
  return r'C:\Windows';
}

String get _powershell => '$_systemRoot\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';

String get _taskkill => '$_systemRoot\\System32\\taskkill.exe';

/// Every process whose image name is the app (not this updater).
Future<List<int>> _programPids(String exe) async {
  final name = exe.split(_sep).last;
  if (Platform.isWindows) {
    final base = name.toLowerCase().endsWith('.exe') ? name.substring(0, name.length - 4) : name;
    final safe = base.replaceAll("'", "''");
    final ps = await Process.run(_powershell, [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "(Get-Process -Name '$safe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id) -join ' '",
    ]);
    return [
      for (final part in '${ps.stdout}'.split(RegExp(r'\s+')))
        if (int.tryParse(part) != null && int.parse(part) != pid) int.parse(part),
    ];
  }
  final r = await Process.run('ps', ['-C', name, '-o', 'pid=']);
  if (r.exitCode != 0) return const [];
  return [
    for (final part in '${r.stdout}'.split(RegExp(r'\s+')))
      if (int.tryParse(part) != null && int.parse(part) != pid) int.parse(part),
  ];
}

Future<bool> _programStillRunning(int watchPid, String exe) async {
  if (await _alive(watchPid)) return true;
  return (await _programPids(exe)).isNotEmpty;
}

/// Task Manager "End task" for one process.
/// No `/T`: a tree kill also targets this updater when the app started it, and
/// Windows then refuses the whole kill ("Access is denied"), so the app stays.
Future<void> _endPid(int target) async {
  if (target <= 0 || target == pid) return;
  if (Platform.isWindows) {
    final tk = await Process.run(_taskkill, ['/F', '/PID', '$target']);
    _say('taskkill /F /PID $target -> ${tk.exitCode} ${'${tk.stdout}'.trim()} ${'${tk.stderr}'.trim()}'.trim());
    if (await _alive(target)) {
      final ps = await Process.run(_powershell, [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'Stop-Process -Id $target -Force -ErrorAction SilentlyContinue',
      ]);
      _say('Stop-Process -Force $target -> ${ps.exitCode} ${'${ps.stderr}'.trim()}'.trim());
    }
  } else {
    final r = await Process.run('kill', ['-9', '$target']);
    _say('kill -9 $target -> ${r.exitCode} ${'${r.stderr}'.trim()}'.trim());
  }
}

Future<void> _endRunningProgram(int watchPid, String exe) async {
  final targets = <int>{...await _programPids(exe)};
  if (await _alive(watchPid)) targets.add(watchPid);
  targets.remove(pid);
  targets.removeWhere((p) => p <= 0);
  if (targets.isEmpty) {
    _say('recheck: program is not running');
    return;
  }
  _say('ending task: ${targets.join(', ')}');
  for (final target in targets) {
    await _endPid(target);
  }
}

/// Leave the app's process tree before ending it. Otherwise End Task kills us too.
Future<void> _ensureDetached(List<String> args) async {
  if (args.contains('--spawned')) return;
  final self = Platform.resolvedExecutable;
  final forwarded = [...args, '--spawned', '1'];
  _say('leaving the app process tree');
  if (Platform.isWindows) {
    String q(String s) => "'${s.replaceAll("'", "''")}'";
    final argList = forwarded.map(q).join(', ');
    final script = 'Start-Process -FilePath ${q(self)} -WindowStyle Hidden -ArgumentList $argList';
    final r = await Process.run(_powershell, ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script]);
    if (r.exitCode != 0) {
      _say('could not detach (${r.exitCode}): ${r.stderr}');
      return; // still try the update from here
    }
    exit(0);
  }
  try {
    await Process.start(self, forwarded, mode: ProcessStartMode.detached);
    exit(0);
  } catch (e) {
    _say('could not detach: $e');
  }
}

/// Recheck the running program, then End Task until it is actually gone.
Future<void> _closeApp(int watchPid, String exe) async {
  for (var i = 0; i < 8; i++) {
    if (!await _programStillRunning(watchPid, exe)) {
      _say('app already exited (pid $watchPid)');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  for (var round = 1; round <= 6; round++) {
    if (!await _programStillRunning(watchPid, exe)) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      // One more look: Task Manager can take a moment to drop the process.
      if (!await _programStillRunning(watchPid, exe)) {
        _say('app closed');
        return;
      }
    }
    _say('recheck $round: program still running');
    await _endRunningProgram(watchPid, exe);
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
  if (await _programStillRunning(watchPid, exe)) {
    throw 'The app (pid $watchPid) did not close in time';
  }
  await Future<void>.delayed(const Duration(milliseconds: 500));
  _say('app closed');
}

Future<Directory> _unpack(String archive) async {
  final stage = Directory('${Directory.systemTemp.path}${_sep}khmer_update_stage');
  if (stage.existsSync()) stage.deleteSync(recursive: true);
  stage.createSync(recursive: true);
  final zip = archive.toLowerCase().endsWith('.zip');
  // Windows: use the built-in bsdtar (it reads zip); a `tar` from Git for Windows could not.
  final tar = Platform.isWindows ? '${Platform.environment['SystemRoot'] ?? r'C:\\Windows'}\\System32\\tar.exe' : 'tar';
  final r = await Process.run(tar, [zip ? '-xf' : '-xzf', archive, '-C', stage.path]);
  if (r.exitCode != 0) throw 'Unpack failed (${r.exitCode}): ${r.stderr}';
  return stage;
}

/// The folder that holds the main executable (the package may or may not wrap it in one extra folder).
Directory _packageRoot(Directory stage, String exe) {
  if (File('${stage.path}$_sep$exe').existsSync()) return stage;
  for (final e in stage.listSync().whereType<Directory>()) {
    if (File('${e.path}$_sep$exe').existsSync()) return e;
  }
  throw 'The package does not contain $exe';
}

Future<void> _copyOver(
  Directory from,
  Directory to,
  String exe,
  int watchPid,
) async {
  final files = from.listSync(recursive: true, followLinks: false).whereType<File>().toList()
    // The main executable goes last: if copying breaks half way, the old app still starts.
    ..sort((a, b) {
      final ae = a.path.endsWith('$_sep$exe') ? 1 : 0;
      final be = b.path.endsWith('$_sep$exe') ? 1 : 0;
      return ae - be;
    });
  for (final f in files) {
    final rel = f.path.substring(from.path.length + 1);
    final dest = File('${to.path}$_sep$rel');
    dest.parent.createSync(recursive: true);
    for (var attempt = 1;; attempt++) {
      try {
        f.copySync(dest.path);
        break;
      } on FileSystemException {
        if (attempt >= 30) rethrow; // files stay locked for a moment after a process ends (antivirus, indexer)
        if (attempt == 1 || attempt % 4 == 0) {
          _say('file locked ($rel), recheck running program');
          await _endRunningProgram(watchPid, exe);
        }
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
  }
  if (!Platform.isWindows) await Process.run('chmod', ['+x', '${to.path}$_sep$exe']);
}

Future<void> _start(String appDir, String exe) async {
  final path = '$appDir$_sep$exe';
  if (Platform.isWindows) {
    // New console, not /B: the restarted app must outlive this updater task.
    await Process.run('cmd', ['/c', 'start', '', path], workingDirectory: appDir);
  } else {
    await Process.start(path, const [], workingDirectory: appDir, mode: ProcessStartMode.detached);
  }
}

Future<void> main(List<String> args) async {
  final a = _parse(args);
  final watchPid = int.tryParse(a['pid'] ?? '');
  final appDir = a['app-dir'];
  final exe = a['exe'];
  final archive = a['archive'];
  if (watchPid == null || appDir == null || exe == null || archive == null) {
    _say('Missing arguments: $args');
    exit(2);
  }
  _say('--- update start: $args');
  await _ensureDetached(args);
  try {
    await _closeApp(watchPid, exe);
    final stage = await _unpack(archive);
    final root = _packageRoot(stage, exe);
    await _copyOver(root, Directory(appDir), exe, watchPid);
    final stamp = a['stamp'];
    if (stamp != null && stamp.isNotEmpty) {
      final f = File(stamp)..parent.createSync(recursive: true);
      f.writeAsStringSync('{"builtAt":"${a['built-at'] ?? ''}","sha":"${a['sha'] ?? ''}"}');
    }
    try {
      stage.deleteSync(recursive: true);
      File(archive).deleteSync();
    } catch (_) {}
    _say('update ok');
  } catch (e) {
    _say('update FAILED: $e');
    try {
      await _start(appDir, exe); // bring the old version back
    } catch (_) {}
    exit(1);
  }
  try {
    await _start(appDir, exe);
    _say('app restarted');
  } catch (e) {
    _say('could not restart: $e');
    exit(1);
  }
  _say('updater task ended');
  exit(0);
}

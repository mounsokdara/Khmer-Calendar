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
    final r = await Process.run('tasklist', ['/FI', 'PID eq $watchPid', '/NH', '/FO', 'CSV']);
    final out = '${r.stdout}';
    if (_tasklistUnreadable(out)) {
      final ps = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        'if (Get-Process -Id $watchPid -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }',
      ]);
      return ps.exitCode == 0;
    }
    // CSV lines look like: "khmer_calendar.exe","1234","Session Name",...
    return RegExp('"$watchPid"').hasMatch(out);
  }
  return (await Process.run('kill', ['-0', '$watchPid'])).exitCode == 0;
}

bool _tasklistUnreadable(String out) {
  final t = out.trim();
  if (t.isEmpty) return true;
  if (t.contains('"') || t.contains('INFO:') || t.toLowerCase().contains('no tasks')) return false;
  return true;
}

/// Every process whose image name is the app (not this updater).
Future<List<int>> _programPids(String exe) async {
  final name = exe.split(_sep).last;
  if (Platform.isWindows) {
    final image = name.toLowerCase().endsWith('.exe') ? name : '$name.exe';
    final r = await Process.run('tasklist', ['/FI', 'IMAGENAME eq $image', '/FO', 'CSV', '/NH']);
    final out = '${r.stdout}';
    final found = <int>[
      for (final m in RegExp(r'"[^"]*","(\d+)"').allMatches(out))
        if (int.tryParse(m.group(1)!) != null) int.parse(m.group(1)!),
    ];
    if (found.isNotEmpty || !_tasklistUnreadable(out)) {
      return found.where((p) => p != pid).toList();
    }
    final base = image.toLowerCase().endsWith('.exe') ? image.substring(0, image.length - 4) : image;
    final safe = base.replaceAll("'", "''");
    final ps = await Process.run('powershell', [
      '-NoProfile',
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

/// End the running app task. [force] is Task Manager "End task" (taskkill /F, kill -9).
Future<void> _endRunningProgram(int watchPid, String exe, {required bool force}) async {
  final targets = <int>{...await _programPids(exe)};
  if (await _alive(watchPid)) targets.add(watchPid);
  targets.remove(pid);
  targets.removeWhere((p) => p <= 0);
  if (targets.isEmpty) return;
  _say('${force ? 'force ' : ''}ending task: ${targets.join(', ')}');
  if (Platform.isWindows) {
    for (final p in targets) {
      await Process.run('taskkill', ['/PID', '$p', '/T', if (force) '/F']);
    }
  } else {
    await Process.run('kill', [if (force) '-9', ...targets.map((p) => '$p')]);
  }
}

/// Recheck the running program. Let it exit on its own, then end the task until it is gone.
Future<void> _closeApp(int watchPid, String exe) async {
  for (var i = 0; i < 15; i++) {
    if (!await _programStillRunning(watchPid, exe)) {
      _say('app already exited (pid $watchPid)');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  for (var round = 1; round <= 8; round++) {
    if (!await _programStillRunning(watchPid, exe)) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _say('app closed');
      return;
    }
    _say('recheck $round: program still running');
    await _endRunningProgram(watchPid, exe, force: round >= 3);
    await Future<void>.delayed(Duration(milliseconds: round >= 3 ? 700 : 450));
  }
  if (await _programStillRunning(watchPid, exe)) {
    throw 'The app (pid $watchPid) did not close in time';
  }
  await Future<void>.delayed(const Duration(milliseconds: 600));
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
          await _endRunningProgram(watchPid, exe, force: true);
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

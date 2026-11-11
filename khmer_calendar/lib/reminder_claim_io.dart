import 'dart:io';

var _swept = false;

Directory _dir() => Directory(
    '${Directory.systemTemp.path}${Platform.pathSeparator}khmer_calendar_fired');

/// Atomically claims a reminder so the window and the background helper never
/// both show it. Returns true only for the first process that asks.
bool claimReminder(String key) {
  try {
    final dir = _dir();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!_swept) {
      _swept = true;
      final cutoff = DateTime.now().subtract(const Duration(days: 3));
      for (final e in dir.listSync()) {
        try {
          if (e is File && e.lastModifiedSync().isBefore(cutoff)) e.deleteSync();
        } catch (_) {}
      }
    }
    var name = key.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    if (name.length > 120) name = name.substring(0, 120);
    File('${dir.path}${Platform.pathSeparator}$name').createSync(exclusive: true);
    return true;
  } on FileSystemException {
    return false;
  } catch (_) {
    return true;
  }
}

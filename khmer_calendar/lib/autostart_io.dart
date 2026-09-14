import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';

void _setup() {
  LaunchAtStartup.instance.setup(
    appName: 'Khmer Calendar',
    appPath: Platform.resolvedExecutable,
  );
}

Future<bool> enableDesktopAutostart() async {
  _setup();
  await LaunchAtStartup.instance.enable();
  return LaunchAtStartup.instance.isEnabled();
}

Future<void> disableDesktopAutostart() async {
  _setup();
  await LaunchAtStartup.instance.disable();
}

Future<bool> isDesktopAutostartEnabled() async {
  _setup();
  return LaunchAtStartup.instance.isEnabled();
}

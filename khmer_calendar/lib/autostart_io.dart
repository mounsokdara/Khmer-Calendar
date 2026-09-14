import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';

Future<bool> enableDesktopAutostart() async {
  LaunchAtStartup.instance.setup(
    appName: 'Khmer Calendar',
    appPath: Platform.resolvedExecutable,
  );
  await LaunchAtStartup.instance.enable();
  return LaunchAtStartup.instance.isEnabled();
}

Future<void> disableDesktopAutostart() async {
  LaunchAtStartup.instance.setup(
    appName: 'Khmer Calendar',
    appPath: Platform.resolvedExecutable,
  );
  await LaunchAtStartup.instance.disable();
}

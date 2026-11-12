// In-app updater: reads version.txt, fetches the matching release tag (vX.Y.Z), downloads the package
// for this device and installs it without opening a browser.
export 'update_types.dart';
export 'update_stub.dart' if (dart.library.io) 'update_io.dart';

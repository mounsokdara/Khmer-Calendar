import 'dev_update_types.dart';

const bool inAppUpdateSupported = false;

Future<UpdateBuild?> fetchUpdateBuild() async => null;

Future<String> downloadUpdateBuild(UpdateBuild build, void Function(int received, int total) onProgress,
        {bool Function()? isCancelled}) async =>
    throw const UpdateException('Not supported on this platform');

Future<UpdateInstallResult> installUpdateBuild(String path, UpdateBuild build) async => UpdateInstallResult.failed;

const bool updateRestartsApp = false;

Future<void> finishUpdateInstall() async {}

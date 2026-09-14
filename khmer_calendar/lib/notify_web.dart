import 'dart:js_interop';

@JS('Notification.requestPermission')
external JSPromise<JSString> _requestPermission();

@JS('Notification.permission')
external JSString get _permission;

Future<bool> requestBrowserNotification() async {
  try {
    final r = await _requestPermission().toDart;
    return r.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

bool isBrowserNotificationGranted() {
  try {
    return _permission.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

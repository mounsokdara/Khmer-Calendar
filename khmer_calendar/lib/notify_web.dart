import 'dart:js_interop';

@JS('Notification.requestPermission')
external JSPromise<JSString> _requestPermission();

/// Always hits the browser Notification API so Continue never skips the prompt.
Future<bool> requestBrowserNotification() async {
  try {
    final r = await _requestPermission().toDart;
    return r.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

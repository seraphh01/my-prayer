import 'dart:js_interop';

@JS('hideFlutterLoading')
external void _hideFlutterLoading();

void hideHtmlSplashOverlay() {
  try {
    _hideFlutterLoading();
  } catch (_) {}
}

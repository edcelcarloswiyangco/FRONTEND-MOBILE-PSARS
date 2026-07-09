import 'dart:html' as html;

Future<String?> discoverLocalApiBaseUrl() async {
  return null;
}

Future<bool> hasActiveNetworkConnection() async {
  return html.window.navigator.onLine ?? false;
}
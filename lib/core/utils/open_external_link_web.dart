import 'dart:html' as html;

Future<bool> openExternalLink(Uri uri) async {
  html.window.open(uri.toString(), '_blank', 'noopener,noreferrer');
  return true;
}

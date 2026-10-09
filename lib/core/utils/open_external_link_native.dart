import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalLink(Uri uri) async {
  return launchUrl(uri, mode: LaunchMode.platformDefault);
}

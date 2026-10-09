import 'open_external_link_native.dart'
    if (dart.library.html) 'open_external_link_web.dart'
    as link_openers;

Future<bool> openExternalLink(Uri uri) => link_openers.openExternalLink(uri);

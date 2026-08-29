import 'package:web/web.dart' as web;

import 'csrf.dart';

/// Web: read the token from the cookie the server deliberately left readable.
class CsrfTokensImpl implements CsrfTokens {
  @override
  String? read() {
    for (final pair in web.document.cookie.split(';')) {
      final separator = pair.indexOf('=');
      if (separator < 0) continue;
      if (pair.substring(0, separator).trim() != csrfCookieName) continue;
      final value = pair.substring(separator + 1).trim();
      return value.isEmpty ? null : Uri.decodeComponent(value);
    }
    return null;
  }
}

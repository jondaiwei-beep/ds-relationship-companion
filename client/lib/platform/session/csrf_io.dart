import 'csrf.dart';

/// Android: the refresh token is sent in the request body, so there is no
/// ambient credential a cross-site request could ride on and nothing to
/// prove. The server only checks CSRF for `client_type = 'WEB'`.
class CsrfTokensImpl implements CsrfTokens {
  @override
  String? read() => null;
}

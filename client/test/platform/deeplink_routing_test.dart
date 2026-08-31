import 'package:dsapp/platform/deeplink/callback_params.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Android reader used to be `return null`, so every one of these was
/// unreachable on the only platform the product ships on. The manifest was
/// correct the whole time — Android handed the URI over and Dart dropped it.
void main() {
  group('a magic link carries its token in the fragment', () {
    test('both halves are read', () {
      final p = CallbackParams.parse(
        'https://ds-staging.beforeweplay.com/auth/callback#ml=tok123&flow=f-9',
      );

      expect(p, isNotNull);
      expect(p!.token, 'tok123');
      expect(p.flowId, 'f-9');
    });

    test('a token in the query is not accepted', () {
      // The fragment is deliberate: it never reaches an HTTP request, a
      // Referer header, or a server log. A link with the token in the query
      // has already leaked it, so honouring it would reward the leak.
      final p = CallbackParams.parse(
        'https://ds-staging.beforeweplay.com/auth/callback?ml=tok&flow=f',
      );

      expect(p, isNull);
    });

    test('half a link is no link', () {
      // Asking the server to consume a token this device never requested is
      // worse than reporting an incomplete link.
      for (final url in [
        'https://x/auth/callback#ml=tok123',
        'https://x/auth/callback#flow=f-9',
        'https://x/auth/callback#',
        'https://x/auth/callback',
      ]) {
        expect(CallbackParams.parse(url), isNull, reason: url);
      }
    });

    test('an empty value is missing, not present', () {
      expect(CallbackParams.parse('https://x/auth/callback#ml=&flow=f'), isNull);
      expect(CallbackParams.parse('https://x/auth/callback#ml=t&flow='), isNull);
    });
  });

  group('the path an incoming link routes to', () {
    // Mirrors `_open` in main.dart: the path is the contract, and the guard
    // decides who may see it.
    String pathOf(String url) {
      final uri = Uri.parse(url);
      return uri.fragment.isEmpty
          ? uri.path
          : '${uri.path}#${uri.fragment}';
    }

    test('an invitation keeps its token in the path', () {
      expect(
        pathOf('https://ds-staging.beforeweplay.com/invite/tok-abc'),
        '/invite/tok-abc',
      );
    });

    test('a magic link keeps its fragment', () {
      expect(
        pathOf('https://ds-staging.beforeweplay.com/auth/callback#ml=t&flow=f'),
        '/auth/callback#ml=t&flow=f',
      );
    });
  });
}

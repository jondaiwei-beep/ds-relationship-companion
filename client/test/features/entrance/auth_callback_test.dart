import 'package:dsapp/platform/deeplink/callback_params.dart';
import 'package:flutter_test/flutter_test.dart';

/// The magic-link callback carries a one-time token, and where it carries it
/// is a security decision rather than a formatting one.
void main() {
  group('the token travels in the fragment, on purpose', () {
    test('a real callback URL parses', () {
      final p = CallbackParams.parse(
        'https://ds.example.com/auth/callback#ml=abc.def&flow=f-1',
      );

      expect(p, isNotNull);
      expect(p!.token, 'abc.def');
      expect(p.flowId, 'f-1');
    });

    test('a token in the query string is not accepted', () {
      // The server puts it after `#` so it is never sent in the HTTP request
      // or a Referer header. A link carrying it as a query parameter did not
      // come from us, and consuming it would defeat the reason for the
      // fragment in the first place.
      expect(
        CallbackParams.parse(
          'https://ds.example.com/auth/callback?ml=abc&flow=f-1',
        ),
        isNull,
      );
    });
  });

  test('a URL captured from the production server parses', () {
    // Read out of the staging app log on 2026-08-30, unmodified. A parser
    // that only handles the URLs I imagined is not a parser for this server.
    const url =
        'https://ds-staging.beforeweplay.com/auth/callback'
        '#ml=ml1.3LtDIWKISmCDv8c4nEedXJOZDYpJ2hbWV3AQqgop4fE'
        '&flow=8bbe88a8-7c5d-4c4a-9e69-a6b51988d869';

    final p = CallbackParams.parse(url);
    expect(p!.token, 'ml1.3LtDIWKISmCDv8c4nEedXJOZDYpJ2hbWV3AQqgop4fE');
    expect(p.flowId, '8bbe88a8-7c5d-4c4a-9e69-a6b51988d869');
  });

  group('half a link is not a link', () {
    test('a token with no flow is refused', () {
      // Guessing the flow would mean asking the server to consume a token
      // this device never requested — which is exactly the forwarded-link
      // case the flow id exists to stop.
      expect(
        CallbackParams.parse('https://x/auth/callback#ml=abc'),
        isNull,
      );
    });

    test('a flow with no token is refused', () {
      expect(
        CallbackParams.parse('https://x/auth/callback#flow=f-1'),
        isNull,
      );
    });

    test('empty values are refused, not passed on', () {
      expect(
        CallbackParams.parse('https://x/auth/callback#ml=&flow=f-1'),
        isNull,
      );
      expect(
        CallbackParams.parse('https://x/auth/callback#ml=abc&flow='),
        isNull,
      );
    });

    test('no fragment at all is refused', () {
      expect(CallbackParams.parse('https://x/auth/callback'), isNull);
      expect(CallbackParams.parse('not a url at all'), isNull);
    });
  });

  test('a percent-encoded token survives the round trip', () {
    // The server encodes it; a JWT-shaped token contains characters that
    // change meaning inside a fragment if they are not decoded back.
    final p = CallbackParams.parse(
      'https://x/auth/callback#ml=a%2Bb%2Fc%3D&flow=f-1',
    );

    expect(p!.token, 'a+b/c=');
  });
}

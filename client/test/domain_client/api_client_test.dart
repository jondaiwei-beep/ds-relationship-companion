import 'package:dio/dio.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// The transport is the last layer that can refuse to send a protected
/// request without a session. Above it are widgets, providers, lifecycle
/// callbacks and retries — thirty-four screens' worth of callers, each of
/// which would otherwise have to remember.
void main() {
  late ApiClient api;
  late _RecordingAdapter adapter;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;
    api = ApiClient(baseUrl: 'http://test', dio: dio);
  });

  group('with no session', () {
    test('an authenticated GET is refused before it is sent', () async {
      await expectLater(api.get('/v1/dynamics/abc/today'), throwsA(isA<DioException>()));

      expect(
        adapter.sent,
        isEmpty,
        reason: 'the request still names a Dynamic in its path, even though '
            'the server would reject it',
      );
    });

    test('the refusal reads as authorization loss, not a generic error',
        () async {
      try {
        await api.get('/v1/dynamics/abc/today');
        fail('should have thrown');
      } on DioException catch (e) {
        // Screens classify 401/403 as authorization loss and show the state
        // designed for it. A bare error would show "something went wrong".
        expect(e.response?.statusCode, 401);
      }
    });

    test('an authenticated POST is refused', () async {
      await expectLater(
        api.post('/v1/occurrences/1/complete'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.sent, isEmpty);
    });

    test('an unauthenticated POST is allowed: that is how you sign in',
        () async {
      await api.post('/v1/auth/sign-in', authenticated: false, body: {});

      expect(adapter.sent, ['/v1/auth/sign-in']);
    });
  });

  group('the 401 interceptor', () {
    test('fires when an authenticated request is rejected', () async {
      var lost = 0;
      api.interceptAuthenticationLoss(() => lost++);
      api.accessToken = 'dead';
      adapter.status = 401;

      await expectLater(
        api.get('/v1/dynamics/abc/today'),
        throwsA(isA<DioException>()),
      );

      expect(lost, 1);
    });

    test('does not fire for a wrong password', () async {
      // Sign-in carries no token. A 401 there means the credentials were
      // wrong, and ending the session would clear the very thing the person
      // is trying to create.
      var lost = 0;
      api.interceptAuthenticationLoss(() => lost++);
      adapter.status = 401;

      await expectLater(
        api.post('/v1/auth/sign-in', authenticated: false, body: {}),
        throwsA(isA<DioException>()),
      );

      expect(lost, 0);
    });

    test('does not fire on a 404, which is how "not yours" is answered',
        () async {
      // Authorization failures answer 404 by design, so that a non-member
      // cannot tell an existing Dynamic from an absent one. That must not be
      // read as a dead token.
      var lost = 0;
      api.interceptAuthenticationLoss(() => lost++);
      api.accessToken = 'good';
      adapter.status = 404;

      await expectLater(
        api.get('/v1/dynamics/someone-elses/today'),
        throwsA(isA<DioException>()),
      );

      expect(lost, 0);
    });
  });

  test('with a session, requests are sent and carry the token', () async {
    api.accessToken = 'tok';

    await api.get('/v1/dynamics/abc/today');

    expect(adapter.sent, ['/v1/dynamics/abc/today']);
    expect(adapter.lastHeaders?['Authorization'], 'Bearer tok');
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  final sent = <String>[];
  Map<String, dynamic>? lastHeaders;
  int status = 200;

  @override
  Future<ResponseBody> fetch(RequestOptions options, _, _) async {
    sent.add(options.path);
    lastHeaders = options.headers;
    return ResponseBody.fromString('{}', status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

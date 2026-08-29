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

  @override
  Future<ResponseBody> fetch(RequestOptions options, _, _) async {
    sent.add(options.path);
    lastHeaders = options.headers;
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

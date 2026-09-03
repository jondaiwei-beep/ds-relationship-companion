import 'package:dio/dio.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// The edge host is not reachable from every network at every moment. A
/// connect that never reached the server is retried on the next host; a
/// request the server may have received is not retried here at all.
void main() {
  late _HostAdapter adapter;
  late ApiClient api;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: 'https://edge'));
    adapter = _HostAdapter();
    dio.httpClientAdapter = adapter;
    api = ApiClient(
      baseUrl: 'https://edge',
      fallbackBaseUrls: const ['https://direct'],
      dio: dio,
    );
  });

  test('a connect failure on the edge is retried on the direct host', () async {
    adapter.failing = {'edge'};
    await api.post('/v1/auth/register', body: const {}, authenticated: false);

    expect(adapter.hosts, ['edge', 'direct']);
    expect(api.baseUrl, 'https://direct', reason: 'stays on the host that answered');
    expect(api.resolve('/v1/media/x'), 'https://direct/v1/media/x');
  });

  test('gives up after the hosts are exhausted and reports the connect failure', () async {
    adapter.failing = {'edge', 'direct'};
    await expectLater(
      api.post('/v1/auth/register', body: const {}, authenticated: false),
      throwsA(isA<DioException>().having((e) => e.type, 'type', DioExceptionType.connectionError)),
    );
    expect(adapter.hosts.length, 3, reason: 'three attempts, rotating');
    expect(api.baseUrl, 'https://edge');
  });

  test('a timeout after sending is not retried: the request may have landed', () async {
    adapter.failing = {'edge'};
    adapter.failure = DioExceptionType.receiveTimeout;
    await expectLater(
      api.post('/v1/auth/register', body: const {}, authenticated: false),
      throwsA(isA<DioException>().having((e) => e.type, 'type', DioExceptionType.receiveTimeout)),
    );
    expect(adapter.hosts, ['edge']);
  });
}

class _HostAdapter implements HttpClientAdapter {
  final hosts = <String>[];
  Set<String> failing = const {};
  DioExceptionType failure = DioExceptionType.connectionError;

  @override
  Future<ResponseBody> fetch(RequestOptions options, _, _) async {
    hosts.add(options.uri.host);
    if (failing.contains(options.uri.host)) {
      throw DioException(requestOptions: options, type: failure);
    }
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

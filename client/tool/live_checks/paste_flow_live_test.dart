// NOT part of the normal suite — this hits LIVE staging and creates real
// rows. Run explicitly:
//   flutter test tool/live_checks/paste_flow_live_test.dart
//
// Exercises the real sign-in flow against LIVE staging, using the same
// AuthRepository the app uses: start a flow on-device, request a link, read
// the link off the host, parse it exactly as the paste field does, and
// consume it. Proves the paste path actually authenticates.
import 'dart:convert';
import 'dart:io';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://ds-api.beforeweplay.com';
  final email = 'owner-apk-${DateTime.now().millisecondsSinceEpoch}@staging.test';

  test('a pasted magic link signs the device in', () async {
    final repo = AuthRepository(ApiClient(baseUrl: base));

    // 1. The device starts a flow; the verifier never leaves it.
    final flow = AuthFlow.start();
    await repo.requestMagicLink(email: email, flow: flow);

    // 2. Retrieve the link from the host (staging has no email sender).
    final r = await Process.run('bash', ['ops/fetch_magic_link.sh', email]);
    final out = r.stdout.toString();
    final link = RegExp(r'https://\S+').firstMatch(out)?.group(0);
    expect(link, isNotNull, reason: 'no link on host:\n$out');

    // 3. Parse it exactly as the paste field does.
    final uri = Uri.parse(link!);
    final parts = Uri.splitQueryString(uri.fragment);
    final token = parts['ml'];
    final flowId = parts['flow'];
    expect(token, isNotNull);
    expect(flowId, flow.flowId, reason: 'link must belong to THIS flow');

    // 4. Consume with the verifier this device generated.
    final result = await repo.consume(token: token!, flow: flow, clientType: 'ANDROID');
    expect(result.accessToken, isNotEmpty);

    // 5. The token really authorizes a protected endpoint.
    final c = HttpClient();
    final req = await c.postUrl(Uri.parse('$base/v1/dynamics'));
    req.headers.set('authorization', 'Bearer ${result.accessToken}');
    req.headers.contentType = ContentType.json;
    // Every mutation is idempotent by contract.
    req.headers.set('Idempotency-Key', 'apk-check-${flow.flowId}');
    req.write(jsonEncode({
      'desiredOutcome': 'CLOSER',
      'structureLevel': 'LIGHT',
      'referenceTimezone': 'Asia/Shanghai',
    }));
    final resp = await req.close();
    final body = await resp.transform(utf8.decoder).join();
    expect(resp.statusCode, 201, reason: body);
    // ignore: avoid_print
    print('OK  signed in as $email  ->  dynamic created');
  }, timeout: const Timeout(Duration(minutes: 3)));
}

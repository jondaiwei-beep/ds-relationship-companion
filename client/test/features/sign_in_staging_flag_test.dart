import 'package:dsapp/features/activation/presentation/sign_in_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('staging quick sign-in is OFF unless explicitly compiled in', () {
    // It depends on a server endpoint that returns a credential for any
    // address, so it must never appear in a build that did not ask for it.
    // Production passes no --dart-define, so this stays false.
    expect(kStagingQuickSignIn, isFalse,
        reason: 'STAGING_QUICK_SIGN_IN must never default to on');
  });
}

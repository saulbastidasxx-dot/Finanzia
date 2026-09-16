import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/services/security_service.dart';

void main() {
  test('PIN result enum exposes locked state', () {
    expect(PinCheckResult.values, contains(PinCheckResult.locked));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/services/preferences_service.dart';

void main() {
  test('alert defaults are enabled', () {
    const p = AlertPreferences();
    expect(p.enabled, isTrue);
    expect(p.budgets, isTrue);
    expect(p.recurring, isTrue);
    expect(p.debts, isTrue);
  });
}

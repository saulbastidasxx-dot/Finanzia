import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/financial_alert_service.dart';
import 'package:finanzia/services/preferences_service.dart';

void main() {
  test('master switch disables alerts', () {
    expect(
      FinancialAlertService().build(
        FinanceStore(),
        preferences: const AlertPreferences(enabled: false),
      ),
      isEmpty,
    );
  });
}

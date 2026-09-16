import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/financial_alert_service.dart';
import 'package:finanzia/services/preferences_service.dart';

void main() {
  test('disabled preferences produce no alerts', () {
    final s = FinanceStore();
    final alerts = FinancialAlertService().build(
      s,
      preferences: const AlertPreferences(enabled: false),
    );
    expect(alerts, isEmpty);
  });
}

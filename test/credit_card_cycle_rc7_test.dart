import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/credit_card_service.dart';

void main() {
  test('card uses its own statement and due days', () {
    final store = FinanceStore();
    const card = FinanceAccount(
      id: 'c',
      name: 'Visa',
      type: AccountType.creditCard,
      openingBalance: 0,
      creditLimit: 1000,
      statementDay: 25,
      dueDay: 8,
    );
    store.accounts.add(card);

    final summary = CreditCardService.summary(
      store,
      card,
      at: DateTime(2026, 9, 16),
    );
    expect(summary.statementDate, DateTime(2026, 9, 25));
    expect(summary.dueDate, DateTime(2026, 10, 8));
  });

  test('account JSON preserves billing cycle', () {
    const card = FinanceAccount(
      id: 'c',
      name: 'Visa',
      type: AccountType.creditCard,
      openingBalance: 0,
      statementDay: 31,
      dueDay: 10,
    );
    final restored = FinanceAccount.fromJson(card.toJson());
    expect(restored.statementDay, 31);
    expect(restored.dueDay, 10);
  });
}

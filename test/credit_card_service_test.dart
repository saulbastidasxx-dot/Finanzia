import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/credit_card_service.dart';

void main() {
  test('credit card summary', () {
    final store = FinanceStore();
    const card = FinanceAccount(
      id: 'c',
      name: 'Card',
      type: AccountType.creditCard,
      openingBalance: -250,
      creditLimit: 1000,
    );
    store.accounts.add(card);
    final s = CreditCardService.summary(store, card);
    expect(s.available, 750);
    expect(s.utilization, 0.25);
  });
}

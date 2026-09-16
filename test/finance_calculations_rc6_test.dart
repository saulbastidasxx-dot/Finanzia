import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';
import 'package:finanzia/models/finance_store.dart';

void main() {
  test('transfers change balances but not income expense', () {
    final s = FinanceStore();
    s.accounts.addAll(const [
      FinanceAccount(
        id: 'a',
        name: 'A',
        type: AccountType.bank,
        openingBalance: 1000,
      ),
      FinanceAccount(
        id: 'b',
        name: 'B',
        type: AccountType.savings,
        openingBalance: 0,
      ),
    ]);
    final n = DateTime.now();
    s.transactions.add(
      FinanceTransaction(
        id: 't',
        type: TransactionType.transfer,
        amount: 250,
        category: 'Otros',
        description: 'Mover',
        accountId: 'a',
        destinationAccountId: 'b',
        date: n,
      ),
    );
    expect(s.balanceFor('a'), 750);
    expect(s.balanceFor('b'), 250);
    expect(s.amountForMonth(TransactionType.income, n), 0);
    expect(s.amountForMonth(TransactionType.expense, n), 0);
  });
  test('credit card payment modeled as transfer is not double counted', () {
    final s = FinanceStore();
    s.accounts.addAll(const [
      FinanceAccount(
        id: 'bank',
        name: 'Banco',
        type: AccountType.bank,
        openingBalance: 1000,
      ),
      FinanceAccount(
        id: 'card',
        name: 'Tarjeta',
        type: AccountType.creditCard,
        openingBalance: -300,
        creditLimit: 1000,
      ),
    ]);
    s.transactions.add(
      FinanceTransaction(
        id: 'p',
        type: TransactionType.transfer,
        amount: 200,
        category: 'Otros',
        description: 'Pago tarjeta',
        accountId: 'bank',
        destinationAccountId: 'card',
        date: DateTime.now(),
      ),
    );
    expect(s.balanceFor('bank'), 800);
    expect(s.balanceFor('card'), -100);
    expect(s.monthExpenses, 0);
  });
  test('savings rate guards zero income', () {
    expect(FinanceStore().savingsRateForMonth(DateTime.now()), 0);
  });
}

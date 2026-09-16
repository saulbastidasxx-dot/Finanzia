import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';

void main() {
  test('transfer destination contract', () {
    final t = FinanceTransaction(
      id: '1',
      type: TransactionType.transfer,
      amount: 10,
      category: 'Otros',
      description: 'Transfer',
      accountId: 'a',
      destinationAccountId: 'b',
      date: DateTime(2026),
    );
    expect(t.toJson()['destinationAccountId'], 'b');
  });
}

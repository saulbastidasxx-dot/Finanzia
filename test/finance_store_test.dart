import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';

void main() {
  test('transfer is a distinct transaction type', () {
    expect(TransactionType.transfer, isNot(TransactionType.expense));
    expect(TransactionType.transfer, isNot(TransactionType.income));
  });
}

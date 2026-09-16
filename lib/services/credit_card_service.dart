import '../models/finance_models.dart';
import '../models/finance_store.dart';

class CreditCardSummary {
  final double debt, limit, available, utilization;
  final DateTime? statementDate, dueDate;
  const CreditCardSummary({
    required this.debt,
    required this.limit,
    required this.available,
    required this.utilization,
    this.statementDate,
    this.dueDate,
  });
}

class CreditCardService {
  static DateTime _nextDay(DateTime now, int day, {int monthOffset = 0}) {
    final base = DateTime(now.year, now.month + monthOffset, 1);
    final max = DateTime(base.year, base.month + 1, 0).day;
    return DateTime(base.year, base.month, day.clamp(1, max).toInt());
  }

  static CreditCardSummary summary(
    FinanceStore store,
    FinanceAccount a, {
    DateTime? at,
  }) {
    final limit = a.creditLimit ?? 0.0;
    final debt = (-store.balanceFor(
      a.id,
    )).clamp(0.0, double.infinity).toDouble();
    final now = at ?? DateTime.now();
    DateTime? statement, due;
    if (a.statementDay != null) {
      statement = _nextDay(now, a.statementDay!);
      if (statement.isBefore(DateTime(now.year, now.month, now.day)))
        statement = _nextDay(now, a.statementDay!, monthOffset: 1);
    }
    if (a.dueDay != null) {
      due = _nextDay(now, a.dueDay!);
      if (due.isBefore(DateTime(now.year, now.month, now.day)))
        due = _nextDay(now, a.dueDay!, monthOffset: 1);
    }
    return CreditCardSummary(
      debt: debt,
      limit: limit,
      available: (limit - debt).clamp(0.0, double.infinity).toDouble(),
      utilization: limit <= 0 ? 0.0 : (debt / limit).clamp(0.0, 1.0).toDouble(),
      statementDate: statement,
      dueDate: due,
    );
  }
}

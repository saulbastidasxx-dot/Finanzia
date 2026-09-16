enum FinancialAlertSeverity { info, warning, critical }

class FinancialAlert {
  final String id;
  final String title;
  final String message;
  final FinancialAlertSeverity severity;
  final DateTime? dueDate;
  final String kind;
  const FinancialAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.dueDate,
    required this.kind,
  });
}

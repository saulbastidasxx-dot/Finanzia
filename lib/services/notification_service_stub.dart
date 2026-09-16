import '../models/financial_alert.dart';

class NotificationService {
  Future<bool> initialize() => Future.value(false);
  Future<int> notifyAlerts(List<FinancialAlert> alerts) => Future.value(0);
}

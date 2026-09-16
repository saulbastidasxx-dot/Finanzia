import '../models/finance_store.dart';
import 'export_service_common.dart';

class ExportService {
  Future<String> exportCsv(FinanceStore store) async => buildFinanceCsv(store);
}

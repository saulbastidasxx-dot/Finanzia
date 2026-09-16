import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/finance_store.dart';
import 'export_service_common.dart';
class ExportService{Future<String> exportCsv(FinanceStore store)async{final d=await getApplicationDocumentsDirectory();final f=File('${d.path}/finanzia_movimientos_${DateTime.now().millisecondsSinceEpoch}.csv');await f.writeAsString(buildFinanceCsv(store));return f.path;}}

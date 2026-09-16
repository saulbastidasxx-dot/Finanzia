import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/finance_store.dart';
import 'export_service_common.dart';
class ExportService{
  Future<String> exportCsv(FinanceStore store)async{
    final d=await getTemporaryDirectory();
    final name='finanzia_movimientos_${DateTime.now().millisecondsSinceEpoch}.csv';
    final f=File('${d.path}/$name');
    await f.writeAsString(buildFinanceCsv(store),flush:true);
    await Share.shareXFiles([XFile(f.path)],subject:'Movimientos de Finanzia',text:'Exportación CSV de Finanzia');
    return name;
  }
}

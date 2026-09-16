import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/finance_store.dart';
import 'report_pdf_builder.dart';
class PdfExportService{
  Future<String> exportReport(FinanceStore store)async{
    final bytes=await buildFinancePdf(store);
    final d=await getTemporaryDirectory();
    final name='finanzia_reporte_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final f=File('${d.path}/$name');
    await f.writeAsBytes(bytes,flush:true);
    await Share.shareXFiles([XFile(f.path)],subject:'Reporte de Finanzia',text:'Reporte financiero generado por Finanzia');
    return name;
  }
}

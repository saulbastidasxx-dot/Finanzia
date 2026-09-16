import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/finance_store.dart';
import 'report_pdf_builder.dart';
class PdfExportService{Future<String> exportReport(FinanceStore store)async{final bytes=await buildFinancePdf(store);final d=await getApplicationDocumentsDirectory();final f=File('${d.path}/finanzia_reporte_${DateTime.now().millisecondsSinceEpoch}.pdf');await f.writeAsBytes(bytes,flush:true);return f.path;}}

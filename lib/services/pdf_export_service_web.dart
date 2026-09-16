// ignore_for_file: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use
import 'dart:html' as html;

import '../models/finance_store.dart';
import 'report_pdf_builder.dart';

class PdfExportService {
  Future<String> exportReport(FinanceStore store) async {
    final bytes = await buildFinancePdf(store);
    final name =
        'finanzia_reporte_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)
      ..download = name
      ..style.display = 'none';
    html.document.body?.children.add(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
    return name;
  }
}

// ignore_for_file: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use
import 'dart:html' as html;

import '../models/finance_store.dart';
import 'export_service_common.dart';

class ExportService {
  Future<String> exportCsv(FinanceStore store) async {
    final name =
        'finanzia_movimientos_${DateTime.now().millisecondsSinceEpoch}.csv';
    final blob = html.Blob([buildFinanceCsv(store)], 'text/csv;charset=utf-8');
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

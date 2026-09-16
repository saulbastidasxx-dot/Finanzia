import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../models/finance_store.dart';

Future<Uint8List> buildFinancePdf(FinanceStore store) async {
  final doc = pw.Document(title: 'Reporte Finanzia');
  final money = NumberFormat.currency(symbol: '${store.profile.currency} ');
  final now = DateTime.now();
  final byCategory = <String, double>{};
  for (final t in store.transactions.where(
    (x) =>
        x.type == TransactionType.expense &&
        x.date.year == now.year &&
        x.date.month == now.month,
  )) {
    byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
  }
  final categories = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(34),
      header: (c) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Finanzia',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
        ],
      ),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Pagina ${c.pageNumber} de ${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (c) => [
        pw.Text(
          'Resumen financiero',
          style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Reporte personal de ${store.profile.name}'),
        pw.SizedBox(height: 20),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _metric('Patrimonio neto', money.format(store.netWorth)),
            _metric('Ingresos del mes', money.format(store.monthIncome)),
            _metric('Gastos del mes', money.format(store.monthExpenses)),
            _metric(
              'Ahorro del mes',
              money.format(store.monthIncome - store.monthExpenses),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Cuentas',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Cuenta', 'Tipo', 'Saldo'],
          data: store.accounts
              .map(
                (a) => [
                  a.name,
                  a.type.name,
                  money.format(store.balanceFor(a.id)),
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Gastos por categoria · mes actual',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        if (categories.isEmpty)
          pw.Text('Sin gastos registrados.')
        else
          pw.TableHelper.fromTextArray(
            headers: ['Categoria', 'Total'],
            data: categories
                .take(12)
                .map((e) => [e.key, money.format(e.value)])
                .toList(),
          ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Movimientos recientes',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Fecha', 'Tipo', 'Descripcion', 'Monto'],
          data:
              (store.transactions.toList()
                    ..sort((a, b) => b.date.compareTo(a.date)))
                  .take(20)
                  .map(
                    (t) => [
                      DateFormat('dd/MM/yy').format(t.date),
                      t.type.name,
                      t.description,
                      money.format(t.amount),
                    ],
                  )
                  .toList(),
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          'Este reporte resume los datos registrados en Finanzia y no constituye asesoramiento financiero.',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _metric(String label, String value) => pw.Container(
  width: 240,
  padding: const pw.EdgeInsets.all(12),
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: PdfColors.grey300),
    borderRadius: pw.BorderRadius.circular(8),
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 5),
      pw.Text(
        value,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
    ],
  ),
);

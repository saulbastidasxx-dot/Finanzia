import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../models/finance_store.dart';
import '../core/theme.dart';
import '../widgets/empty_state.dart';
import 'add_transaction.dart';

class TransactionsScreen extends StatefulWidget {
  final FinanceStore store;
  const TransactionsScreen({super.key, required this.store});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String query = '';
  TransactionType? filter;
  String? _accountFilter, _categoryFilter;
  DateTime? _fromDate, _toDate;
  FinanceStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    final all = [...store.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final items = all.where((t) {
      final q = query.toLowerCase().trim();
      final text =
          q.isEmpty ||
          t.description.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      final type = filter == null || t.type == filter;
      final account =
          _accountFilter == null ||
          t.accountId == _accountFilter ||
          t.destinationAccountId == _accountFilter;
      final category = _categoryFilter == null || t.category == _categoryFilter;
      final from =
          _fromDate == null ||
          !t.date.isBefore(
            DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day),
          );
      final to =
          _toDate == null ||
          t.date.isBefore(
            DateTime(_toDate!.year, _toDate!.month, _toDate!.day + 1),
          );
      return text && type && account && category && from && to;
    }).toList();
    final money = NumberFormat.currency(symbol: '\$');
    final advanced =
        _accountFilter != null ||
        _categoryFilter != null ||
        _fromDate != null ||
        _toDate != null;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Movimientos',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Nuevo movimiento',
                onPressed: () => showTransactionEditor(context, store),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _advancedFilters(context),
              icon: const Icon(Icons.tune),
              label: Text(advanced ? 'Filtros activos' : 'Filtros avanzados'),
            ),
          ),
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar por descripción o categoría',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: filter == null,
                onSelected: (_) => setState(() => filter = null),
              ),
              FilterChip(
                label: const Text('Ingresos'),
                selected: filter == TransactionType.income,
                onSelected: (_) =>
                    setState(() => filter = TransactionType.income),
              ),
              FilterChip(
                label: const Text('Gastos'),
                selected: filter == TransactionType.expense,
                onSelected: (_) =>
                    setState(() => filter = TransactionType.expense),
              ),
              FilterChip(
                label: const Text('Transferencias'),
                selected: filter == TransactionType.transfer,
                onSelected: (_) =>
                    setState(() => filter = TransactionType.transfer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin movimientos',
              description: advanced || query.isNotEmpty
                  ? 'No hay movimientos que coincidan con los filtros.'
                  : 'Registra tu primer ingreso, gasto o transferencia.',
              actionLabel: advanced
                  ? 'Limpiar filtros'
                  : 'Registrar movimiento',
              onAction: advanced
                  ? _clearAdvanced
                  : () => showTransactionEditor(context, store),
            ),
          ...items.map(
            (t) => Dismissible(
              key: ValueKey(t.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmDelete(context, t),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(20),
                color: FinanziaTheme.coral,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => store.deleteTransaction(t.id),
              child: Card(
                child: ListTile(
                  onTap: () =>
                      showTransactionEditor(context, store, existing: t),
                  leading: CircleAvatar(
                    child: Icon(
                      t.type == TransactionType.income
                          ? Icons.arrow_downward
                          : t.type == TransactionType.expense
                          ? Icons.arrow_upward
                          : Icons.swap_horiz,
                    ),
                  ),
                  title: Text(t.description),
                  subtitle: Text(
                    '${t.category} · ${DateFormat.yMMMd().format(t.date)}\n${_accountName(t.accountId)}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '${t.type == TransactionType.income
                        ? '+'
                        : t.type == TransactionType.expense
                        ? '-'
                        : ''}${money.format(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: t.type == TransactionType.income
                          ? FinanziaTheme.green
                          : t.type == TransactionType.expense
                          ? FinanziaTheme.coral
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAdvanced() => setState(() {
    _accountFilter = null;
    _categoryFilter = null;
    _fromDate = null;
    _toDate = null;
  });

  Future<void> _advancedFilters(BuildContext context) async {
    var account = _accountFilter, category = _categoryFilter;
    var from = _fromDate, to = _toDate;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) {
          Future<void> pick(bool isFrom) async {
            final current = isFrom ? from : to;
            final picked = await showDatePicker(
              context: sheet,
              initialDate: current ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null)
              setSheet(() {
                if (isFrom) {
                  from = picked;
                } else {
                  to = picked;
                }
              });
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheet).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filtros avanzados',
                    style: Theme.of(sheet).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: account,
                    decoration: const InputDecoration(labelText: 'Cuenta'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...store.accounts.map(
                        (a) => DropdownMenuItem<String?>(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setSheet(() => account = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...store.categories.map(
                        (c) =>
                            DropdownMenuItem<String?>(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (v) => setSheet(() => category = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => pick(true),
                          child: Text(
                            from == null
                                ? 'Desde'
                                : DateFormat.yMd().format(from!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => pick(false),
                          child: Text(
                            to == null ? 'Hasta' : DateFormat.yMd().format(to!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setSheet(() {
                            account = null;
                            category = null;
                            from = null;
                            to = null;
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (from != null &&
                              to != null &&
                              from!.isAfter(to!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La fecha inicial no puede ser posterior a la final.',
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _accountFilter = account;
                            _categoryFilter = category;
                            _fromDate = from;
                            _toDate = to;
                          });
                          Navigator.pop(sheet);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _accountName(String id) {
    for (final a in store.accounts) {
      if (a.id == id) return a.name;
    }
    return 'Cuenta eliminada';
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    FinanceTransaction t,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Eliminar movimiento'),
          content: Text(
            '¿Eliminar “${t.description}”? Los saldos se recalcularán automáticamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}

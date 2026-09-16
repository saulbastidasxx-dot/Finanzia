import 'package:flutter/material.dart';

import '../core/validators.dart';
import '../models/finance_models.dart';
import '../models/finance_store.dart';

Future<void> showTransactionEditor(
  BuildContext context,
  FinanceStore store, {
  TransactionType initial = TransactionType.expense,
  FinanceTransaction? existing,
}) async {
  if (store.accounts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crea una cuenta antes de registrar movimientos.'),
      ),
    );
    return;
  }
  var type = existing?.type ?? initial;
  var accountId = existing?.accountId ?? store.accounts.first.id;
  String? destination = existing?.destinationAccountId;
  var selectedDate = existing?.date ?? DateTime.now();
  final amount = TextEditingController(
    text: existing == null ? '' : existing.amount.toStringAsFixed(2),
  );
  final description = TextEditingController(text: existing?.description ?? '');
  final category = TextEditingController(text: existing?.category ?? '');
  final formKey = GlobalKey<FormState>();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, setLocal) {
        final destinations = store.accounts
            .where((a) => a.id != accountId)
            .toList();
        if (destination == accountId) destination = null;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(c).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Nuevo movimiento' : 'Editar movimiento',
                    style: Theme.of(c).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Gasto'),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Ingreso'),
                      ),
                      ButtonSegment(
                        value: TransactionType.transfer,
                        label: Text('Transferir'),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (s) => setLocal(() => type = s.first),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => FinanziaValidators.positiveMoney(v),
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: description,
                    validator: (v) => FinanziaValidators.requiredText(
                      v,
                      label: 'La descripción',
                    ),
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 12),
                  if (type != TransactionType.transfer)
                    TextFormField(
                      controller: category,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        helperText: 'Si la dejas vacía se usará “Otros”',
                      ),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: accountId,
                    items: store.accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => accountId = v!),
                    decoration: InputDecoration(
                      labelText: type == TransactionType.transfer
                          ? 'Desde'
                          : 'Cuenta',
                    ),
                  ),
                  if (type == TransactionType.transfer) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: destination,
                      validator: (v) =>
                          v == null ? 'Selecciona la cuenta de destino' : null,
                      items: destinations
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => destination = v),
                      decoration: const InputDecoration(labelText: 'Hacia'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: c,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null)
                        setLocal(
                          () => selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            selectedDate.hour,
                            selectedDate.minute,
                          ),
                        );
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final value = double.parse(
                        amount.text.replaceAll(',', '.'),
                      );
                      final tx = FinanceTransaction(
                        id:
                            existing?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        type: type,
                        amount: value,
                        category: type == TransactionType.transfer
                            ? 'Transferencia'
                            : (category.text.trim().isEmpty
                                  ? 'Otros'
                                  : category.text.trim()),
                        description: description.text.trim(),
                        accountId: accountId,
                        destinationAccountId: type == TransactionType.transfer
                            ? destination
                            : null,
                        date: selectedDate,
                      );
                      if (existing == null) {
                        await store.addTransaction(tx);
                      } else {
                        await store.updateTransaction(tx);
                      }
                      if (c.mounted) Navigator.pop(c);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        existing == null
                            ? 'Guardar movimiento'
                            : 'Guardar cambios',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showAddTransaction(
  BuildContext context,
  FinanceStore store,
  TransactionType initial,
) => showTransactionEditor(context, store, initial: initial);

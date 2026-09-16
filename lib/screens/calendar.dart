import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../models/finance_store.dart';

final money = NumberFormat.currency(symbol: '\$');

class CalendarScreen extends StatelessWidget {
  final FinanceStore store;
  const CalendarScreen({super.key, required this.store});
  @override
  Widget build(BuildContext c) {
    final items = [...store.recurring]
      ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
    final out = items
        .where((x) => x.isExpense && x.active)
        .fold<double>(0, (s, x) => s + x.amount);
    final inc = items
        .where((x) => !x.isExpense && x.active)
        .fold<double>(0, (s, x) => s + x.amount);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Calendario',
                  style: Theme.of(c).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Nuevo recurrente',
                onPressed: () => _edit(c),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Pagos e ingresos recurrentes del mes'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              Chip(label: Text('Pagos ${money.format(out)}')),
              Chip(label: Text('Ingresos ${money.format(inc)}')),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aún no tienes movimientos recurrentes.'),
              ),
            ),
          ...items.map(
            (r) => Card(
              child: ListTile(
                onTap: () => _edit(c, existing: r),
                leading: CircleAvatar(child: Text('${r.dayOfMonth}')),
                title: Text(r.name),
                subtitle: Text(
                  '${r.category} · ${r.isExpense ? 'Gasto' : 'Ingreso'}${r.active ? '' : ' · Pausado'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      money.format(r.amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _edit(c, existing: r);
                        if (v == 'delete') _delete(c, r);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext c, RecurringPayment item) async {
    final ok =
        await showDialog<bool>(
          context: c,
          builder: (d) => AlertDialog(
            title: const Text('Eliminar recurrente'),
            content: Text(
              '¿Eliminar “${item.name}”? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(d, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
    if (ok) await store.deleteRecurring(item.id);
  }

  void _edit(BuildContext c, {RecurringPayment? existing}) {
    if (store.accounts.isEmpty) {
      ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(
          content: Text(
            'Crea una cuenta antes de añadir movimientos recurrentes.',
          ),
        ),
      );
      return;
    }
    final name = TextEditingController(text: existing?.name ?? ''),
        amount = TextEditingController(
          text: existing?.amount.toStringAsFixed(2) ?? '',
        ),
        day = TextEditingController(
          text: existing?.dayOfMonth.toString() ?? '',
        );
    String account = existing?.accountId ?? store.accounts.first.id,
        category = existing?.category ?? store.categories.first;
    bool expense = existing?.isExpense ?? true,
        active = existing?.active ?? true;
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: Text(
            existing == null ? 'Nuevo recurrente' : 'Editar recurrente',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
                  ),
                  TextFormField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Monto'),
                    validator: (v) =>
                        (double.tryParse((v ?? '').replaceAll(',', '.')) ??
                                0) <=
                            0
                        ? 'Introduce un monto mayor que 0'
                        : null,
                  ),
                  TextFormField(
                    controller: day,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Día del mes (1–28)',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 || n > 28
                          ? 'Usa un día entre 1 y 28'
                          : null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: store.categories
                        .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                        .toList(),
                    onChanged: (v) => category = v!,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: account,
                    items: store.accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => account = v!,
                    decoration: const InputDecoration(labelText: 'Cuenta'),
                  ),
                  SwitchListTile(
                    value: expense,
                    onChanged: (v) => set(() => expense = v),
                    title: Text(expense ? 'Gasto' : 'Ingreso'),
                  ),
                  SwitchListTile(
                    value: active,
                    onChanged: (v) => set(() => active = v),
                    title: const Text('Activo'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final x = RecurringPayment(
                  id:
                      existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  category: category,
                  accountId: account,
                  amount: double.parse(amount.text.replaceAll(',', '.')),
                  dayOfMonth: int.parse(day.text),
                  isExpense: expense,
                  active: active,
                );
                if (existing == null) {
                  await store.addRecurring(x);
                } else {
                  await store.updateRecurring(x);
                }
                if (d.mounted) Navigator.pop(d);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

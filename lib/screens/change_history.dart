import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_store.dart';
import '../models/change_event.dart';

class ChangeHistoryScreen extends StatelessWidget {
  final FinanceStore store;
  const ChangeHistoryScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) {
    final items = store.changes.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de cambios')),
      body: items.isEmpty
          ? const Center(child: Text('Todavía no hay cambios registrados.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (c, i) => _tile(items[i]),
            ),
    );
  }

  Widget _tile(ChangeEvent e) => Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Icon(
          e.action == 'delete' ? Icons.delete_outline : Icons.edit_outlined,
        ),
      ),
      title: Text(
        '${_label(e.entity)} · ${e.action == 'delete' ? 'Eliminado' : 'Actualizado'}',
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy · HH:mm').format(e.changedAt.toLocal()),
      ),
      trailing: Tooltip(
        message: e.synced ? 'Sincronizado' : 'Pendiente de sincronizar',
        child: Icon(
          e.synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
        ),
      ),
    ),
  );
  String _label(String x) => switch (x) {
    'account' => 'Cuenta',
    'transaction' => 'Movimiento',
    'budget' => 'Presupuesto',
    'goal' => 'Meta',
    'debt' => 'Deuda',
    'recurring' => 'Recurrente',
    'profile' => 'Perfil',
    _ => x,
  };
}

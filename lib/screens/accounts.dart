import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/validators.dart';
import '../models/finance_models.dart';
import '../models/finance_store.dart';
import '../widgets/empty_state.dart';
import 'credit_card_details.dart';

class AccountsScreen extends StatelessWidget {
  final FinanceStore store;
  const AccountsScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '\$');
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cuentas y tarjetas',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _editor(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (store.accounts.isEmpty)
            EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Aún no tienes cuentas',
              description: 'Agrega tu banco, efectivo, ahorros o tarjeta para comenzar a registrar movimientos.',
              actionLabel: 'Crear cuenta',
              onAction: () => _editor(context),
            ),
          ...store.accounts.map(
            (a) => Card(
              child: ListTile(
                onTap: () => a.type == AccountType.creditCard
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreditCardDetailsScreen(store: store, account: a),
                        ),
                      )
                    : _editor(context, existing: a),
                leading: CircleAvatar(
                  child: Icon(
                    a.type == AccountType.creditCard
                        ? Icons.credit_card
                        : Icons.account_balance_wallet_outlined,
                  ),
                ),
                title: Text(a.name),
                subtitle:
                    a.type == AccountType.creditCard && a.creditLimit != null
                    ? Builder(
                        builder: (_) {
                          final debt = (-store.balanceFor(
                            a.id,
                          )).clamp(0.0, double.infinity).toDouble();
                          final used = (debt / a.creditLimit!)
                              .clamp(0.0, 1.0)
                              .toDouble();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Límite ${money.format(a.creditLimit)} · Disponible ${money.format((a.creditLimit! - debt).clamp(0.0, double.infinity).toDouble())}',
                              ),
                              const SizedBox(height: 5),
                              LinearProgressIndicator(value: used),
                            ],
                          );
                        },
                      )
                    : Text(_typeLabel(a.type)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      money.format(store.balanceFor(a.id)),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _editor(context, existing: a);
                        if (v == 'delete') _delete(context, a);
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

  String _typeLabel(AccountType type) => switch (type) {
    AccountType.bank => 'Banco',
    AccountType.cash => 'Efectivo',
    AccountType.creditCard => 'Tarjeta de crédito',
    AccountType.savings => 'Ahorros',
  };

  Future<void> _editor(BuildContext context, {FinanceAccount? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final balance = TextEditingController(
      text: (existing?.openingBalance ?? 0).toStringAsFixed(2),
    );
    final limit = TextEditingController(
      text: existing?.creditLimit?.toStringAsFixed(2) ?? '',
    );
    final statementDay = TextEditingController(
      text: existing?.statementDay?.toString() ?? '',
    );
    final dueDay = TextEditingController(
      text: existing?.dueDay?.toString() ?? '',
    );
    AccountType type = existing?.type ?? AccountType.bank;
    final key = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Nueva cuenta' : 'Editar cuenta'),
          content: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    validator: (v) =>
                        FinanziaValidators.requiredText(v, label: 'El nombre'),
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AccountType>(
                    initialValue: type,
                    items: AccountType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(_typeLabel(e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Tipo'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: balance,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (v) =>
                        double.tryParse((v ?? '').replaceAll(',', '.')) == null
                        ? 'Ingresa un saldo válido'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Saldo inicial',
                    ),
                  ),
                  if (type == AccountType.creditCard) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: limit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        return FinanziaValidators.positiveMoney(
                          v,
                          label: 'El límite',
                        );
                      },
                      decoration: const InputDecoration(
                        labelText: 'Límite de crédito',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: statementDay,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        final n = int.tryParse(v!);
                        return n == null || n < 1 || n > 31
                            ? 'Día entre 1 y 31'
                            : null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Día de corte',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dueDay,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        final n = int.tryParse(v!);
                        return n == null || n < 1 || n > 31
                            ? 'Día entre 1 y 31'
                            : null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Día de vencimiento',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(key.currentState?.validate() ?? false)) return;
                final account = FinanceAccount(
                  id:
                      existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  type: type,
                  openingBalance: double.parse(
                    balance.text.replaceAll(',', '.'),
                  ),
                  creditLimit:
                      type == AccountType.creditCard &&
                          limit.text.trim().isNotEmpty
                      ? double.parse(limit.text.replaceAll(',', '.'))
                      : null,
                  statementDay:
                      type == AccountType.creditCard &&
                          statementDay.text.trim().isNotEmpty
                      ? int.parse(statementDay.text)
                      : null,
                  dueDay:
                      type == AccountType.creditCard &&
                          dueDay.text.trim().isNotEmpty
                      ? int.parse(dueDay.text)
                      : null,
                );
                if (existing == null) {
                  await store.addAccount(account);
                } else {
                  await store.updateAccount(account);
                }
                if (c.mounted) Navigator.pop(c);
              },
              child: Text(existing == null ? 'Guardar' : 'Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, FinanceAccount account) async {
    final used = store.transactions.any(
      (t) => t.accountId == account.id || t.destinationAccountId == account.id,
    );
    if (used) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes eliminar una cuenta que tiene movimientos.'),
        ),
      );
      return;
    }
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Eliminar cuenta'),
            content: Text(
              '¿Eliminar “${account.name}”? Esta acción no se puede deshacer.',
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
    if (ok) await store.deleteAccount(account.id);
  }
}

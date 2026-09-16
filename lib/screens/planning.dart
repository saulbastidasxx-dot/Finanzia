import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../models/finance_store.dart';
import '../widgets/empty_state.dart';

final _money = NumberFormat.currency(symbol: '\$');

class PlanningScreen extends StatefulWidget {
  final FinanceStore store;
  const PlanningScreen({super.key, required this.store});
  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tab;
  @override
  void initState() {
    super.initState();
    tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Planificación',
                  style: Theme.of(c).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Añadir',
                onPressed: () => _edit(c),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
        TabBar(
          controller: tab,
          tabs: const [
            Tab(text: 'Presupuestos'),
            Tab(text: 'Metas'),
            Tab(text: 'Deudas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tab,
            children: [_budgets(), _goals(), _debts()],
          ),
        ),
      ],
    ),
  );
  Widget _budgets() {
    if (widget.store.budgets.isEmpty)
      return EmptyState(
        icon: Icons.pie_chart_outline,
        title: 'Sin presupuestos',
        description: 'Define límites mensuales para controlar tus categorías.',
        actionLabel: 'Crear presupuesto',
        onAction: () => _edit(context),
      );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: widget.store.budgets.map((b) {
        final spent = widget.store.spentForCategory(b.category),
            p = b.limit <= 0
                ? 0.0
                : (spent / b.limit).clamp(0.0, 1.0).toDouble();
        return Card(
          child: InkWell(
            onTap: () => _edit(context, budget: b),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.category,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${_money.format(spent)} / ${_money.format(b.limit)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: p),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _confirmDelete(
                          'presupuesto',
                          () => widget.store.deleteBudget(b.id),
                        ),
                        child: const Text('Eliminar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _edit(context, budget: b),
                        child: const Text('Editar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _goals() {
    if (widget.store.goals.isEmpty)
      return EmptyState(
        icon: Icons.flag_outlined,
        title: 'Sin metas',
        description: 'Crea una meta y sigue tu progreso de ahorro.',
        actionLabel: 'Crear meta',
        onAction: () => _edit(context),
      );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: widget.store.goals
          .map(
            (g) => Card(
              child: ListTile(
                onTap: () => _edit(context, goal: g),
                title: Text(g.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: g.target <= 0
                          ? 0
                          : (g.current / g.target).clamp(0.0, 1.0).toDouble(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_money.format(g.current)} de ${_money.format(g.target)}${g.targetDate == null ? '' : ' · Meta ${DateFormat('dd/MM/yyyy').format(g.targetDate!)}'}',
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _edit(context, goal: g);
                    if (v == 'delete')
                      _confirmDelete(
                        'meta',
                        () => widget.store.deleteGoal(g.id),
                      );
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _debts() {
    if (widget.store.debts.isEmpty)
      return EmptyState(
        icon: Icons.account_balance_outlined,
        title: 'Sin deudas registradas',
        description:
            'Añade préstamos o deudas para incluirlos en tu patrimonio neto.',
        actionLabel: 'Añadir deuda',
        onAction: () => _edit(context),
      );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            title: const Text('Deuda total'),
            trailing: Text(
              _money.format(widget.store.debtTotal),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        ...widget.store.debts.map(
          (d) => Card(
            child: ListTile(
              onTap: () => _edit(context, debt: d),
              title: Text(d.name),
              subtitle: Text(
                'APR ${d.apr.toStringAsFixed(1)}% · Pago mín. ${_money.format(d.minimumPayment)}${d.dueDate == null ? '' : ' · Vence ${DateFormat('dd/MM/yyyy').format(d.dueDate!)}'}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _edit(context, debt: d);
                  if (v == 'delete')
                    _confirmDelete(
                      'deuda',
                      () => widget.store.deleteDebt(d.id),
                    );
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    String what,
    Future<void> Function() action,
  ) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text('Eliminar $what'),
            content: Text('¿Seguro que deseas eliminar este $what?'),
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
    if (ok) await action();
  }

  void _edit(BuildContext c, {Budget? budget, SavingsGoal? goal, Debt? debt}) {
    final i = budget != null
        ? 0
        : goal != null
        ? 1
        : debt != null
        ? 2
        : tab.index;
    final editing = budget != null || goal != null || debt != null;
    final name = TextEditingController(
          text: budget?.category ?? goal?.name ?? debt?.name ?? '',
        ),
        a = TextEditingController(
          text:
              budget?.limit.toString() ??
              goal?.target.toString() ??
              debt?.balance.toString() ??
              '',
        ),
        b = TextEditingController(
          text: goal?.current.toString() ?? debt?.apr.toString() ?? '',
        ),
        min = TextEditingController(
          text: debt?.minimumPayment.toString() ?? '',
        );
    DateTime? date = goal?.targetDate ?? debt?.dueDate;
    String? error;
    showDialog(
      context: c,
      builder: (d) => StatefulBuilder(
        builder: (d, setD) => AlertDialog(
          title: Text(
            '${editing ? 'Editar' : 'Nuevo'} ${i == 0
                ? 'presupuesto'
                : i == 1
                ? 'meta'
                : 'deuda'}',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: i == 0 ? 'Categoría' : 'Nombre',
                  ),
                ),
                TextField(
                  controller: a,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: i == 0
                        ? 'Límite mensual'
                        : i == 1
                        ? 'Objetivo'
                        : 'Saldo',
                  ),
                ),
                if (i > 0)
                  TextField(
                    controller: b,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: i == 1 ? 'Ahorrado actualmente' : 'APR %',
                    ),
                  ),
                if (i == 2)
                  TextField(
                    controller: min,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Pago mínimo'),
                  ),
                if (i > 0)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      i == 1 ? 'Fecha objetivo' : 'Próximo vencimiento',
                    ),
                    subtitle: Text(
                      date == null
                          ? 'Sin fecha'
                          : DateFormat('dd/MM/yyyy').format(date!),
                    ),
                    trailing: IconButton(
                      tooltip: 'Elegir fecha',
                      onPressed: () async {
                        final x = await showDatePicker(
                          context: d,
                          initialDate:
                              date ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (x != null) setD(() => date = x);
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: TextStyle(color: Theme.of(d).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (editing)
              TextButton(
                onPressed: () {
                  Navigator.pop(d);
                  if (i == 0)
                    _confirmDelete(
                      'presupuesto',
                      () => widget.store.deleteBudget(budget!.id),
                    );
                  if (i == 1)
                    _confirmDelete(
                      'meta',
                      () => widget.store.deleteGoal(goal!.id),
                    );
                  if (i == 2)
                    _confirmDelete(
                      'deuda',
                      () => widget.store.deleteDebt(debt!.id),
                    );
                },
                child: const Text('Eliminar'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final x = double.tryParse(a.text.replaceAll(',', '.')) ?? 0,
                    y = double.tryParse(b.text.replaceAll(',', '.')) ?? 0,
                    z = double.tryParse(min.text.replaceAll(',', '.')) ?? 0;
                if (name.text.trim().isEmpty || x <= 0 || y < 0 || z < 0) {
                  setD(() => error = 'Revisa los campos.');
                  return;
                }
                final id =
                    budget?.id ??
                    goal?.id ??
                    debt?.id ??
                    DateTime.now().microsecondsSinceEpoch.toString();
                if (i == 0) {
                  final v = Budget(
                    id: id,
                    category: name.text.trim(),
                    limit: x,
                  );
                  editing
                      ? widget.store.updateBudget(v)
                      : widget.store.addBudget(v);
                }
                if (i == 1) {
                  if (y > x) {
                    setD(
                      () => error =
                          'El ahorro actual no puede superar el objetivo.',
                    );
                    return;
                  }
                  final v = SavingsGoal(
                    id: id,
                    name: name.text.trim(),
                    target: x,
                    current: y,
                    targetDate: date,
                  );
                  editing
                      ? widget.store.updateGoal(v)
                      : widget.store.addGoal(v);
                }
                if (i == 2) {
                  final v = Debt(
                    id: id,
                    name: name.text.trim(),
                    balance: x,
                    apr: y,
                    minimumPayment: z,
                    dueDate: date,
                  );
                  editing
                      ? widget.store.updateDebt(v)
                      : widget.store.addDebt(v);
                }
                Navigator.pop(d);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

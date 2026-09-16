import 'package:flutter/material.dart';

import '../models/finance_store.dart';
import '../models/financial_alert.dart';
import '../services/financial_alert_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';

class AlertsScreen extends StatefulWidget {
  final FinanceStore store;
  const AlertsScreen({super.key, required this.store});
  @override
  State<AlertsScreen> createState() => _S();
}

class _S extends State<AlertsScreen> {
  AlertPreferences? prefs;
  @override
  void initState() {
    super.initState();
    PreferencesService().loadAlerts().then((v) {
      if (mounted) setState(() => prefs = v);
    });
  }

  @override
  Widget build(BuildContext c) {
    if (prefs == null)
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    final alerts = FinancialAlertService().build(
      widget.store,
      preferences: prefs!,
    );
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alertas',
                  style: Theme.of(c).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Badge(
                label: Text('${alerts.length}'),
                child: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prefs!.enabled
                ? 'Vencimientos, pagos recurrentes y presupuestos que requieren atención.'
                : 'Las alertas están desactivadas en Configuración.',
          ),
          const SizedBox(height: 12),
          if (prefs!.enabled)
            FilledButton.tonalIcon(
              onPressed: () => _notify(c, alerts),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Activar avisos del dispositivo'),
            ),
          const SizedBox(height: 18),
          if (alerts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay alertas financieras activas.'),
              ),
            )
          else
            ...alerts.map(
              (a) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(_icon(a))),
                  title: Text(
                    a.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(a.message),
                  trailing: Icon(_sev(a.severity)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _notify(BuildContext c, List<FinancialAlert> a) async {
    final svc = NotificationService();
    final available = await svc.initialize();
    if (!c.mounted) return;
    if (!available) {
      ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(
          content: Text(
            'Las notificaciones locales están disponibles en Android/iPhone.',
          ),
        ),
      );
      return;
    }
    final n = await svc.notifyAlerts(a);
    if (c.mounted)
      ScaffoldMessenger.of(c)
          .showSnackBar(SnackBar(content: Text('$n avisos nuevos enviados.')));
  }

  IconData _icon(FinancialAlert a) => switch (a.kind) {
    'budget' => Icons.pie_chart_outline,
    'debt' => Icons.receipt_long_outlined,
    _ => Icons.event_repeat_outlined,
  };
  IconData _sev(FinancialAlertSeverity s) => switch (s) {
    FinancialAlertSeverity.info => Icons.info_outline,
    FinancialAlertSeverity.warning => Icons.warning_amber,
    FinancialAlertSeverity.critical => Icons.error_outline,
  };
}

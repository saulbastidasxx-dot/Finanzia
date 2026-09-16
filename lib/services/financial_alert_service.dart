import '../models/finance_store.dart';
import '../models/financial_alert.dart';
import 'preferences_service.dart';

class FinancialAlertService {
  List<FinancialAlert> build(FinanceStore store, {DateTime? now, AlertPreferences preferences=const AlertPreferences()}) {
    if(!preferences.enabled){return const [];}
    final today = now ?? DateTime.now();
    final alerts = <FinancialAlert>[];
    if(preferences.budgets) { for (final b in store.budgets) {
      final spent = store.spentForCategory(b.category);
      if (b.limit <= 0) continue;
      final ratio = spent / b.limit;
      if (ratio >= 1) {
        alerts.add(FinancialAlert(id:'budget:${b.id}', title:'Presupuesto excedido', message:'${b.category}: ${_money(spent)} de ${_money(b.limit)}', severity:FinancialAlertSeverity.critical, kind:'budget'));
      } else if (ratio >= .8) {
        alerts.add(FinancialAlert(id:'budget:${b.id}', title:'Presupuesto cerca del límite', message:'${b.category}: ${(ratio*100).round()}% utilizado', severity:FinancialAlertSeverity.warning, kind:'budget'));
      }
    }
    }
    if(preferences.recurring) { for (final r in store.recurring.where((x)=>x.active)) {
      final due = _nextDayOfMonth(today, r.dayOfMonth);
      final days = _days(today, due);
      if (days <= 7) alerts.add(FinancialAlert(id:'recurring:${r.id}:${due.month}', title:r.isExpense?'Pago próximo':'Ingreso esperado', message:'${r.name} · ${_money(r.amount)} · ${days==0?'hoy':'en $days día${days==1?'':'s'}'}', severity:days<=2?FinancialAlertSeverity.warning:FinancialAlertSeverity.info, dueDate:due, kind:'recurring'));
    }
    }
    if(preferences.debts) { for (final d in store.debts) {
      if (d.dueDate == null) continue;
      final days = _days(today, d.dueDate!);
      if (days >= 0 && days <= 10) alerts.add(FinancialAlert(id:'debt:${d.id}:${d.dueDate!.month}', title:'Vencimiento de deuda', message:'${d.name} · mínimo ${_money(d.minimumPayment)} · ${days==0?'vence hoy':'vence en $days días'}', severity:days<=3?FinancialAlertSeverity.critical:FinancialAlertSeverity.warning, dueDate:d.dueDate, kind:'debt'));
    }
    }
    alerts.sort((a,b)=>_weight(b.severity).compareTo(_weight(a.severity)));
    return alerts;
  }
  int _weight(FinancialAlertSeverity s)=>switch(s){FinancialAlertSeverity.info=>1,FinancialAlertSeverity.warning=>2,FinancialAlertSeverity.critical=>3};
  int _days(DateTime a, DateTime b){final x=DateTime(a.year,a.month,a.day),y=DateTime(b.year,b.month,b.day);return y.difference(x).inDays;}
  DateTime _nextDayOfMonth(DateTime n,int day){DateTime candidate=DateTime(n.year,n.month,day.clamp(1,DateTime(n.year,n.month+1,0).day).toInt());if(candidate.isBefore(DateTime(n.year,n.month,n.day))) {final max=DateTime(n.year,n.month+2,0).day;candidate=DateTime(n.year,n.month+1,day.clamp(1,max).toInt());}return candidate;}
  String _money(double v)=>'\$${v.toStringAsFixed(2)}';
}

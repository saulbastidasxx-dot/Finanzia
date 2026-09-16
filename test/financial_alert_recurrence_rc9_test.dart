import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/financial_alert_service.dart';
void main(){
  test('recurring alert id changes with the due month',(){
    final s=FinanceStore();s.accounts.add(const FinanceAccount(id:'a',name:'Banco',type:AccountType.bank,openingBalance:0));
    s.recurring.add(const RecurringPayment(id:'r',name:'Renta',category:'Vivienda',accountId:'a',amount:500,dayOfMonth:5,isExpense:true,active:true));
    final jan=FinancialAlertService().build(s,now:DateTime(2026,1,1)).firstWhere((a)=>a.kind=='recurring');
    final feb=FinancialAlertService().build(s,now:DateTime(2026,2,1)).firstWhere((a)=>a.kind=='recurring');
    expect(jan.id,isNot(feb.id));
  });
  test('paused recurring items do not create alerts',(){
    final s=FinanceStore();s.accounts.add(const FinanceAccount(id:'a',name:'Banco',type:AccountType.bank,openingBalance:0));
    s.recurring.add(const RecurringPayment(id:'r',name:'Renta',category:'Vivienda',accountId:'a',amount:500,dayOfMonth:5,isExpense:true,active:false));
    expect(FinancialAlertService().build(s,now:DateTime(2026,1,1)).where((a)=>a.kind=='recurring'),isEmpty);
  });
}

import '../models/finance_models.dart';
import '../models/finance_store.dart';

class CreditCardSummary{
 final double debt,limit,available,utilization;final DateTime? statementDate,dueDate;
 const CreditCardSummary({required this.debt,required this.limit,required this.available,required this.utilization,this.statementDate,this.dueDate});
}
class CreditCardService{
 static CreditCardSummary summary(FinanceStore store,FinanceAccount a){
   final limit=a.creditLimit??0;final debt=(-store.balanceFor(a.id)).clamp(0,double.infinity);
   final now=DateTime.now();final statement=DateTime(now.year,now.month,20);
   final due=DateTime(now.year,now.month+1,10);
   return CreditCardSummary(debt:debt,limit:limit,available:(limit-debt).clamp(0,double.infinity),utilization:limit<=0?0:(debt/limit).clamp(0,1),statementDate:statement,dueDate:due);
 }
}
import '../models/finance_store.dart';
String buildFinanceCsv(FinanceStore store){
  String esc(Object? v){final s=(v??'').toString();return (s.contains(',')||s.contains('"')||s.contains('\n'))?'"${s.replaceAll('"','""')}"':s;}
  final b=StringBuffer('fecha,tipo,descripcion,categoria,cuenta,destino,monto\n');
  for(final t in store.transactions){final account=store.accounts.where((a)=>a.id==t.accountId).map((a)=>a.name).firstOrNull??t.accountId;final dest=t.destinationAccountId==null?'':(store.accounts.where((a)=>a.id==t.destinationAccountId).map((a)=>a.name).firstOrNull??t.destinationAccountId!);b.writeln([t.date.toIso8601String(),t.type.name,t.description,t.category,account,dest,t.amount.toStringAsFixed(2)].map(esc).join(','));}
  return b.toString();
}
extension _FirstOrNull<T> on Iterable<T>{T? get firstOrNull=>isEmpty?null:first;}

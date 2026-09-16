import 'package:flutter/material.dart';import 'package:intl/intl.dart';import '../models/finance_models.dart';import '../models/finance_store.dart';import '../services/credit_card_service.dart';
final _money=NumberFormat.currency(symbol:'\$');
class CreditCardDetailsScreen extends StatelessWidget{
 final FinanceStore store;final FinanceAccount account;const CreditCardDetailsScreen({super.key,required this.store,required this.account});
 @override Widget build(BuildContext c){final s=CreditCardService.summary(store,account);final tx=store.transactions.where((t)=>t.accountId==account.id||t.destinationAccountId==account.id).toList()..sort((a,b)=>b.date.compareTo(a.date));return Scaffold(appBar:AppBar(title:Text(account.name)),body:ListView(padding:const EdgeInsets.all(20),children:[
  Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Saldo utilizado'),Text(_money.format(s.debt),style:Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:16),LinearProgressIndicator(value:s.utilization),const SizedBox(height:8),Text('${(s.utilization*100).toStringAsFixed(0)}% del límite utilizado'),const Divider(height:28),Row(children:[Expanded(child:_v('Límite',_money.format(s.limit))),Expanded(child:_v('Disponible',_money.format(s.available)))])]))),
  const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[Expanded(child:_v('Corte',s.statementDate==null?'—':DateFormat('dd MMM').format(s.statementDate!))),Expanded(child:_v('Vencimiento',s.dueDate==null?'—':DateFormat('dd MMM').format(s.dueDate!)))]))),
  const SizedBox(height:20),Text('Actividad de la tarjeta',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:8),
  if(tx.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('No hay movimientos en esta tarjeta.'))),
  ...tx.take(20).map((t)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(t.description),subtitle:Text('${t.category} · ${DateFormat('dd/MM/yyyy').format(t.date)}'),trailing:Text(_money.format(t.amount))))
 ]));}
 Widget _v(String a,String b)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a),const SizedBox(height:4),Text(b,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:17))]);
}
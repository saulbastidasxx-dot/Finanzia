import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../models/finance_store.dart';

final money=NumberFormat.currency(symbol:'\$');
enum ReportRange{month,threeMonths,year,all}

class ReportsScreen extends StatefulWidget{
  final FinanceStore store;
  const ReportsScreen({super.key,required this.store});
  @override State<ReportsScreen> createState()=>_ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen>{
  ReportRange range=ReportRange.month;
  DateTime get start{
    final n=DateTime.now();
    return switch(range){
      ReportRange.month=>DateTime(n.year,n.month,1),
      ReportRange.threeMonths=>DateTime(n.year,n.month-2,1),
      ReportRange.year=>DateTime(n.year,1,1),
      ReportRange.all=>DateTime(2000),
    };
  }
  String get label=>switch(range){ReportRange.month=>'Este mes',ReportRange.threeMonths=>'3 meses',ReportRange.year=>'Este año',ReportRange.all=>'Todo'};

  @override
  Widget build(BuildContext c){
    final tx=widget.store.transactions.where((x)=>!x.date.isBefore(start)).toList();
    final inc=tx.where((x)=>x.type==TransactionType.income).fold<double>(0,(s,x)=>s+x.amount);
    final exp=tx.where((x)=>x.type==TransactionType.expense).fold<double>(0,(s,x)=>s+x.amount);
    final by=<String,double>{};
    for(final t in tx.where((x)=>x.type==TransactionType.expense)){by[t.category]=(by[t.category]??0)+t.amount;}
    final sorted=by.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final maxBar=[inc,exp,1.0].reduce((a,b)=>a>b?a:b)*1.2;

    return SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
      Row(children:[
        Expanded(child:Text('Reportes',style:Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800))),
        PopupMenuButton<ReportRange>(
          initialValue:range,
          onSelected:(v)=>setState(()=>range=v),
          itemBuilder:(_)=>ReportRange.values.map((v)=>PopupMenuItem(value:v,child:Text(switch(v){ReportRange.month=>'Este mes',ReportRange.threeMonths=>'Últimos 3 meses',ReportRange.year=>'Este año',ReportRange.all=>'Todo el historial'}))).toList(),
          child:Chip(avatar:const Icon(Icons.date_range,size:18),label:Text(label)),
        ),
      ]),
      const SizedBox(height:16),
      Wrap(spacing:12,runSpacing:12,children:[_m('Ingresos',inc),_m('Gastos',exp),_m('Ahorro',inc-exp),_m('Patrimonio neto',widget.store.netWorth)]),
      const SizedBox(height:24),
      Text('Ingresos vs. gastos',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),
      SizedBox(height:220,child:BarChart(BarChartData(
        maxY:maxBar,
        barGroups:[BarChartGroupData(x:0,barRods:[BarChartRodData(toY:inc,width:34)]),BarChartGroupData(x:1,barRods:[BarChartRodData(toY:exp,width:34)])],
        titlesData:FlTitlesData(
          leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
          rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
          topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
          bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,getTitlesWidget:(v,m)=>Padding(padding:const EdgeInsets.only(top:8),child:Text(v==0?'Ingresos':'Gastos')))),
        ),
      ))),
      const SizedBox(height:24),
      Text('Gastos por categoría',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),
      if(sorted.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:24),child:Text('No hay gastos en este período.')),
      ...sorted.take(8).map((e)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(e.key),subtitle:LinearProgressIndicator(value:exp==0?0.0:(e.value/exp).clamp(0.0,1.0).toDouble()),trailing:Text(money.format(e.value),style:const TextStyle(fontWeight:FontWeight.w700)))),
    ]));
  }

  Widget _m(String t,double v)=>SizedBox(width:190,child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t),const SizedBox(height:8),Text(money.format(v),style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800))]))));
}

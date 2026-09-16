import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../models/finance_store.dart';
import 'accounts.dart';
import 'add_transaction.dart';
import 'dashboard.dart';
import 'planning.dart';
import 'calendar.dart';
import 'reports.dart';
import 'settings.dart';
import 'transactions.dart';
import 'alerts.dart';

class HomeShell extends StatefulWidget {
  final FinanceStore store;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  const HomeShell({super.key,required this.store,required this.themeMode,required this.onThemeChanged});
  @override State<HomeShell> createState()=>_HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index=0;

  @override
  Widget build(BuildContext context) {
    final wide=MediaQuery.sizeOf(context).width>=800;
    final pages=<Widget>[
      Dashboard(store:widget.store),
      TransactionsScreen(store:widget.store),
      AccountsScreen(store:widget.store),
      PlanningScreen(store:widget.store),
      CalendarScreen(store:widget.store),
      ReportsScreen(store:widget.store),
      AlertsScreen(store:widget.store),
      SettingsScreen(store:widget.store,themeMode:widget.themeMode,onThemeChanged:widget.onThemeChanged),
    ];
    const labels=['Inicio','Movimientos','Cuentas','Planificación','Calendario','Reportes','Alertas','Configuración'];
    const icons=[Icons.home_outlined,Icons.swap_horiz,Icons.account_balance_wallet_outlined,Icons.pie_chart_outline,Icons.calendar_month_outlined,Icons.bar_chart_outlined,Icons.notifications_none,Icons.settings_outlined];
    final body=pages[index];

    if(wide){
      return Scaffold(body:Row(children:[
        NavigationRail(
          extended:true,
          selectedIndex:index,
          onDestinationSelected:(i)=>setState(()=>index=i),
          leading:const Padding(padding:EdgeInsets.all(20),child:Text('Finanzia',style:TextStyle(fontSize:26,fontWeight:FontWeight.w800))),
          destinations:List.generate(8,(i)=>NavigationRailDestination(icon:Icon(icons[i]),label:Text(labels[i]))),
        ),
        const VerticalDivider(width:1),
        Expanded(child:Scaffold(body:body,floatingActionButton:_fab(context))),
      ]));
    }

    final primaryIndex=switch(index){0=>0,1=>1,2=>2,5=>3,_=>4};
    return Scaffold(
      body:body,
      bottomNavigationBar:NavigationBar(
        selectedIndex:primaryIndex,
        onDestinationSelected:(i){
          if(i<3){setState(()=>index=i);}
          else if(i==3){setState(()=>index=5);}
          else{_showMore(context);}
        },
        destinations:const [
          NavigationDestination(icon:Icon(Icons.home_outlined),label:'Inicio'),
          NavigationDestination(icon:Icon(Icons.swap_horiz),label:'Movimientos'),
          NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined),label:'Cuentas'),
          NavigationDestination(icon:Icon(Icons.bar_chart_outlined),label:'Reportes'),
          NavigationDestination(icon:Icon(Icons.more_horiz),label:'Más'),
        ],
      ),
      floatingActionButton:_fab(context),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _showMore(BuildContext context) async {
    final selected=await showModalBottomSheet<int>(
      context:context,
      showDragHandle:true,
      builder:(c)=>SafeArea(child:Wrap(children:[
        const ListTile(title:Text('Más')),
        ListTile(leading:const Icon(Icons.pie_chart_outline),title:const Text('Planificación'),onTap:()=>Navigator.pop(c,3)),
        ListTile(leading:const Icon(Icons.calendar_month_outlined),title:const Text('Calendario'),onTap:()=>Navigator.pop(c,4)),
        ListTile(leading:const Icon(Icons.notifications_none),title:const Text('Alertas'),onTap:()=>Navigator.pop(c,6)),
        ListTile(leading:const Icon(Icons.settings_outlined),title:const Text('Configuración'),onTap:()=>Navigator.pop(c,7)),
      ])),
    );
    if(selected!=null&&mounted)setState(()=>index=selected);
  }

  Widget _fab(BuildContext context)=>FloatingActionButton(
    onPressed:()=>showModalBottomSheet(
      context:context,
      showDragHandle:true,
      builder:(c)=>SafeArea(child:Wrap(children:[
        ListTile(leading:const Icon(Icons.arrow_downward),title:const Text('Registrar ingreso'),onTap:(){Navigator.pop(c);showAddTransaction(context,widget.store,TransactionType.income);}),
        ListTile(leading:const Icon(Icons.arrow_upward),title:const Text('Registrar gasto'),onTap:(){Navigator.pop(c);showAddTransaction(context,widget.store,TransactionType.expense);}),
        ListTile(leading:const Icon(Icons.swap_horiz),title:const Text('Transferencia'),onTap:(){Navigator.pop(c);showAddTransaction(context,widget.store,TransactionType.transfer);}),
      ])),
    ),
    child:const Icon(Icons.add),
  );
}

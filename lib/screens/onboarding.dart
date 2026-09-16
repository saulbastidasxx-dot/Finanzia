import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget child;
  const OnboardingScreen({super.key,required this.child});
  @override State<OnboardingScreen> createState()=>_OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final page=PageController();
  int index=0;
  bool loading=true,done=false;

  @override
  void initState(){
    super.initState();
    PreferencesService().onboardingDone.then((v){if(mounted)setState((){done=v;loading=false;});});
  }

  @override
  void dispose(){page.dispose();super.dispose();}

  @override
  Widget build(BuildContext c){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    if(done)return widget.child;
    final items=[
      (Icons.account_balance_wallet_outlined,'Todo tu dinero, en un solo lugar','Organiza cuentas, tarjetas, gastos e ingresos con una vista clara.'),
      (Icons.track_changes_outlined,'Planifica con intención','Crea presupuestos, metas y recordatorios para mantener el rumbo.'),
      (Icons.lock_outline,'Privado y sincronizado','Protege Finanzia con PIN o biometría y sincroniza tus dispositivos.'),
    ];
    return Scaffold(body:SafeArea(child:Column(children:[
      Expanded(child:PageView(
        controller:page,
        onPageChanged:(i)=>setState(()=>index=i),
        children:items.map((x)=>Padding(
          padding:const EdgeInsets.all(32),
          child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Icon(x.$1,size:82),
            const SizedBox(height:28),
            Text(x.$2,textAlign:TextAlign.center,style:Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),
            const SizedBox(height:14),
            Text(x.$3,textAlign:TextAlign.center,style:Theme.of(c).textTheme.bodyLarge),
          ]),
        )).toList(),
      )),
      Padding(
        padding:const EdgeInsets.all(24),
        child:Row(children:[
          Text('${index+1}/3'),
          const Spacer(),
          FilledButton(
            onPressed:()async{
              if(index<2){await page.nextPage(duration:const Duration(milliseconds:250),curve:Curves.easeOut);}
              else{await PreferencesService().finishOnboarding();if(mounted)setState(()=>done=true);}
            },
            child:Text(index<2?'Continuar':'Comenzar'),
          ),
        ]),
      ),
    ])));
  }
}

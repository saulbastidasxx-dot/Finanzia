import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'models/finance_store.dart';
import 'screens/home_shell.dart';
import 'screens/auth_gate.dart';
import 'screens/app_lock_gate.dart';
import 'screens/onboarding.dart';
import 'services/preferences_service.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  if(SupabaseConfig.configured){try{await Supabase.initialize(url:SupabaseConfig.url,anonKey:SupabaseConfig.publishableKey);}catch(e){startupError=e;}}
  runApp(FinanziaApp(startupError:startupError));
}
class FinanziaApp extends StatefulWidget { final Object? startupError;const FinanziaApp({super.key,this.startupError}); @override State<FinanziaApp> createState()=>_FinanziaAppState(); }
class _FinanziaAppState extends State<FinanziaApp> {
  ThemeMode mode=ThemeMode.system; final store=FinanceStore(); bool preferencesReady=false;Object? loadError;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{try{await Future.wait([store.load(),PreferencesService().loadThemeMode().then((v)=>mode=v)]);if(mounted)setState(()=>preferencesReady=true);}catch(e){if(mounted)setState(()=>loadError=e);}}
  void _setTheme(ThemeMode v){setState(()=>mode=v);PreferencesService().saveThemeMode(v);}
  @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Finanzia',theme:FinanziaTheme.light,darkTheme:FinanziaTheme.dark,themeMode:mode,home:AnimatedBuilder(animation:store,builder:(context,_){
    final err=widget.startupError??loadError;
    if(err!=null)return Scaffold(body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.error_outline,size:48),const SizedBox(height:16),Text('No se pudo iniciar Finanzia',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:8),const Text('Revisa la configuración de Supabase o el almacenamiento local y vuelve a abrir la aplicación.',textAlign:TextAlign.center)])))));
    if(!store.ready||!preferencesReady) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    if(!SupabaseConfig.configured) return OnboardingScreen(child:AppLockGate(child:HomeShell(store:store,themeMode:mode,onThemeChanged:_setTheme)));
    return OnboardingScreen(child:AuthGate(store:store,themeMode:mode,onThemeChanged:_setTheme));
  }));
}

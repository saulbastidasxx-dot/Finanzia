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
  if (SupabaseConfig.configured) await Supabase.initialize(url:SupabaseConfig.url,anonKey:SupabaseConfig.anonKey);
  runApp(const FinanziaApp());
}
class FinanziaApp extends StatefulWidget { const FinanziaApp({super.key}); @override State<FinanziaApp> createState()=>_FinanziaAppState(); }
class _FinanziaAppState extends State<FinanziaApp> {
  ThemeMode mode=ThemeMode.system; final store=FinanceStore(); bool preferencesReady=false;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{await Future.wait([store.load(),PreferencesService().loadThemeMode().then((v)=>mode=v)]);if(mounted)setState(()=>preferencesReady=true);}
  void _setTheme(ThemeMode v){setState(()=>mode=v);PreferencesService().saveThemeMode(v);}
  @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Finanzia',theme:FinanziaTheme.light,darkTheme:FinanziaTheme.dark,themeMode:mode,home:AnimatedBuilder(animation:store,builder:(context,_){
    if(!store.ready||!preferencesReady) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    if(!SupabaseConfig.configured) return OnboardingScreen(child:AppLockGate(child:HomeShell(store:store,themeMode:mode,onThemeChanged:_setTheme)));
    return OnboardingScreen(child:AuthGate(store:store,themeMode:mode,onThemeChanged:_setTheme));
  }));
}

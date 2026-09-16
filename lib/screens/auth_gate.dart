import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_store.dart';
import 'home_shell.dart';
import 'app_lock_gate.dart';
import 'auto_sync_gate.dart';

class AuthGate extends StatelessWidget {
  final FinanceStore store; final ThemeMode themeMode; final ValueChanged<ThemeMode> onThemeChanged;
  const AuthGate({super.key,required this.store,required this.themeMode,required this.onThemeChanged});
  @override Widget build(BuildContext context)=>StreamBuilder<AuthState>(stream:Supabase.instance.client.auth.onAuthStateChange,builder:(context,s){
    if(Supabase.instance.client.auth.currentSession==null) return const AuthScreen();
    return AutoSyncGate(store:store,child:AppLockGate(child:HomeShell(store:store,themeMode:themeMode,onThemeChanged:onThemeChanged)));
  });
}

class AuthScreen extends StatefulWidget { const AuthScreen({super.key}); @override State<AuthScreen> createState()=>_AuthScreenState(); }
class _AuthScreenState extends State<AuthScreen>{
  final email=TextEditingController(),pass=TextEditingController(),name=TextEditingController(); bool register=false,busy=false; String? error;
  Future<void> go()async{setState(()=>busy=true);try{final a=Supabase.instance.client.auth;if(register){await a.signUp(email:email.text.trim(),password:pass.text,userMetadata:{'name':name.text.trim()});}else{await a.signInWithPassword(email:email.text.trim(),password:pass.text);}}catch(e){setState(()=>error=e.toString());}finally{if(mounted)setState(()=>busy=false);}}
  Future<void> reset()async{if(email.text.trim().isEmpty){setState(()=>error='Escribe tu correo primero.');return;}try{await Supabase.instance.client.auth.resetPasswordForEmail(email.text.trim());setState(()=>error='Te enviamos un enlace de recuperación.');}catch(e){setState(()=>error=e.toString());}}
  @override Widget build(BuildContext context)=>Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Card(child:Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text('Finanzia',style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.w900)),const Text('Tu vida financiera, en equilibrio'),const SizedBox(height:28),if(register)TextField(controller:name,decoration:const InputDecoration(labelText:'Nombre')),if(register)const SizedBox(height:12),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Correo electrónico')),const SizedBox(height:12),TextField(controller:pass,obscureText:true,decoration:const InputDecoration(labelText:'Contraseña')),if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!)),const SizedBox(height:18),FilledButton(onPressed:busy?null:go,child:Text(busy?'Procesando…':register?'Crear cuenta':'Iniciar sesión')),TextButton(onPressed:busy?null:()=>setState(()=>register=!register),child:Text(register?'Ya tengo una cuenta':'Crear una cuenta')),if(!register)TextButton(onPressed:reset,child:const Text('¿Olvidaste tu contraseña?'))])))))));
}

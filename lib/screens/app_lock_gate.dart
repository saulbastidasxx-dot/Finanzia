import 'package:flutter/material.dart';
import '../services/security_service.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key,required this.child});
  @override State<AppLockGate> createState()=>_AppLockGateState();
}
class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final security=SecurityService(); bool loading=true,locked=false; final pin=TextEditingController(); String? error;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);_load();}
  @override void dispose(){WidgetsBinding.instance.removeObserver(this);pin.dispose();super.dispose();}
  Future<void> _load()async{final enabled=await security.pinEnabled;if(mounted)setState((){locked=enabled;loading=false;});}
  @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.paused||state==AppLifecycleState.inactive){security.pinEnabled.then((v){if(v&&mounted)setState(()=>locked=true);});}}
  Future<void> _unlock()async{final ok=await security.verifyPin(pin.text);if(ok){pin.clear();setState((){locked=false;error=null;});}else setState(()=>error='PIN incorrecto');}
  Future<void> _bio()async{if(await security.authenticateBiometric()&&mounted)setState(()=>locked=false);}
  @override Widget build(BuildContext context){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(!locked)return widget.child;return Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:380),child:Card(child:Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Icon(Icons.lock_outline,size:48),const SizedBox(height:16),Text('Finanzia bloqueada',textAlign:TextAlign.center,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:6),const Text('Introduce tu PIN para continuar.',textAlign:TextAlign.center),const SizedBox(height:24),TextField(controller:pin,autofocus:true,obscureText:true,keyboardType:TextInputType.number,maxLength:6,onSubmitted:(_)=>_unlock(),decoration:InputDecoration(labelText:'PIN',errorText:error,counterText:'')),const SizedBox(height:12),FilledButton(onPressed:_unlock,child:const Text('Desbloquear')),FutureBuilder<bool>(future:security.biometricAvailable,builder:(context,s)=>s.data==true?TextButton.icon(onPressed:_bio,icon:const Icon(Icons.fingerprint),label:const Text('Usar biometría')):const SizedBox.shrink())])))))));}
}

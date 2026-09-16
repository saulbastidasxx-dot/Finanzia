import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_store.dart';
import '../services/cloud_sync_service.dart';

class AutoSyncGate extends StatefulWidget {
  final FinanceStore store; final Widget child;
  const AutoSyncGate({super.key,required this.store,required this.child});
  @override State<AutoSyncGate> createState()=>_AutoSyncGateState();
}
class _AutoSyncGateState extends State<AutoSyncGate> with WidgetsBindingObserver {
  Timer? timer; bool syncing=false,started=false,conflict=false;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);widget.store.addListener(_changed);WidgetsBinding.instance.addPostFrameCallback((_)=>_sync());}
  @override void dispose(){timer?.cancel();widget.store.removeListener(_changed);WidgetsBinding.instance.removeObserver(this);super.dispose();}
  void _changed(){if(!started||syncing||conflict)return;timer?.cancel();timer=Timer(const Duration(seconds:2),_sync);}
  @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.resumed)_sync();}
  Future<void> _sync()async{
    if(syncing||Supabase.instance.client.auth.currentUser==null)return;
    syncing=true;
    try{
      final outcome=await CloudSyncService(Supabase.instance.client).smartSync(widget.store);
      started=true;
      if(outcome==SyncOutcome.conflict){conflict=true;if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Hay cambios distintos en este dispositivo y en la nube. Resuélvelos desde Configuración > Sincronización.')));}
      else conflict=false;
    }catch(_){started=true;}
    finally{syncing=false;}
  }
  @override Widget build(BuildContext context)=>widget.child;
}

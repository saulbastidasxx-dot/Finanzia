import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_store.dart';
import '../services/cloud_sync_service.dart';

enum _SyncUiState { idle, syncing, synced, pending, conflict, error }

class AutoSyncGate extends StatefulWidget {
  final FinanceStore store; final Widget child;
  const AutoSyncGate({super.key,required this.store,required this.child});
  @override State<AutoSyncGate> createState()=>_AutoSyncGateState();
}
class _AutoSyncGateState extends State<AutoSyncGate> with WidgetsBindingObserver {
  Timer? timer; bool syncing=false,started=false,conflict=false;_SyncUiState state=_SyncUiState.idle;String? message;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);widget.store.addListener(_changed);WidgetsBinding.instance.addPostFrameCallback((_)=>_sync());}
  @override void dispose(){timer?.cancel();widget.store.removeListener(_changed);WidgetsBinding.instance.removeObserver(this);super.dispose();}
  void _changed(){if(!started||syncing||conflict)return;if(mounted)setState(()=>state=_SyncUiState.pending);timer?.cancel();timer=Timer(const Duration(seconds:2),_sync);}
  @override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.resumed)_sync();}
  Future<void> _sync()async{
    if(syncing||Supabase.instance.client.auth.currentUser==null)return;
    syncing=true;if(mounted)setState((){state=_SyncUiState.syncing;message='Sincronizando…';});
    try{
      final outcome=await CloudSyncService(Supabase.instance.client).smartSync(widget.store);started=true;
      if(outcome==SyncOutcome.conflict){conflict=true;if(mounted)setState((){state=_SyncUiState.conflict;message='Conflicto de sincronización. Resuélvelo en Configuración > Sincronización.';});}
      else{conflict=false;if(mounted)setState((){state=_SyncUiState.synced;message='Sincronizado';});}
    }catch(e){started=true;if(mounted)setState((){state=_SyncUiState.error;message='No se pudo sincronizar. Tus cambios permanecen pendientes en este dispositivo.';});}
    finally{syncing=false;}
  }
  @override Widget build(BuildContext context){
    final show=state==_SyncUiState.syncing||state==_SyncUiState.pending||state==_SyncUiState.conflict||state==_SyncUiState.error;
    return Stack(children:[widget.child,if(show)SafeArea(child:Align(alignment:Alignment.topCenter,child:Padding(padding:const EdgeInsets.all(8),child:Material(elevation:4,borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(state==_SyncUiState.error?Icons.cloud_off_outlined:state==_SyncUiState.conflict?Icons.sync_problem:Icons.sync,size:18),const SizedBox(width:8),Flexible(child:Text(message??'Sincronización pendiente')),if(state==_SyncUiState.error)...[const SizedBox(width:8),TextButton(onPressed:_sync,child:const Text('Reintentar'))]]))))))]);
  }
}

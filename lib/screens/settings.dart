import 'legal.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_store.dart';
import '../services/supabase_config.dart';
import '../services/cloud_sync_service.dart';
import '../services/security_service.dart';
import '../services/export_service.dart';
import '../services/pdf_export_service.dart';
import '../services/preferences_service.dart';
import '../services/account_deletion_service.dart';
import '../core/validators.dart';
import 'change_history.dart';

class SettingsScreen extends StatelessWidget{
  final FinanceStore store;final ThemeMode themeMode;final ValueChanged<ThemeMode> onThemeChanged;
  const SettingsScreen({super.key,required this.store,required this.themeMode,required this.onThemeChanged});
  @override Widget build(BuildContext context){
    final connected=SupabaseConfig.configured&&Supabase.instance.client.auth.currentUser!=null;
    return SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
      Text('Configuración',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:20),
      Card(child:Column(children:[
        ListTile(leading:const CircleAvatar(child:Icon(Icons.person_outline)),title:Text(store.profile.name),subtitle:Text(connected?Supabase.instance.client.auth.currentUser?.email??store.profile.email:store.profile.email),trailing:const Icon(Icons.chevron_right),onTap:()=>_profile(context)),
        ListTile(leading:const Icon(Icons.cloud_outlined),title:const Text('Sincronización'),subtitle:Text(connected?'Automática · segura ante conflictos':'Modo local · configura Supabase para nube'),trailing:Icon(connected?Icons.cloud_done_outlined:Icons.cloud_off_outlined),onTap:connected?()=>_syncMenu(context):null),
        ListTile(leading:const Icon(Icons.security),title:const Text('Seguridad'),subtitle:const Text('PIN y biometría'),trailing:const Icon(Icons.chevron_right),onTap:()=>_security(context)),
        ListTile(leading:const Icon(Icons.attach_money),title:const Text('Moneda'),subtitle:Text(store.profile.currency),onTap:()=>_currency(context)),
        ListTile(leading:const Icon(Icons.brightness_6_outlined),title:const Text('Apariencia'),subtitle:Padding(padding:const EdgeInsets.only(top:10,bottom:8),child:SegmentedButton<ThemeMode>(segments:const [ButtonSegment(value:ThemeMode.light,label:Text('Claro')),ButtonSegment(value:ThemeMode.dark,label:Text('Oscuro')),ButtonSegment(value:ThemeMode.system,label:Text('Auto'))],selected:{themeMode},onSelectionChanged:(s)=>onThemeChanged(s.first)))),
        const ListTile(leading:Icon(Icons.language),title:Text('Idioma'),subtitle:Text('Español')),
        ListTile(leading:const Icon(Icons.download_outlined),title:const Text('Exportar movimientos'),subtitle:const Text('CSV compatible con Excel y Google Sheets'),onTap:()=>_export(context)),
        ListTile(leading:const Icon(Icons.picture_as_pdf_outlined),title:const Text('Reporte PDF'),subtitle:const Text('Resumen financiero listo para guardar o compartir'),onTap:()=>_exportPdf(context)),
        ListTile(leading:const Icon(Icons.notifications_active_outlined),title:const Text('Preferencias de alertas'),subtitle:const Text('Presupuestos, pagos y deudas'),trailing:const Icon(Icons.chevron_right),onTap:()=>_alertPreferences(context)),
        ListTile(leading:const Icon(Icons.history),title:const Text('Historial de cambios'),subtitle:Text('${store.changes.length} eventos · ${store.pendingChanges.length} pendientes'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ChangeHistoryScreen(store:store)))),
        ListTile(leading:const Icon(Icons.privacy_tip_outlined),title:const Text('Privacidad y términos'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const LegalScreen()))),
        if(connected)ListTile(leading:Icon(Icons.delete_forever_outlined,color:Theme.of(context).colorScheme.error),title:Text('Eliminar cuenta',style:TextStyle(color:Theme.of(context).colorScheme.error)),subtitle:const Text('Elimina la cuenta y sus datos permanentemente'),onTap:()=>_deleteAccount(context)),
        if(connected)ListTile(leading:const Icon(Icons.logout),title:const Text('Cerrar sesión'),onTap:()=>Supabase.instance.client.auth.signOut())
      ]))
    ]));
  }

  Future<void> _syncMenu(BuildContext context)async{
    final action=await showModalBottomSheet<String>(context:context,builder:(c)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      const ListTile(title:Text('Sincronización Finanzia'),subtitle:Text('La app sincroniza automáticamente. Estas opciones sirven para revisar o resolver conflictos.')),
      ListTile(leading:const Icon(Icons.sync),title:const Text('Sincronizar ahora'),subtitle:const Text('Detecta qué copia cambió y actúa solo si es seguro'),onTap:()=>Navigator.pop(c,'smart')),
      ListTile(leading:const Icon(Icons.cloud_upload_outlined),title:const Text('Conservar este dispositivo'),subtitle:const Text('Reemplaza la copia en la nube'),onTap:()=>Navigator.pop(c,'up')),
      ListTile(leading:const Icon(Icons.cloud_download_outlined),title:const Text('Conservar la nube'),subtitle:const Text('Reemplaza los datos de este dispositivo'),onTap:()=>Navigator.pop(c,'down'))
    ])));
    if (action==null||!context.mounted) {return;}
    try{
      final svc=CloudSyncService(Supabase.instance.client);String message='Sincronización completada';
      if(action=='up')await svc.upload(store);else if(action=='down')await svc.download(store);else{
        final r=await svc.smartSync(store);
        message=switch(r){SyncOutcome.uploaded=>'Cambios de este dispositivo subidos',SyncOutcome.downloaded=>'Cambios de la nube descargados',SyncOutcome.merged=>'Cambios combinados sin conflicto',SyncOutcome.unchanged=>'Todo está sincronizado',SyncOutcome.conflict=>'Conflicto detectado en el mismo registro: elige qué copia conservar'};
      }
      if (context.mounted) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));}
    }catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo sincronizar: $e')));}
  }

  Future<void> _security(BuildContext context)async{
    final svc=SecurityService();final enabled=await svc.pinEnabled;if(!context.mounted)return;
    if(enabled){
      final action=await showModalBottomSheet<String>(context:context,builder:(c)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[const ListTile(title:Text('Seguridad'),subtitle:Text('El bloqueo con PIN está activo. En dispositivos compatibles también podrás usar biometría.')),ListTile(leading:const Icon(Icons.password),title:const Text('Cambiar PIN'),onTap:()=>Navigator.pop(c,'change')),ListTile(leading:const Icon(Icons.lock_open),title:const Text('Desactivar PIN'),onTap:()=>Navigator.pop(c,'off'))])));
      if(action=='off'){await svc.disablePin();if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Bloqueo con PIN desactivado')));}else if(action=='change'&&context.mounted){await _setPin(context,svc);}
    }else await _setPin(context,svc);
  }

  Future<void> _setPin(BuildContext context,SecurityService svc)async{
    final a=TextEditingController(),b=TextEditingController();
    await showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Configurar PIN'),content:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Usa entre 4 y 6 dígitos. Finanzia pedirá el PIN al volver a abrir la app.'),const SizedBox(height:14),TextField(controller:a,obscureText:true,keyboardType:TextInputType.number,maxLength:6,decoration:const InputDecoration(labelText:'Nuevo PIN',counterText:'')),const SizedBox(height:10),TextField(controller:b,obscureText:true,keyboardType:TextInputType.number,maxLength:6,decoration:const InputDecoration(labelText:'Repetir PIN',counterText:''))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancelar')),FilledButton(onPressed:()async{if(a.text!=b.text||!RegExp(r'^\d{4,6}$').hasMatch(a.text)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Los PIN deben coincidir y tener 4 a 6 dígitos')));return;}await svc.setPin(a.text);if(c.mounted)Navigator.pop(c);},child:const Text('Activar'))]));
  }

  Future<void> _export(BuildContext context)async{
    try{final result=await ExportService().exportCsv(store);if(!context.mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('CSV listo: $result')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo exportar: $e')));}
  }


  Future<void> _exportPdf(BuildContext context)async{
    try{final result=await PdfExportService().exportReport(store);if(!context.mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Reporte PDF listo: $result')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo generar el PDF: $e')));}
  }

  Future<void> _alertPreferences(BuildContext context) async {
    final svc=PreferencesService(); var x=await svc.loadAlerts(); if(!context.mounted)return;
    await showDialog(context:context,builder:(c)=>StatefulBuilder(builder:(c,set)=>AlertDialog(title:const Text('Alertas'),content:Column(mainAxisSize:MainAxisSize.min,children:[SwitchListTile(title:const Text('Activar alertas'),value:x.enabled,onChanged:(v)=>set(()=>x=AlertPreferences(enabled:v,budgets:x.budgets,recurring:x.recurring,debts:x.debts))),SwitchListTile(title:const Text('Presupuestos'),value:x.budgets,onChanged:x.enabled?(v)=>set(()=>x=AlertPreferences(enabled:x.enabled,budgets:v,recurring:x.recurring,debts:x.debts)):null),SwitchListTile(title:const Text('Pagos recurrentes'),value:x.recurring,onChanged:x.enabled?(v)=>set(()=>x=AlertPreferences(enabled:x.enabled,budgets:x.budgets,recurring:v,debts:x.debts)):null),SwitchListTile(title:const Text('Deudas'),value:x.debts,onChanged:x.enabled?(v)=>set(()=>x=AlertPreferences(enabled:x.enabled,budgets:x.budgets,recurring:x.recurring,debts:v)):null)]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancelar')),FilledButton(onPressed:()async{await svc.saveAlerts(x);if(c.mounted)Navigator.pop(c);},child:const Text('Guardar'))])));
  }

  Future<void> _profile(BuildContext context)async{
    final authUser=SupabaseConfig.configured?Supabase.instance.client.auth.currentUser:null;
    final currentEmail=authUser?.email??store.profile.email;
    final n=TextEditingController(text:store.profile.name),e=TextEditingController(text:currentEmail),key=GlobalKey<FormState>();
    await showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Mi perfil'),content:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[TextFormField(controller:n,validator:(v)=>FinanziaValidators.requiredText(v,label:'El nombre'),decoration:const InputDecoration(labelText:'Nombre')),const SizedBox(height:12),TextFormField(controller:e,keyboardType:TextInputType.emailAddress,validator:FinanziaValidators.email,decoration:InputDecoration(labelText:'Correo',helperText:authUser==null?'Perfil local':'Supabase enviará confirmación si es necesaria'))])),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancelar')),FilledButton(onPressed:()async{
      if (!(key.currentState?.validate() {??false))return;}
      final name=n.text.trim(),email=e.text.trim();
      try{
        if(authUser!=null&&email!=currentEmail){await Supabase.instance.client.auth.updateUser(UserAttributes(email:email));}
        await store.updateProfile(store.profile.copyWith(name:name,email:email));
        if (c.mounted) {Navigator.pop(c);}
        if (context.mounted) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(authUser!=null&&email!=currentEmail?'Perfil actualizado. Revisa tu correo si Supabase solicita confirmar el cambio.':'Perfil actualizado.')));}
      }catch(err){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo actualizar el perfil: $err')));}
    },child:const Text('Guardar'))]));
  }
  Future<void> _currency(BuildContext context)async{final v=await showDialog<String>(context:context,builder:(c)=>SimpleDialog(title:const Text('Moneda principal'),children:['USD','EUR','GBP','MXN','COP','VES'].map((x)=>SimpleDialogOption(onPressed:()=>Navigator.pop(c,x),child:Text(x))).toList()));if(v!=null)store.updateProfile(store.profile.copyWith(currency:v));}
  Future<void> _deleteAccount(BuildContext context)async{final confirm=TextEditingController();final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Eliminar cuenta permanentemente'),content:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Esta acción no se puede deshacer. Escribe ELIMINAR para confirmar.'),const SizedBox(height:16),TextField(controller:confirm,decoration:const InputDecoration(labelText:'Confirmación'))]),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,confirm.text.trim().toUpperCase()=='ELIMINAR'),child:const Text('Eliminar definitivamente'))]))??false;if(!ok||!context.mounted)return;try{await AccountDeletionService(Supabase.instance.client).deleteCurrentUser(store);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Cuenta eliminada.')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo eliminar la cuenta: $e')));}}

}

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_alert.dart';
class NotificationService{
  final _plugin=FlutterLocalNotificationsPlugin();
  Future<bool> initialize()async{
    if(!Platform.isAndroid&&!Platform.isIOS)return false;
    const settings=InitializationSettings(android:AndroidInitializationSettings('@mipmap/ic_launcher'),iOS:DarwinInitializationSettings());
    await _plugin.initialize(settings);
    if(Platform.isAndroid){final p=_plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();await p?.requestNotificationsPermission();}
    if(Platform.isIOS){final p=_plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();await p?.requestPermissions(alert:true,badge:true,sound:true);}
    return true;
  }
  Future<int> notifyAlerts(List<FinancialAlert> alerts)async{
    if(!Platform.isAndroid&&!Platform.isIOS)return 0;
    final prefs=await SharedPreferences.getInstance();var shown=0;
    final relevant=alerts.where((x)=>x.severity!=FinancialAlertSeverity.info).toList();
    final activeKeys=relevant.map((a)=>'finanzia_notified_${a.id}').toSet();
    for(final key in prefs.getKeys().where((k)=>k.startsWith('finanzia_notified_')).toList()){
      if(!activeKeys.contains(key))await prefs.remove(key);
    }
    for(final a in relevant){
      final key='finanzia_notified_${a.id}';if(prefs.getBool(key)==true)continue;
      await _plugin.show(a.id.hashCode & 0x7fffffff,a.title,a.message,const NotificationDetails(android:AndroidNotificationDetails('finanzia_alertas','Alertas financieras',channelDescription:'Presupuestos, pagos y vencimientos de Finanzia',importance:Importance.high,priority:Priority.high),iOS:DarwinNotificationDetails(presentAlert:true,presentBadge:true,presentSound:true)));
      await prefs.setBool(key,true);shown++;
    }
    return shown;
  }
}

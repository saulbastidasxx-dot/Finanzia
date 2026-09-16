import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertPreferences {
  final bool enabled, budgets, recurring, debts;
  const AlertPreferences({this.enabled=true,this.budgets=true,this.recurring=true,this.debts=true});
}
class PreferencesService {
  Future<AlertPreferences> loadAlerts() async { final p=await SharedPreferences.getInstance(); return AlertPreferences(enabled:p.getBool('alerts_enabled')??true,budgets:p.getBool('alerts_budgets')??true,recurring:p.getBool('alerts_recurring')??true,debts:p.getBool('alerts_debts')??true); }
  Future<void> saveAlerts(AlertPreferences x) async { final p=await SharedPreferences.getInstance(); await p.setBool('alerts_enabled',x.enabled);await p.setBool('alerts_budgets',x.budgets);await p.setBool('alerts_recurring',x.recurring);await p.setBool('alerts_debts',x.debts); }
  Future<bool> get onboardingDone async => (await SharedPreferences.getInstance()).getBool('onboarding_done')??false;
  Future<void> finishOnboarding()=>SharedPreferences.getInstance().then((p)=>p.setBool('onboarding_done',true));
  Future<ThemeMode> loadThemeMode() async { final raw=(await SharedPreferences.getInstance()).getString('theme_mode')??'system'; return switch(raw){'light'=>ThemeMode.light,'dark'=>ThemeMode.dark,_=>ThemeMode.system}; }
  Future<void> saveThemeMode(ThemeMode mode) async => (await SharedPreferences.getInstance()).setString('theme_mode',switch(mode){ThemeMode.light=>'light',ThemeMode.dark=>'dark',ThemeMode.system=>'system'});
  Future<bool> loadPrivacyMode() async => (await SharedPreferences.getInstance()).getBool('privacy_hide_amounts')??false;
  Future<void> savePrivacyMode(bool hidden) async => (await SharedPreferences.getInstance()).setBool('privacy_hide_amounts',hidden);
}

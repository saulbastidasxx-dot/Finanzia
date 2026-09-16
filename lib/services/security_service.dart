import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_service.dart';

class SecurityService {
  static const _enabledKey='finanzia_pin_enabled';
  static const _saltKey='finanzia_pin_salt';
  static const _hashKey='finanzia_pin_hash';
  final BiometricService biometrics=BiometricService();

  Future<bool> get pinEnabled async => (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;
  Future<bool> get biometricAvailable => biometrics.isAvailable();

  Future<void> setPin(String pin) async {
    if(!RegExp(r'^\d{4,6}$').hasMatch(pin)) throw ArgumentError('El PIN debe tener entre 4 y 6 dígitos.');
    final p=await SharedPreferences.getInstance();
    final random=Random.secure();
    final salt=List<int>.generate(24,(_)=>random.nextInt(256));
    final saltText=base64UrlEncode(salt);
    await p.setString(_saltKey,saltText);
    await p.setString(_hashKey,_hash(pin,saltText));
    await p.setBool(_enabledKey,true);
  }

  Future<bool> verifyPin(String pin) async {
    final p=await SharedPreferences.getInstance();
    final salt=p.getString(_saltKey), stored=p.getString(_hashKey);
    if(salt==null||stored==null)return false;
    return _hash(pin,salt)==stored;
  }

  Future<void> disablePin() async {
    final p=await SharedPreferences.getInstance();
    await p.remove(_saltKey);await p.remove(_hashKey);await p.setBool(_enabledKey,false);
  }

  Future<bool> authenticateBiometric()=>biometrics.authenticate();
  String _hash(String pin,String salt)=>sha256.convert(utf8.encode('$salt:$pin')).toString();
}

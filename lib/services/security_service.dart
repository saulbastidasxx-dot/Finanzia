import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_service.dart';

enum PinCheckResult { success, invalid, locked }

class SecurityService {
  static const _enabledKey='finanzia_pin_enabled';
  static const _saltKey='finanzia_pin_salt';
  static const _hashKey='finanzia_pin_hash';
  static const _attemptsKey='finanzia_pin_failed_attempts';
  static const _lockUntilKey='finanzia_pin_lock_until';
  static const _maxAttempts=5;
  static const FlutterSecureStorage _secure=FlutterSecureStorage();
  final BiometricService biometrics=BiometricService();

  Future<bool> get pinEnabled async => (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;
  Future<bool> get biometricAvailable => biometrics.isAvailable();

  Future<void> setPin(String pin) async {
    if(!RegExp(r'^\d{4,6}$').hasMatch(pin)) throw ArgumentError('El PIN debe tener entre 4 y 6 dígitos.');
    final random=Random.secure();
    final salt=List<int>.generate(32,(_)=>random.nextInt(256));
    final saltText=base64UrlEncode(salt);
    await _secure.write(key:_saltKey,value:saltText);
    await _secure.write(key:_hashKey,value:_derive(pin,saltText));
    final p=await SharedPreferences.getInstance();
    await p.setBool(_enabledKey,true);
    await _resetAttempts(p);
    // Remove legacy verifier after successful migration/write.
    await p.remove(_saltKey);await p.remove(_hashKey);
  }

  Future<PinCheckResult> verifyPin(String pin) async {
    final p=await SharedPreferences.getInstance();
    final until=p.getInt(_lockUntilKey)??0;
    final now=DateTime.now().millisecondsSinceEpoch;
    if(until>now){return PinCheckResult.locked;}
    if(until!=0){await _resetAttempts(p);}

    final salt=await _secure.read(key:_saltKey);
    final stored=await _secure.read(key:_hashKey);
    bool valid=false;
    if(salt!=null&&stored!=null){
      valid=_constantTimeEquals(_derive(pin,salt),stored);
    }else{
      // Legacy migration: validate once with the previous scheme, then rewrite securely.
      final legacySalt=p.getString(_saltKey),legacyHash=p.getString(_hashKey);
      if(legacySalt!=null&&legacyHash!=null){
        final legacy=sha256.convert(utf8.encode('$legacySalt:$pin')).toString();
        valid=_constantTimeEquals(legacy,legacyHash);
        if(valid){await setPin(pin);return PinCheckResult.success;}
      }
    }
    if(valid){await _resetAttempts(p);return PinCheckResult.success;}
    final attempts=(p.getInt(_attemptsKey)??0)+1;
    if(attempts>=_maxAttempts){
      final exponent=(attempts-_maxAttempts).clamp(0,4).toInt();
      final seconds=30*(1<<exponent);
      await p.setInt(_attemptsKey,attempts);
      await p.setInt(_lockUntilKey,now+Duration(seconds:seconds).inMilliseconds);
      return PinCheckResult.locked;
    }
    await p.setInt(_attemptsKey,attempts);
    return PinCheckResult.invalid;
  }

  Future<Duration> remainingLockout() async {
    final p=await SharedPreferences.getInstance();
    final ms=(p.getInt(_lockUntilKey)??0)-DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds:ms>0?ms:0);
  }

  Future<void> disablePin() async {
    await _secure.delete(key:_saltKey);await _secure.delete(key:_hashKey);
    final p=await SharedPreferences.getInstance();
    await p.setBool(_enabledKey,false);await _resetAttempts(p);
    await p.remove(_saltKey);await p.remove(_hashKey);
  }

  Future<void> clearAllSecurityData() async {
    await _secure.delete(key:_saltKey);await _secure.delete(key:_hashKey);
    final p=await SharedPreferences.getInstance();
    for(final key in [_enabledKey,_saltKey,_hashKey,_attemptsKey,_lockUntilKey]){await p.remove(key);}
  }

  Future<bool> authenticateBiometric()=>biometrics.authenticate();

  String _derive(String pin,String salt){
    // Iterated SHA-256 raises the cost of brute force for short local PINs.
    List<int> bytes=utf8.encode('$salt:$pin');
    for(var i=0;i<60000;i++){bytes=sha256.convert(bytes).bytes;}
    return base64UrlEncode(bytes);
  }
  bool _constantTimeEquals(String a,String b){
    if(a.length!=b.length){return false;}var diff=0;
    for(var i=0;i<a.length;i++){diff|=a.codeUnitAt(i)^b.codeUnitAt(i);}
    return diff==0;
  }
  Future<void> _resetAttempts(SharedPreferences p)async{await p.remove(_attemptsKey);await p.remove(_lockUntilKey);}
}

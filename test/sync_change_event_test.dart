import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/change_event.dart';
void main(){
 test('change event json round trip',(){
  final at=DateTime.utc(2026,9,16,12,30);
  final e=ChangeEvent(id:'evt',entity:'transaction',entityId:'tx',action:'upsert',changedAt:at,payload:{'amount':42.5},synced:false);
  final x=ChangeEvent.fromJson(e.toJson());
  expect(x.key,'transaction:tx');expect(x.changedAt,at);expect(x.payload?['amount'],42.5);expect(x.synced,isFalse);
 });
 test('copyWith preserves event identity',(){
  final e=ChangeEvent(id:'1',entity:'account',entityId:'a',action:'delete',changedAt:DateTime.utc(2026));
  final x=e.copyWith(synced:true);expect(x.synced,isTrue);expect(x.entityId,'a');expect(x.action,'delete');
 });
}

class ChangeEvent {
  final String id;
  final String entity;
  final String entityId;
  final String action;
  final DateTime changedAt;
  final Map<String,dynamic>? payload;
  final bool synced;
  const ChangeEvent({required this.id,required this.entity,required this.entityId,required this.action,required this.changedAt,this.payload,this.synced=false});
  String get key => '$entity:$entityId';
  ChangeEvent copyWith({bool? synced})=>ChangeEvent(id:id,entity:entity,entityId:entityId,action:action,changedAt:changedAt,payload:payload,synced:synced??this.synced);
  Map<String,dynamic> toJson()=>{'id':id,'entity':entity,'entityId':entityId,'action':action,'changedAt':changedAt.toIso8601String(),'payload':payload,'synced':synced};
  factory ChangeEvent.fromJson(Map<String,dynamic> j)=>ChangeEvent(id:j['id'],entity:j['entity'],entityId:j['entityId'],action:j['action'],changedAt:DateTime.parse(j['changedAt']),payload:j['payload']==null?null:Map<String,dynamic>.from(j['payload']),synced:j['synced']??false);
}

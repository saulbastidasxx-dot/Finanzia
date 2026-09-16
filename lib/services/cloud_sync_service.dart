import 'package:supabase_flutter/supabase_flutter.dart';
import 'retry_policy.dart';
import 'package:uuid/uuid.dart';
import '../models/finance_store.dart';
import '../models/finance_models.dart';
import '../models/user_profile.dart';
import '../models/change_event.dart';

enum SyncOutcome { uploaded, downloaded, merged, unchanged, conflict }

class CloudSyncService {
  final RetryPolicy retryPolicy=const RetryPolicy();
  final SupabaseClient client;
  const CloudSyncService(this.client);
  String get uid => client.auth.currentUser!.id;

  bool _isUuid(String value)=>RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$').hasMatch(value);
  String _cloudId(String kind,String local)=>_isUuid(local)?local:const Uuid().v5(Namespace.url.value,'finanzia:$uid:$kind:$local');
  String _entityCloudId(ChangeEvent e)=>e.entity=='profile'?uid:_cloudId(e.entity,e.entityId);

  Future<DateTime?> cloudUpdatedAt() async {
    final row=await client.from('sync_state').select('updated_at').eq('user_id',uid).maybeSingle();
    return row==null?null:DateTime.parse(row['updated_at']).toUtc();
  }

  Future<bool> _hasCloudData() async {
    final rows=await client.from('accounts').select('id').eq('user_id',uid).limit(1);
    return rows.isNotEmpty;
  }

  Future<Set<String>> _remoteChangedKeys(DateTime since,String deviceId)async{
    final rows=await retryPolicy.run(()=>client.from('sync_changes').select('entity,entity_id,device_id').eq('user_id',uid).gt('changed_at',since.toUtc().toIso8601String()).order('changed_at'));
    return rows.where((r)=>r['device_id']!=deviceId).map<String>((r)=>'${r['entity']}:${r['entity_id']}').toSet();
  }

  Future<void> _pruneChangeLog() async {
    final cutoff=DateTime.now().toUtc().subtract(const Duration(days:90));
    await client.from('sync_changes').delete().eq('user_id',uid).lt('changed_at',cutoff.toIso8601String());
  }

  Future<SyncOutcome> smartSync(FinanceStore s) async {
    final remote=await cloudUpdatedAt();
    if(remote==null){if(await _hasCloudData())return SyncOutcome.conflict;await upload(s);return SyncOutcome.uploaded;}
    final last=s.lastSyncedAt?.toUtc();
    if(last==null)return SyncOutcome.conflict;
    final localPending=s.pendingChanges;
    final localChanged=localPending.isNotEmpty;
    final remoteChanged=remote.isAfter(last.add(const Duration(milliseconds:1)));
    if(localChanged&&remoteChanged){
      final remoteKeys=await _remoteChangedKeys(last,s.deviceId);
      if(remoteKeys.isEmpty||remoteKeys.any((k)=>k.startsWith('snapshot:')))return SyncOutcome.conflict;
      final localKeys=localPending.map((e)=>'${e.entity}:${_entityCloudId(e)}').toSet();
      if(remoteKeys.intersection(localKeys).isNotEmpty)return SyncOutcome.conflict;
      await uploadIncremental(s);
      await download(s);
      return SyncOutcome.merged;
    }
    if(localChanged){await uploadIncremental(s);return SyncOutcome.uploaded;}
    if(remoteChanged){await download(s);return SyncOutcome.downloaded;}
    return SyncOutcome.unchanged;
  }

  Future<void> uploadIncremental(FinanceStore s)async{
    final pending=s.pendingChanges;
    if(pending.isEmpty)return;
    for(final e in pending){await _applyChange(e);}
    await client.from('sync_changes').insert(pending.map((e)=>{'user_id':uid,'entity':e.entity,'entity_id':_entityCloudId(e),'action':e.action,'device_id':s.deviceId,'changed_at':e.changedAt.toUtc().toIso8601String()}).toList());
    final previous=await client.from('sync_state').select('revision').eq('user_id',uid).maybeSingle();
    final revision=((previous?['revision'] as num?)?.toInt()??0)+1;
    final now=DateTime.now().toUtc();
    await client.from('sync_state').upsert({'user_id':uid,'revision':revision,'updated_at':now.toIso8601String()});
    final remote=await cloudUpdatedAt()??now;
    await s.markChangesSynced(pending.map((e)=>e.id),remote);await _pruneChangeLog();
  }

  Future<void> _applyChange(ChangeEvent e)async{
    final p=e.payload;
    if(e.entity=='profile'){
      if(e.action!='delete'&&p!=null)await client.from('profiles').upsert({'id':uid,'name':p['name']??'','currency':p['currency']??'USD'});
      return;
    }
    if(e.entity=='account'){
      final id=_cloudId('account',e.entityId);
      if(e.action=='delete'){await client.from('accounts').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('accounts').upsert({'id':id,'user_id':uid,'name':p['name'],'type':p['type'],'opening_balance':p['openingBalance'],'credit_limit':p['creditLimit'],'statement_day':p['statementDay'],'due_day':p['dueDay'],'updated_at':e.changedAt.toIso8601String()});
      return;
    }
    if(e.entity=='transaction'){
      final id=_cloudId('transaction',e.entityId);
      if(e.action=='delete'){await client.from('transactions').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('transactions').upsert({'id':id,'user_id':uid,'type':p['type'],'amount':p['amount'],'category':p['category'],'description':p['description']??'','account_id':_cloudId('account',p['accountId']),'destination_account_id':p['destinationAccountId']==null?null:_cloudId('account',p['destinationAccountId']),'occurred_at':DateTime.parse(p['date']).toUtc().toIso8601String(),'updated_at':e.changedAt.toIso8601String()});
      return;
    }
    if(e.entity=='budget'){
      final id=_cloudId('budget',e.entityId);
      if(e.action=='delete'){await client.from('budgets').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('budgets').upsert({'id':id,'user_id':uid,'category':p['category'],'monthly_limit':p['limit'],'updated_at':e.changedAt.toIso8601String()});
      return;
    }
    if(e.entity=='goal'){
      final id=_cloudId('goal',e.entityId);
      if(e.action=='delete'){await client.from('goals').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('goals').upsert({'id':id,'user_id':uid,'name':p['name'],'target':p['target'],'current_amount':p['current'],'target_date':p['targetDate']==null?null:DateTime.parse(p['targetDate']).toIso8601String().split('T').first,'updated_at':e.changedAt.toIso8601String()});
      return;
    }
    if(e.entity=='debt'){
      final id=_cloudId('debt',e.entityId);
      if(e.action=='delete'){await client.from('debts').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('debts').upsert({'id':id,'user_id':uid,'name':p['name'],'balance':p['balance'],'apr':p['apr'],'minimum_payment':p['minimumPayment'],'due_date':p['dueDate']==null?null:DateTime.parse(p['dueDate']).toIso8601String().split('T').first,'updated_at':e.changedAt.toIso8601String()});
      return;
    }
    if(e.entity=='recurring'){
      final id=_cloudId('recurring',e.entityId);
      if(e.action=='delete'){await client.from('recurring_payments').delete().eq('user_id',uid).eq('id',id);return;}
      if(p!=null)await client.from('recurring_payments').upsert({'id':id,'user_id':uid,'name':p['name'],'category':p['category'],'account_id':_cloudId('account',p['accountId']),'amount':p['amount'],'day_of_month':p['dayOfMonth'],'is_expense':p['isExpense'],'active':p['active'],'updated_at':e.changedAt.toIso8601String()});
    }
  }

  Future<void> upload(FinanceStore s) async {
    final accountMap={for(final a in s.accounts)a.id:_cloudId('account',a.id)};
    // Snapshot upload is deliberately non-destructive: valid remote rows are never erased before replacements exist.
    // Explicit deletions are handled by incremental change events.
    await client.from('profiles').upsert({'id':uid,'name':s.profile.name,'currency':s.profile.currency});
    final now=DateTime.now().toUtc().toIso8601String();
    if(s.accounts.isNotEmpty)await client.from('accounts').upsert(s.accounts.map((a)=>{'id':accountMap[a.id],'user_id':uid,'name':a.name,'type':a.type.name,'opening_balance':a.openingBalance,'credit_limit':a.creditLimit,'statement_day':a.statementDay,'due_day':a.dueDay,'updated_at':now}).toList());
    if(s.transactions.isNotEmpty)await client.from('transactions').upsert(s.transactions.map((t)=>{'id':_cloudId('transaction',t.id),'user_id':uid,'type':t.type.name,'amount':t.amount,'category':t.category,'description':t.description,'account_id':accountMap[t.accountId],'destination_account_id':t.destinationAccountId==null?null:accountMap[t.destinationAccountId],'occurred_at':t.date.toUtc().toIso8601String(),'updated_at':now}).toList());
    if(s.budgets.isNotEmpty)await client.from('budgets').upsert(s.budgets.map((x)=>{'id':_cloudId('budget',x.id),'user_id':uid,'category':x.category,'monthly_limit':x.limit,'updated_at':now}).toList());
    if(s.goals.isNotEmpty)await client.from('goals').upsert(s.goals.map((x)=>{'id':_cloudId('goal',x.id),'user_id':uid,'name':x.name,'target':x.target,'current_amount':x.current,'target_date':x.targetDate?.toIso8601String().split('T').first,'updated_at':now}).toList());
    if(s.debts.isNotEmpty)await client.from('debts').upsert(s.debts.map((x)=>{'id':_cloudId('debt',x.id),'user_id':uid,'name':x.name,'balance':x.balance,'apr':x.apr,'minimum_payment':x.minimumPayment,'due_date':x.dueDate?.toIso8601String().split('T').first,'updated_at':now}).toList());
    if(s.recurring.isNotEmpty)await client.from('recurring_payments').upsert(s.recurring.map((x)=>{'id':_cloudId('recurring',x.id),'user_id':uid,'name':x.name,'category':x.category,'account_id':accountMap[x.accountId],'amount':x.amount,'day_of_month':x.dayOfMonth,'is_expense':x.isExpense,'active':x.active,'updated_at':now}).toList());
    final previous=await client.from('sync_state').select('revision').eq('user_id',uid).maybeSingle();
    final revision=((previous?['revision'] as num?)?.toInt()??0)+1;
    final at=DateTime.now().toUtc();
    await client.from('sync_state').upsert({'user_id':uid,'revision':revision,'updated_at':at.toIso8601String()});
    await client.from('sync_changes').insert({'user_id':uid,'entity':'snapshot','entity_id':uid,'action':'replace','device_id':s.deviceId,'changed_at':at.toIso8601String()});
    final remote=await cloudUpdatedAt()??at;await s.markSynced(remote);await _pruneChangeLog();
  }

  Future<void> download(FinanceStore s) async {
    final p=await client.from('profiles').select().eq('id',uid).maybeSingle();
    final aa=await client.from('accounts').select().eq('user_id',uid);
    final tt=await client.from('transactions').select().eq('user_id',uid).order('occurred_at',ascending:false);
    final bb=await client.from('budgets').select().eq('user_id',uid);
    final gg=await client.from('goals').select().eq('user_id',uid);
    final dd=await client.from('debts').select().eq('user_id',uid);
    final rr=await client.from('recurring_payments').select().eq('user_id',uid);
    final remote=await cloudUpdatedAt()??DateTime.now().toUtc();
    await s.replaceAll(
      profile:UserProfile(name:p?['name']??client.auth.currentUser?.userMetadata?['name']??'Usuario',email:client.auth.currentUser?.email??'',currency:p?['currency']??'USD'),
      accounts:aa.map<FinanceAccount>((a)=>FinanceAccount(id:a['id'],name:a['name'],type:AccountType.values.byName(a['type']),openingBalance:(a['opening_balance'] as num).toDouble(),creditLimit:(a['credit_limit'] as num?)?.toDouble(),statementDay:(a['statement_day'] as num?)?.toInt(),dueDay:(a['due_day'] as num?)?.toInt())).toList(),
      transactions:tt.map<FinanceTransaction>((t)=>FinanceTransaction(id:t['id'],type:TransactionType.values.byName(t['type']),amount:(t['amount'] as num).toDouble(),category:t['category'],description:t['description']??'',accountId:t['account_id'],destinationAccountId:t['destination_account_id'],date:DateTime.parse(t['occurred_at']).toLocal())).toList(),
      budgets:bb.map<Budget>((x)=>Budget(id:x['id'],category:x['category'],limit:(x['monthly_limit'] as num).toDouble())).toList(),
      goals:gg.map<SavingsGoal>((x)=>SavingsGoal(id:x['id'],name:x['name'],target:(x['target'] as num).toDouble(),current:(x['current_amount'] as num).toDouble(),targetDate:x['target_date']==null?null:DateTime.parse(x['target_date']))).toList(),
      debts:dd.map<Debt>((x)=>Debt(id:x['id'],name:x['name'],balance:(x['balance'] as num).toDouble(),apr:(x['apr'] as num).toDouble(),minimumPayment:(x['minimum_payment'] as num).toDouble(),dueDate:x['due_date']==null?null:DateTime.parse(x['due_date']))).toList(),
      recurring:rr.map<RecurringPayment>((x)=>RecurringPayment(id:x['id'],name:x['name'],category:x['category'],accountId:x['account_id'],amount:(x['amount'] as num).toDouble(),dayOfMonth:x['day_of_month'],isExpense:x['is_expense'],active:x['active'])).toList(),
      syncedAt:remote,
    );
  }
}

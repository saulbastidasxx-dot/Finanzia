import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'finance_models.dart';
import 'user_profile.dart';
import 'change_event.dart';

class FinanceStore extends ChangeNotifier {
  UserProfile profile=const UserProfile(name:'María',email:'maria@finanzia.app');
  static const _key='finanzia_local_v5';
  DateTime localModifiedAt=DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? lastSyncedAt;
  String deviceId='';
  final accounts=<FinanceAccount>[];
  final transactions=<FinanceTransaction>[];
  final budgets=<Budget>[];
  final goals=<SavingsGoal>[];
  final debts=<Debt>[];
  final recurring=<RecurringPayment>[];
  final changes=<ChangeEvent>[];
  final categories=<String>['Alimentos','Restaurantes','Transporte','Vivienda','Servicios','Salud','Compras','Entretenimiento','Educación','Salario','Freelance','Otros'];
  bool ready=false;

  List<ChangeEvent> get pendingChanges=>changes.where((e)=>!e.synced).toList(growable:false);

  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString(_key)??p.getString('finanzia_local_v4');
    deviceId=p.getString('finanzia_device_id')??const Uuid().v4();
    await p.setString('finanzia_device_id',deviceId);
    if(raw!=null){
      final d=jsonDecode(raw);
      localModifiedAt=DateTime.tryParse(d['localModifiedAt']??'')??DateTime.fromMillisecondsSinceEpoch(0);
      lastSyncedAt=DateTime.tryParse(d['lastSyncedAt']??'');
      accounts.addAll((d['accounts']??[]).map<FinanceAccount>((e)=>FinanceAccount.fromJson(Map<String,dynamic>.from(e))));
      transactions.addAll((d['transactions']??[]).map<FinanceTransaction>((e)=>FinanceTransaction.fromJson(Map<String,dynamic>.from(e))));
      budgets.addAll((d['budgets']??[]).map<Budget>((e)=>Budget.fromJson(Map<String,dynamic>.from(e))));
      goals.addAll((d['goals']??[]).map<SavingsGoal>((e)=>SavingsGoal.fromJson(Map<String,dynamic>.from(e))));
      debts.addAll((d['debts']??[]).map<Debt>((e)=>Debt.fromJson(Map<String,dynamic>.from(e))));
      if(d['recurring']!=null) recurring.addAll((d['recurring'] as List).map((e)=>RecurringPayment.fromJson(Map<String,dynamic>.from(e))));
      if(d['changes']!=null) changes.addAll((d['changes'] as List).map((e)=>ChangeEvent.fromJson(Map<String,dynamic>.from(e))));
      if(d['categories']!=null){categories..clear()..addAll(List<String>.from(d['categories']));}
      if(d['profile']!=null) profile=UserProfile.fromJson(Map<String,dynamic>.from(d['profile']));
    }else{
      _seed();localModifiedAt=DateTime.now().toUtc();await _save(touch:false);
    }
    ready=true;notifyListeners();
  }

  void _seed(){
    final now=DateTime.now();
    accounts.addAll(const [FinanceAccount(id:'bank',name:'Banco Principal',type:AccountType.bank,openingBalance:2305.40),FinanceAccount(id:'savings',name:'Ahorros',type:AccountType.savings,openingBalance:5000),FinanceAccount(id:'cash',name:'Efectivo',type:AccountType.cash,openingBalance:250),FinanceAccount(id:'card',name:'Tarjeta de Crédito',type:AccountType.creditCard,openingBalance:0,creditLimit:3000)]);
    transactions.addAll([FinanceTransaction(id:'t1',type:TransactionType.income,amount:2500,category:'Salario',description:'Salario',accountId:'bank',date:now.subtract(const Duration(days:2))),FinanceTransaction(id:'t2',type:TransactionType.expense,amount:85.40,category:'Alimentos',description:'Supermercado',accountId:'bank',date:now.subtract(const Duration(days:1))),FinanceTransaction(id:'t3',type:TransactionType.expense,amount:42.30,category:'Restaurantes',description:'Restaurante',accountId:'card',date:now),FinanceTransaction(id:'t4',type:TransactionType.income,amount:600,category:'Freelance',description:'Proyecto freelance',accountId:'bank',date:now)]);
    budgets.addAll(const [Budget(id:'b1',category:'Alimentos',limit:500),Budget(id:'b2',category:'Restaurantes',limit:250)]);
    goals.add(SavingsGoal(id:'g1',name:'Fondo de emergencia',target:10000,current:4200,targetDate:DateTime(now.year+1,6,1)));
    recurring.addAll(const [RecurringPayment(id:'r1',name:'Internet',category:'Servicios',accountId:'bank',amount:65,dayOfMonth:8),RecurringPayment(id:'r2',name:'Streaming',category:'Entretenimiento',accountId:'card',amount:14.99,dayOfMonth:15)]);
    debts.add(Debt(id:'d1',name:'Préstamo personal',balance:4200,apr:8.9,minimumPayment:180,dueDate:DateTime(now.year,now.month+1,5)));
  }

  double balanceFor(String id){final a=accounts.firstWhere((e)=>e.id==id);var v=a.openingBalance;for(final t in transactions){if(t.type==TransactionType.income&&t.accountId==id)v+=t.amount;if(t.type==TransactionType.expense&&t.accountId==id)v-=t.amount;if(t.type==TransactionType.transfer){if(t.accountId==id)v-=t.amount;if(t.destinationAccountId==id)v+=t.amount;}}return v;}
  double get totalAssets=>accounts.where((a)=>a.type!=AccountType.creditCard).fold(0,(s,a)=>s+balanceFor(a.id));
  double get cardDebt=>accounts.where((a)=>a.type==AccountType.creditCard).fold(0,(s,a)=>s+(-balanceFor(a.id)).clamp(0,double.infinity));
  double get debtTotal=>debts.fold(0,(s,d)=>s+d.balance);
  double get netWorth=>totalAssets-cardDebt-debtTotal;
  double get monthIncome=>amountForMonth(TransactionType.income,DateTime.now());
  double get monthExpenses=>amountForMonth(TransactionType.expense,DateTime.now());
  double amountForMonth(TransactionType type,DateTime month)=>transactions.where((t)=>t.type==type&&t.date.year==month.year&&t.date.month==month.month).fold(0,(s,t)=>s+t.amount);
  double savingsForMonth(DateTime month)=>amountForMonth(TransactionType.income,month)-amountForMonth(TransactionType.expense,month);
  double savingsRateForMonth(DateTime month){final income=amountForMonth(TransactionType.income,month);return income<=0?0:savingsForMonth(month)/income;}
  double spentForCategory(String c){final n=DateTime.now();return transactions.where((t)=>t.type==TransactionType.expense&&t.category==c&&t.date.year==n.year&&t.date.month==n.month).fold(0,(s,t)=>s+t.amount);}

  Future<void> addAccount(FinanceAccount x)async{accounts.add(x);_record('account',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<bool> deleteAccount(String id)async{final referenced=transactions.any((t)=>t.accountId==id||t.destinationAccountId==id)||recurring.any((r)=>r.accountId==id);if(referenced)return false;final before=accounts.length;accounts.removeWhere((a)=>a.id==id);if(accounts.length==before)return false;_record('account',id,'delete');await _save();notifyListeners();return true;}
  Future<void> addTransaction(FinanceTransaction x)async{transactions.insert(0,x);_record('transaction',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> deleteTransaction(String id)async{transactions.removeWhere((t)=>t.id==id);_record('transaction',id,'delete');await _save();notifyListeners();}
  Future<void> updateTransaction(FinanceTransaction x)async{final i=transactions.indexWhere((t)=>t.id==x.id);if(i<0)return;transactions[i]=x;_record('transaction',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> updateAccount(FinanceAccount x)async{final i=accounts.indexWhere((a)=>a.id==x.id);if(i<0)return;accounts[i]=x;_record('account',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> addBudget(Budget x)async{budgets.add(x);_record('budget',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> updateBudget(Budget x)async{final i=budgets.indexWhere((e)=>e.id==x.id);if(i<0)return;budgets[i]=x;_record('budget',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> deleteBudget(String id)async{budgets.removeWhere((x)=>x.id==id);_record('budget',id,'delete');await _save();notifyListeners();}
  Future<void> addGoal(SavingsGoal x)async{goals.add(x);_record('goal',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> updateGoal(SavingsGoal x)async{final i=goals.indexWhere((e)=>e.id==x.id);if(i<0)return;goals[i]=x;_record('goal',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> deleteGoal(String id)async{goals.removeWhere((x)=>x.id==id);_record('goal',id,'delete');await _save();notifyListeners();}
  Future<void> addDebt(Debt x)async{debts.add(x);_record('debt',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> updateDebt(Debt x)async{final i=debts.indexWhere((e)=>e.id==x.id);if(i<0)return;debts[i]=x;_record('debt',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> deleteDebt(String id)async{debts.removeWhere((x)=>x.id==id);_record('debt',id,'delete');await _save();notifyListeners();}
  Future<void> addRecurring(RecurringPayment x)async{recurring.add(x);_record('recurring',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> updateRecurring(RecurringPayment x)async{final i=recurring.indexWhere((e)=>e.id==x.id);if(i<0)return;recurring[i]=x;_record('recurring',x.id,'upsert',x.toJson());await _save();notifyListeners();}
  Future<void> deleteRecurring(String id)async{recurring.removeWhere((x)=>x.id==id);_record('recurring',id,'delete');await _save();notifyListeners();}
  Future<void> contributeGoal(String id,double amount)async{final i=goals.indexWhere((g)=>g.id==id);if(i<0||amount<=0)return;goals[i]=goals[i].copyWith(current:(goals[i].current+amount).clamp(0,goals[i].target));_record('goal',id,'upsert',goals[i].toJson());await _save();notifyListeners();}
  Future<void> addCategory(String x)async{if(x.trim().isNotEmpty&&!categories.contains(x.trim()))categories.add(x.trim());await _save();notifyListeners();}
  Future<bool> deleteCategory(String x)async{final used=transactions.any((t)=>t.category==x)||budgets.any((b)=>b.category==x)||recurring.any((r)=>r.category==x);if(used)return false;categories.remove(x);await _save();notifyListeners();return true;}
  Future<void> updateProfile(UserProfile x)async{profile=x;_record('profile','profile','upsert',x.toJson());await _save();notifyListeners();}

  Future<void> clearLocalData()async{
    accounts.clear();transactions.clear();budgets.clear();goals.clear();debts.clear();recurring.clear();changes.clear();
    categories..clear()..addAll(['Alimentos','Restaurantes','Transporte','Vivienda','Servicios','Salud','Compras','Entretenimiento','Educación','Salario','Freelance','Otros']);
    profile=const UserProfile(name:'Usuario',email:'');localModifiedAt=DateTime.fromMillisecondsSinceEpoch(0);lastSyncedAt=null;
    final p=await SharedPreferences.getInstance();await p.remove(_key);await p.remove('finanzia_local_v4');notifyListeners();
  }

  void _record(String entity,String entityId,String action,[Map<String,dynamic>? payload]){
    changes.add(ChangeEvent(id:const Uuid().v4(),entity:entity,entityId:entityId,action:action,changedAt:DateTime.now().toUtc(),payload:payload));
    if(changes.length>250) changes.removeRange(0,changes.length-250);
  }

  Future<void> replaceAll({required UserProfile profile,required List<FinanceAccount> accounts,required List<FinanceTransaction> transactions,required List<Budget> budgets,required List<SavingsGoal> goals,required List<Debt> debts,required List<RecurringPayment> recurring,DateTime? syncedAt})async{
    this.profile=profile;this.accounts..clear()..addAll(accounts);this.transactions..clear()..addAll(transactions);this.budgets..clear()..addAll(budgets);this.goals..clear()..addAll(goals);this.debts..clear()..addAll(debts);this.recurring..clear()..addAll(recurring);
    if(syncedAt!=null){lastSyncedAt=syncedAt;localModifiedAt=syncedAt;for(var i=0;i<changes.length;i++)changes[i]=changes[i].copyWith(synced:true);}
    await _save(touch:false);notifyListeners();
  }
  Future<void> markSynced(DateTime at)async{lastSyncedAt=at;localModifiedAt=at;for(var i=0;i<changes.length;i++)changes[i]=changes[i].copyWith(synced:true);await _save(touch:false);notifyListeners();}
  Future<void> markChangesSynced(Iterable<String> ids,DateTime at)async{final set=ids.toSet();for(var i=0;i<changes.length;i++){if(set.contains(changes[i].id))changes[i]=changes[i].copyWith(synced:true);}lastSyncedAt=at;localModifiedAt=at;await _save(touch:false);notifyListeners();}

  Future<void> _save({bool touch=true})async{
    if(touch)localModifiedAt=DateTime.now().toUtc();
    final p=await SharedPreferences.getInstance();
    await p.setString(_key,jsonEncode({'accounts':accounts.map((e)=>e.toJson()).toList(),'transactions':transactions.map((e)=>e.toJson()).toList(),'budgets':budgets.map((e)=>e.toJson()).toList(),'goals':goals.map((e)=>e.toJson()).toList(),'debts':debts.map((e)=>e.toJson()).toList(),'recurring':recurring.map((e)=>e.toJson()).toList(),'categories':categories,'profile':profile.toJson(),'changes':changes.map((e)=>e.toJson()).toList(),'deviceId':deviceId,'localModifiedAt':localModifiedAt.toIso8601String(),'lastSyncedAt':lastSyncedAt?.toIso8601String()}));
  }
}

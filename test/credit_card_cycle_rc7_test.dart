import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/models/finance_models.dart';
import 'package:finanzia/models/finance_store.dart';
import 'package:finanzia/services/credit_card_service.dart';
void main(){test('card uses its own statement and due days',(){final s=FinanceStore();const a=FinanceAccount(id:'c',name:'Visa',type:AccountType.creditCard,openingBalance:0,creditLimit:1000,statementDay:25,dueDay:8);final x=CreditCardService.summary(s,a,at:DateTime(2026,9,16));expect(x.statementDate,DateTime(2026,9,25));expect(x.dueDate,DateTime(2026,10,8));});test('account JSON preserves billing cycle',(){const a=FinanceAccount(id:'c',name:'Visa',type:AccountType.creditCard,openingBalance:0,statementDay:31,dueDay:10);final b=FinanceAccount.fromJson(a.toJson());expect(b.statementDay,31);expect(b.dueDay,10);});}

import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/core/validators.dart';

void main(){
  group('FinanziaValidators',(){
    test('requiredText rechaza vacío',(){expect(FinanziaValidators.requiredText(''),isNotNull);expect(FinanziaValidators.requiredText('Cuenta'),isNull);});
    test('positiveMoney acepta decimales con coma',(){expect(FinanziaValidators.positiveMoney('12,50'),isNull);expect(FinanziaValidators.positiveMoney('0'),isNotNull);expect(FinanziaValidators.positiveMoney('-2'),isNotNull);});
    test('email valida formato básico',(){expect(FinanziaValidators.email('maria@finanzia.app'),isNull);expect(FinanziaValidators.email('maria'),isNotNull);});
  });
}

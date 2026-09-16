import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/services/retry_policy.dart';

void main(){
  test('retries transient failures and eventually succeeds',()async{
    var attempts=0;
    final r=await const RetryPolicy(maxAttempts:3,initialDelay:Duration.zero).run<int>(()async{
      attempts++;
      if(attempts<3)throw Exception('transient');
      return 7;
    });
    expect(r,7);
    expect(attempts,3);
  });

  test('stops after max attempts',()async{
    var attempts=0;
    expect(
      ()=>const RetryPolicy(maxAttempts:2,initialDelay:Duration.zero).run<void>(()async{
        attempts++;throw Exception('down');
      }),
      throwsException,
    );
    await Future<void>.delayed(Duration.zero);
    expect(attempts,2);
  });
}

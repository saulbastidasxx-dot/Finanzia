import 'dart:async';

class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  const RetryPolicy({this.maxAttempts=3,this.initialDelay=const Duration(milliseconds:400)});

  Future<T> run<T>(Future<T> Function() action,{bool Function(Object error)? retryIf}) async {
    Object? last;
    for(var attempt=1;attempt<=maxAttempts;attempt++){
      try{return await action();}
      catch(e){
        last=e;
        if(attempt>=maxAttempts || (retryIf!=null && !retryIf(e))) rethrow;
        final delay=initialDelay*attempt;
        await Future<void>.delayed(delay);
      }
    }
    throw last!;
  }
}

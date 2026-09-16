import 'package:flutter/foundation.dart';

enum ConnectivityState { online, offline, checking }

class AppStatus extends ChangeNotifier {
  ConnectivityState connectivity = ConnectivityState.checking;
  String? lastError;
  bool get isOffline => connectivity == ConnectivityState.offline;
  void setConnectivity(ConnectivityState value) {
    connectivity = value;
    notifyListeners();
  }

  void reportError(Object error) {
    lastError = error.toString();
    notifyListeners();
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }
}

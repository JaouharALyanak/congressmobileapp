import 'package:flutter/material.dart';
import '../utils/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true; // optimistic default

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    // Real check on startup
    _isOnline = await ConnectivityService.isOnline();
    notifyListeners();

    // Listen to network changes in real time
    ConnectivityService.onStatusChange.listen((connected) async {
      if (connected) {
        // Network came back — do a real ping to confirm
        _isOnline = await ConnectivityService.isOnline();
      } else {
        _isOnline = false;
      }
      notifyListeners();
    });
  }
}

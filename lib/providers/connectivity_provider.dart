import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  bool _hasConnection = true;
  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  InternetConnectionChecker? _internetChecker;
  bool get isOnline => _isOnline;

  bool get hasConnection => _hasConnection;

  bool get isOffline => !_isOnline;

  bool get isOfflineModeAvailable => true;

  bool get shouldShowOfflineFeatures => isOfflineModeAvailable && isOffline;

  Future<void> initialize() async {
    _internetChecker = InternetConnectionChecker.createInstance();
    _hasConnection = await _internetChecker!.hasConnection;
    _isOnline = _hasConnection;

    _connectionSubscription = _internetChecker!.onStatusChange.listen((
      InternetConnectionStatus status,
    ) {
      final wasOnline = _isOnline;
      _hasConnection = status == InternetConnectionStatus.connected;
      _isOnline = _hasConnection;

      if (wasOnline != _isOnline) {
        notifyListeners();
        _logConnectivityChange();
      }
    });

    debugPrint('ConnectivityService initialized. Online: $_isOnline');
  }

  Future<bool> checkConnection() async {
    try {
      _hasConnection = await _internetChecker!.hasConnection;
      _isOnline = _hasConnection;
      notifyListeners();
      return _isOnline;
    } catch (e) {
      debugPrint('Error checking connection: $e');
      _hasConnection = false;
      _isOnline = false;
      notifyListeners();
      return false;
    }
  }

  void setOfflineMode(bool offline) {
    _isOnline = !offline;
    notifyListeners();
    debugPrint('Offline mode ${offline ? 'enabled' : 'disabled'}');
  }

  void _logConnectivityChange() {
    debugPrint('Connectivity changed: ${_isOnline ? 'ONLINE' : 'OFFLINE'}');
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

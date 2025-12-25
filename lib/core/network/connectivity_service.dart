import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state
enum ConnectivityStatus {
  online,
  offline,
}

/// Connectivity service provider
final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ConnectivityService().statusStream;
});

/// Simple accessor for current status
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityProvider);
  return status.when(
    data: (s) => s == ConnectivityStatus.online,
    loading: () => true,
    error: (_, __) => true,
  );
});

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityService() {
    _init();
  }

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  Future<void> _init() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Consider online if any connection is available
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    _statusController.add(
      isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline,
    );
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _statusController.close();
  }
}

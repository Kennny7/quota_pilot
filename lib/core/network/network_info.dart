// lib/core/network/network_info.dart

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class SimpleNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // Graceful online default
}

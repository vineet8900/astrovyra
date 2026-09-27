import 'dart:async';

class WalletEventBus {
  WalletEventBus._internal();

  static final WalletEventBus _instance = WalletEventBus._internal();

  factory WalletEventBus() {
    return _instance;
  }

  final _walletController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get walletStream => _walletController.stream;

  void updateWallet(Map<String, dynamic> userData) {
    if (!_walletController.isClosed) {
      _walletController.sink.add(userData);
    }
  }

  void dispose() {
    _walletController.close();
  }
}

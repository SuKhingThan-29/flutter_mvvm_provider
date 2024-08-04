import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityViewModel with ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  ConnectivityViewModel() {
    _checkConnectivity();
  }
  Future<void> _checkConnectivity()async{
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());


    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _isConnected=true;
      // Mobile network available.
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      _isConnected=true;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      _isConnected=false;
    }
    notifyListeners();
  }
}



import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show PlatformException, SystemNavigator;
import 'package:flutter/material.dart';

class NetworkChecker extends GetxController {
  RxList numbersList = [].obs;

  Connectivity _connectivity = Connectivity();
  Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;
  get connectionStatus => _connectionStatus;

  @override
  void onInit() async {
    super.onInit();
    await updateConnectionStatus();
  }

  Future<void> updateConnectionStatus() async {
    try {
      _connectionStatus.value = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
  }

  setnewstate(ConnectivityResult status) {
    _connectionStatus.value = status;
  }
}

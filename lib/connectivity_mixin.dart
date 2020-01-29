import 'dart:async';

import 'package:connectivity/connectivity.dart';

mixin ConnectivityMixin {
  StreamSubscription<ConnectivityResult> subscription;

  initializeConnectivity({Function onConnected, Function onDisconnected}) {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        onConnected();
      } else {
        onDisconnected();
      }
    });
  }
}

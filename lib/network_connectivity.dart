import 'dart:async';

import 'package:flutter/services.dart';

enum Networkstate { connected, disconnected }

class NetworkConnectivity {
  static NetworkConnectivity _instance;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<Networkstate> _onnetworkstatechange;

  factory NetworkConnectivity() {
    if (_instance == null) {
      final MethodChannel methodchannel =
          const MethodChannel('network_connectivity');
      final EventChannel eventChannel =
          const EventChannel('network_connectivity_state');
      _instance = new NetworkConnectivity.call(methodchannel, eventChannel);
    }
    return _instance;
  }

  NetworkConnectivity.call(this._methodChannel, this._eventChannel);

  Future<String> get platformVersion async {
    final String version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> get isConnected async {
    final bool connected = await _methodChannel.invokeMethod("getconnectivity");
    return connected;
  }

  Future<String> get ipaddress async {
    final String ip = await _methodChannel.invokeMethod("getipaddress");
    return ip;
  }

  Stream<Networkstate> get onnetworkstatechange {
    if (_onnetworkstatechange == null) {
      _onnetworkstatechange = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseBatteryState(event));
    }
    return _onnetworkstatechange;
  }

  Networkstate _parseBatteryState(String state) {
    switch (state) {
      case '200':
        return Networkstate.connected;
      case '0':
        return Networkstate.disconnected;
      default:
        throw new ArgumentError('$state do`not found any network.');
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_connectivity/network_connectivity.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown', _ipaddress = "unkown";
  bool _connected=false;
  NetworkConnectivity _connectivity = new NetworkConnectivity();
  Networkstate _state;
  StreamSubscription<Networkstate> _conectionchange;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _conectionchange = _connectivity.onnetworkstatechange.listen((Networkstate state) {
      setState(() {
        _state = state;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_conectionchange != null) {
      _conectionchange.cancel();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion, ipaddress;
    bool connected;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _connectivity.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      connected = await _connectivity.isConnected;
    } on Exception {
      connected = false;
    }
    try {
      ipaddress = await _connectivity.ipaddress;
    } on Exception {
      ipaddress = 'Failed to get Networks  State get';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
      _connected = connected;
      _ipaddress = ipaddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text(
              'Running on: $_platformVersion\n$_ipaddress\nnetwork connected $_state'),
        ),
      ),
    );
  }
}

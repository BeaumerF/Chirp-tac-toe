import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chirpsdk/chirpsdk.dart';
import 'package:simple_permissions/simple_permissions.dart';

String _appKey = '';
String _appSecret = '';
String _appConfig = '';

class ChirpApp extends StatefulWidget {
  @override
  _ChirpAppState createState() => _ChirpAppState();
}

class _ChirpAppState extends State<ChirpApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold( );
  }

  Future<void> _initChirp() async {
    await ChirpSDK.init(_appKey, _appSecret);
  }

  Future<void> _configureChirp() async {
    await ChirpSDK.setConfig(_appConfig);
  }

  Future<void> _sendRandomChirp() async {
    await ChirpSDK.sendRandom();
  }

    Future<void> _sendChirp(Uint8List data) async {
    await ChirpSDK.send(data);
  }

  Future<void> _startAudioProcessing() async {
    await ChirpSDK.start();
  }

  Future<void> _stopAudioProcessing() async {
    await ChirpSDK.stop();
  }

  Future<void> _requestPermissions() async {
    bool permission = await SimplePermissions.checkPermission(Permission.RecordAudio);
    if (!permission) {
      await SimplePermissions.requestPermission(Permission.RecordAudio);
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initChirp();
    _configureChirp();
    _startAudioProcessing();
  }

  @override
  void dispose() {
    _stopAudioProcessing();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopAudioProcessing();
    } else if (state == AppLifecycleState.resumed) {
      _startAudioProcessing();
    }
  }
}

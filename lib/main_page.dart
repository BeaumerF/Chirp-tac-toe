
import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chirpsdk/chirpsdk.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:chirptactoe/game_page.dart';

String _appKey = '';
String _appSecret = '';
String _appConfig = '';

// <--
// MainPage here
// -->
class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String playerName = '';
  String lastPlayerName = '';
  int playerID = 0;
  String player2Name = '';
  int player2ID = 0;
 
  ChirpState _chirpState = ChirpState.not_created;
  Uint8List _chirpData = Uint8List(0);
  
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

  Future<void> _setChirpCallbacks() async {
    ChirpSDK.onStateChanged.listen((e) {
      setState(() {
        _chirpState = e.current;
      });
    });
    ChirpSDK.onSending.listen((e) {
      setState(() {
        _chirpData = e.payload;
      });
    });
    ChirpSDK.onSent.listen((e) {
      setState(() {
        _chirpData = e.payload;
      });
    });
    ChirpSDK.onReceived.listen((e) {
      setState(() {
        var receivedData =  new String.fromCharCodes(e.payload);
        if (receivedData.contains(" "))
        {
          var list = receivedData.split(" ");
          player2ID = int.parse(list[0]);
          player2Name = list[1];
        }
      });
    });
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
    _setChirpCallbacks();
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

  Widget build(BuildContext context) {
          TextStyle style21 = new TextStyle(
      inherit: true,
      color: Colors.white,
      fontSize: 21.0,
    );
    TextStyle color = new TextStyle(
      inherit: true,
      color: new Color(0xffe84c3d),
      fontSize: 21.0,
    );
          Text buttonStart = new Text(
                'Start Game',
            style: style21,
          );
               Text buttonSend = new Text(
                'Send',
            style: style21,
          );
//styles

    return new Scaffold(
         backgroundColor: new Color(0xff39465a),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            // new Container(
            //   padding: const EdgeInsets.only(top: 50.0),
            //   child: new Image(
            //     image: new AssetImage('assets/images/logo.png'),
            //     height: 100.00,
            //     width: 100.00,
            //   ),
            // ),

            new Container(
              padding: const EdgeInsets.only(top: 35.0, left: 25.0, right: 25.0),
              child: new TextField(
                onChanged: (String text) => setState(() {
                  playerName = text;
                }),
                decoration: new InputDecoration(hintText: "Player name", hintStyle: color),
                style: color,
             ),
            ),

                       new Container(
              padding: const EdgeInsets.only(top: 35.0),
              child: new FlatButton(
              child: buttonSend,
              onPressed: () { 
                if (playerName.isNotEmpty && playerName.length <= 10)
                {
                  if (lastPlayerName != playerName)
                  {
                    lastPlayerName = playerName;
                    playerID = new math.Random().nextInt(99);
                  }
                  var toSend = playerID.toString() + ' ' + playerName;
                  _sendChirp(new Uint8List.fromList(toSend.codeUnits));
                }
                },
             ),
             ),

            new Container(
              padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
              child: new Text('You play with',
                style: color,
             ),
            ),

                        new Container(
              padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
              child: new Text(player2Name,
                style: color,
             ),
            ),

           new Container(
              padding: const EdgeInsets.only(top: 35.0),
              child: new FlatButton(
              child: buttonStart,
              onPressed: () { 
                if (playerName.isNotEmpty && player2Name.isNotEmpty)
                Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) =>
                     new GamePage(playerID, player2ID)
                                  )
                                  )
                                  ;
                },
             ),
             ),

          ],
        ),
      ),
    );
  }
}
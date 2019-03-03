import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chirpsdk/chirpsdk.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:chirptactoe/custom_dailog.dart';
import 'package:chirptactoe/game_button.dart';

String _appKey = '';
String _appSecret = '';
String _appConfig = '';

class GamePage extends StatefulWidget {
  @override
  final int p1;
  final int p2;
  GamePage(this.p1, this.p2);
  _GamePageState createState() => new _GamePageState(this.p1, this.p2);
}

class _GamePageState extends State<GamePage> {
  List<GameButton> buttonsList;
    var player1;
  var player2;
  var activePlayer = 2;
  final int p1;
  final int p2;
  int lastgb = -1;
  _GamePageState(this.p1, this.p2);

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

        if (receivedData.contains(' '))
        {
          var list = receivedData.split(" ");
          if (int.parse(list[0]) == p2)
            {
              if (lastgb != -1)
                buttonsList[lastgb].enabled = false;
              buttonsList[int.parse(list[1])].text = "0";
              buttonsList[int.parse(list[1])].bg = Colors.black;
              player2.add(buttonsList[int.parse(list[1])].id);
              activePlayer = 1;
            }
        }
        int winner = checkWinner();
        if (winner == -1) {
          if (buttonsList.every((p) => p.text != "")) {
            showDialog(
                context: context,
                builder: (_) => new CustomDialog("Game Tied",
                    "Press the reset button to start again.", resetGame));
          } else {
            // activePlayer == 2 ? autoPlay() : null
            /*player2*/;
          }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermissions();
    _initChirp();
    _configureChirp();
    _setChirpCallbacks();
    _startAudioProcessing();
    buttonsList = doInit();
  }

  List<GameButton> doInit() {
    player1 = new List();
    player2 = new List();
    if (p1 >= p2)
      activePlayer = 1;

    var gameButtons = <GameButton>[
      new GameButton(id: 0),
      new GameButton(id: 1),
      new GameButton(id: 2),
      new GameButton(id: 3),
      new GameButton(id: 4),
      new GameButton(id: 5),
      new GameButton(id: 6),
      new GameButton(id: 7),
      new GameButton(id: 8),
    ];
    return gameButtons;
  }

  void playGame(GameButton gb) {
    setState(() {
    if (gb.enabled)
    {
        if (activePlayer == 1 && gb.text == "") {
          gb.text = "X";
          gb.bg = Colors.red;
          activePlayer = 2;
          player1.add(gb.id);
          var toSend = p1.toString() + ' ' + (gb.id).toString();
          _sendChirp(new Uint8List.fromList(toSend.codeUnits));
          lastgb = gb.id;
        } else if (gb.text == "X")
        {
          var toSend = p1.toString() + ' ' + (gb.id).toString();
          _sendChirp(new Uint8List.fromList(toSend.codeUnits));
        }
      }
      int winner = checkWinner();
      if (winner == -1) {
        if (buttonsList.every((p) => p.text != "")) {
          showDialog(
              context: context,
              builder: (_) => new CustomDialog("Game Tied",
                  "Press the reset button to start again.", resetGame));
        } else {
          // activePlayer == 2 ? autoPlay() : null
          /*player2*/;
        }
      }
    });
  }
  
  void gameOver() {
    
  }

  int checkWinner() {
    var winner = -1;
   if (player1.contains(1) && player1.contains(2) && player1.contains(0)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(2) && player2.contains(0)) {
      winner = 2;
    }

    // row 2
    if (player1.contains(4) && player1.contains(5) && player1.contains(3)) {
      winner = 1;
    }
    if (player2.contains(4) && player2.contains(5) && player2.contains(3)) {
      winner = 2;
    }

    // row 3
    if (player1.contains(7) && player1.contains(8) && player1.contains(6)) {
      winner = 1;
    }
    if (player2.contains(7) && player2.contains(8) && player2.contains(6)) {
      winner = 2;
    }

    // col 1
    if (player1.contains(0) && player1.contains(3) && player1.contains(6)) {
      winner = 1;
    }
    if (player2.contains(0) && player2.contains(3) && player2.contains(6)) {
      winner = 2;
    }

    // col 2
    if (player1.contains(1) && player1.contains(4) && player1.contains(7)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(4) && player2.contains(7)) {
      winner = 2;
    }

    // col 3
    if (player1.contains(2) && player1.contains(5) && player1.contains(8)) {
      winner = 1;
    }
    if (player2.contains(2) && player2.contains(5) && player2.contains(8)) {
      winner = 2;
    }

    //diagonal
    if (player1.contains(0) && player1.contains(4) && player1.contains(8)) {
      winner = 1;
    }
    if (player2.contains(0) && player2.contains(4) && player2.contains(8)) {
      winner = 2;
    }

    if (player1.contains(2) && player1.contains(4) && player1.contains(6)) {
      winner = 1;
    }
    if (player2.contains(2) && player2.contains(4) && player2.contains(6)) {
      winner = 2;
    }

    if (winner != -1) {
      if (winner == 1) {
        showDialog(
            context: context,
            builder: (_) => new CustomDialog("You Won",
                "Press the reset button to start again.", resetGame));
      } else {
        showDialog(
            context: context,
            builder: (_) => new CustomDialog("You Lost",
                "Press the reset button to start again.", resetGame));
      }
    }

    return winner;
  }

  void resetGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      buttonsList = doInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Chirp Tac Toe"),
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Expanded(
              child: new GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 9.0,
                    mainAxisSpacing: 9.0),
                itemCount: buttonsList.length,
                itemBuilder: (context, i) => new SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: new RaisedButton(
                        padding: const EdgeInsets.all(8.0),
                        onPressed: buttonsList[i].enabled
                            ? () => playGame(buttonsList[i])
                            : null,
                        child: new Text(
                          buttonsList[i].text,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 20.0),
                        ),
                        color: buttonsList[i].bg,
                        disabledColor: buttonsList[i].bg,
                      ),
                    ),
              ),
            ),
            // new RaisedButton(
            //   child: new Text(
            //     (p2.toString() + " " + test + '---' + lastgb.toString()),
            //     style: new TextStyle(color: Colors.white, fontSize: 20.0),
            //   ),
            //   color: Colors.red,
            //   padding: const EdgeInsets.all(20.0),
            //   onPressed: resetGame,
            // )
          ],
        ));
  }
}

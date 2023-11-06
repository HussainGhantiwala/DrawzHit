// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribble/home.dart';
import 'package:skribble/models/my_custom_painter.dart';
import 'package:skribble/models/touch_point.dart';
import 'package:skribble/waiting_lobby.dart';
import 'package:skribble/widget/final_screen_leaderboard.dart';
import 'package:skribble/widget/player_score_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenForm;
  PaintScreen({required this.data, required this.screenForm});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.white;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text(
        '_',
        style: TextStyle(fontSize: 30, color: Colors.white),
      ));
    }
  }

  //socket.io client connection
  void connect() {
    _socket = IO.io('http://192.168.29.184:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();
    if (widget.screenForm == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print("Connected!!");
      _socket.on('updateRoom', (roomData) {
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });
      _socket.on(
          'notCorrectGame',
          (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false));
      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        }
      });
      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });
      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextInputReadOnly = false;
                  guessedUserCtr = 0;
                  points.clear();
                  _start = 60;
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                backgroundColor: Colors.black,
                title: Center(
                  child: Text(
                    'Word was $oldWord',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            });
      });
      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });
      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString()
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
            setState(() {
              _timer.cancel();
              isShowFinalLeaderboard = true;
            });
          }
        }
      });
      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });
      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
      _socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });
      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextInputReadOnly = true;
        });
      });
      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString()
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    //select color
    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  'Choose Color',
                  style: TextStyle(color: Colors.white),
                ),
                content: SingleChildScrollView(
                    child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          String colorString = color.toString();
                          String valueString =
                              colorString.split('(0x')[1].split(')')[0];
                          print(colorString);
                          print(valueString);
                          Map map = {
                            'color': valueString,
                            'roomName': dataOfRoom['name']
                          };
                          _socket.emit('color-change', map);
                        })),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'))
                ],
              ));
    }

    return Scaffold(
      drawer: PlayerScore(scoreboard),
      key: scaffoldKey,
      // ignore: unnecessary_null_comparison
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
              ? !isShowFinalLeaderboard
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(8.4, 10.4),
                                      blurRadius: 0)
                                ], borderRadius: BorderRadius.circular(20.0)),
                                width: width,
                                height: height * 0.55,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    print(details.localPosition.dx);
                                    _socket.emit('paint', {
                                      'details': {
                                        'dx': details.localPosition.dx,
                                        'dy': details.globalPosition.dy,
                                      },
                                      'roomName': widget.data['name']
                                    });
                                  },
                                  onPanStart: (details) {
                                    print(details.localPosition.dx);
                                    _socket.emit('paint', {
                                      'details': {
                                        'dx': details.localPosition.dx,
                                        'dy': details.globalPosition.dy,
                                      },
                                      'roomName': widget.data['name']
                                    });
                                  },
                                  onPanEnd: (details) {
                                    print(details);
                                    _socket.emit('paint', {
                                      'details': null,
                                      'roomName': widget.data['name']
                                    });
                                  },
                                  child: SizedBox.expand(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          size: Size.infinite,
                                          painter: MyCustomPainter(
                                              pointsList: points),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(children: [
                                IconButton(
                                    onPressed: () {
                                      selectColor();
                                    },
                                    icon: Icon(
                                      Icons.color_lens,
                                      color: selectedColor,
                                    )),
                                Expanded(
                                  child: Slider(
                                      min: 1.0,
                                      max: 10,
                                      label: "Strokewidth $strokeWidth",
                                      activeColor: selectedColor,
                                      value: strokeWidth,
                                      onChanged: (double value) {
                                        Map map = {
                                          'value': value,
                                          'roomName': dataOfRoom['name']
                                        };
                                        _socket.emit('stroke-width', map);
                                      }),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _socket.emit(
                                        'clean-screen', dataOfRoom['name']);
                                  },
                                  icon: const Icon(Icons.layers_clear),
                                  color: selectedColor,
                                )
                              ]),
                              dataOfRoom['turn']['nickname'] !=
                                      widget.data['nickname']
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: textBlankWidget,
                                    )
                                  : Center(
                                      child: Text(
                                        dataOfRoom['word'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30),
                                      ),
                                    ),

                              //displaying messeges
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        var msg = messages[index].values;
                                        print(msg);
                                        return ListTile(
                                          title: Text(
                                            msg.elementAt(0),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            msg.elementAt(1),
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 16),
                                          ),
                                        );
                                      })),
                            ],
                          ),
                        ),
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(6.4, 6.4),
                                        blurRadius: 0)
                                  ], borderRadius: BorderRadius.circular(10.0)),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    readOnly: isTextInputReadOnly,
                                    style: const TextStyle(color: Colors.white),
                                    controller: controller,
                                    onSubmitted: (value) {
                                      if (value.trim().isNotEmpty) {
                                        Map map = {
                                          'username': widget.data['nickname'],
                                          'msg': value.trim(),
                                          'word': dataOfRoom['word'],
                                          'roomName': widget.data['name'],
                                          'guessedUserCtr': guessedUserCtr,
                                          'totalTime': 60,
                                          'timeTaken': 60 - _start,
                                        };
                                        _socket.emit('msg', map);
                                        controller.clear();
                                      }
                                    },
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                            )),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                        filled: true,
                                        fillColor: Colors.grey[700],
                                        hintText: 'Your guess',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ))
                            : Container(),
                        SafeArea(
                          child: IconButton(
                            onPressed: () =>
                                scaffoldKey.currentState!.openDrawer(),
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : FinalLeaderBoard(scoreboard, winner)
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
              color: Colors.black, offset: Offset(5.4, 5.4), blurRadius: 0)
        ], borderRadius: BorderRadius.circular(15.0)),
        margin: EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Color(0xFF333333),
          child: Text(
            '$_start',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
    );
  }
}

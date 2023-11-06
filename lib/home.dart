// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:skribble/join_screen.dart';
import 'package:skribble/room_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create/Join a room",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Colors.blueGrey,
                      offset: Offset(6.4, 6.4),
                      blurRadius: 0)
                ], borderRadius: BorderRadius.circular(10.0)),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 2.5, 50),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RoomScreen())),
                    child: Text(
                      "Create",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )),
              ),
              Container(
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Colors.blueGrey,
                      offset: Offset(6.4, 6.4),
                      blurRadius: 0)
                ], borderRadius: BorderRadius.circular(10.0)),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 2.5, 50),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => JoinRoomScreen())),
                    child: Text(
                      "Join",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingLobbyScreen extends StatefulWidget {
  final int occupancy;
  final int noOfPlayers;
  final String lobbyName;
  final players;
  const WaitingLobbyScreen({
    super.key,
    required this.occupancy,
    required this.noOfPlayers,
    required this.lobbyName,
    required this.players,
  });

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Waiting for ${widget.occupancy - widget.noOfPlayers} players to Join',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(6.4, 6.4), blurRadius: 0)
            ], borderRadius: BorderRadius.circular(10.0)),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              readOnly: true,
              onTap: () {
                //copy room code
                Clipboard.setData(ClipboardData(text: widget.lobbyName));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  'Copied',
                  style: TextStyle(color: Colors.white),
                )));
              },
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      )),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: Colors.grey[700],
                  hintText: 'Tap to copy room name!',
                  hintStyle: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  )),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Text(
            'Players :',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          ListView.builder(
              primary: true,
              shrinkWrap: true,
              itemCount: widget.noOfPlayers,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    widget.players[index]['nickname'],
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  leading: Text(
                    '${index + 1}.',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                );
              })
        ],
      ),
    );
  }
}

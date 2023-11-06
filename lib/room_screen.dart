// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:skribble/paint_screen.dart';
import 'package:skribble/widget/custom_text_feild.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundValue;
  late String? _roomSizeValue;
  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _maxRoundValue!,
        "maxRounds": _roomSizeValue!
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenForm: 'createRoom')));
    }
  }

  @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _maxRoundValue;
  //   _roomSizeValue;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create Room",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _nameController,
              hintText: "Enter your name",
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _roomNameController,
              hintText: "Enter Room name",
            ),
          ),
          SizedBox(
            height: 20,
          ),
          DropdownButton<String>(
            borderRadius: BorderRadius.circular(8),
            focusColor: Colors.grey[700],
            onChanged: (String? value) {
              setState(() {
                _maxRoundValue = value;
              });
            },
            items: <String>["2", "5", "10", "15"]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        )))
                .toList(),
            hint: Text("Max No of Rounds",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            height: 20,
          ),
          DropdownButton<String>(
            borderRadius: BorderRadius.circular(8),
            focusColor: Colors.grey[700],
            onChanged: (String? value) {
              setState(() {
                _roomSizeValue = value;
              });
            },
            items: <String>[
              "2",
              "3",
              "4",
              "5",
              "6",
              "7",
              "8",
              "9",
              "10",
              "11",
              "12"
            ]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        )))
                .toList(),
            hint: Text("Max No of Players",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  color: Colors.black, offset: Offset(6.4, 6.4), blurRadius: 0)
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
                onPressed: () {
                  createRoom();
                },
                child: Text(
                  "Create",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                )),
          )
        ],
      ),
    );
  }
}

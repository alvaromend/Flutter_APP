import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import './AnswerCall.dart';

//Simulates a fake call when pressing the button.
//We tried to make it as real as possible

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

//Library AudioPlayers used to manage to ringtone

class _CallScreenState extends State<CallScreen> {
  AudioPlayer player = AudioPlayer();
  String audioasset = "assets/audio/iphone.mp3";

  //because the reproduction method must start with the new screen
  //but the initState() function can not be async, we define another function
  //calling it from the init
  @override
  void initState() {
    super.initState();
    _play();
  }

  //Alvaro has taken care of the reproduction of the ringing tone
  void _play() async {
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await player.playBytes(soundbytes);
  }

  //The design of the layout and connecting the different screens has been done by 
  //Guillermo Rodriguez
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 40),
              Text(
                'Miriam Pulido', //Reference to a friend of ours
                style: TextStyle(
                  fontSize: 35.00,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '+34 687 456 871',
                style: TextStyle(
                  fontSize: 14.00,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 90,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //We implement the 2 call buttons in order to simulate a real call
              //each one offers functionality to the app
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        player.stop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AnswerCall()),
                        );
                      },
                      icon: const Icon(Icons.call)),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        player.stop();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.call_end)),
                )
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}

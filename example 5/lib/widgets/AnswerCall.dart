import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/formatTime.dart';

//In case the fake call is "answered", the app simulates another screen similar
//to the call screens used by apple/android

class AnswerCall extends StatefulWidget {
  const AnswerCall({Key? key}) : super(key: key);

  @override
  State<AnswerCall> createState() => _AnswerCallState();
}

class _AnswerCallState extends State<AnswerCall> {
  //The timer has been implemented by Guillermo Rodriguez
  //For credibility purposes, a stopwatch is included like in the real calls
  final stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    stopwatch.start();
    _timer = new Timer.periodic(new Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
                'Miriam Pulido',
                style: TextStyle(
                  fontSize: 35.00,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatTime(stopwatch.elapsedMilliseconds),
                style: TextStyle(
                  fontSize: 22.00,
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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
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
  }
}

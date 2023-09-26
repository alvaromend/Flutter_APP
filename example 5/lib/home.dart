import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import './widgets/CallScreen.dart';

//Homescreen of the App. It simulates to be an App designed to provided status about the eSense data (which it also does).
//The connection with the device and the subscription of events are also coded here based on the esense_flutter library documentation
//The part of the code dealing with eSense connections has been done by Guillermo Rodriguez

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
  bool call = false;
  bool connected = false;
  final Uri _url = Uri.parse('https://www.esense.io/');
  bool toppage = false;
  static const String eSenseDeviceName = 'eSense-0170';
  ESenseManager eSenseManager = ESenseManager(eSenseDeviceName);

  //Functionality added to the app in order to give more credibility
  //This functionality has been done by Alvaro
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  void initState() {
    super.initState();
    _listenToESense();
    subscription?.resume();
  }

  Future<void> _askForPermissions() async {
    if (!(await Permission.bluetooth.request().isGranted)) {
      print(
          'WARNING - no permission to use Bluetooth granted. Cannot access eSense device.');
    }
    if (!(await Permission.locationWhenInUse.request().isGranted)) {
      print(
          'WARNING - no permission to access location granted. Cannot access eSense device.');
    }
  }

  //Connection conventions based on: https://pub.dev/packages/esense_flutter
  Future<void> _listenToESense() async {
    if (Platform.isAndroid) await _askForPermissions();
    eSenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      if (event.type == ConnectionType.connected) _listenToESenseEvents();
      setState(() {
        connected = false;
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            connected = true;
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  Future<void> _connectToESense() async {
    if (!connected) {
      print('connecting...');
      connected = await eSenseManager.connect();
      setState(() {
        _deviceStatus = connected ? 'connecting...' : 'connection failed';
      });
    }
  }

  void _listenToESenseEvents() async {
    eSenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');
      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName ?? 'Unknown';
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage ?? -1;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            if (_button == 'pressed') {
              call = true;
            }
            ;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) async =>
          (connected) ? await eSenseManager.getBatteryVoltage() : null,
    );
    Timer(const Duration(seconds: 2),
        () async => await eSenseManager.getDeviceName());
    Timer(const Duration(seconds: 3),
        () async => await eSenseManager.getAccelerometerOffset());
    Timer(
        const Duration(seconds: 4),
        () async =>
            await eSenseManager.getAdvertisementAndConnectionInterval());
    Timer(const Duration(seconds: 5),
        () async => await eSenseManager.getSensorConfig());
  }

  StreamSubscription? subscription;
  void _startListenToSensorEvents() async {
    print('setting sampling frequency...');
    await eSenseManager.setSamplingRate(10);
    subscription = eSenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
        _event = event.toString();
        _event.replaceAll(',', '\n');
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  void dispose() {
    _pauseListenToSensorEvents();
    eSenseManager.disconnect();
    super.dispose();
  }

  // This layout has been designed by Alvaro Mendez
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('eSense'),
          actions: [
            IconButton(
                tooltip: 'Official eSense Website',
                onPressed: _launchUrl,
                icon: const Icon(Icons.info))
          ],
        ),
        body: Builder(builder: (context) {
          //This builder method and implementation of reacting to the input
          //has been done by Guillermo Rodriguez
          //Studies wether the button has been pressed. Resets values in
          //order to keep working on consecutive times
          if (call) {
            subscription?.pause();
            call = false;
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CallScreen()),
              );
            });
          }
          ;
          return Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'eSense Device Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_deviceStatus'),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'eSense Device Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_deviceName'),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'eSense Battery Level:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_voltage'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'eSense Button Event: \t$_button',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_button'),
                  ],
                ),
                const Text(''),
                Text(_event),
                Container(
                  height: 80,
                  width: 300,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: TextButton.icon(
                    onPressed: _connectToESense,
                    icon: connected
                        ? const Icon(Icons.done)
                        : const Icon(Icons.login),
                    label: connected
                        ? const Text('DEVICE WORKS CORRECTLY')
                        : const Text(
                            'CONNECT...',
                            style: TextStyle(fontSize: 35),
                          ),
                  ),
                ),
                SizedBox(height: 40)
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          // starts/stops listening to sensor events, disabled until we're connected to the device.
          onPressed: (!eSenseManager.connected)
              ? null
              : (!sampling)
                  ? _startListenToSensorEvents
                  : _pauseListenToSensorEvents,
          tooltip: 'Listen to eSense sensors',
          child: (!sampling)
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
        ),
      ),
    );
  }
}

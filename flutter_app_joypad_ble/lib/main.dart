import 'dart:async';
import 'dart:convert' show utf8;

import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'loader.dart';

Color insightOrange = Color(0xffeb6011);
bool scanFlag = false;

Future<void> main() async {
  runApp(MainScreen());
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insight BLE',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return JoyPad();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: insightOrange,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class JoyPad extends StatefulWidget {
  @override
  _JoyPadState createState() => _JoyPadState();
}

class _JoyPadState extends State<JoyPad> {
  @override
  void initState() {
    connectionText = "Start Scanning";
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  final String TARGET_DEVICE_NAME = "CIRCU";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  startScan() {
    print("starting scan...");
    if (!scanFlag) {
      Loader();
      scanFlag = true;
      scanSubScription =
          flutterBlue.scan(timeout: Duration(seconds: 2)).listen((scanResult) {
        print("scanning");
        connectionText = "scanning";
        if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
          print('DEVICE found');
          targetDevice = scanResult.device;
          connectToDevice();
          stopScan();
          setState(() {
            connectionText = "connecting";
          });
        }
      }, onDone: () {
        setState(() {
          connectionText = "none found";
        });
        print("stopping scan");
        stopScan();
        scanFlag = false;
      });
    }
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "connecting";
    });

    await targetDevice.connect();
/*
        .connect(timeout: Duration(seconds: 1), autoConnect: true)
        .catchError(() {
          print("YO WE TIMED OUT DAWG FIX THIS!!!!!!!!!!!!!!!");
          setState(() {
            connectionText = "timedout";
          });
    });*/

    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            setState(() {
              connectionText = "Ready";
            });
          }
        });
      }
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;
    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback onDirectionChanged(
        double degrees, double distance) {
      String data = "";
      print(
          "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}");
      if (((degrees < 90) || (degrees > 270)) && (distance > 0.5)) {
        data = "h";
        writeData(data);
      } else if (((degrees < 270) || (degrees < 90)) && (distance > 0.5)) {
        data = "l";
        writeData(data);
      } else {
        data = "x";
        writeData(data);
      }
    }

    PadButtonPressedCallback padBUttonPressedCallback(
        int buttonIndex, Gestures gesture) {
      //String data = "buttonIndex : ${buttonIndex}";
      String data = "";
      if (buttonIndex == 3) {
        data = "f";
        setState(() {
          connectionText = "Moving Forward";
        });
      } else if (buttonIndex == 1) {
        data = "r";
        setState(() {
          connectionText = "Moving Backward";
        });
      } else if (buttonIndex == 2) {
        data = "d";
        setState(() {
          connectionText = "Stopping";
        });
      } else if (buttonIndex == 0) {
        data = "u";
        setState(() {
          connectionText = "Starting";
        });
      }
      print(data);
      writeData(data);
    }

    if ((connectionText == "scanning") ||
        (connectionText == "connecting") ||
        (connectionText == "connected")) {
      return Loader();
    } else if (connectionText == "none found") {
      Fluttertoast.showToast(
          msg: "Try power cycling bluetooth",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: insightOrange,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
            child: Image.asset('assets/images/white_logo.png'),
            height: 40.0,
            width: 105.0,
          ),
        ]),
      ),
      body: Container(
        child: targetCharacteristic == null
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/images/illustration.png'),
                    width: 120.0,
                    height: 120.0,
                  ),
                  RaisedButton(
                    onPressed: () {
                      startScan();
                    },
                    child: Text("Start Scanning"),
                  ),
                ],
              ))
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  JoystickView(
                    onDirectionChanged: onDirectionChanged,
                    interval: Duration(seconds: 1),
                  ),
                  PadButtonsView(
                    padButtonPressedCallback: padBUttonPressedCallback,
                  ),
                ],
              ),
      ),
    );
  }
}

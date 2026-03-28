////////// filename: app.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class App extends StatefulWidget {
  App({super.key});
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool bleConnected = false;
  late BluetoothCharacteristic bleTx;

  Future<void> connect() async {
    final BluetoothDevice bleDevice = BluetoothDevice.fromId(
      "28:CD:C1:08:28:9C",
    );
    late BluetoothService bleService;
    await bleDevice.connect(license: License.free);
    List<BluetoothService> services = await bleDevice.discoverServices();
    services.forEach((s) {
      if (s.serviceUuid.toString() == "ff10") bleService = s;
    });
    for (BluetoothCharacteristic c in bleService.characteristics) {
      if (c.characteristicUuid.toString() == "ff11") {
        bleTx = c;
        setState(() {
          bleConnected = true;
        });
      }
    }
  }

  void send(val) async {
    List<int> data = utf8.encode(val);
    await bleTx.write(data);
  }

  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      body: Column(
        spacing: 50,
        children: [
          SizedBox(height: 50),
          Text('press ble connect'),
          ElevatedButton(child: Text('ble connect'), onPressed: connect),
          Visibility(
            visible: bleConnected,
            child: Column(
              spacing: 50,
              children: [
                ElevatedButton(
                  child: Text('send on'),
                  onPressed: () => send('on '),
                ),
                ElevatedButton(
                  child: Text('send off'),
                  onPressed: () => send('off'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

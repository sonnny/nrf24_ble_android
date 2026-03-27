//filename: app.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'dart:convert';

class App extends StatelessWidget {
  var status = 'connect'.obs;
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
      if (c.characteristicUuid.toString() == "ff11") bleTx = c;
      status.value = 'ready';
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
          Text('press ble connect'),
          ElevatedButton(child: Text('ble connect'), onPressed: connect),
          Obx(
            () => status.value == 'ready'
                ? Text('connected!')
                : CircularProgressIndicator(),
          ),
          ElevatedButton(child: Text('send on'), onPressed: () => send('on')),
          ElevatedButton(child: Text('send off'), onPressed: () => send('off')),
        ],
      ),
    );
  }
}

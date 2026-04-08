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
  double _value = 0.0;
  bool direction = false;

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
          ElevatedButton(child: Text('ble connect'), onPressed: connect),
          Visibility(
            visible: bleConnected,
            child: Column(
              spacing: 50,
              children: [
                Row(
                  children: [
                    Text(
                      'throttle:',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                    // SizedBox(width: 5),
                    Expanded(
                      child: Slider(
                        value: _value,
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        label: _value.round().toString(),
                        onChanged: (double d) {
                          setState(() {
                            _value = d;
                          });
                        },
                        onChangeEnd: (double newValue) {
                          setState(() {
                            _value = newValue;
                            print('T ' + newValue.round().toString());
                            send('TT ' + newValue.round().toString());
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SwitchListTile(
                  value: direction,
                  title: Text('Direction'),
                  subtitle: Text('forward or reverse'),
                  onChanged: (bool value) {
                    setState(() {
                      direction = !direction;
                      send('DD ' + direction.toString());
                      // if (direction)
                      //   send('FFORWARD1111111');
                      // else
                      //  send('RREVERSE22222222');
                      // send('D ' + direction.toString());
                    });
                  },
                ),

                ElevatedButton(
                  child: Text('send on'),
                  onPressed: () => send('0012345678901234'),
                ),

                ElevatedButton(
                  child: Text('send off'),
                  onPressed: () => send('aabcdefghijklmno'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

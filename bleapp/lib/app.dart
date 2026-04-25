////////// filename: app.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

// label for steering row buttons
const List<Widget> steering_dir = <Widget>[
  Text(' << '),
  Text('left'),
  Text('center'),
  Text('right'),
  Text(' >> '),
];

class App extends StatefulWidget {
  App({super.key});
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool bleConnected = false;
  late BluetoothCharacteristic bleTx;
  double _value = 0.0;
  bool direction = true;
  bool lightsOn1 = false;
  bool lightsOn2 = false;
  List<bool> _selectedSteering = <bool>[false, false, true, false, false];

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
      floatingActionButton: FloatingActionButton(
        onPressed: connect,
        // backgroundColor: bleConnected ? Colors.blue : Colors.red,
        child: Icon(
          Icons.bluetooth,
          size: 30.0,
          color: bleConnected ? Colors.blue : Colors.red,
        ),
      ),
      body: Column(
        spacing: 35,
        children: [
          SizedBox(height: 50),
          Visibility(
            visible: bleConnected,
            child: Column(
              spacing: 50,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Text(
                        'Throttle:',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),

                      Expanded(
                        child: Slider(
                          value: _value,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: _value.round().toString(),
                          onChanged: (double d) {
                            setState(() {
                              _value = d;
                            });
                          },
                          onChangeEnd: (double newValue) {
                            setState(() {
                              _value = newValue;
                              send('TT ' + newValue.round().toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SwitchListTile(
                  value: direction,
                  title: Text(
                    'Direction',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  subtitle: Text('forward or reverse'),
                  onChanged: (bool value) {
                    setState(() {
                      direction = !direction;
                      send('DD ' + direction.toString());
                    });
                  },
                ),
                Center(
                  child: Text(
                    'Steering',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                // single choice horizontal toggle buttons
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    send('SS ' + index.toString());
                    setState(() {
                      for (int i = 0; i < _selectedSteering.length; i++) {
                        _selectedSteering[i] = i == index;
                      }
                    });
                  },
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Colors.red[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.red[200],
                  color: Colors.red[400],
                  constraints: BoxConstraints(minHeight: 40.0, minWidth: 60.0),
                  isSelected: _selectedSteering,
                  children: steering_dir,
                ),

                Row(
                  children: [
                    IconButton(
                      color: lightsOn1 ? Colors.red : Colors.green,
                      iconSize: 50,
                      icon: Icon(Icons.lightbulb),
                      onPressed: () {
                        setState(() {
                          lightsOn1 = !lightsOn1;
                          send('L1 ' + lightsOn1.toString());
                        });
                      },
                    ),

                    IconButton(
                      color: lightsOn2 ? Colors.red : Colors.green,
                      iconSize: 50,
                      icon: Icon(Icons.emoji_objects),
                      onPressed: () {
                        setState(() {
                          lightsOn2 = !lightsOn2;
                          String str = lightsOn2.toString();
                          send("L2 $str");
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

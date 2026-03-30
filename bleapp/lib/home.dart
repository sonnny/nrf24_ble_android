////////// filename: home.dart
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      body: Center(
        child: Text('''

        make sure bluetooth is on
        make sure on setting give this app
            location permission
        see plugin flutter_blue_plus on what to
           add to AndroidManifest.xml

      data sent to nrf24l01 receiver
        T 0 - 100  (T = throttle)

        D false/true (D = direction)
        
      '''),
      ),
    );
  }
}

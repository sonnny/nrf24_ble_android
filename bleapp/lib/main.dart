////////// filename: main.dart
import 'package:flutter/material.dart';
import './bottom_nav.dart';
import './home.dart';
import './app.dart';
import './source.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});
  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int page = 0;

  @override
  Widget build(BuildContext bc) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bottom nav demo',
      home: Scaffold(
        body: [Home(), App(), Source()][page],

        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (int i) {
            setState(() {
              page = i;
            });
          },
          destinations: bottom_nav,
        ),
      ),
    );
  }
}

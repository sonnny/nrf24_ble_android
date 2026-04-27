////////// filename: main.dart
import 'package:flutter/material.dart';
import './home.dart';
import './app.dart';
import './source.dart';

void main() {
  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  MainApp({super.key});
  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeep demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.bluetooth)),
            Tab(icon: Icon(Icons.note)),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(child: Text('cloudy')),
          App(),
          Center(child: Text('sunny')),
        ],
      ),
    );
  }
}

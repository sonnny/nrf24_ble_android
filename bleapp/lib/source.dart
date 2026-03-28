////////// filename: source.dart
import 'package:flutter/material.dart';

class Source extends StatelessWidget {
  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Text('''
source code here
asldkf
asdfjkl
        
      '''),
        ),
      ),
    );
  }
}

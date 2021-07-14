import 'package:flutter/material.dart';
import 'contactListWithDeleteScreen.dart';


void main() {
  runApp(FirstScreen());
}

class FirstScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task-003',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: DataFromAPI(),
    );
  }
}


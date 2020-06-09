import 'package:flutter/material.dart';
import 'package:flutter_moment/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'moment',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: new Home());
  }
}

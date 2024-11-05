import 'package:bluetooth_connect/Screens/Home%20screens/home6.dart';
import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home6(),
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      
    );
  }
}


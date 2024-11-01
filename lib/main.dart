import 'package:bluetooth_connect/Screens/Home%20screens/home2.dart';
import 'package:bluetooth_connect/Screens/Home%20screens/home3.dart';
import 'package:bluetooth_connect/Screens/Home%20screens/home4.dart';
import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';

import 'Screens/Home screens/home5.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home5(),
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      
    );
  }
}


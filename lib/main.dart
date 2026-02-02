import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'utils/http_override.dart';


void main() {
  
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}


//ผมรักจรูญ
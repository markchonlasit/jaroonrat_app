import 'dart:io';
import 'package:flutter/material.dart';
import '---login---/login.dart';
import 'utils/http_override.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



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

      /// ✅ กำหนดภาษาไทย
      locale: Locale('th'),

      supportedLocales: [
        Locale('th'),
        Locale('en'),
      ],

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: LoginPage(),
    );
  }
}

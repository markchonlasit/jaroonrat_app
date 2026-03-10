import 'dart:io';
import 'package:flutter/material.dart';
import '---login---/login.dart';
import 'utils/http_override.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(); // 👈 เพิ่มบรรทัดนี้

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('th_TH', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 เพิ่มตรงนี้
      debugShowCheckedModeBanner: false,

      locale: const Locale('th', 'TH'),

      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: LoginPage(),
    );
  }
}

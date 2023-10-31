import 'dart:io';

import 'package:attendancesystem/scanner-page.dart';
import 'package:flutter/material.dart';
import 'package:attendancesystem/login-form.dart';
import 'package:attendancesystem/home.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {'/home-page': (context) => const Home()},
    );
  }
}

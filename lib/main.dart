import 'package:flutter/material.dart';
import 'sensors_page.dart';

void main() {
  runApp(const SensorsApp());
}

class SensorsApp extends StatelessWidget {
  const SensorsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sensors Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SensorsPage(),
    );
  }
}
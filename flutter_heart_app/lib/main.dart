import 'package:flutter/material.dart';
import 'package:flutter_heart_app/screen/login_sreen.dart';
import 'package:flutter_heart_app/screen/xray_analysis_page.dart';
import 'package:flutter_heart_app/screen/home_screen.dart';
import 'prediction_page.dart';
import 'patient_dashboard.dart';
import 'services/mqtt_test_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Prediction',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,

      home: const HomeScreen(), // استدعاء الصفحة الجديدة
    );
  }
}

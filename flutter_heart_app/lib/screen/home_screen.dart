import 'package:flutter/material.dart';
import 'xray_analysis_page.dart';
import 'package:flutter_heart_app/patient_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const XRayAnalysisPage(),
    const PatientDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'X-Ray'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Heart Disease',
          ),
        ],
      ),
    );
  }
}

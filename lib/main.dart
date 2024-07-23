import 'package:flutter/material.dart';
import 'package:otaku_tracker/pages/landing/LandingPage.dart';

void main() {
  runApp(const OtakuTrackerApp());
}

class OtakuTrackerApp extends StatelessWidget {
  const OtakuTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otaku Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

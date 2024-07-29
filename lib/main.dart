import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/pages/landing/landing_page.dart';

void main() {
  runApp(const ProviderScope(
    child: OtakuTrackerApp(),
  ));
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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: LandingPage(),
    );
  }
}

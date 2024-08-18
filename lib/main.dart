import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/pages/landing_page.dart';
import 'package:otaku_tracker/pages/my_list_page.dart';
import 'package:otaku_tracker/pages/seasonal_page.dart';
import 'package:otaku_tracker/providers/navigation_index_provider.dart';
import 'package:otaku_tracker/widgets/global_navigation_bar.dart';

void main() {
  runApp(const ProviderScope(
    child: ProviderScope(child: OtakuTrackerApp()),
  ));
}

final routes = {
  '/seasonal': (context) => SeasonalPage(),
  '/my-list': (context) => MyListPage()
};

class OtakuTrackerApp extends StatelessWidget {
  const OtakuTrackerApp({super.key});

  // TODO: Implement Global Search bar using showSearch: https://stackoverflow.com/questions/74380428/searchbar-that-expands-to-the-whole-screen-in-flutter
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otaku Tracker',
      initialRoute: '/',
      routes: routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: NavigationContainer(),
      ),
    );
  }
}

class NavigationContainer extends ConsumerWidget {
  const NavigationContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const GlobalNavigationBar(),
      body: <Widget>[
        LandingPage(),
        SeasonalPage(),
        MyListPage()
      ][ref.watch(navigationIndexProvider)],
    );
  }
}

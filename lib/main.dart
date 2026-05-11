import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/pages/home/landing_page.dart';
import 'package:otaku_tracker/pages/my_list/my_list_page.dart';
import 'package:otaku_tracker/pages/seasonal/seasonal_page.dart';
import 'package:otaku_tracker/providers/navigation/gorouter_provider.dart';
import 'package:otaku_tracker/providers/navigation/navigation_index_provider.dart';
import 'package:otaku_tracker/services/navigation/deeplink_service.dart';
import 'package:otaku_tracker/widgets/shared/app/global_navigation_bar.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics
      .instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
        error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(
    child: ProviderScope(child: OtakuTrackerApp()),
  ));

  // Initialize deep linking
  final deepLinkService = DeepLinkService();
  deepLinkService.init();
}

class OtakuTrackerApp extends ConsumerWidget {
  const OtakuTrackerApp({super.key});

  // TODO: Implement Global Search bar using showSearch: https://stackoverflow.com/questions/74380428/searchbar-that-expands-to-the-whole-screen-in-flutter
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Otaku Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
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

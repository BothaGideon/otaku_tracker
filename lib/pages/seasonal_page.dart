import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_index_provider.dart';

class SeasonalPage extends ConsumerWidget {
  const SeasonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
        appBar: AppBar(title: Text('Seasonal Page')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            child: Text('Go to Home Page'),
          ),
        ));
  }
}

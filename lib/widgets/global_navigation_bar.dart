import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/navigation_index_provider.dart';

class GlobalNavigationBar extends ConsumerWidget {
  const GlobalNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        ref.read(navigationIndexProvider.notifier).state = index;
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.energy_savings_leaf_outlined),
          label: 'Seasonal',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_border),
          label: 'Saved',
        ),
      ],
    );
  }
}

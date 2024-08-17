import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
          icon: Icon(Symbols.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Symbols.nest_eco_leaf),
          label: 'Seasonal',
        ),
        NavigationDestination(
          icon: Icon(Symbols.bookmark_add),
          label: 'My list',
        ),
      ],
    );
  }
}

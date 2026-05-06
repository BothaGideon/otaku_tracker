import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/pages/my_profile_page.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_search_delegate.dart';

class OtakuTrackerAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final Widget title;
  final bool showProfileAction;
  final bool showSearchAction;

  const OtakuTrackerAppBar({
    super.key,
    required this.title,
    this.showProfileAction = true,
    this.showSearchAction = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);
    final userData = userDataAsync.valueOrNull;
    final isLoggedIn = userData?['username'] != null;

    return AppBar(
      title: title,
      actions: [
        if (showSearchAction)
          IconButton(
            tooltip: 'Search anime',
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OtakuTrackerSearchDelegate(),
              );
            },
          ),
        if (showProfileAction && isLoggedIn)
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Symbols.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyProfilePage(),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

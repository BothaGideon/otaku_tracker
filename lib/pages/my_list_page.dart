import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';

import '../providers/navigation_index_provider.dart';

class MyListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final oauthService = ref.read(oauthProvider);
    String? username;

    return Scaffold(
        appBar: AppBar(title: Text('My List Page')),
        body: ElevatedButton(
          onPressed: () async {
            username = await oauthService.login();

            if (username != null) {
              // Navigate to the home page or another appropriate screen
              context.go('/callback');
            } else {
              Fluttertoast.showToast(
                msg: "Login failed",
                backgroundColor: Colors.red,
              );
            }
          },
          child: Text(username ?? 'Login with MyAnimeList'),
        ));
  }
}

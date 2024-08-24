import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/services/oauth_service.dart';

import '../providers/navigation_index_provider.dart';

class MyListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    String? username;

    return Scaffold(
        appBar: AppBar(title: Text('My List Page')),
        body: ElevatedButton(
          onPressed: () async {
            username = await OauthService().login();
          },
          child: Text(username ?? 'Try again'),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';

import '../providers/navigation_index_provider.dart';

class MyListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
        appBar: AppBar(title: Text('My List Page')),
        body: LoadingErrorState(
          onRetry: () {
            print('Yay!');
          },
        ));
  }
}

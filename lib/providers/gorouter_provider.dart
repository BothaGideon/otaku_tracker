import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_tracker/main.dart';
import 'package:otaku_tracker/pages/my_list_page.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NavigationContainer(),
      ),
      GoRoute(
        path: '/callback',
        builder: (context, state) => MyListPage(),
      ),
    ],
    initialLocation: '/',
    redirect: (context, state) {
      // Handle any logic you need for redirection
      return null;
    },
    errorBuilder: (context, state) => LoadingErrorState(onRetry: () {}),
  );
});

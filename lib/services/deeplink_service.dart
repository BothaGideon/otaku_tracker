import 'dart:developer';

import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void init() {
    print("Deep link service init");

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Handle the deep link
        print("Deep link received: $uri");
        final code = uri.queryParameters['code'];
        print(code);
        // Navigate to the appropriate screen based on the URI
        // Example:
        if (uri.path == '/auth') {
          // Navigate to the specific page
          // Use a navigation method, e.g., using GoRouter or Navigator
          log('boyyyyyyyy');
          // _goRouter.go('/your_target_page');
        }
      }
    });
  }
}

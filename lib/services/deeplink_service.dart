import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  static const platform = MethodChannel('com.example.otaku_tracker/deep_link');

  Function(Uri)? _onDeepLinkReceived;

  void init() {
    print("Deep link service init");

    // Handle initial deep link when app is launched
    _handleInitialLink();

    // Listen for deep links while app is running
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Listen for deep links from native Android
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink' && call.arguments is String) {
        final uri = Uri.parse(call.arguments);
        _handleDeepLink(uri);
      }
    });
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      log('Error getting initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print("Deep link received: $uri");

    // Check if this is an OAuth callback
    if (uri.scheme == 'otaku.tracker' && uri.queryParameters.containsKey('code')) {
      print("OAuth callback received with code: ${uri.queryParameters['code']}");
      // The OAuth service will handle this through FlutterWebAuth2
      return;
    }

    // Handle other deep links
    final code = uri.queryParameters['code'];
    print("Deep link code: $code");

    if (uri.path == '/auth') {
      log('Authentication deep link received');
    }

    // Notify listeners
    _onDeepLinkReceived?.call(uri);
  }

  void setDeepLinkHandler(Function(Uri) handler) {
    _onDeepLinkReceived = handler;
  }
}

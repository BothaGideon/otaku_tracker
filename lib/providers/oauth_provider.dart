import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/services/oauth_service.dart';

final oauthProvider = FutureProvider<dynamic>((ref) async {
  final response = OauthService().login();
  log('$response');
  return null;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/services/oauth_service.dart';

final oauthProvider = Provider<OauthService>((ref) {
  return OauthService();
});

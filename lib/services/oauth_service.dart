import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

const clientId = String.fromEnvironment('MALAPI');
const tokenUri = 'https://myanimelist.net/v1/oauth2/token';
const authorizeUri = 'https://myanimelist.net/v1/oauth2/authorize';
const apiBaseUrl = 'https://api.myanimelist.net/v2';

class OauthService {
  Future<String?> login() async {
    final verifier = _generateCodeVerifier();
    final loginUrl = _generateLoginUrl(verifier);

    try {
      dev.log('Starting OAuth flow with URL: $loginUrl');
      final uri = await FlutterWebAuth2.authenticate(
          url: loginUrl, callbackUrlScheme: 'otaku.tracker');
      dev.log('OAuth callback received: $uri');

      final queryParams = Uri.parse(uri).queryParameters;
      final code = queryParams['code'];

      if (code == null) {
        dev.log('No authorization code in callback URI');
        return null;
      }

      dev.log('Authorization code received: $code');

      final tokenJson = await _generateTokens(verifier, code);
      final username = await _getUserName(tokenJson['access_token']);

      dev.log('Login successful for user: $username');
      tokenJson['datetime'] = DateTime.now();
      dev.log('Token data: $tokenJson');

      // TODO: Implement way to store username and tokenJson
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('username', username);

      return username;
    } catch (e) {
      dev.log("OAuth error: $e");
      return "An error occurred during OAuth: $e";
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(200, (i) => random.nextInt(256));
    return base64UrlEncode(values).substring(0, 128);
  }

  String _generateLoginUrl(String verifier) {
    return '$authorizeUri?response_type=code&client_id=$clientId&code_challenge=$verifier';
  }

  Future<Map<String, dynamic>> _generateTokens(
      String verifier, String code) async {
    final params = {
      'client_id': clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': verifier
    };
    final response = await http.post(Uri.parse(tokenUri), body: params);
    return jsonDecode(response.body);
  }

  Future<String> _getUserName(String accessToken) async {
    const url = '$apiBaseUrl/users/@me';
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $accessToken'});
    return jsonDecode(response.body)['name'];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';

import '../providers/navigation_index_provider.dart';

class MyListPage extends ConsumerStatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage> {
  String? username;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final oauthService = ref.read(oauthProvider);

    return Scaffold(
        appBar: AppBar(title: Text('My List Page')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (username != null)
                Text('Logged in as: $username')
              else
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final result = await oauthService.login();

                      if (result != null && !result.startsWith('An error occurred')) {
                        setState(() {
                          username = result;
                          isLoading = false;
                        });

                        Fluttertoast.showToast(
                          msg: "Login successful",
                          backgroundColor: Colors.green,
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });

                        Fluttertoast.showToast(
                          msg: result ?? "Login failed",
                          backgroundColor: Colors.red,
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      Fluttertoast.showToast(
                        msg: "Login failed: $e",
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Login with MyAnimeList'),
                ),
            ],
          ),
        ));
  }
}

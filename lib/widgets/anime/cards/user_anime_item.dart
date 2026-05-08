import 'package:flutter/material.dart';

/// This widget has been deprecated in favor of using [PosterImageTitle] directly.
/// PosterImageTitle now supports userStatus and userScore parameters, making it suitable
/// for both generic anime browsing and user-tracked anime display.
@Deprecated('Use PosterImageTitle instead')
class UserAnimeItem extends StatelessWidget {
  const UserAnimeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

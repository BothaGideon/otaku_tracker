import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? pictureUrl;
  final double radius;
  final double iconSize;

  const UserAvatar({
    super.key,
    this.pictureUrl,
    this.radius = 20.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedPictureUrl = pictureUrl?.trim();
    final hasPicture = trimmedPictureUrl != null && trimmedPictureUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      foregroundImage: hasPicture ? NetworkImage(trimmedPictureUrl) : null,
      onForegroundImageError: hasPicture ? (_, __) {} : null,
      child: Icon(Icons.account_circle, size: iconSize),
    );
  }
}

import 'package:flutter/cupertino.dart';

class CarouselTitleSubtitle extends StatelessWidget {
  const CarouselTitleSubtitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle!,
                style: const TextStyle(
                    fontSize: 12.0, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }
}

import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class NetworkImageSkeleton extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const NetworkImageSkeleton({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: trimmedUrl.isEmpty
            ? const SkeletonBox()
            : Stack(
                fit: StackFit.expand,
                children: [
                  const SkeletonBox(),
                  Image.network(
                    trimmedUrl,
                    width: width,
                    height: height,
                    fit: fit,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }

                      return const SizedBox.shrink();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

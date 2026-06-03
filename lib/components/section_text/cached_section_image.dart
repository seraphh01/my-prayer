import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedSectionImage extends StatelessWidget {
  const CachedSectionImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius,
    this.fallbackAsset = 'assets/images/error_image.jpg',
  });

  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            memCacheWidth: (width * 2).round(),
            memCacheHeight: (height * 2).round(),
            placeholder: (_, __) => SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Image.asset(
              fallbackAsset,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}

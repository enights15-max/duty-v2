import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A reusable widget that loads images from the network with disk + memory caching,
/// a subtle shimmer placeholder while loading, and a graceful error fallback.
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final IconData errorIcon;
  final double errorIconSize;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.errorIcon = Icons.broken_image_rounded,
    this.errorIconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: palette.surfaceAlt,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: palette.textMuted,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: palette.surfaceAlt,
            child: Center(
              child: Icon(
                errorIcon,
                color: palette.textMuted,
                size: errorIconSize,
              ),
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

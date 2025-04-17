import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';

/// Accepts an animation controller that controls left-right movement of the carousel,
/// and list of up to five image urls ordered according to their order on screen.
/// Special cases if one or two images are provided.
class ImageCarousel extends StatelessWidget {
  final AnimationController imageAnimationController;
  final List<String?> orderedImageUrls;
  final bool reverseAnimation;
  final String imageToDarkenFully;

  const ImageCarousel({
    Key? key,
    required this.imageAnimationController,
    required this.orderedImageUrls,
    required this.imageToDarkenFully,
    this.reverseAnimation = false,
  }) : super(key: key);

  int get _length => orderedImageUrls.length;

  bool _showFullImageShade(int index) =>
      imageToDarkenFully == orderedImageUrls[index] &&
      orderedImageUrls[index]?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final size = responsiveLayoutService.isMobile(context)
        ? min(MediaQuery.of(context).size.width, AppSize.kMaxCarouselSize)
        : AppSize.kMaxCarouselSize;

    switch (_length) {
      case 1:
        return _buildSingleImage(size);
      case 2:
        return _buildDoubleImage(size);
      default:
        return _buildMultipleImages(size);
    }
  }

  Widget _buildSingleImage(double size) {
    // Single item is app page description
    final image = orderedImageUrls.first;
    return _CarouselImageBox(
      size: size,
      opacity: 1,
      fullOverlay: true,
      showOverlay: orderedImageUrls.firstOrNull?.isNotEmpty == true,
      child: _CarouselCommunityImage(image),
    );
  }

  Widget _buildDoubleImage(double size) {
    // Two items are side by side, not looping
    return AnimatedBuilder(
      animation: imageAnimationController,
      builder: (context, child) {
        return Center(
          child: ClipRRect(
            child: OverflowBox(
              maxWidth: 1400,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                child: Transform.translate(
                  offset: Offset(
                    -size * imageAnimationController.value +
                        ((reverseAnimation ? -.5 : .5) * size),
                    0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CarouselImageBox(
                        opacity: reverseAnimation
                            ? .2 + (imageAnimationController.value * .8).abs()
                            : 1 - (imageAnimationController.value * .8).abs(),
                        size: size,
                        fullOverlay: _showFullImageShade(0),
                        child: _CarouselCommunityImage(orderedImageUrls[0]),
                      ),
                      _CarouselImageBox(
                        opacity: reverseAnimation
                            ? 1 - (imageAnimationController.value * .8).abs()
                            : .2 + (imageAnimationController.value * .8).abs(),
                        size: size,
                        fullOverlay: _showFullImageShade(1),
                        child: ProxiedImage(orderedImageUrls[1]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleImages(double size) {
    // More than two items, looping carousel animations
    return AnimatedBuilder(
      animation: imageAnimationController,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              child: Transform.translate(
                offset: Offset(
                  -size * imageAnimationController.value - size * 2,
                  0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CarouselImageBox(
                      opacity: .2,
                      size: size,
                      fullOverlay: _showFullImageShade(0),
                      child: _CarouselCommunityImage(orderedImageUrls[0]),
                    ),
                    _CarouselImageBox(
                      opacity: .2 -
                          (imageAnimationController.value * .8).clamp(-1, 0),
                      size: size,
                      fullOverlay: _showFullImageShade(1),
                      child: _CarouselCommunityImage(orderedImageUrls[1]),
                    ),
                    _CarouselImageBox(
                      opacity: 1 - (imageAnimationController.value * .8).abs(),
                      size: size,
                      fullOverlay: _showFullImageShade(2),
                      child: _CarouselCommunityImage(orderedImageUrls[2]),
                    ),
                    _CarouselImageBox(
                      opacity: .2 +
                          (imageAnimationController.value * .8).clamp(0, 1),
                      size: size,
                      fullOverlay: _showFullImageShade(3 % _length),
                      child: _CarouselCommunityImage(
                        orderedImageUrls[3 % _length],
                      ),
                    ),
                    _CarouselImageBox(
                      opacity: .2,
                      size: size,
                      fullOverlay: _showFullImageShade(4 % _length),
                      child: _CarouselCommunityImage(
                        orderedImageUrls[4 % _length],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CarouselImageBox extends StatelessWidget {
  final double size;
  final Widget child;
  final double opacity;
  final bool fullOverlay;
  final bool showOverlay;

  const _CarouselImageBox({
    Key? key,
    required this.size,
    required this.child,
    required this.opacity,
    this.fullOverlay = false,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: _buildImageBox(),
    );
  }

  Widget _buildImageBox() {
    final sizedImage = SizedBox(
      width: size,
      height: size,
      child: child,
    );

    if (showOverlay) {
      return _ShadedOverlay(
        height: fullOverlay ? size : 200,
        width: size,
        isGradient: !fullOverlay,
        child: sizedImage,
      );
    } else {
      return sizedImage;
    }
  }
}

class _ShadedOverlay extends StatelessWidget {
  final Widget child;
  final bool isGradient;
  final double height;
  final double width;

  const _ShadedOverlay({
    Key? key,
    required this.child,
    this.isGradient = true,
    this.height = 250,
    this.width = AppSize.kMaxCarouselSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: width),
            height: height,
            decoration: BoxDecoration(
              gradient: isGradient
                  ? LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: const [
                        AppColor.black,
                        Colors.transparent,
                      ],
                    )
                  : null,
              color: !isGradient ? Colors.black54 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselCommunityImage extends StatelessWidget {
  final String? url;

  const _CarouselCommunityImage(
    this.url, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localUrl = url;
    if (localUrl == null || localUrl.trim().isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      return ProxiedImage(localUrl);
    }
  }
}

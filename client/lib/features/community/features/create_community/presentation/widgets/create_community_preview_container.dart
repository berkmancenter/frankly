import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/community/community.dart';
import 'package:pedantic/pedantic.dart';

enum PreviewContainerField {
  name,
  tagline,
  about,
}

class PreviewContainer extends StatelessWidget {
  static const previewContainerSize = Size(335, 182);
  static const carouselContainerSize = 103.0;
  static const iconSize = 17.0;

  final Community community;
  final PreviewContainerField? fieldToEmphasize;
  final bool finalPreview;

  const PreviewContainer(
    this.community, {
    this.fieldToEmphasize,
    this.finalPreview = false,
    Key? key,
  }) : super(key: key);

  Color _containerColor(BuildContext context) => finalPreview
      ? (ThemeUtils.parseColor(community.themeLightColor) ??
          context.theme.colorScheme.surface)
      : context.theme.colorScheme.surface;

  Color _carouselColor(BuildContext context) => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ??
          context.theme.colorScheme.primary)
      : context.theme.colorScheme.onPrimaryContainer;

  Color _nameColor(BuildContext context) => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ??
          context.theme.colorScheme.primary)
      : !isNullOrEmpty(community.name)
          ? context.theme.colorScheme.primary
          : context.theme.colorScheme.onPrimaryContainer;

  Color _taglineColor(BuildContext context) => finalPreview
      ? context.theme.colorScheme.onPrimary
      : !isNullOrEmpty(community.tagLine)
          ? context.theme.colorScheme.onPrimary
          : context.theme.colorScheme.onPrimaryContainer;

  Color _aboutColor(BuildContext context) => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ??
          context.theme.colorScheme.primary)
      : !isNullOrEmpty(community.description)
          ? context.theme.colorScheme.primary
          : context.theme.colorScheme.onPrimaryContainer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: previewContainerSize.width,
      height: previewContainerSize.height,
      decoration: BoxDecoration(
        color: _containerColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  SizedBox(width: 5),
                  _checkEmphasis(
                    emphasize: fieldToEmphasize == PreviewContainerField.name,
                    child: _buildLineMock(24, color: _nameColor(context)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Container(
                height: carouselContainerSize,
                width: carouselContainerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _carouselColor(context),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    if (!isNullOrEmpty(community.bannerImageUrl)) ...[
                      ProxiedImage(
                        community.bannerImageUrl,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(
                            color:
                                context.theme.colorScheme.onPrimaryContainer),
                        SizedBox(height: 10),
                        _checkEmphasis(
                          emphasize:
                              fieldToEmphasize == PreviewContainerField.tagline,
                          child: _buildTagline(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 9),
              _checkEmphasis(
                emphasize: fieldToEmphasize == PreviewContainerField.about,
                child: _buildAbout(context),
              ),
            ],
          ),
          SizedBox(width: 12),
          Column(
            children: [
              SizedBox(height: 33),
              for (int i = 0; i < 3; i++) ...[
                if (i != 0) SizedBox(height: 7),
                Container(
                  width: carouselContainerSize,
                  height: 29,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: context.theme.colorScheme.surfaceContainerLowest,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(
          {Color color = context.theme.colorScheme.onPrimaryContainer}) =>
      !isNullOrEmpty(community.profileImageUrl)
          ? ProxiedImage(
              community.profileImageUrl,
              width: iconSize,
              height: iconSize,
              borderRadius: BorderRadius.circular(10),
            )
          : _buildCircleMock(color: color);

  Widget _buildAbout(context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineMock(50, color: _aboutColor(context)),
          SizedBox(height: 5),
          _buildLineMock(43, color: _aboutColor(context)),
          SizedBox(height: 5),
          _buildLineMock(48, color: _aboutColor(context)),
        ],
      );

  Widget _buildTagline(context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLineMock(50, color: _taglineColor(context)),
          SizedBox(height: 8),
          _buildLineMock(43, color: _taglineColor(context)),
          SizedBox(height: 8),
          _buildLineMock(48, color: _taglineColor(context)),
        ],
      );

  Widget _buildCircleMock(
          {Color color = context.theme.colorScheme.onPrimaryContainer}) =>
      Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        width: iconSize,
        height: iconSize,
      );

  Widget _buildLineMock(double width,
          {Color color = context.theme.colorScheme.onPrimaryContainer}) =>
      Container(
        width: width,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: color,
        ),
      );

  Widget _checkEmphasis({required Widget child, required bool emphasize}) {
    if (emphasize) {
      return EmphasisAnimation(
        child: child,
      );
    } else {
      return child;
    }
  }
}

class EmphasisAnimation extends StatefulWidget {
  final Widget child;

  const EmphasisAnimation({required this.child, Key? key}) : super(key: key);

  @override
  State createState() => _EmphasisAnimationState();
}

class _EmphasisAnimationState extends State<EmphasisAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
    value: 1,
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    animate();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> animate() async {
    await controller.animateTo(0, curve: Curves.easeOut);
    unawaited(controller.animateTo(1, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform.scale(
        scale: 1.20 - (controller.value * .15),
        child: Opacity(
          opacity: .75 + (controller.value * .25),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

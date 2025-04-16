import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/styles/app_styles.dart';
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

  Color get _containerColor => finalPreview
      ? (ThemeUtils.parseColor(community.themeLightColor) ?? AppColor.gray6)
      : AppColor.gray6;

  Color get _carouselColor => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ?? AppColor.darkBlue)
      : AppColor.gray4;

  Color get _nameColor => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ?? AppColor.darkBlue)
      : !isNullOrEmpty(community.name)
          ? AppColor.darkBlue
          : AppColor.gray4;

  Color get _taglineColor => finalPreview
      ? AppColor.white
      : !isNullOrEmpty(community.tagLine)
          ? AppColor.white
          : AppColor.gray3;

  Color get _aboutColor => finalPreview
      ? (ThemeUtils.parseColor(community.themeDarkColor) ?? AppColor.darkBlue)
      : !isNullOrEmpty(community.description)
          ? AppColor.darkBlue
          : AppColor.gray4;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: previewContainerSize.width,
      height: previewContainerSize.height,
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildNameAndLogo(),
              SizedBox(height: 6),
              _buildCarousel(),
              SizedBox(height: 9),
              _checkEmphasis(
                emphasize: fieldToEmphasize == PreviewContainerField.about,
                child: _buildAbout(),
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
                    color: AppColor.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndLogo() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          SizedBox(width: 5),
          _checkEmphasis(
            emphasize: fieldToEmphasize == PreviewContainerField.name,
            child: _buildLineMock(24, color: _nameColor),
          ),
        ],
      );

  Widget _buildLogo({Color color = AppColor.gray4}) =>
      !isNullOrEmpty(community.profileImageUrl)
          ? ProxiedImage(
              community.profileImageUrl,
              width: iconSize,
              height: iconSize,
              borderRadius: BorderRadius.circular(10),
            )
          : _buildCircleMock(color: color);

  Widget _buildCarousel() => Container(
        height: carouselContainerSize,
        width: carouselContainerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: _carouselColor,
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
                _buildLogo(color: AppColor.gray3),
                SizedBox(height: 10),
                _checkEmphasis(
                  emphasize: fieldToEmphasize == PreviewContainerField.tagline,
                  child: _buildTagline(),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildAbout() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineMock(50, color: _aboutColor),
          SizedBox(height: 5),
          _buildLineMock(43, color: _aboutColor),
          SizedBox(height: 5),
          _buildLineMock(48, color: _aboutColor),
        ],
      );

  Widget _buildTagline() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLineMock(50, color: _taglineColor),
          SizedBox(height: 8),
          _buildLineMock(43, color: _taglineColor),
          SizedBox(height: 8),
          _buildLineMock(48, color: _taglineColor),
        ],
      );

  Widget _buildCircleMock({Color color = AppColor.gray4}) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        width: iconSize,
        height: iconSize,
      );

  Widget _buildLineMock(double width, {Color color = AppColor.gray4}) =>
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

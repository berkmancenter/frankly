import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class ProfileChip extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final TextStyle? textStyle;
  final void Function()? onTap;
  final double? imageHeight;
  final bool showBorder;
  final bool showName;

  const ProfileChip({
    Key? key,
    this.name = '',
    this.imageUrl,
    this.onTap,
    this.imageHeight,
    this.showBorder = true,
    this.textStyle,
    this.showName = true,
  }) : super(key: key);

  Widget _buildNotFoundWidget() {
    return Container(
      alignment: Alignment.center,
      height: imageHeight ?? 80,
      width: imageHeight ?? 80,
      decoration: BoxDecoration(
        color: AppColor.darkBlue,
      ),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '',
        style: AppTextStyle.body.copyWith(color: AppColor.brightGreen),
      ),
    );
  }

  Widget _buildImageWidget() {
    final localImageUrl = imageUrl;

    final notFound = localImageUrl == null || localImageUrl.trim().isEmpty;

    return ClipOval(
      child: notFound
          ? _buildNotFoundWidget()
          : JuntoImage(
              localImageUrl,
              height: imageHeight ?? 80,
              width: imageHeight ?? 80,
            ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.white.withOpacity(0.2),
      ),
      padding: showBorder ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageAndName() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: imageHeight ?? 42,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: _buildProfileImage(),
          ),
        ),
        if (showName)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: JuntoText(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ).merge(textStyle ?? TextStyle()),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localOnTap = onTap;

    return localOnTap == null
        ? _buildImageAndName()
        : JuntoInkWell(
            onTap: localOnTap,
            hoverColor: Colors.transparent,
            child: _buildImageAndName(),
          );
  }
}

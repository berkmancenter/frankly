import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

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

  Widget _buildImageAndName() {
    final localImageUrl = imageUrl;

    final notFound = localImageUrl == null || localImageUrl.trim().isEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: imageHeight ?? 42,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white.withOpacity(0.2),
              ),
              padding: showBorder ? const EdgeInsets.all(2) : EdgeInsets.zero,
              child: ClipOval(
                child: notFound
                    ? Container(
                        alignment: Alignment.center,
                        height: imageHeight ?? 80,
                        width: imageHeight ?? 80,
                        decoration: BoxDecoration(
                          color: AppColor.darkBlue,
                        ),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '',
                          style: AppTextStyle.body
                              .copyWith(color: AppColor.brightGreen),
                        ),
                      )
                    : ProxiedImage(
                        localImageUrl,
                        height: imageHeight ?? 80,
                        width: imageHeight ?? 80,
                      ),
              ),
            ),
          ),
        ),
        if (showName)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: HeightConstrainedText(
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
        : CustomInkWell(
            onTap: localOnTap,
            hoverColor: Colors.transparent,
            child: _buildImageAndName(),
          );
  }
}

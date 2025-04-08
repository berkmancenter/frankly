import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';

/// This is an icon that appears in the top or bottom nav bar. If it is selected it shows a solid
/// indicator line below the icon. The size of the icon and spacing between it and the indicator
/// can be manually set in the case of slightly differently sized icons / images, but they are
/// intended to appear the same size and distance apart on screen. Either iconData or a local image
/// path is required.
class SelectableNavigationIcon extends StatelessWidget {
  final bool isSelected;
  final IconData? iconData;
  final AppAsset? imagePath;
  final AppAsset? selectedImagePath;
  final void Function()? onTap;
  final double iconSize;
  final double iconSpacing;

  const SelectableNavigationIcon({
    Key? key,
    required this.isSelected,
    this.iconData,
    this.imagePath,
    this.selectedImagePath,
    this.onTap,
    this.iconSize = 30.0,
    this.iconSpacing = 6.0,
  })  : assert(iconData != null || imagePath != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected) SizedBox(height: iconSpacing + 2),
        CustomInkWell(
          onTap: onTap,
          child: iconData != null
              ? Icon(
                  iconData,
                  size: iconSize,
                  color: isSelected
                      ? context.theme.colorScheme.primary
                      : AppColor.gray3,
                )
              : ProxiedImage(
                  null,
                  asset: isSelected ? selectedImagePath : imagePath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                ),
        ),
        if (isSelected) ...[
          SizedBox(height: iconSpacing.toDouble()),
          Container(
              height: 2, width: 20, color: context.theme.colorScheme.primary),
        ],
      ],
    );
  }
}

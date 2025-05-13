import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/styles/app_asset.dart';

/// Supplementary model to be passed to [AppGenericStateWidget].
class AppGenericStateData {
  final String text;
  final void Function() onTap;

  AppGenericStateData(this.text, this.onTap);
}

/// Shows reusable widget which is usually placed in the empty page.
///
///  We handle various cases, such as `empty page`, `something went wrong`,
/// `thread was deleted`, etc. For all of these, we are using this widget.
///
/// [title] and [imagePath] are mandatory.
/// [appGenericStateData] is optional.
class AppGenericStateWidget extends StatelessWidget {
  final String title;
  final AppAsset imagePath;
  final ResponsiveLayoutService responsiveLayoutService;
  final AppGenericStateData? appGenericStateData;

  const AppGenericStateWidget({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.responsiveLayoutService,
    this.appGenericStateData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localAppGenerisStateData = appGenericStateData;
    const scale = 0.5;
    final imageSize =
        responsiveLayoutService.getDynamicSize(context, 100, scale: scale);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            responsiveLayoutService.getDynamicSize(context, 100, scale: scale),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: responsiveLayoutService.getDynamicSize(
              context,
              50,
              scale: scale,
            ),
          ),
          Text(
            title,
            style: AppTextStyle.headline4
                .copyWith(color: context.theme.colorScheme.primary),
          ),
          SizedBox(height: 10),
          ProxiedImage(
            null,
            asset: imagePath,
            width: imageSize,
            height: imageSize,
          ),
          if (localAppGenerisStateData != null) ...[
            SizedBox(height: 10),
            ActionButton(
              text: localAppGenerisStateData.text,
              textColor: context.theme.colorScheme.onPrimary,
              color: context.theme.colorScheme.primary,
              onPressed: localAppGenerisStateData.onTap,
            ),
          ],
          SizedBox(
            height: responsiveLayoutService.getDynamicSize(
              context,
              60,
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }
}

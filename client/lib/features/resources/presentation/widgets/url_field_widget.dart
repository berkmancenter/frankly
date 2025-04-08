import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

/// Textfield for URL input that handles loading and URL preview.
class UrlFieldWidget extends StatelessWidget {
  final void Function(String)? onUrlChange;
  final String? error;
  final String? url;
  final void Function() onSubmit;
  final bool isLoading;
  final Color? buttonColor;
  final Color? iconColor;
  final Color? borderColor;
  final TextEditingController? controller;
  final bool isEdited;

  const UrlFieldWidget({
    Key? key,
    this.onUrlChange,
    this.error,
    this.url,
    this.buttonColor,
    this.borderColor,
    required this.onSubmit,
    this.isLoading = false,
    this.iconColor,
    this.controller,
    this.isEdited = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomTextField(
                onEditingComplete:
                    url?.isNotEmpty == true && isNullOrEmpty(error)
                        ? () => onSubmit()
                        : null,
                hintText: 'Paste or enter a URL',
                initialValue: url,
                controller: controller,
                borderColor: (isNullOrEmpty(error)
                        ? borderColor
                        : AppColor.redDarkMode) ??
                    context.theme.colorScheme.primary,
                onChanged: onUrlChange,
              ),
            ),
            if (isEdited) ...[
              SizedBox(width: 10),
              CustomInkWell(
                boxShape: BoxShape.circle,
                onTap: isNullOrEmpty(error) ? () => onSubmit() : null,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      (isNullOrEmpty(error) ? buttonColor : AppColor.gray3) ??
                          context.theme.colorScheme.primary,
                  child: Icon(
                    Icons.check,
                    color: iconColor ?? AppColor.brightGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (error?.isNotEmpty ?? false) ...[
          SizedBox(height: 10),
          HeightConstrainedText(
            error!,
            style: TextStyle(color: AppColor.redLightMode),
          ),
        ],
        if (isLoading) ...[
          SizedBox(height: 20),
          dotted_border.DottedBorder(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            dashPattern: const [5, 5],
            strokeCap: StrokeCap.round,
            borderType: dotted_border.BorderType.RRect,
            radius: Radius.circular(4),
            color: AppColor.gray3,
            child: Center(
              child: ProxiedImage(
                null,
                asset: AppAsset('media/loading.gif'),
                width: 30,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

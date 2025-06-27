import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';

class CreateCommunityImageFields extends StatelessWidget {
  final String? profileImageUrl;
  final Future<void> Function(String) updateProfileImage;
  final Future<void> Function({required bool isBannerImage}) removeImage;

  const CreateCommunityImageFields({
    Key? key,
    this.profileImageUrl,
    required this.updateProfileImage,
    required this.removeImage,
  }) : super(key: key);

  Future<void> _editLogoPressed() async {
    String? url =
        await GetIt.instance<MediaHelperService>().pickImageViaCloudinary();
    url = url?.trim();
    if (url != null) {
      await updateProfileImage(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoField(context),
      ],
    );
  }

  Widget _buildLogoField(BuildContext context) => CreateCommunityImageField(
        text: context.l10n.logo,
        onTap: () => alertOnError(context, () => _editLogoPressed()),
        onTapRemove: () =>
            alertOnError(context, () => removeImage(isBannerImage: false)),
        isCircle: true,
        onImageSelect: updateProfileImage,
        image: profileImageUrl,
        isOptional: true,
      );
}

class CreateCommunityImageField extends StatelessWidget {
  final String text;
  final void Function() onTap;
  final void Function() onTapRemove;
  final bool isCircle;
  final String? image;
  final void Function(String)? onImageSelect;
  final bool isOptional;

  const CreateCommunityImageField({
    required this.text,
    required this.onTap,
    required this.onTapRemove,
    this.isCircle = false,
    this.image,
    this.onImageSelect,
    this.isOptional = false,
    Key? key,
  }) : super(key: key);

  bool get showImage => !isNullOrEmpty(image);

  double get size => 80.0;

  Widget _buildRemoveImageIcon(BuildContext context) {
    return ActionButton(
            text: context.l10n.remove,
            onPressed: onTapRemove,
            type: ActionButtonType.outline,
            icon: Icon(Icons.delete),
          );
  }

  Widget _buildImageWidget(BuildContext context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size + 10,
            height: size + 10,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !showImage ? context.theme.colorScheme.surfaceDim : Colors.transparent,
              border: !showImage ? null : Border.all(
                color: context.theme.colorScheme.primary,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: !showImage ? Icon(
              Icons.image_outlined,
              color: context.theme.colorScheme.primary,
              size: size,
            ) : ProxiedImage(
            image,
            width: size,
            height: size,
          ),
          ),
          SizedBox(width: 30),
          ActionButton(
            text: !showImage ? context.l10n.upload : context.l10n.edit,
            onPressed: onTap,
            type: ActionButtonType.outline,
            icon: Icon(!showImage ? Icons.add : Icons.edit),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          context.l10n.logo,
          style: context.theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 30),
        Row(
          children: [
            Semantics(
              button: true,
              label: text,
              child: _buildImageWidget(context),
            ),
            SizedBox(width: 10),
            if (showImage)             
              _buildRemoveImageIcon(context),
          ],
        ),
      ],
    );
  }
}

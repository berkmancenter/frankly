import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class CreateCommunityImageFields extends StatelessWidget {
  final String? bannerImageUrl;
  final String? profileImageUrl;
  final Future<void> Function(String) updateBannerImage;
  final Future<void> Function(String) updateProfileImage;
  final Future<void> Function({required bool isBannerImage}) removeImage;

  const CreateCommunityImageFields({
    Key? key,
    this.bannerImageUrl,
    this.profileImageUrl,
    required this.updateBannerImage,
    required this.updateProfileImage,
    required this.removeImage,
  }) : super(key: key);

  Future<void> _editBannerPressed() async {
    String? url =
        await GetIt.instance<MediaHelperService>().pickImageViaCloudinary();
    url = url?.trim();
    if (url != null) {
      await updateBannerImage(url);
    }
  }

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
        SizedBox(height: 16),
        _buildBackgroundField(context),
      ],
    );
  }

  Widget _buildLogoField(BuildContext context) => CreateCommunityImageField(
        text: 'Logo',
        onTap: () => alertOnError(context, () => _editLogoPressed()),
        onTapRemove: () =>
            alertOnError(context, () => removeImage(isBannerImage: false)),
        isCircle: true,
        onImageSelect: updateProfileImage,
        image: profileImageUrl,
        isOptional: true,
      );

  Widget _buildBackgroundField(BuildContext context) =>
      CreateCommunityImageField(
        text: 'Background',
        onTap: () => alertOnError(context, () => _editBannerPressed()),
        onTapRemove: () =>
            alertOnError(context, () => removeImage(isBannerImage: true)),
        onImageSelect: updateBannerImage,
        image: bannerImageUrl,
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

  double get size => 30.0;

  Widget _buildRemoveImageIcon() {
    return CustomInkWell(
      onTap: onTapRemove,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        child: Icon(
          Icons.close,
          color: AppColor.gray2,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInkWellWidget() {
    if (!showImage) {
      return CustomInkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isCircle ? 15 : 5),
        child: Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(isCircle ? 15 : 5),
            border: Border.all(
              color: AppColor.gray2,
            ),
          ),
          child: Icon(
            Icons.add,
            color: AppColor.gray2,
            size: 20,
          ),
        ),
      );
    } else {
      return CustomInkWell(
        boxShape: isCircle ? BoxShape.circle : null,
        borderRadius: !isCircle ? BorderRadius.circular(5) : null,
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            border: Border.all(color: AppColor.gray4),
            borderRadius:
                (!isCircle && !showImage) ? BorderRadius.circular(5) : null,
          ),
          alignment: Alignment.center,
          child: ProxiedImage(
            image,
            width: size,
            height: size,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(button: true, label: text, child: _buildInkWellWidget()),
        SizedBox(width: 10),
        if (showImage) ...[
          Expanded(
            child: HeightConstrainedText(
              text,
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildRemoveImageIcon(),
        ] else ...[
          Expanded(
            child: HeightConstrainedText(
              text,
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOptional)
            HeightConstrainedText(
              'Optional',
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.gray3),
            ),
        ],
      ],
    );
  }
}

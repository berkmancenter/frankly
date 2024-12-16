import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/choose_platform_presenter.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/app/junto/discussions/platform_data.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

/// [ChoosePlatformPage] Widget Class that shows view for selecting BYOV platforms

class ChoosePlatformPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChoosePlatformPagePresenter(
        discussionProvider: context.watch<CreateDiscussionDialogModel>().discussionProvider,
      )..initialize(),
      child: _ChoosePlatformPage(),
    );
  }
}

class _ChoosePlatformPage extends StatefulWidget {
  @override
  State<_ChoosePlatformPage> createState() => _ChoosePlatformPageState();
}

class _ChoosePlatformPageState extends State<_ChoosePlatformPage> {
  @override
  Widget build(BuildContext context) {
    final _presenter = context.watch<ChoosePlatformPagePresenter>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: JuntoText(
              'Choose platform',
              style: AppTextStyle.headline1.copyWith(fontSize: 30),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Column(
            children: [
              for (var platform in allowedVideoPlatforms) ...[
                JuntoInkWell(
                  onTap: () => _presenter.selectPlatform(platform),
                  hoverColor: AppColor.gray3.withOpacity(0.1),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    leading: SizedBox(
                      height: 40,
                      width: 40,
                      child: JuntoImage(
                        null,
                        asset: AppAsset(platform.platformKey.info.logoUrl),
                      ),
                    ),
                    title: JuntoText(platform.platformKey.info.title, style: AppTextStyle.subhead),
                    subtitle: JuntoText(
                      platform.platformKey.info.description,
                      style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray4),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(width: 1, color: AppColor.darkBlue),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: _presenter.isSelectedPlatform(platform)
                            ? AppColor.darkBlue
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                if ((platform.platformKey != PlatformKey.junto) &&
                    _presenter.isSelectedPlatform(platform))
                  LinkField(
                    onSubmit: () => _presenter.updateSelectedPlatform(),
                    onCancel: () => _presenter.clearPlatformUrl(),
                    editing: _presenter.editingUrl,
                    error: _presenter.error,
                    url: _presenter.url,
                    controller: _presenter.urlController,
                  ),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DialogBackButton(),
            ActionButton(
              onPressed: _presenter.isValidUrl ||
                      _presenter.selectedPlatform?.platformKey == PlatformKey.junto
                  ? () => alertOnError(context, () async {
                        final discussion = await _presenter.submit();
                        Navigator.of(context).pop(discussion);
                      })
                  : null,
              text: 'Update Event',
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget that allows users to input/edit URL links and shows validation errors when present.

class LinkField extends StatelessWidget {
  final String? error;
  final String? url;
  final bool editing;
  final void Function() onSubmit;
  final void Function() onCancel;
  final TextEditingController? controller;

  const LinkField({
    Key? key,
    this.error,
    this.url,
    this.controller,
    required this.editing,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: JuntoTextField(
                  labelText: 'Paste a link',
                  labelStyle: AppTextStyle.bodySmall.copyWith(
                    color: isNullOrEmpty(error) ? AppColor.darkBlue : AppColor.redLightMode,
                  ),
                  onEditingComplete: () => onSubmit(),
                  padding: EdgeInsets.zero,
                  controller: controller,
                  validator: (text) => error,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  if (editing)
                    JuntoInkWell(
                      onTap: isNullOrEmpty(error) && !isNullOrEmpty(url) ? () => onSubmit() : null,
                      boxShape: BoxShape.circle,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNullOrEmpty(error) && !isNullOrEmpty(url)
                              ? AppColor.darkBlue
                              : AppColor.gray4,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: isNullOrEmpty(error) && !isNullOrEmpty(url)
                              ? AppColor.brightGreen
                              : AppColor.gray1,
                        ),
                      ),
                    )
                  else
                    JuntoInkWell(
                      onTap: () => onCancel(),
                      boxShape: BoxShape.circle,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(color: AppColor.darkBlue),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 15,
                        ),
                      ),
                    ),
                  if (!isNullOrEmpty(error)) SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

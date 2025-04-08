import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/create_event/presentation/choose_platform_presenter.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/event_dialog_buttons.dart';
import 'package:client/features/events/data/models/platform_data.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

/// [ChoosePlatformPage] Widget Class that shows view for selecting BYOV platforms

class ChoosePlatformPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChoosePlatformPagePresenter(
        eventProvider: context.watch<CreateEventDialogModel>().eventProvider,
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
    final presenter = context.watch<ChoosePlatformPagePresenter>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: HeightConstrainedText(
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
                CustomInkWell(
                  onTap: () => presenter.selectPlatform(platform),
                  hoverColor: AppColor.gray3.withOpacity(0.1),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    leading: SizedBox(
                      height: 40,
                      width: 40,
                      child: ProxiedImage(
                        null,
                        asset: AppAsset(platform.platformKey.info.logoUrl),
                      ),
                    ),
                    title: HeightConstrainedText(
                      platform.platformKey.info.title,
                      style: AppTextStyle.subhead,
                    ),
                    subtitle: HeightConstrainedText(
                      platform.platformKey.info.description,
                      style: AppTextStyle.eyebrowSmall
                          .copyWith(color: AppColor.gray4),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: presenter.isSelectedPlatform(platform)
                            ? context.theme.colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                if ((platform.platformKey != PlatformKey.community) &&
                    presenter.isSelectedPlatform(platform))
                  LinkField(
                    onSubmit: () => presenter.updateSelectedPlatform(),
                    onCancel: () => presenter.clearPlatformUrl(),
                    editing: presenter.editingUrl,
                    error: presenter.error,
                    url: presenter.url,
                    controller: presenter.urlController,
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
              onPressed: presenter.isValidUrl ||
                      presenter.selectedPlatform?.platformKey ==
                          PlatformKey.community
                  ? () => alertOnError(context, () async {
                        final event = await presenter.submit();
                        Navigator.of(context).pop(event);
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
                child: CustomTextField(
                  labelText: 'Paste a link',
                  labelStyle: AppTextStyle.bodySmall.copyWith(
                    color: isNullOrEmpty(error)
                        ? context.theme.colorScheme.primary
                        : AppColor.redLightMode,
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
                    CustomInkWell(
                      onTap: isNullOrEmpty(error) && !isNullOrEmpty(url)
                          ? () => onSubmit()
                          : null,
                      boxShape: BoxShape.circle,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNullOrEmpty(error) && !isNullOrEmpty(url)
                              ? context.theme.colorScheme.primary
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
                    CustomInkWell(
                      onTap: () => onCancel(),
                      boxShape: BoxShape.circle,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: context.theme.colorScheme.primary,
                          ),
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

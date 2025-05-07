import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/event_dialog_buttons.dart';
import 'package:client/features/community/presentation/widgets/featured_toggle_button.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';
import 'package:client/services.dart';
import 'package:client/core/localization/localization_helper.dart';


final l10n = appLocalizationService.getLocalization();

enum _VisibilityType {
  public,
  private,
}

final _visibilityTypeDescriptionLookup = <_VisibilityType, String>{
  _VisibilityType.public: l10n.allowTheCommunityToJoin,
  _VisibilityType.private: l10n.iWillShareThisWithAPrivateGroup,
};

class SelectVisibilityPage extends StatefulWidget {
  const SelectVisibilityPage();

  @override
  _SelectVisibilityPageState createState() => _SelectVisibilityPageState();
}

class _SelectVisibilityPageState extends State<SelectVisibilityPage> {
  @override
  Widget build(BuildContext context) {
    final dialogModel = context.read<CreateEventDialogModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeightConstrainedText(
          context.l10n.publicOrPrivate,
          style: AppTextStyle.headline1,
        ),
        SizedBox(height: 20),
        Center(
          child: FormBuilderRadioGroup<_VisibilityType>(
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            focusNode: FocusNode(),
            initialValue: dialogModel.event.isPublic == true
                ? _VisibilityType.public
                : _VisibilityType.private,
            name: 'visibility_options',
            onChanged: (value) {
              dialogModel.updateVisibility(
                isPublic: value == _VisibilityType.public,
              );
            },
            activeColor: AppColor.darkBlue,
            separator: null,
            options: [
              for (final entry in _visibilityTypeDescriptionLookup.entries)
                FormBuilderFieldOption(
                  value: entry.key,
                  child: HeightConstrainedText(
                    entry.value,
                    style: TextStyle(color: AppColor.darkBlue, fontSize: 15),
                  ),
                ),
            ],
            controlAffinity: ControlAffinity.leading,
            orientation: OptionsOrientation.vertical,
          ),
        ),
        if (dialogModel.isEdit &&
            Provider.of<CommunityPermissionsProvider>(context)
                .canEditCommunity) ...[
          SizedBox(height: 5),
          FeaturedToggleButton(
            controlAffinity: ListTileControlAffinity.leading,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
            ),
            textColor: AppColor.darkBlue,
            communityId: dialogModel.communityProvider.communityId,
            label:
                'Feature on ${dialogModel.communityProvider.community.name} homepage',
            documentId: dialogModel.event.id,
            documentPath:
                '${dialogModel.event.collectionPath}/${dialogModel.event.id}',
            featuredType: FeaturedType.event,
          ),
        ],
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            DialogBackButton(),
            NextOrSubmitButton(),
          ],
        ),
      ],
    );
  }
}

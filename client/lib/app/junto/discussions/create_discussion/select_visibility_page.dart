import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/dialog_button.dart';
import 'package:junto/common_widgets/featured_toggle_button.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

enum _VisibilityType {
  public,
  private,
}

final _visibilityTypeDescriptionLookup = <_VisibilityType, String>{
  _VisibilityType.public: 'Allow the community to join',
  _VisibilityType.private: 'I\'ll share this with a private group',
};

class SelectVisibilityPage extends StatefulWidget {
  const SelectVisibilityPage();

  @override
  _SelectVisibilityPageState createState() => _SelectVisibilityPageState();
}

class _SelectVisibilityPageState extends State<SelectVisibilityPage> {
  @override
  Widget build(BuildContext context) {
    final dialogModel = context.read<CreateDiscussionDialogModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        JuntoText(
          'Public or private?',
          style: AppTextStyle.headline1,
        ),
        SizedBox(height: 20),
        Center(
          child: Theme(
            data: ThemeData(
              unselectedWidgetColor: AppColor.darkBlue,
            ),
            child: FormBuilderRadioGroup<_VisibilityType>(
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              focusNode: FocusNode(),
              initialValue: dialogModel.discussion.isPublic == true
                  ? _VisibilityType.public
                  : _VisibilityType.private,
              name: 'visibility_options',
              onChanged: (value) {
                dialogModel.updateVisibility(isPublic: value == _VisibilityType.public);
              },
              activeColor: AppColor.darkBlue,
              separator: null,
              options: [
                for (final entry in _visibilityTypeDescriptionLookup.entries)
                  FormBuilderFieldOption(
                    value: entry.key,
                    child: JuntoText(
                      entry.value,
                      style: TextStyle(color: AppColor.darkBlue, fontSize: 15),
                    ),
                  ),
              ],
              controlAffinity: ControlAffinity.leading,
              orientation: OptionsOrientation.vertical,
            ),
          ),
        ),
        if (dialogModel.isEdit &&
            Provider.of<CommunityPermissionsProvider>(context).canEditCommunity) ...[
          SizedBox(height: 5),
          FeaturedToggleButton(
            controlAffinity: ListTileControlAffinity.leading,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
            ),
            textColor: AppColor.darkBlue,
            juntoId: dialogModel.juntoProvider.juntoId,
            label: 'Feature on ${dialogModel.juntoProvider.junto.name} homepage',
            documentId: dialogModel.discussion.id,
            documentPath: '${dialogModel.discussion.collectionPath}/${dialogModel.discussion.id}',
            featuredType: FeaturedType.conversation,
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

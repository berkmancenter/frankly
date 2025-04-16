import 'package:client/features/events/features/live_meeting/features/meeting_agenda/utils/agenda_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_user_suggestions_data.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';

import 'agenda_item_user_suggestions_contract.dart';
import '../../data/models/agenda_item_user_suggestions_model.dart';
import '../agenda_item_user_suggestions_presenter.dart';

class AgendaItemUserSuggestions extends StatefulWidget {
  final bool isEditMode;
  final AgendaItemUserSuggestionsData userSuggestionsData;
  final void Function(AgendaItemUserSuggestionsData) onChanged;

  const AgendaItemUserSuggestions({
    Key? key,
    required this.isEditMode,
    required this.userSuggestionsData,
    required this.onChanged,
  });

  @override
  _AgendaItemUserSuggestionsState createState() =>
      _AgendaItemUserSuggestionsState();
}

class _AgendaItemUserSuggestionsState extends State<AgendaItemUserSuggestions>
    implements AgendaItemUserSuggestionsView {
  //ignore:unused_field
  late AgendaItemUserSuggestionsModel _model;
  late AgendaItemUserSuggestionsPresenter _presenter;

  void _init() {
    _model = AgendaItemUserSuggestionsModel(
      widget.isEditMode,
      widget.userSuggestionsData,
      widget.onChanged,
    );
    _presenter = AgendaItemUserSuggestionsPresenter(context, this, _model);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(AgendaItemUserSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEditMode != widget.isEditMode) {
      _init();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allowEdit = _presenter.allowEdit();

    if (_model.isEditMode && allowEdit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            initialValue: _model.agendaItemUserSuggestionsData.headline,
            labelText: 'Headline',
            hintText: context.l10n.suggestions,
            maxLength: agendaSuggestionCharactersLength,
            maxLines: 1,
            counterStyle: AppTextStyle.bodySmall.copyWith(
              color: AppColor.darkBlue,
            ),
            onChanged: (value) => _presenter.updateTitle(value),
          ),
          SizedBox(height: 20),
          HeightConstrainedText(
            'Let participants suggest agenda items and then upvote or downvote.',
            style: AppTextStyle.body.copyWith(color: AppColor.gray3),
          ),
        ],
      );
    } else {
      return ProxiedImage(
        null,
        asset: AppAsset.kUserSuggestionAgendaCover,
      );
    }
  }

  @override
  void updateView() {
    setState(() {});
  }
}

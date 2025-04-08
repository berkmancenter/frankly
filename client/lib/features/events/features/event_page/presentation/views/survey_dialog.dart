import 'package:client/core/utils/random_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/survey_presenter.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';
import 'package:client/app.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

class SurveyDialogResult {
  final List<BreakoutQuestion> questions;
  final String? zipCode;

  SurveyDialogResult({
    required this.questions,
    this.zipCode,
  });
}

class SurveyDialog extends StatelessWidget {
  const SurveyDialog({Key? key}) : super(key: key);

  static Future<SurveyDialogResult?> show({
    required CommunityProvider communityProvider,
    required EventProvider eventProvider,
  }) async {
    if (useBotControls) {
      final breakoutQuestions =
          eventProvider.event.breakoutRoomDefinition?.breakoutQuestions;
      if (breakoutQuestions == null) return null;
      return SurveyDialogResult(
        questions: breakoutQuestions.map((q) {
          final answerOptions = q.answers.expand((a) => a.options).toList();
          final answerOptionId = answerOptions.isEmpty
              ? ''
              : answerOptions[random.nextInt(answerOptions.length)].id;
          return q.copyWith(answerOptionId: answerOptionId);
        }).toList(),
        zipCode: random.nextInt(100000).toString().padLeft(5, '0'),
      );
    }

    final dialogResult = await CreateDialogUiMigration<SurveyDialogResult>(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SurveyPresenter(
          communityProvider: communityProvider,
          eventProvider: eventProvider,
        )..initialize(),
        child: PointerInterceptor(child: SurveyDialog()),
      ),
    ).show();

    return dialogResult;
  }

  @override
  Widget build(BuildContext context) {
    final surveyPresenter = context.watch<SurveyPresenter>();

    const spacerHeight = 20.0;

    const String description =
        'Please answer a few questions so we can match you with the right group.';

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
          HeightConstrainedText(
            'Finish RSVP',
            style: AppTextStyle.headline1,
          ),
          SizedBox(height: spacerHeight),
          HeightConstrainedText(
            description,
            style: AppTextStyle.bodyMedium,
          ),
          SizedBox(height: spacerHeight),
          for (var questionData in surveyPresenter.surveyQuestions)
            _buildQuestionInfo(context, questionData),
          SizedBox(height: spacerHeight),
          Align(
            alignment: Alignment.centerRight,
            child: ActionButton(
              color: surveyPresenter.checkSurveyCompleted()
                  ? AppColor.brightGreen
                  : AppColor.gray4,
              onPressed: () => surveyPresenter.checkSurveyCompleted()
                  ? Navigator.of(context).pop(
                      SurveyDialogResult(
                        questions: surveyPresenter.surveyQuestions,
                        zipCode: surveyPresenter.zipCodeController.text,
                      ),
                    )
                  : null,
              text: 'Finish',
            ),
          ),
          SizedBox(height: spacerHeight),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(
    BuildContext context,
    BreakoutQuestion questionData,
  ) {
    final answerOptions =
        questionData.answers.map((e) => e.options).flattened.toList();
    final isMobile = responsiveLayoutService.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        HeightConstrainedText(
          questionData.title,
          style: AppTextStyle.headline4,
        ),
        SizedBox(height: 5),
        if (answerOptions.length == 2) ...[
          if (isMobile) ...[
            _buildSurveyButton(
              context: context,
              questionData: questionData,
              answerOption: answerOptions[0],
              expand: true,
            ),
            SizedBox(height: 10),
            _buildSurveyButton(
              context: context,
              questionData: questionData,
              answerOption: answerOptions[1],
              expand: true,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildSurveyButton(
                    context: context,
                    questionData: questionData,
                    answerOption: answerOptions[0],
                    expand: true,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildSurveyButton(
                    context: context,
                    questionData: questionData,
                    answerOption: answerOptions[1],
                    expand: true,
                  ),
                ),
              ],
            ),
        ] else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < answerOptions.length; i++)
                _buildSurveyButton(
                  context: context,
                  questionData: questionData,
                  answerOption: answerOptions[i],
                ),
            ],
          ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSurveyButton({
    required BuildContext context,
    required BreakoutQuestion questionData,
    required BreakoutAnswerOption answerOption,
    bool expand = false,
  }) {
    var questionId = questionData.id;
    final isAnswerSelected = questionData.answerOptionId == answerOption.id;

    return ActionButton(
      type: ActionButtonType.outline,
      onPressed: () => context.read<SurveyPresenter>().setQuestionAnswer(
            id: questionId,
            answerOptionId: answerOption.id,
          ),
      expand: expand,
      color: _getButtonColor(isAnswerSelected: isAnswerSelected, invert: false),
      borderSide:
          BorderSide(color: context.theme.colorScheme.primary, width: 1),
      borderRadius: BorderRadius.circular(30),
      textColor:
          _getButtonColor(isAnswerSelected: isAnswerSelected, invert: true),
      child: Flexible(
        flex: expand ? 1 : 0,
        child: Container(
          constraints: BoxConstraints(maxWidth: 220),
          child: HeightConstrainedText(
            answerOption.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTextStyle.body.copyWith(
              color: _getButtonColor(
                isAnswerSelected: isAnswerSelected,
                invert: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor({
    required bool isAnswerSelected,
    required bool invert,
  }) {
    bool isDarkColor = !isAnswerSelected;
    if (invert) {
      isDarkColor = !isDarkColor;
    }

    return isDarkColor ? AppColor.white : context.theme.colorScheme.primary;
  }
}

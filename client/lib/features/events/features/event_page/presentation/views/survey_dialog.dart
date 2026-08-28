import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/random_utils.dart';
import 'package:client/core/widgets/custom_text_field.dart';
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
          if (q.type == BreakoutQuestionType.freeText) {
            return q.copyWith(
              freeTextAnswer: 'Random response ${random.nextInt(100000)}',
            );
          } else if (q.answers.isEmpty) {
            // Edge case: clear the freeTextAnswer if the question is not a free text question
            return q.copyWith(freeTextAnswer: null);
          }

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

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
          HeightConstrainedText(
            context.l10n.finishRsvp,
            style: AppTextStyle.headline1,
          ),
          SizedBox(height: spacerHeight),
          HeightConstrainedText(
            context.l10n.pleaseAnswerQuestions,
            style: AppTextStyle.bodyMedium,
          ),
          SizedBox(height: spacerHeight),
          for (var questionData in surveyPresenter.surveyQuestions)
            _buildQuestionInfo(context, surveyPresenter, questionData),
          SizedBox(height: spacerHeight),
          Align(
            alignment: Alignment.centerRight,
            child: ActionButton(
              onPressed: surveyPresenter.checkSurveyCompleted()
                  ? () => Navigator.of(context).pop(
                        SurveyDialogResult(
                          questions: surveyPresenter.surveyQuestions,
                          zipCode: surveyPresenter.zipCodeController.text,
                        ),
                      )
                  : null,
              text: context.l10n.finish,
            ),
          ),
          SizedBox(height: spacerHeight),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(
    BuildContext context,
    SurveyPresenter surveyPresenter,
    BreakoutQuestion questionData,
  ) {
    final isMobile = responsiveLayoutService.isMobile(context);

    if (questionData.type == BreakoutQuestionType.freeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          HeightConstrainedText(
            questionData.title,
            style: AppTextStyle.headline4,
          ),
          SizedBox(height: 5),
          CustomTextField(
            controller: surveyPresenter.freeTextResponseController,
            maxLines: 3,
            maxLength: 270,
          ),
          SizedBox(height: 10),
        ],
      );
    }

    final answerOptions =
        questionData.answers.map((e) => e.options).flattened.toList();

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
      type:
          isAnswerSelected ? ActionButtonType.filled : ActionButtonType.outline,
      onPressed: () => context.read<SurveyPresenter>().setQuestionAnswer(
            id: questionId,
            answerOptionId: answerOption.id,
          ),
      expand: expand,
      borderRadius: BorderRadius.circular(30),
      child: Flexible(
        flex: expand ? 1 : 0,
        child: Container(
          constraints: BoxConstraints(maxWidth: 220),
          child: HeightConstrainedText(
            answerOption.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodyMedium!.copyWith(
              color: isAnswerSelected
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

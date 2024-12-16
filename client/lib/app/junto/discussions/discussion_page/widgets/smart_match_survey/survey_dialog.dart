import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/smart_match_survey/survey_presenter.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

class SurveyDialogResult {
  final List<BreakoutQuestion> questions;
  final bool? optInAmericaTalks;
  final String? zipCode;

  SurveyDialogResult({
    required this.questions,
    this.optInAmericaTalks,
    this.zipCode,
  });
}

class SurveyDialog extends StatelessWidget {
  const SurveyDialog({Key? key}) : super(key: key);

  static Future<SurveyDialogResult?> show({
    required JuntoProvider juntoProvider,
    required DiscussionProvider discussionProvider,
  }) async {
    if (useBotControls) {
      final breakoutQuestions =
          discussionProvider.discussion.breakoutRoomDefinition?.breakoutQuestions;
      if (breakoutQuestions == null) return null;
      return SurveyDialogResult(
        questions: breakoutQuestions.map((q) {
          final answerOptions = q.answers.expand((a) => a.options).toList();
          final answerOptionId =
              answerOptions.isEmpty ? '' : answerOptions[random.nextInt(answerOptions.length)].id;
          return q.copyWith(answerOptionId: answerOptionId);
        }).toList(),
        optInAmericaTalks: random.nextInt(10) > 3,
        zipCode: random.nextInt(100000).toString().padLeft(5, '0'),
      );
    }

    final dialogResult = await CreateDialogUiMigration<SurveyDialogResult>(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SurveyPresenter(
          juntoProvider: juntoProvider,
          discussionProvider: discussionProvider,
        )..initialize(),
        child: PointerInterceptor(child: SurveyDialog()),
      ),
    ).show();

    return dialogResult;
  }

  @override
  Widget build(BuildContext context) {
    final _surveyPresenter = context.watch<SurveyPresenter>();
    final isMeetingOfAmerica = _surveyPresenter.juntoProvider.isMeetingOfAmerica;
    const spacerHeight = 20.0;

    final String description;
    if (isMeetingOfAmerica) {
      description = 'Please answer the questions below to help us match people '
          'of different backgrounds and beliefs.';
    } else if (_surveyPresenter.juntoProvider.isAmericaTalks) {
      description = 'Thank you for being the type of person who cares about your community! '
          'So that we can match you with one or more people with different backgrounds and '
          'beliefs, we need you to answer a few quick questions.';
    } else {
      description = 'Please answer a few questions so we can match you with the right group.';
    }

    return JuntoUiMigration(
      whiteBackground: true,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            JuntoText(
              'Finish RSVP',
              style: AppTextStyle.headline1,
            ),
            SizedBox(height: spacerHeight),
            JuntoText(
              description,
              style: AppTextStyle.bodyMedium,
            ),
            SizedBox(height: spacerHeight),
            for (var questionData in _surveyPresenter.surveyQuestions)
              _buildQuestionInfo(context, questionData),
            if (_surveyPresenter.juntoProvider.isAmericaTalks) ...[
              SizedBox(height: spacerHeight),
              _buildZipCodeAmericaTalksQuestion(context),
              SizedBox(height: spacerHeight),
              _buildCheckboxAmericaTalksQuestion(context),
            ],
            SizedBox(height: spacerHeight),
            Align(
              alignment: Alignment.centerRight,
              child: ActionButton(
                color:
                    _surveyPresenter.checkSurveyCompleted() ? AppColor.brightGreen : AppColor.gray4,
                onPressed: () => _surveyPresenter.checkSurveyCompleted()
                    ? Navigator.of(context).pop(SurveyDialogResult(
                        questions: _surveyPresenter.surveyQuestions,
                        optInAmericaTalks: _surveyPresenter.optInAmericaTalks,
                        zipCode: _surveyPresenter.zipCodeController.text,
                      ))
                    : null,
                text: isMeetingOfAmerica ? 'Next' : 'Finish',
              ),
            ),
            SizedBox(height: spacerHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildZipCodeAmericaTalksQuestion(BuildContext context) {
    final _surveyPresenter = context.watch<SurveyPresenter>();
    final isMobile = responsiveLayoutService.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            JuntoText(
              'What is your zip code?',
              style: AppTextStyle.headline4,
            ),
            SizedBox(width: 10, height: 10),
            Flexible(
              flex: isMobile ? 0 : 1,
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: JuntoTextField(
                  controller: _surveyPresenter.zipCodeController,
                  padding: EdgeInsets.zero,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCheckboxAmericaTalksQuestion(BuildContext context) {
    final _surveyPresenter = context.watch<SurveyPresenter>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          activeColor: AppColor.darkBlue,
          checkColor: AppColor.brightGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), side: BorderSide(color: AppColor.gray3)),
          value: _surveyPresenter.optInAmericaTalks,
          onChanged: (bool? value) =>
              _surveyPresenter.optInAmericaTalks = !_surveyPresenter.optInAmericaTalks,
        ),
        SizedBox(width: 6),
        Flexible(
          child: JuntoText(
            'Yes! I want to join the movement and stay in the loop with occasional '
            'updates, opportunities and offers from America Talks and its partners.',
            style: AppTextStyle.headline4,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionInfo(BuildContext context, BreakoutQuestion questionData) {
    final answerOptions = questionData.answers.map((e) => e.options).flattened.toList();
    final isMobile = responsiveLayoutService.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        JuntoText(
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
            )
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
      borderSide: BorderSide(color: AppColor.darkBlue, width: 1),
      borderRadius: BorderRadius.circular(30),
      textColor: _getButtonColor(isAnswerSelected: isAnswerSelected, invert: true),
      child: Flexible(
        flex: expand ? 1 : 0,
        child: Container(
          constraints: BoxConstraints(maxWidth: 220),
          child: JuntoText(
            answerOption.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTextStyle.body.copyWith(
              color: _getButtonColor(isAnswerSelected: isAnswerSelected, invert: true),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor({required bool isAnswerSelected, required bool invert}) {
    bool isDarkColor = !isAnswerSelected;
    if (invert) {
      isDarkColor = !isDarkColor;
    }

    return isDarkColor ? AppColor.white : AppColor.darkBlue;
  }
}

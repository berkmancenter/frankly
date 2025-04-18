import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:flutter/cupertino.dart' hide ReorderableList;
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:intl/intl.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/breakout_room_definition/presentation/breakout_room_presenter.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/add_more_button.dart';
import 'package:client/features/events/features/event_page/presentation/views/category_card.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/circle_save_check_button.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/rounded_button.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/app_clickable_widget.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:provider/provider.dart';

class BreakoutRoomDefinitionCard extends StatefulWidget {
  const BreakoutRoomDefinitionCard({Key? key}) : super(key: key);

  @override
  _BreakoutRoomDefinitionCardState createState() =>
      _BreakoutRoomDefinitionCardState();
}

class _BreakoutRoomDefinitionCardState
    extends State<BreakoutRoomDefinitionCard> {
  static const _maxSmartMatchQuestionsCount = 8;
  static const _maxBreakoutCategoryCount = 10;

  late BreakoutAssignmentMethod _assignmentMethod;
  late BreakoutRoomPresenter _presenter;
  late List<BreakoutQuestion> _questions = [];
  late bool _enableBreakoutCategory;

  @override
  void initState() {
    _enableBreakoutCategory =
        context.read<EventProvider>().enableBreakoutsByCategory;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _presenter = context.watch<BreakoutRoomPresenter>();
    _assignmentMethod =
        _presenter.breakoutRoomDefinitionDetails.assignmentMethod;
    _questions = _presenter.breakoutRoomDefinitionDetails.breakoutQuestions;

    final canFetchCapabilities =
        context.read<CommunityPermissionsProvider>().canModerateContent;
    final communityId = _presenter.eventProvider.communityId;
    return Center(
      child: CustomStreamBuilder<PlanCapabilityList?>(
        entryFrom: '__BreakoutRoomsDialogState._buildContent',
        stream: canFetchCapabilities
            ? cloudFunctionsCommunityService
                .getCommunityCapabilities(
                  GetCommunityCapabilitiesRequest(communityId: communityId),
                )
                .asStream()
            : Future.value(null).asStream(),
        builder: (context, caps) {
          final hasSmartMatchingCapability = caps?.hasSmartMatching ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  RoundedButton(
                    label: 'By Size',
                    onPressed: _assignmentMethod !=
                            BreakoutAssignmentMethod.targetPerRoom
                        ? () => _presenter.updateAssignmentMethod(
                              assignmentMethod:
                                  BreakoutAssignmentMethod.targetPerRoom,
                            )
                        : null,
                  ),
                  if (hasSmartMatchingCapability)
                    RoundedButton(
                      label: 'Smart Match',
                      onPressed: _assignmentMethod !=
                              BreakoutAssignmentMethod.smartMatch
                          ? () => _presenter.updateAssignmentMethod(
                                assignmentMethod:
                                    BreakoutAssignmentMethod.smartMatch,
                              )
                          : null,
                    ),
                  if (_enableBreakoutCategory)
                    RoundedButton(
                      label: 'By Category',
                      onPressed:
                          _assignmentMethod != BreakoutAssignmentMethod.category
                              ? () => _presenter.updateAssignmentMethod(
                                    assignmentMethod:
                                        BreakoutAssignmentMethod.category,
                                  )
                              : null,
                    ),
                ],
              ),
              SizedBox(height: 30),
              _buildCardFields(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardFields() {
    switch (_assignmentMethod) {
      case BreakoutAssignmentMethod.smartMatch:
        return Column(
          children: [
            _buildSizeCard(),
            SizedBox(height: 10),
            _buildQuestionsList(),
          ],
        );
      case BreakoutAssignmentMethod.category:
        return _enableBreakoutCategory
            ? _buildCategoryCard()
            : _buildSizeCard();
      case BreakoutAssignmentMethod.targetPerRoom:
      default:
        return _buildSizeCard();
    }
  }

  Widget _buildSizeCard() {
    final presenter = context.watch<BreakoutRoomPresenter>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          'Target size',
          style: AppTextStyle.subhead.copyWith(color: AppColor.white),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: HeightConstrainedText(
                  'Target Size?',
                  style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                ),
              ),
              FormBuilderSlider(
                activeColor: AppColor.darkBlue,
                inactiveColor: AppColor.gray6,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  border: const OutlineInputBorder(),
                ),
                initialValue: presenter
                    .breakoutRoomDefinitionDetails.targetParticipants!
                    .toDouble(),
                min: 2,
                numberFormat: NumberFormat('##'),
                max: 20,
                divisions: 20 - 2,
                onChangeEnd: (value) {
                  presenter.updateParticipants(
                    participantsNumber: value.round(),
                  );
                },
                name: 'num_participants',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartMatchCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        HeightConstrainedText(
          'Matching questions',
          style: AppTextStyle.subhead.copyWith(color: AppColor.darkBlue),
        ),
        SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];

            return ReorderableItem(
              key: Key(_questions[index].id),
              childBuilder: (context, state) =>
                  state == ReorderableItemState.normal
                      ? QuestionCard(questionId: question.id)
                      : Opacity(
                          opacity: 0.4,
                          child: QuestionCard(questionId: question.id),
                        ),
            );
          },
        ),
        if (_questions.isNotEmpty) SizedBox(height: 20),
        if (_questions.length < _maxSmartMatchQuestionsCount)
          AddMoreButton(
            isWhiteBackground: true,
            onPressed: () =>
                context.read<BreakoutRoomPresenter>().addQuestion(),
            label: 'Add a question',
          ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return ReorderableList(
      onReorder: (Key draggedKey, Key newPositionKey) {
        final draggedIndex = _presenter
            .breakoutRoomDefinitionDetails.breakoutQuestions
            .indexWhere((item) => Key(item.id) == draggedKey);
        final newPositionIndex = _presenter
            .breakoutRoomDefinitionDetails.breakoutQuestions
            .indexWhere((item) => Key(item.id) == newPositionKey);

        if (draggedIndex >= 0 && newPositionIndex >= 0) {
          _presenter.reorderQuestions(
            draggedIndex: draggedIndex,
            newPositionIndex: newPositionIndex,
          );
          return true;
        }

        return false;
      },
      onReorderDone: (_) =>
          alertOnError(context, () => _presenter.saveReorder()),
      child: _buildSmartMatchCard(),
    );
  }

  Widget _buildCategoryCard() {
    final categories = _presenter.breakoutRoomDefinitionDetails.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          'Category',
          style: AppTextStyle.subhead.copyWith(color: AppColor.white),
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColor.darkerBlue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              ListView.builder(
                key: Key(categories.length.toString()),
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return CategoryCard(position: index);
                },
              ),
              if (categories.isNotEmpty) SizedBox(height: 20),
              if (categories.length < _maxBreakoutCategoryCount)
                Container(
                  color: AppColor.darkBlue,
                  child: AddMoreButton(
                    onPressed: () =>
                        context.read<BreakoutRoomPresenter>().addCategory(),
                    label: 'Add a category',
                  ),
                ),
              SizedBox(height: 30),
              CircleSaveCheckButton(
                isEnabled: _presenter.isCategoryNotSaved,
                onPressed: () => _presenter.updateBreakoutRoomCategory(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuestionCard extends StatefulWidget {
  final String questionId;

  const QuestionCard({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late final BreakoutRoomPresenter _presenter;
  late ValueNotifier<bool> _isExpanded;
  BreakoutCardViewType _breakoutCardViewType = BreakoutCardViewType.overview;
  final int answersCharactersLength = 40;

  @override
  void initState() {
    super.initState();
    _presenter = context.read<BreakoutRoomPresenter>();

    final surveyQuestion = _presenter.getQuestion(widget.questionId);
    final isCompleted = surveyQuestion.title.isEmpty
        ? false
        : _presenter.isQuestionAndAnswersCompleted(surveyQuestion);
    _isExpanded = ValueNotifier(!isCompleted);
    _breakoutCardViewType =
        isCompleted ? BreakoutCardViewType.overview : BreakoutCardViewType.edit;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<BreakoutRoomPresenter>();

    const questionMaxLength = 140;
    final surveyQuestion = _presenter.getQuestion(widget.questionId);
    final questionPosition = _presenter.getQuestionPosition(widget.questionId);
    final questionText = surveyQuestion.title.isEmpty
        ? 'Question ${questionPosition + 1}'
        : surveyQuestion.title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ExpansionTile(
        key: Key(_isExpanded.value.toString()),
        initiallyExpanded: _isExpanded.value,
        backgroundColor: AppColor.white,
        collapsedBackgroundColor: AppColor.white,
        title: Row(
          children: [
            ReorderableListener(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.reorder,
                  color: Theme.of(context).isDark
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: HeightConstrainedText(
                  questionText,
                  style:
                      AppTextStyle.subhead.copyWith(color: AppColor.darkBlue),
                ),
              ),
            ),
            if (_breakoutCardViewType == BreakoutCardViewType.overview)
              _buildEditButton(),
          ],
        ),
        iconColor: AppColor.darkBlue,
        collapsedIconColor: AppColor.darkBlue,
        onExpansionChanged: (expanded) => _isExpanded.value = expanded,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  readOnly:
                      _breakoutCardViewType == BreakoutCardViewType.overview,
                  labelText: 'Enter Question ${questionPosition + 1}',
                  maxLines: 1,
                  maxLength: questionMaxLength,
                  initialValue: !isNullOrEmpty(surveyQuestion.title)
                      ? surveyQuestion.title
                      : null,
                  onChanged: (value) => _presenter.updateQuestionData(
                    question: value,
                    questionId: widget.questionId,
                  ),
                  useDarkMode: false,
                ),
                SizedBox(height: 30),
                for (var i = 0; i < surveyQuestion.answers.length; i++) ...[
                  _builderAnswerTextField(surveyQuestion.answers[i], i),
                  SizedBox(height: 6),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: AppColor.gray4,
                        ),
                        child: IconButton(
                          icon: Icon(
                            CupertinoIcons.trash,
                            color: AppColor.white,
                            size: 15,
                          ),
                          onPressed: _breakoutCardViewType ==
                                  BreakoutCardViewType.edit
                              ? () async {
                                  final delete = await ConfirmDialog(
                                    mainText:
                                        'Are you sure you want to delete?',
                                  ).show(context: context);
                                  if (delete) {
                                    await alertOnError(
                                      context,
                                      () =>
                                          _presenter.deleteBreakoutRoomQuestion(
                                        widget.questionId,
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    CircleSaveCheckButton(
                      isEnabled:
                          _breakoutCardViewType == BreakoutCardViewType.edit,
                      onPressed:
                          _breakoutCardViewType == BreakoutCardViewType.edit
                              ? () => updateBreakoutRoomQuestionDetails()
                              : null,
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return ActionButton(
      type: ActionButtonType.outline,
      color: AppColor.white,
      textColor: AppColor.darkBlue,
      onPressed: () {
        _isExpanded.value = true;
        _toggleCardViewType();
      },
      text: 'Edit',
      icon: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Icon(Icons.edit, color: AppColor.darkBlue, size: 20),
      ),
      iconSide: ActionButtonIconSide.right,
    );
  }

  Widget _builderAnswerTextField(
    BreakoutAnswer breakoutAnswer,
    int answerIndex,
  ) {
    return Column(
      children: List.generate(breakoutAnswer.options.length, (index) {
        final breakoutAnswerOption = breakoutAnswer.options[index];
        final labelText = _presenter.getLabelText(
          breakoutAnswer.options,
          breakoutAnswerOption.id,
          answerIndex,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: CustomTextField(
                key: Key(breakoutAnswerOption.id),
                readOnly:
                    _breakoutCardViewType == BreakoutCardViewType.overview,
                labelText: labelText,
                initialValue: breakoutAnswerOption.title,
                maxLines: 1,
                maxLength: answersCharactersLength,
                onChanged: (value) => _presenter.updateQuestionAnswerData(
                  value: value,
                  questionId: widget.questionId,
                  breakoutAnswerOption: breakoutAnswerOption,
                ),
                useDarkMode: false,
              ),
            ),
            SizedBox(width: 10),
            if (_breakoutCardViewType == BreakoutCardViewType.edit)
              if (index == 0)
                AppClickableWidget(
                  child: ProxiedImage(
                    null,
                    asset: AppAsset.kPlusPng,
                    width: 20,
                    height: 20,
                  ),
                  onTap: () => _presenter.addAnswer(breakoutAnswer),
                )
              else
                AppClickableWidget(
                  child: ProxiedImage(
                    null,
                    asset: AppAsset.kTrashPng,
                    width: 20,
                    height: 20,
                  ),
                  onTap: () => _presenter.removeAnswerOption(
                    breakoutAnswer,
                    breakoutAnswerOption.id,
                  ),
                ),
          ],
        );
      }).toList(),
    );
  }

  Future<void> updateBreakoutRoomQuestionDetails() async {
    final success = await _presenter.updateBreakoutRoomQuestion();
    if (success) {
      _toggleCardViewType();
    }
  }

  void _toggleCardViewType() {
    switch (_breakoutCardViewType) {
      case BreakoutCardViewType.overview:
        _breakoutCardViewType = BreakoutCardViewType.edit;
        break;
      case BreakoutCardViewType.edit:
        _breakoutCardViewType = BreakoutCardViewType.overview;
        break;
    }
    setState(() {});
  }
}

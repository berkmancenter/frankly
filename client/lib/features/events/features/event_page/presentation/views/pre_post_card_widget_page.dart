import 'package:client/core/utils/toast_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/add_more_button.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/circle_save_check_button.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/pre_post_card_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/pre_post_card_widget_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_card_attribute.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:data_models/templates/template.dart';

enum PrePostCardWidgetType { overview, edit }

class PrePostCardWidgetPage extends StatefulWidget {
  final PrePostCardType prePostCardType;
  final void Function(PrePostCard) onUpdate;
  final void Function() onDelete;
  final Event? event;
  final Template? template;
  final PrePostCard? prePostCard;
  final PrePostCardWidgetType prePostCardWidgetType;
  final bool isEditable;

  const PrePostCardWidgetPage({
    Key? key,
    required this.prePostCardType,
    required this.onUpdate,
    required this.onDelete,
    this.event,
    this.template,
    this.prePostCard,
    this.prePostCardWidgetType = PrePostCardWidgetType.overview,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<PrePostCardWidgetPage> createState() => _PrePostCardWidgetPageState();
}

class _PrePostCardWidgetPageState extends State<PrePostCardWidgetPage>
    implements PrePostCardWidgetView {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  late final PrePostCardWidgetModel _model;
  late final PrePostCardWidgetPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = PrePostCardWidgetModel(
      widget.prePostCardType,
      widget.event,
      widget.isEditable,
      widget.template,
    );
    _presenter = PrePostCardWidgetPresenter(context, this, _model);
    _presenter.init(widget.prePostCardWidgetType, widget.prePostCard);
  }

  @override
  void updateView() {
    if (mounted) setState(() {});
  }

  @override
  void showToast(String text) {
    showRegularToast(context, text, toastType: ToastType.success);
  }

  Future<void> _showDeleteDialog() async {
    final title = _presenter.getTitle();

    await ConfirmDialog(
      title: 'Delete $title agenda item',
      mainText: 'Are you sure want to delete?',
      onConfirm: (context) {
        Navigator.pop(context);
        widget.onDelete();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final isEditIconShown = _presenter.isEditIconShown();
    final title = _presenter.getTitle();

    return Material(
      color: Colors.transparent,
      child: Form(
        key: _formKey,
        // Wrap to SingleChildScrollView so it doesn't overflow on small devices
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: context.theme.colorScheme.surfaceContainer,
                  border: Border.all(
                    width: 1,
                    color: context.theme.colorScheme.outline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _presenter.toggleExpansion(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyle.subhead,
                            ),
                          ),
                          if (isEditIconShown)
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                key: Key('prePostCardWidgetPage-deleteCard'),
                                icon: Icon(
                                  CupertinoIcons.delete,
                                ),
                                onPressed: () => _showDeleteDialog(),
                              ),
                            ),
                          if (isEditIconShown)
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _presenter.toggleCardType(),
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              _model.isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () => _presenter.toggleExpansion(),
                          ),
                        ],
                      ),
                    ),
                    if (_model.isExpanded) SizedBox(height: 20),
                    // Apply additional animation for more fancy experience
                    AnimatedSize(
                      duration: kTabScrollDuration,
                      curve: Curves.easeIn,
                      child: Container(
                        child: _model.isExpanded ? _buildCardContent() : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    switch (_model.prePostCardWidgetType) {
      case PrePostCardWidgetType.overview:
        return _buildOverviewPrePostCard();
      case PrePostCardWidgetType.edit:
        return _buildEditablePrePostCard();
    }
  }

  Widget _buildEditablePrePostCard() {
    final String beforeAfter;
    switch (widget.prePostCardType) {
      case PrePostCardType.preEvent:
        beforeAfter = 'before';
        break;
      case PrePostCardType.postEvent:
        beforeAfter = 'after';
        break;
    }

    final prePostUrls = _model.prePostCard.prePostUrls;

    return Column(
      key: Key('prePostCardWidget-editablePrePostCard'),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What message do you want to show participants $beforeAfter the event?',
              style: AppTextStyle.subhead,
            ),
            SizedBox(height: 30),
            CustomTextField(
              hintText: 'Enter Headline',
              initialValue: _model.prePostCard.headline,
              borderType: BorderType.outline,
              borderRadius: 10,
              maxLines: 1,
              maxLength: 50,
              onChanged: (text) => _presenter.updateEnteredHeadline(text),
              validator: (text) => _presenter.validateHeadline(text),
            ),
            SizedBox(height: 14),
            CustomTextField(
              hintText:
                  'Enter Message. Eg, Take this survey $beforeAfter the event',
              initialValue: _model.prePostCard.message,
              borderType: BorderType.outline,
              borderRadius: 10,
              maxLength: 200,
              minLines: 3,
              onChanged: (text) => _presenter.updateEnteredMessage(text),
              validator: (text) => _presenter.validateMessage(text),
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightConstrainedText(
                'Add action links participants should visit $beforeAfter the event',
                style: AppTextStyle.subhead,
              ),
              SizedBox(height: 30),
              if (prePostUrls.isNotEmpty) ...[
                ListView.builder(
                  key: Key(prePostUrls.length.toString()),
                  shrinkWrap: true,
                  itemCount: prePostUrls.length,
                  itemBuilder: (BuildContext context, int index) {
                    return responsiveLayoutService.isMobile(context)
                        ? _buildMobileActionLinks(index)
                        : _buildDesktopActionLinks(index);
                  },
                ),
                SizedBox(height: 30),
              ],
              AddMoreButton(
                onPressed: () => _presenter.addNewActionLink(),
                label: 'Add action link',
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Center(
                child: AppClickableWidget(
                  onTap: () => _showDeleteDialog(),
                  child: Icon(CupertinoIcons.delete),
                ),
              ),
            ),
            SizedBox(width: 20),
            CircleSaveCheckButton(
              isEnabled: _presenter.hasBeenEdited(widget.event),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  widget.onUpdate(_presenter.getPrePostCardDetailsToSave());
                  _presenter.afterPrePostDataSaved();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileActionLinks(int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;

    List<PrePostCardAttributeType> availableAttributeTypes = [];
    List<PrePostCardAttribute> attributes = [];

    if (urlIndex < prePostUrls.length) {
      availableAttributeTypes = _presenter
          .getAvailableAttributeTypes(prePostUrls[urlIndex].attributes);
      attributes = prePostUrls[urlIndex].attributes;
    }

    final String finalisedUrl =
        _presenter.getFinalisedUrl(prePostUrls[urlIndex]);
    final String finalisedUrlFieldValue =
        finalisedUrl.isEmpty ? 'URL invalid' : finalisedUrl;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10),
        _buildEnterButtonTextField(urlIndex),
        SizedBox(width: 30),
        Row(
          children: [
            Expanded(
              child: _buildEnterUrlTextField(urlIndex),
            ),
            SizedBox(width: 10),
            _buildDeleteActionLink(urlIndex),
          ],
        ),
        SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightConstrainedText(
                'URL Preview',
                style: AppTextStyle.body.copyWith(color: AppColor.white),
              ),
              SizedBox(height: 4),
              HeightConstrainedText(
                finalisedUrlFieldValue,
                style: AppTextStyle.body,
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        if (attributes.isNotEmpty) ..._buildPrePostCardAttributes(urlIndex),
        if (availableAttributeTypes.isNotEmpty)
          _buildAddURLParameterButton(urlIndex),
      ],
    );
  }

  Widget _buildDesktopActionLinks(int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;

    List<PrePostCardAttributeType> availableAttributeTypes = [];
    List<PrePostCardAttribute> attributes = [];

    if (urlIndex < prePostUrls.length) {
      availableAttributeTypes = _presenter
          .getAvailableAttributeTypes(prePostUrls[urlIndex].attributes);
      attributes = prePostUrls[urlIndex].attributes;
    }

    final String finalisedUrl =
        _presenter.getFinalisedUrl(prePostUrls[urlIndex]);
    final String finalisedUrlFieldValue =
        finalisedUrl.isEmpty ? 'URL invalid' : finalisedUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildEnterButtonTextField(urlIndex)),
            SizedBox(width: 40),
            Expanded(child: _buildEnterUrlTextField(urlIndex)),
            SizedBox(width: 10),
            _buildDeleteActionLink(urlIndex),
          ],
        ),
        SizedBox(height: 14),
        if (attributes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeightConstrainedText(
                  'URL Preview',
                  style: AppTextStyle.body,
                ),
                SizedBox(height: 4),
                HeightConstrainedText(
                  finalisedUrlFieldValue,
                  style: AppTextStyle.body,
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: Column(
                children: [
                  ..._buildPrePostCardAttributes(urlIndex),
                  if (availableAttributeTypes.isNotEmpty)
                    _buildAddURLParameterButton(urlIndex),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnterButtonTextField(int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;
    String? buttonText;

    if (urlIndex < prePostUrls.length) {
      buttonText = prePostUrls[urlIndex].buttonText;
    }

    return CustomTextField(
      labelText: 'Button Text',
      initialValue: buttonText,
      borderType: BorderType.outline,
      borderRadius: 10,
      maxLines: 1,
      maxLength: 20,
      onChanged: (text) => _presenter.updateEnteredButtonText(urlIndex, text),
      validator: (text) => _presenter.validateButtonText(text, urlIndex),
    );
  }

  Widget _buildEnterUrlTextField(int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;
    String? surveyUrl;

    if (urlIndex < prePostUrls.length) {
      surveyUrl = prePostUrls[urlIndex].surveyUrl;
    }

    return CustomTextField(
      labelText: 'Enter URL',
      initialValue: surveyUrl,
      borderType: BorderType.outline,
      borderRadius: 10,
      maxLines: 1,
      maxLength: 100,
      onChanged: (text) => _presenter.updateEnteredUrl(text, urlIndex),
      validator: (url) => _presenter.validateUrl(url, urlIndex),
    );
  }

  List<Widget> _buildPrePostCardAttributes(int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;

    List<PrePostCardAttribute> attributes = [];

    if (urlIndex < prePostUrls.length) {
      attributes = prePostUrls[urlIndex].attributes;
    }

    if (attributes.isEmpty) return [];

    return [
      ListView.builder(
        shrinkWrap: true,
        itemCount: attributes.length,
        itemBuilder: (context, attributeIndex) {
          final PrePostCardAttribute attribute = attributes[attributeIndex];
          List<PrePostCardAttributeType> availableAttributeTypes = [];

          if (urlIndex < prePostUrls.length) {
            availableAttributeTypes = _presenter
                .getAvailableAttributeTypes(prePostUrls[urlIndex].attributes);
          }

          return AttributeOption(
            key: Key(attribute.type.toString()),
            attribute: attribute,
            innerAvailableAttributeTypes:
                _presenter.getInnerAvailableAttributeTypes(
              availableAttributeTypes,
              attribute.type,
            ),
            urlIndex: urlIndex,
            attributeIndex: attributeIndex,
            onValidateUrlParameter: (value) {
              _presenter.validateUrlParameter(value);
            },
            onDeleteQueryParamRow: () {
              _presenter.deleteQueryParamRow(urlIndex, attributeIndex);
            },
            onUpdateEnteredQueryName: (value) {
              _presenter.updateEnteredQueryName(
                urlIndex,
                attributeIndex,
                attribute,
                value,
              );
            },
            onUpdateAttributeTypeSelection: (type) {
              _presenter.updateAttributeTypeSelection(
                type,
                urlIndex,
                attributeIndex,
              );
            },
          );
        },
      ),
      SizedBox(height: 20),
    ];
  }

  Widget _buildOverviewPrePostCard() {
    final prePostUrls = _model.prePostCard.prePostUrls;
    return Container(
      key: Key('prePostCardWidget-overviewPrePostCard'),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _model.prePostCard.headline,
            style: AppTextStyle.headline3,
          ),
          SizedBox(height: 20),
          Text(
            _model.prePostCard.message,
            style: AppTextStyle.subhead,
          ),
          SizedBox(height: 20),
          if (prePostUrls.isNotEmpty)
            Wrap(
              spacing: 20,
              runSpacing: 15,
              children: [
                for (var urlInfo in prePostUrls)
                  _buildLinkActionButton(urlInfo),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLinkActionButton(PrePostUrlParams urlInfo) {
    final buttonText = urlInfo.buttonText;
    var surveyUrl = urlInfo.surveyUrl;
    final bool isButtonVisible = buttonText != null && buttonText.isNotEmpty;
    final bool isSurveyUrlValid = surveyUrl != null && surveyUrl.isNotEmpty;

    if (isButtonVisible && isSurveyUrlValid) {
      return ActionButton(
        color: context.theme.colorScheme.primary,
        text: buttonText,
        onPressed: () => alertOnError(
          context,
          () => _presenter.launchUrl(urlInfo),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildAddURLParameterButton(int urlIndex) {
    // Complex UI in order to keep button on most left side and have nice splash while clicking it.
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onTap: () => _presenter.addNewURLParamRow(urlIndex),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Add URL Parameter',
                    style: AppTextStyle.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteActionLink(int urlIndex) {
    return Padding(
      padding: EdgeInsets.only(top: 25),
      child: AppClickableWidget(
        child: Icon(CupertinoIcons.delete),
        onTap: () => _presenter.removeActionLinkOption(urlIndex),
      ),
    );
  }
}

class AttributeOption extends StatefulWidget {
  final PrePostCardAttribute attribute;
  final List<PrePostCardAttributeType> innerAvailableAttributeTypes;
  final int urlIndex;
  final int attributeIndex;

  final Function(String?) onValidateUrlParameter;
  final Function() onDeleteQueryParamRow;
  final Function(String?) onUpdateEnteredQueryName;
  final Function(PrePostCardAttributeType?) onUpdateAttributeTypeSelection;

  const AttributeOption({
    Key? key,
    required this.attribute,
    required this.innerAvailableAttributeTypes,
    required this.urlIndex,
    required this.attributeIndex,
    required this.onValidateUrlParameter,
    required this.onDeleteQueryParamRow,
    required this.onUpdateEnteredQueryName,
    required this.onUpdateAttributeTypeSelection,
  }) : super(key: key);

  @override
  _AttributeOptionState createState() => _AttributeOptionState();
}

class _AttributeOptionState extends State<AttributeOption> {
  late bool isEditMode;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    isEditMode = isNullOrEmpty(widget.attribute.queryParam);
    _textController = TextEditingController(text: widget.attribute.queryParam);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEditMode
        ? _buildEditAttributeView()
        : _buildAttributeSelectedView();
  }

  Widget _buildAttributeSelectedView() {
    return ActionButton(
      onPressed: () {
        setState(() {
          isEditMode = true;
        });
      },
      text: widget.attribute.type.text,
      color: AppColor.brightGreen,
      icon: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          Icons.edit,
        ),
      ),
      iconSide: ActionButtonIconSide.right,
      padding: EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(30),
    );
  }

  Widget _buildEditAttributeView() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: 'URL Parameter',
                  controller: _textController,
                  initialValue: _textController.text,
                  borderType: BorderType.outline,
                  borderRadius: 10,
                  maxLines: 1,
                  maxLength: 20,
                  onChanged: (_) =>
                      widget.onUpdateEnteredQueryName(_textController.text),
                  validator: (text) => widget.onValidateUrlParameter(text),
                ),
              ),
              SizedBox(width: 10),
              AppClickableWidget(
                onTap: () => widget.onDeleteQueryParamRow(),
                child: Icon(CupertinoIcons.delete),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(right: 45),
          child: _buildDropDownButton(
            widget.attribute,
            widget.innerAvailableAttributeTypes,
            widget.urlIndex,
            widget.attributeIndex,
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDropDownButton(
    PrePostCardAttribute postCardAttribute,
    List<PrePostCardAttributeType> innerAvailableAttributeTypes,
    int urlIndex,
    int attributeIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<PrePostCardAttributeType>(
        alignment: Alignment.centerLeft,
        isExpanded: true,
        underline: SizedBox.shrink(),
        value: postCardAttribute.type,
        icon: Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
          ),
        ),
        selectedItemBuilder: (context) {
          return [
            for (final attributeType in innerAvailableAttributeTypes)
              // Button which is selected
              Container(
                // Add alignment, because by default it show on top
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    attributeType.text,
                    style: AppTextStyle.body,
                  ),
                ),
              ),
          ];
        },
        items: innerAvailableAttributeTypes
            .map(
              (e) => DropdownMenuItem<PrePostCardAttributeType>(
                value: e,
                // Button which is in the selection list (when expanded)
                child: Text(
                  e.text,
                  style: AppTextStyle.body,
                ),
              ),
            )
            .toList(),
        // Whenever button from dropdown is changed
        onChanged: (PrePostCardAttributeType? selectedType) {
          widget.onUpdateAttributeTypeSelection(selectedType);
        },
      ),
    );
  }
}

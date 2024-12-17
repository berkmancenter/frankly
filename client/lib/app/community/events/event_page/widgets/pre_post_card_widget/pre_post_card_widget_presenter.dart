import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/widgets/pre_post_card_widget/pre_post_card_widget_page.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/extensions.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_card_attribute.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:provider/provider.dart';

import 'pre_post_card_widget_contract.dart';
import 'pre_post_card_widget_model.dart';

class PrePostCardWidgetPresenter {
  final PrePostCardWidgetView _view;
  final PrePostCardWidgetModel _model;
  final PrePostCardWidgetPresenterHelper _helper;
  final CloudFunctionsService _cloudFunctionsService;
  final UserService _userService;

  PrePostCardWidgetPresenter(
    BuildContext context,
    this._view,
    this._model, {
    PrePostCardWidgetPresenterHelper? prePostCardWidgetPresenterHelper,
    CloudFunctionsService? testCloudFunctionsService,
    UserService? userService,
  })  : _helper = prePostCardWidgetPresenterHelper ??
            PrePostCardWidgetPresenterHelper(),
        _cloudFunctionsService =
            testCloudFunctionsService ?? cloudFunctionsService,
        _userService =
            userService ?? Provider.of<UserService>(context, listen: false);

  void init(
    PrePostCardWidgetType prePostCardWidgetType,
    PrePostCard? prePostCard,
  ) {
    _model.prePostCard =
        prePostCard ?? PrePostCard.newCard(_model.prePostCardType);
    _model.prePostCardWidgetType = prePostCardWidgetType;
    initProfile();
    _view.updateView();
  }

  String? validateHeadline(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Headline cannot be empty';
    } else {
      return null;
    }
  }

  String? validateMessage(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Message cannot be empty';
    } else {
      return null;
    }
  }

  String? validateUrlParameter(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'URL parameter cannot be empty';
    } else {
      return null;
    }
  }

  String? validateButtonText(String? text, int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;

    final textIsEmpty = text == null || text.trim().isEmpty;
    final urlIsNotEmpty = urlIndex < prePostUrls.length &&
        prePostUrls[urlIndex].surveyUrl != null;
    if (urlIsNotEmpty && textIsEmpty) {
      return 'Button text cannot be empty';
    }
    return null;
  }

  String? validateUrl(String? text, int urlIndex) {
    final prePostUrls = _model.prePostCard.prePostUrls;

    bool doesSurveyUrlExist = true;
    bool areAnyAttributesAdded = true;

    if (urlIndex < prePostUrls.length) {
      doesSurveyUrlExist = prePostUrls[urlIndex].surveyUrl?.isNotEmpty == true;
      areAnyAttributesAdded = prePostUrls[urlIndex].attributes.isNotEmpty;

      if (!doesSurveyUrlExist && areAnyAttributesAdded) {
        return 'URL cannot be empty if some attributes are entered';
      }

      // Only do validation for the URL if button text exists
      if (prePostUrls[urlIndex].buttonText != null) {
        if (text == null || text.trim().isEmpty) {
          return 'URL is not valid';
        }

        final isUrlValid = Uri.tryParse(text) != null;

        if (!isUrlValid) {
          return 'URL is not valid';
        } else {
          return null;
        }
      }
    }
    return null;
  }

  List<PrePostCardAttributeType> getAvailableAttributeTypes(
    List<PrePostCardAttribute> selectedAttributes,
  ) {
    final List<PrePostCardAttributeType> prePostCardAttributeTypes =
        List.of(PrePostCardAttributeType.values);
    for (var selectedAttribute in selectedAttributes) {
      prePostCardAttributeTypes
          .removeWhere((element) => element == selectedAttribute.type);
    }

    return prePostCardAttributeTypes;
  }

  bool isEditIconShown() {
    return _model.isEditable &&
        _model.prePostCardWidgetType == PrePostCardWidgetType.overview;
  }

  void addNewURLParamRow(int urlIndex) {
    // Always marking is as true. Not a mistake.
    _model.isAddURLParamsSectionVisible = true;

    var prePostUrls = _model.prePostCard.prePostUrls;

    if (urlIndex < prePostUrls.length) {
      final List<PrePostCardAttributeType> prePostCardAttributeTypes =
          List.of(getAvailableAttributeTypes(prePostUrls[urlIndex].attributes));

      // Check for the first attribute. Nullability should never happen, but secure
      // just in case.
      final firstAttribute = prePostCardAttributeTypes.firstOrNull;
      if (firstAttribute == null) {
        return;
      }

      final List<PrePostCardAttribute> attributes =
          List.of(prePostUrls[urlIndex].attributes);

      prePostUrls[urlIndex] = prePostUrls[urlIndex].copyWith(
        attributes: [
          ...attributes,
          PrePostCardAttribute(type: firstAttribute, queryParam: ''),
        ],
      );

      _model.prePostCard =
          _model.prePostCard.copyWith(prePostUrls: prePostUrls);

      _view.updateView();
    }
  }

  Future<void> launchUrl(PrePostUrlParams prepostParams) async {
    final finalisedUrl = getFinalisedUrl(prepostParams);
    await _helper.launchUrlFromUtils(finalisedUrl);
  }

  void removeActionLinkOption(int urlIndex) {
    var prePostUrls = _model.prePostCard.prePostUrls;
    List<PrePostUrlParams> prePostUrlsList = [];

    if (urlIndex < prePostUrls.length) {
      prePostUrlsList = List.of(prePostUrls);
      prePostUrlsList = prePostUrls..removeAt(urlIndex);
      _model.prePostCard = _model.prePostCard.copyWith(
        prePostUrls: prePostUrlsList,
      );
      _view.updateView();
    }
  }

  void addNewActionLink() {
    var prePostUrls = _model.prePostCard.prePostUrls;

    prePostUrls.add(
      PrePostUrlParams(buttonText: '', surveyUrl: '', attributes: []),
    );
    _model.prePostCard = _model.prePostCard.copyWith(prePostUrls: prePostUrls);
    _view.updateView();
  }

  void updateCard(int urlIndex) {
    var prePostUrls = _model.prePostCard.prePostUrls;
    List<PrePostCardAttribute> attributes = [];

    if (urlIndex < prePostUrls.length) {
      attributes = List.of(prePostUrls[urlIndex].attributes);
      // Remove attributes if query param is not entered
      attributes.removeWhere((element) => element.queryParam.isEmpty);
      prePostUrls[urlIndex] =
          prePostUrls[urlIndex].copyWith(attributes: attributes);
      _model.prePostCard =
          _model.prePostCard.copyWith(prePostUrls: prePostUrls);
      _model.prePostCardWidgetType = PrePostCardWidgetType.overview;
      _view.updateView();
    }
  }

  PrePostCard getPrePostCardDetailsToSave() {
    var prePostUrls = _model.prePostCard.prePostUrls;
    prePostUrls.removeWhere(
      (link) => isNullOrEmpty(link.buttonText) || isNullOrEmpty(link.surveyUrl),
    );

    prePostUrls = prePostUrls
        .map(
          (link) => link.copyWith(
            attributes: link.attributes
                .map(
                  (attribute) => attribute.copyWith(
                    queryParam: attribute.queryParam.trim().isEmpty
                        ? attribute.defaultQueryParam
                        : attribute.queryParam.trim(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    _model.prePostCard = _model.prePostCard.copyWith(prePostUrls: prePostUrls);

    return _model.prePostCard;
  }

  void updateAttributeTypeSelection(
    PrePostCardAttributeType? selectedType,
    int urlIndex,
    int attributeIndex,
  ) {
    if (selectedType != null) {
      var prePostUrls = _model.prePostCard.prePostUrls;
      if (urlIndex < prePostUrls.length) {
        final PrePostCardAttribute prePostCardAttribute = prePostUrls[urlIndex]
            .attributes[attributeIndex]
            .copyWith(type: selectedType);
        prePostUrls[urlIndex].attributes[attributeIndex] = prePostCardAttribute;
        _model.prePostCard.copyWith(prePostUrls: prePostUrls);
        _view.updateView();
      }
    }
  }

  void updateEnteredQueryName(
    int urlIndex,
    int attributeIndex,
    PrePostCardAttribute attribute,
    text,
  ) {
    var prePostUrls = _model.prePostCard.prePostUrls;

    if (urlIndex < prePostUrls.length) {
      prePostUrls[urlIndex].attributes[attributeIndex] =
          attribute.copyWith(queryParam: text);
      _model.prePostCard.copyWith(prePostUrls: prePostUrls);
      _view.updateView();
    }
  }

  void updateEnteredUrl(String text, int urlIndex) {
    // If input is nothing - nullify
    final String? manipulatedText;
    if (text.isEmpty) {
      manipulatedText = null;
    } else {
      manipulatedText = text;
    }

    final prePostUrls = _model.prePostCard.prePostUrls;

    if (urlIndex < prePostUrls.length) {
      prePostUrls[urlIndex] =
          prePostUrls[urlIndex].copyWith(surveyUrl: manipulatedText);
      _model.prePostCard =
          _model.prePostCard.copyWith(prePostUrls: prePostUrls);
      _view.updateView();
    }
  }

  void updateEnteredButtonText(int urlIndex, String text) {
    // If input is nothing - nullify
    final String? manipulatedText;
    if (text.isEmpty) {
      manipulatedText = null;
    } else {
      manipulatedText = text;
    }
    _view.updateView();
    var prePostUrls = _model.prePostCard.prePostUrls;

    if (urlIndex < prePostUrls.length) {
      prePostUrls[urlIndex] =
          prePostUrls[urlIndex].copyWith(buttonText: manipulatedText);
      _model.prePostCard =
          _model.prePostCard.copyWith(prePostUrls: prePostUrls);
    }
  }

  void updateEnteredMessage(String text) {
    _model.prePostCard = _model.prePostCard.copyWith(message: text);
    _view.updateView();
  }

  void updateEnteredHeadline(String text) {
    _model.prePostCard = _model.prePostCard.copyWith(headline: text);
    _view.updateView();
  }

  bool hasBeenEdited(Event? event) {
    final prePostCard = _model.prePostCardType == PrePostCardType.preEvent
        ? event?.preEventCardData
        : event?.postEventCardData;
    final headline = prePostCard?.headline ?? '';
    final message = prePostCard?.message ?? '';

    return headline != _model.prePostCard.headline ||
        message != _model.prePostCard.message ||
        _model.prePostCard.prePostUrls.isNotEmpty;
  }

  void toggleExpansion() {
    _model.isExpanded = !_model.isExpanded;
    _view.updateView();
  }

  void toggleCardType() {
    switch (_model.prePostCardWidgetType) {
      case PrePostCardWidgetType.overview:
        _model.prePostCardWidgetType = PrePostCardWidgetType.edit;
        break;
      case PrePostCardWidgetType.edit:
        _model.prePostCardWidgetType = PrePostCardWidgetType.overview;
        break;
    }
    _view.updateView();
  }

  void afterPrePostDataSaved() {
    _view.showToast('Saved');
    toggleCardType();
  }

  /// Make sure the one selected always has its own attribute type as well.
  ///
  /// If we avoid this logic, DropDown button will crash upon selection, because selected item
  /// is removed from overall list. Thus it doesn't exist anymore.
  /// This logic prevents that from happening since selected item is always in the list (thus ..add).
  List<PrePostCardAttributeType> getInnerAvailableAttributeTypes(
    List<PrePostCardAttributeType> availableAttributeTypes,
    PrePostCardAttributeType type,
  ) {
    return [...availableAttributeTypes, type];
  }

  @visibleForTesting
  Future<void> initProfile() async {
    _model.email = await _helper.getEmail(_userService, _cloudFunctionsService);
    _view.updateView();
  }

  void deleteQueryParamRow(int urlIndex, int attributeIndex) {
    var prePostUrls = _model.prePostCard.prePostUrls;

    if (urlIndex < prePostUrls.length) {
      List<PrePostCardAttribute> attributes =
          List.of(prePostUrls[urlIndex].attributes);

      attributes = prePostUrls[urlIndex].attributes..removeAt(attributeIndex);

      prePostUrls[urlIndex] =
          prePostUrls[urlIndex].copyWith(attributes: attributes);

      _model.prePostCard =
          _model.prePostCard.copyWith(prePostUrls: prePostUrls);

      _view.updateView();
    }
  }

  String getFinalisedUrl(PrePostUrlParams? urlInfo) {
    if (urlInfo == null) return '';

    return _model.prePostCard.getFinalisedUrl(
      userId: _userService.currentUserId,
      event: _model.event,
      email: _model.email,
      urlInfo: urlInfo,
    );
  }

  String getTitle() {
    switch (_model.prePostCardType) {
      case PrePostCardType.preEvent:
        return 'Pre-event';
      case PrePostCardType.postEvent:
        return 'Post-event';
    }
  }
}

@visibleForTesting
class PrePostCardWidgetPresenterHelper {
  Future<void> launchUrlFromUtils(String url) async {
    await launch(url, targetIsSelf: false);
  }

  Future<String?> getEmail(
    UserService userService,
    CloudFunctionsService cloudFunctionsService,
  ) async {
    final String? userId = userService.currentUserId;
    if (userId == null) {
      loggingService.log(
        'PrePostCardWidgetPresenterHelper.getEmail: userId is null',
        logType: LogType.error,
      );
      return null;
    }

    GetUserAdminDetailsResponse? getUserAdminDetailsResponse;
    try {
      getUserAdminDetailsResponse =
          await cloudFunctionsService.getUserAdminDetails(
        GetUserAdminDetailsRequest(
          userIds: [userId],
        ),
      );
    } catch (e, s) {
      loggingService.log(
        'PrePostCardWidgetPresenterHelper.getEmail',
        error: e,
        stackTrace: s,
      );
    }

    final userAdminDetails = getUserAdminDetailsResponse?.userAdminDetails;
    if (userAdminDetails == null) {
      loggingService.log(
        'PrePostCardWidgetPresenterHelper.getEmail: userAdminDetails is null. UserId: $userId',
        logType: LogType.error,
      );
      return null;
    }

    if (userAdminDetails.isEmpty) {
      loggingService.log(
        'PrePostCardWidgetPresenterHelper.getEmail: userAdminDetails is empty. UserId: $userId',
        logType: LogType.error,
      );
      return null;
    }

    return userAdminDetails.first.email;
  }
}

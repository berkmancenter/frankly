import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/user_admin_details_builder.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';

import 'pre_post_discussion_dialog_model.dart';

class PrePostDiscussionDialogPresenter {
  final PrePostDiscussionDialogModel _model;
  final PrePostDiscussionDialogPresenterHelper _helper;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserAdminDetailsProvider userAdminDetailsProvider;

  PrePostDiscussionDialogPresenter(
    this._model, {
    PrePostDiscussionDialogPresenterHelper? helper,
    ResponsiveLayoutService? testResponsiveLayoutService,
    required this.userAdminDetailsProvider,
  })  : _helper = helper ?? PrePostDiscussionDialogPresenterHelper(),
        _responsiveLayoutService = testResponsiveLayoutService ?? responsiveLayoutService;

  void initialize() {
    // Start loading email
    userAdminDetailsProvider.getInfoFuture();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  double getSize(BuildContext context, double initialSize, {double? scale}) {
    return _responsiveLayoutService.getDynamicSize(context, initialSize, scale: scale);
  }

  Future<void> launchSurvey(PrePostUrlParams urlInfo) async {
    final details = await userAdminDetailsProvider.getInfoFuture();
    final surveyUrl = _model.prePostCard.getFinalisedUrl(
      userId: userService.currentUserId,
      discussion: _model.discussion,
      email: details?.email,
      urlInfo: urlInfo,
    );

    if (surveyUrl.isNotEmpty) {
      await _helper.launchUrl(surveyUrl, kIsWeb);
    }
  }
}

@visibleForTesting
class PrePostDiscussionDialogPresenterHelper {
  Future<void> launchUrl(String surveyUrl, bool isWeb) async {
    await launch(surveyUrl, isWeb: isWeb);
  }
}

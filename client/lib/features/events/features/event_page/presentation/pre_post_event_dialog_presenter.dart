import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/services.dart';
import 'package:data_models/events/pre_post_url_params.dart';

import '../data/models/pre_post_event_dialog_model.dart';

class PrePostEventDialogPresenter {
  final PrePostEventDialogModel _model;
  final PrePostEventDialogPresenterHelper _helper;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserAdminDetailsProvider userAdminDetailsProvider;

  PrePostEventDialogPresenter(
    this._model, {
    PrePostEventDialogPresenterHelper? helper,
    ResponsiveLayoutService? testResponsiveLayoutService,
    required this.userAdminDetailsProvider,
  })  : _helper = helper ?? PrePostEventDialogPresenterHelper(),
        _responsiveLayoutService =
            testResponsiveLayoutService ?? responsiveLayoutService;

  void initialize() {
    // Start loading email
    userAdminDetailsProvider.getInfoFuture();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  double getSize(BuildContext context, double initialSize, {double? scale}) {
    return _responsiveLayoutService.getDynamicSize(
      context,
      initialSize,
      scale: scale,
    );
  }

  Future<void> launchSurvey(PrePostUrlParams urlInfo) async {
    final details = await userAdminDetailsProvider.getInfoFuture();
    final surveyUrl = _model.prePostCard.getFinalisedUrl(
      userId: userService.currentUserId,
      event: _model.event,
      email: details?.email,
      urlInfo: urlInfo,
    );

    if (surveyUrl.isNotEmpty) {
      await _helper.launchUrl(surveyUrl, kIsWeb);
    }
  }
}

@visibleForTesting
class PrePostEventDialogPresenterHelper {
  Future<void> launchUrl(String surveyUrl, bool isWeb) async {
    await launch(surveyUrl, isWeb: isWeb);
  }
}

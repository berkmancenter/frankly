import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/private_community_checkbox.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/mixins.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';

class DialogFlow extends StatefulWidget with ShowDialogMixin {
  final bool showAppNameOnMobile;

  const DialogFlow({
    this.showAppNameOnMobile = true,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DialogFlowState createState() => _DialogFlowState();
}

class _DialogFlowState extends State<DialogFlow> {
  final FocusNode _nameFocus = FocusNode();
  Community _community = Community(
    id: firestoreDatabase.generateNewCommunityId(),
    isPublic: true,
    isOnboardingOverviewEnabled: true,
  );

  int _onStep = 1;
  String? _createdCommunityId;

  // Development flag to turn on or off sending the data to firestore
  static const bool _createCommunity = true;

  @override
  void initState() {
    super.initState();
  }

  /// Returns true if UI should move to next step
  Future<bool> _nextButtonAction() async {
    if (_createCommunity) {
      try {
        _createdCommunityId =
            (await cloudFunctionsCommunityService.createCommunity(
          CreateCommunityRequest(community: _community),
        ))
                .communityId;
      } catch (e, s) {
        loggingService.log(e, logType: LogType.error);
        loggingService.log(s, logType: LogType.error);

        // TODO: Handle error properly
        // final sanitizedError = sanitizeError(e.toString());

        _createdCommunityId = null;
      }
      final createdCommunityId = _createdCommunityId;
      if (createdCommunityId != null) {
        analytics.logEvent(
          AnalyticsCreateCommunityEvent(communityId: createdCommunityId),
        );
        setState(
          () => _community = _community.copyWith(id: createdCommunityId),
        );
        // Immediately proceed to created community
        Navigator.of(context).pop();
        routerDelegate.beamTo(
          CommunityPageRoutes(
            // Use the displayId if available, otherwise use the createdCommunityId
            communityDisplayId: _community.displayId.isNotEmpty
                ? _community.displayId
                : createdCommunityId,
          ).communityHome,
        );
      } else {
        Navigator.of(context).pop();
        await showAlert(context, context.l10n.somethingWentWrongTryAgain);
        return false;
      }
    }

    return true;
  }

  void _resetScroll() => Scrollable.of(context).position.jumpTo(0);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBody(
      maxWidth: 444,
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40),
        HeightConstrainedText(
          context.l10n.createACommunity,
          style: context.theme.textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        _buildStepContent(),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_onStep) {
      case 1:
        return _buildStepOneContent();

      case 2:
        return _buildStepTwoContent();

      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildStepOneContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        CreateCommunityTextFields(
          onNameChanged: (value) =>
              setState(() => _community = _community.copyWith(name: value)),
          onCustomDisplayIdChanged: (value) => setState(
            () => _community = _community.copyWith(
              displayIds: value.isNotEmpty ? [value] : [],
            ),
          ),
          nameFocus: _nameFocus,
          community: _community,
        ),
        SizedBox(height: 6),
        PrivateCommunityCheckbox(
          onUpdate: (bool? v) {
            final value = v ?? true;
            return setState(
              () => _community = _community.copyWith(isPublic: !value),
            );
          },
          value: !(_community.isPublic ?? true),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              text: context.l10n.finish,
              color: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10),
              onPressed: () async {
                if (await _nextButtonAction()) {
                  _resetScroll();
                  setState(() => _onStep++);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTwoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 10),
        Image.asset(
          AppAsset.kCongratulations.path,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 10),
        HeightConstrainedText(
          context.l10n.congratulations,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.communitySuccessPrefix,
                style: context.theme.textTheme.bodyLarge,
              ),
              TextSpan(text: '\n'),
              TextSpan(
                text: _community.name,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '.',
                style: context.theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          context.l10n.communitySuccessSuffix,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

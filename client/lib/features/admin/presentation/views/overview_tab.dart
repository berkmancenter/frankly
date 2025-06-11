import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/admin/presentation/accept_take_rate_presenter.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/create_community_text_fields.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/community/features/create_community/presentation/views/create_community_dialog.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/templates/features/create_template/presentation/views/create_template_dialog.dart';
import 'package:client/features/community/presentation/views/app_share.dart';
import 'package:client/features/community/presentation/widgets/share_section.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/step_progress_indicator.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

import 'overview_contract.dart';
import '../../data/models/overview_model.dart';
import '../overview_presenter.dart';

class OverviewTab extends StatefulHookWidget {
  const OverviewTab();

  @override
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> implements OverviewView {
  late final OverviewModel _model;
  late final OverviewPresenter _presenter;

  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;

  @override
  void initState() {
    super.initState();

    _model = OverviewModel();
    _presenter = OverviewPresenter(context, this, _model);
    _presenter.init();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CommunityProvider>();

    final onboardingStep = _presenter.getCurrentOnboardingStep();
    // final totalSteps = onboardingSteps.length;
    final isMobile = _presenter.isMobile(context);
    Community community = _presenter.getCommunity();

    if (isMobile) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProxiedImage(
                      null,
                      asset: onboardingStep == null
                          ? AppAsset.kEmojiPartyPng
                          : onboardingStep.titleIconPath,
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      onboardingStep == null
                          ? 'Now we’re talking!'
                          : onboardingStep.title,
                      style: AppTextStyle.subhead
                          .copyWith(color: context.theme.colorScheme.secondary),
                    ),
                  ],
                ),
                if (onboardingStep != null)
                  _buildProgressSection(isMobile, totalSteps, onboardingStep),
                SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: totalSteps,
                  itemBuilder: (context, index) {
                    final onboardingStep = onboardingSteps[index];

                    return _buildStepSection(onboardingStep);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeightConstrainedText(
                context.l10n.basicSettings,
                style: context.theme.textTheme.titleMedium,
              ),
              CreateCommunityTextFields(
                showChooseCustomDisplayId: true,
                onCustomDisplayIdChanged: (value) => setState(
                  () => community = community.copyWith(
                    displayIds: value.isNotEmpty ? [value] : [],
                  ),
                ),
                onNameChanged: (value) =>
                    setState(() => community = community.copyWith(name: value)),
                community: community,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildProgressSection(
    bool isMobile,
    int totalSteps,
    OnboardingStep onboardingStep,
  ) {
    final completedStepCount = _presenter.getCompletedStepCount();

    if (isMobile) {
      return Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            child: _buildStepsCounter(completedStepCount, totalSteps),
          ),
          SizedBox(width: 5),
          Row(
            children: [
              Expanded(
                child: StepProgressIndicator(
                  completedStepCount: completedStepCount,
                  totalSteps: totalSteps,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: StepProgressIndicator(
              completedStepCount: completedStepCount,
              totalSteps: totalSteps,
            ),
          ),
          SizedBox(width: 10),
          _buildStepsCounter(completedStepCount, totalSteps),
        ],
      );
    }
  }

  Widget _buildStepsCounter(int completedStepCount, int totalSteps) {
    return Text(
      '$completedStepCount/$totalSteps',
      style: AppTextStyle.body
          .copyWith(color: context.theme.colorScheme.onPrimaryContainer),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildStepSection(OnboardingStep onboardingStep) {
    final isOnboardingStepCompleted =
        _presenter.isOnboardingStepCompleted(onboardingStep);
    final subtitle = _presenter.getSubtitle(onboardingStep);
    final learnMoreUrl = _presenter.getLearnMoreUrl(onboardingStep);
    final isOnboardingStepExpanded =
        _presenter.isOnboardingStepExpanded(onboardingStep);

    return AppClickableWidget(
      isIcon: false,
      onTap: () => _presenter.toggleExpansion(onboardingStep),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProxiedImage(
            null,
            asset: isOnboardingStepCompleted
                ? AppAsset.kCheckCircleGreen
                : AppAsset.kCheckCircleGray,
            width: 20,
            height: 20,
          ),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    onboardingStep.sectionTitle,
                    style: AppTextStyle.bodyMedium
                        .copyWith(color: context.theme.colorScheme.secondary),
                  ),
                ),
                AnimatedSize(
                  duration: kTabScrollDuration,
                  alignment: Alignment.centerLeft,
                  child: isOnboardingStepExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyle.body.copyWith(
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                  children: [
                                    TextSpan(text: subtitle),
                                    if (learnMoreUrl != null)
                                      TextSpan(
                                        text: 'Learn More',
                                        style: AppTextStyle.body.copyWith(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => launch(learnMoreUrl),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // _buildBottomStepSection(onboardingStep),
                          ],
                        )
                      // Make sure to user Container instead of SizedBox.shrink because Container
                      // Will take horizontally enough space for animation to be more `smooth`.
                      // SizedBox.shrink doesn't have any boundaries therefore animated text feels
                      // unnatural.
                      : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStepSection(OnboardingStep onboardingStep) {
    final isMobile = _presenter.isMobile(context);
    final isOnboardingStepCompleted =
        _presenter.isOnboardingStepCompleted(onboardingStep);

    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        return ActionButton(
          text: 'Edit your Community',
          icon: Icon(Icons.edit, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: context.theme.colorScheme.primary,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: context.theme.colorScheme.primary),
          onPressed: () {
            final community = _presenter.getCommunity();

            CreateCommunityDialog(community: community).show();
          },
        );
      case OnboardingStep.createGuide:
        return ActionButton(
          text: 'New template',
          icon: Icon(Icons.add, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: context.theme.colorScheme.primary,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: context.theme.colorScheme.primary),
          onPressed: () {
            CreateTemplateDialog.show(
              communityProvider: context.read<CommunityProvider>(),
              communityPermissionsProvider:
                  context.read<CommunityPermissionsProvider>(),
            );
          },
        );
      case OnboardingStep.hostEvent:
        return ActionButton(
          text: 'New event',
          icon: Icon(Icons.add, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: context.theme.colorScheme.primary,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: context.theme.colorScheme.primary),
          onPressed: () {
            CreateEventDialog.show(context);
          },
        );
      case OnboardingStep.inviteSomeone:
        final community = _presenter.getCommunity();
        final title = community.name;
        final subject = 'Join $title on ${Environment.appName}';
        final body = 'Hey, check out $title on ${Environment.appName}!';
        final shareData = AppShareData(
          subject: subject,
          body: body,
          pathToPage: '/space/${community.id}',
        );

        return ShareSection(
          iconColor: context.theme.colorScheme.primary,
          iconBackgroundColor: context.theme.colorScheme.onPrimary,
          url: shareData.pathToPage,
          body: body,
          subject: subject,
          buttonPadding: 5,
          iconSize: isMobile ? 13 : 22,
        );
      case OnboardingStep.createStripeAccount:
        return ActionButton(
          text: isOnboardingStepCompleted
              ? 'Update Stripe Account'
              : 'Connect to Stripe',
          textColor: context.theme.colorScheme.primary,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: context.theme.colorScheme.primary),
          onPressed: () async {
            // Show dialog only if user has not created an account
            if (!isOnboardingStepCompleted) {
              final communityProvider = context.read<CommunityProvider>();
              final isAccepted =
                  await AcceptTakeRatePresenter.showAcceptTakeRateDialog(
                context,
                communityProvider,
              );
              if (!isAccepted) {
                return;
              }
            }

            await alertOnError(
              context,
              () => _presenter.proceedToConnectWithStripePage(),
            );
          },
        );
    }
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/home/creation_dialog/components/upgrade_perks.dart';
import 'package:junto/app/home/creation_dialog/create_junto_dialog.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/junto/widgets/share/app_share.dart';
import 'package:junto/app/junto/widgets/share/share_section.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/overview_progress_indicator.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

import 'overview_contract.dart';
import 'overview_model.dart';
import 'overview_presenter.dart';

class OverviewTab extends StatefulHookWidget {
  final void Function() onUpgradeTap;

  const OverviewTab({required this.onUpgradeTap});

  @override
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> implements OverviewView {
  late final OverviewModel _model;
  late final OverviewPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = OverviewModel();
    _presenter = OverviewPresenter(context, this, _model);
    _presenter.init();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<JuntoProvider>();
    final onboardingSteps = OnboardingStep.values.toList();
    if (!kShowStripeFeatures) {
      onboardingSteps.remove(OnboardingStep.createStripeAccount);
    }

    final onboardingStep = _presenter.getCurrentOnboardingStep();
    final totalSteps = onboardingSteps.length;
    final isMobile = _presenter.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    JuntoImage(
                      null,
                      asset: onboardingStep == null
                          ? AppAsset.kEmojiPartyPng
                          : onboardingStep.titleIconPath,
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      onboardingStep == null ? 'Now we’re talking!' : onboardingStep.title,
                      style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
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
                    }),
              ],
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: UpgradePerks(onUpgradeTap: () => widget.onUpgradeTap()),
          ),
        ],
      );
    } else {
      return Row(
        // Make sure it's locked as start. Otherwise after toggling selection of step,
        // right section will glitch positions
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;

                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (onboardingStep == null)
                        Row(
                          children: [
                            SizedBox(width: 5),
                            JuntoImage(
                              null,
                              asset: AppAsset.kEmojiPartyPng,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Now we’re talking!',
                              style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            SizedBox(width: 5),
                            JuntoImage(
                              null,
                              asset: onboardingStep.titleIconPath,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                onboardingStep.title,
                                style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
                              ),
                            ),
                            SizedBox(
                              // Pretty specific width constraint. We have to make sure that
                              // `progress` line has enough but not too much space within the row.
                              width: containerWidth / 2.6,
                              child: _buildProgressSection(
                                isMobile,
                                totalSteps,
                                onboardingStep,
                              ),
                            )
                          ],
                        ),
                      SizedBox(height: onboardingStep == null ? 10 : 30),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: totalSteps,
                          itemBuilder: (context, index) {
                            final onboardingStep = onboardingSteps[index];

                            return _buildStepSection(onboardingStep);
                          }),
                    ],
                  ),
                );
              },
            ),
          ),
          Spacer(),
          Expanded(
            flex: 2,
            child: UpgradePerks(onUpgradeTap: () => widget.onUpgradeTap()),
          ),
        ],
      );
    }
  }

  Widget _buildProgressSection(bool isMobile, int totalSteps, OnboardingStep onboardingStep) {
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
                child: OnboardingOverviewProgressIndicator(
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
            child: OnboardingOverviewProgressIndicator(
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
      style: AppTextStyle.body.copyWith(color: AppColor.gray3),
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
    final isOnboardingStepCompleted = _presenter.isOnboardingStepCompleted(onboardingStep);
    final subtitle = _presenter.getSubtitle(onboardingStep);
    final learnMoreUrl = _presenter.getLearnMoreUrl(onboardingStep);
    final isOnboardingStepExpanded = _presenter.isOnboardingStepExpanded(onboardingStep);

    return AppClickableWidget(
      isIcon: false,
      onTap: () => _presenter.toggleExpansion(onboardingStep),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JuntoImage(
            null,
            asset:
                isOnboardingStepCompleted ? AppAsset.kCheckCircleGreen : AppAsset.kCheckCircleGray,
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
                    style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1),
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
                                    style: AppTextStyle.body.copyWith(color: AppColor.gray3),
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
                                    ]),
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildBottomStepSection(onboardingStep),
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
    final isOnboardingStepCompleted = _presenter.isOnboardingStepCompleted(onboardingStep);

    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        return ActionButton(
          text: 'Edit your Community',
          icon: Icon(Icons.edit, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: AppColor.darkBlue,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: AppColor.darkBlue),
          onPressed: () {
            final junto = _presenter.getJunto();

            CreateJuntoDialog(junto: junto).show();
          },
        );
      case OnboardingStep.createGuide:
        return ActionButton(
          text: 'New template',
          icon: Icon(Icons.add, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: AppColor.darkBlue,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: AppColor.darkBlue),
          onPressed: () {
            CreateTopicDialog.show(
              juntoProvider: context.read<JuntoProvider>(),
              communityPermissionsProvider: context.read<CommunityPermissionsProvider>(),
            );
          },
        );
      case OnboardingStep.hostConversation:
        return ActionButton(
          text: 'New event',
          icon: Icon(Icons.add, size: 20),
          iconSide: ActionButtonIconSide.right,
          textColor: AppColor.darkBlue,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: AppColor.darkBlue),
          onPressed: () {
            CreateDiscussionDialog.show(context);
          },
        );
      case OnboardingStep.inviteSomeone:
        final junto = _presenter.getJunto();
        final title = junto.name;
        final subject = 'Join $title on Frankly';
        final body = 'Hey, check out $title on Frankly!';
        final shareData = AppShareData(
          subject: subject,
          body: body,
          pathToPage: '/space/${junto.id}',
        );

        return ShareSection(
          iconColor: AppColor.darkBlue,
          iconBackgroundColor: AppColor.white,
          url: shareData.pathToPage,
          body: body,
          subject: subject,
          buttonPadding: 5,
          iconSize: isMobile ? 13 : 22,
        );
      case OnboardingStep.createStripeAccount:
        return ActionButton(
          text: isOnboardingStepCompleted ? 'Update Stripe Account' : 'Connect to Stripe',
          textColor: AppColor.darkBlue,
          type: ActionButtonType.outline,
          borderSide: BorderSide(color: AppColor.darkBlue),
          onPressed: () async {
            // Show dialog only if user has not created an account
            if (!isOnboardingStepCompleted) {
              final juntoProvider = context.read<JuntoProvider>();
              final isAccepted = await Dialogs.showAcceptTakeRateDialog(context, juntoProvider);
              if (!isAccepted) {
                return;
              }
            }

            await alertOnError(context, () => _presenter.proceedToConnectWithStripePage());
          },
        );
    }
  }
}

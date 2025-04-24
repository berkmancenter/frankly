import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/upgrade_perks.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/admin/presentation/widgets/confirm_dialog_white.dart';
import 'package:client/core/widgets/profile_chip.dart';
import 'package:client/features/community/data/providers/user_admin_details_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/features/admin/data/services/stripe_client_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/admin/billing_subscription.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:client/core/localization/localization_helper.dart';

/// Shows subscription information  for the community and links to manage billing
class AdminBillingTab extends StatefulWidget {
  const AdminBillingTab({Key? key}) : super(key: key);

  @override
  State<AdminBillingTab> createState() => _AdminBillingTabState();
}

class _AdminBillingTabState extends State<AdminBillingTab> {
  @override
  Widget build(BuildContext context) {
    if (responsiveLayoutService.isMobile(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBillingContainer(),
          SizedBox(height: 40),
          UpgradePerks(),
        ],
      );

  Widget _buildDesktopLayout() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: _buildBillingContainer(),
          ),
          Spacer(),
          Expanded(
            flex: 2,
            child: UpgradePerks(),
          ),
        ],
      );

  Widget _buildBillingContainer() => Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: MemoizedStreamBuilder<BillingSubscription?>(
          streamGetter: () =>
              firestoreBillingSubscriptionsService.getActiveSubscription(
            userId: userService.currentUserId!,
            communityId: context.watch<CommunityProvider>().community.id,
          ),
          builder: (context, subscription) {
            return _AdminBillingContainerContent(
              // If the users subscription changes while they are on this page this will reset the
              // state. This is necessary because when they upgrade accounts it can take a second
              // for the new plan webhook to flow through our backend.
              key: Key(
                subscription?.type ??
                    _AdminBillingContainerContentState._freeSubscriptionType,
              ),
              subscription: subscription,
            );
          },
        ),
      );
}

class _AdminBillingContainerContent extends StatefulWidget {
  final BillingSubscription? subscription;

  const _AdminBillingContainerContent({
    required this.subscription,
    Key? key,
  }) : super(key: key);

  @override
  _AdminBillingContainerContentState createState() =>
      _AdminBillingContainerContentState();
}

class _AdminBillingContainerContentState
    extends State<_AdminBillingContainerContent> {
  static const _freeSubscriptionType = 'free';
  static const _individualSubscriptionType = 'individual';
  static const _clubSubscriptionType = 'club';
  static const _proSubscriptionType = 'pro';
  static const _customSubscriptionType = 'custom';
  static const plans = <Plan>[
    Plan(
      name: 'Free',
      cost: '',
      typeCode: _freeSubscriptionType,
      planType: null,
    ),
    Plan(
      name: 'Individual',
      cost: '\$99',
      typeCode: _individualSubscriptionType,
      planType: PlanType.individual,
    ),
    Plan(
      name: 'Club',
      cost: '\$299',
      typeCode: _clubSubscriptionType,
      planType: PlanType.club,
    ),
    Plan(
      name: 'Pro',
      cost: '\$799',
      typeCode: _proSubscriptionType,
      planType: PlanType.pro,
    ),
    Plan(
      name: 'Enterprise',
      cost: 'contact',
      typeCode: _customSubscriptionType,
      planType: null,
    ),
  ];

  late final String _initialPlan =
      widget.subscription?.type ?? _freeSubscriptionType;

  late Plan _selectedPlan = plans.firstWhere(
    (element) => element.typeCode == _initialPlan,
    orElse: () => plans.first,
  );

  bool get _newPlanSelected => _selectedPlan.typeCode != _initialPlan;

  Future<void> _updatePlanPressed() async {
    final community = context.read<CommunityProvider>().community;
    final selectedPlanType = _selectedPlan.planType;

    final hasSubscription = await firestoreBillingSubscriptionsService
        .userHasResumableSubscriptionForCommunity(
      userId: userService.currentUserId!,
      communityId: community.id,
    );

    if (_selectedPlan.typeCode == _customSubscriptionType) {
      await launch(Environment.pricingUrl);
    } else if (hasSubscription) {
      if (selectedPlanType != null) {
        final priceInfo =
            await cloudFunctionsPaymentsService.getStripeSubscriptionPlanInfo(
          GetStripeSubscriptionPlanInfoRequest(type: selectedPlanType),
        );
        NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'en_US');
        final dollarPart = priceInfo.priceInCents / 100;
        final centsPart = priceInfo.priceInCents % 100;
        final priceString = (centsPart == 0)
            ? '\$$dollarPart'
            : formatter.format(priceInfo.priceInCents / 100.0);

        final confirm = await ConfirmDialogWhite(
          title: context.l10n.updateToPlan(priceInfo.name),
          mainText:
              'Effective immediately you will be enrolled in the ${priceInfo.name} '
              '($priceString/mo.). You can update this at any time.',
          confirmText: 'Yes, update plan',
          cancelText: 'No, nevermind',
        ).show();

        if (confirm) {
          await cloudFunctionsPaymentsService.updateStripeSubscriptionPlan(
            UpdateStripeSubscriptionPlanRequest(
              communityId: community.id,
              stripePriceId: priceInfo.stripePriceId,
              type: selectedPlanType,
            ),
          );
        }
      } else {
        if (_selectedPlan.typeCode == _freeSubscriptionType) {
          final confirm = await ConfirmDialogWhite(
            title: context.l10n.cancelCurrentPlan,
            mainText:
                'Immediately cancel your current plan and enroll in the free plan?',
            confirmText: 'Yes, cancel plan',
            cancelText: 'No, nevermind',
          ).show();

          if (confirm) {
            await cloudFunctionsPaymentsService.cancelStripeSubscriptionPlan(
              CancelStripeSubscriptionPlanRequest(
                communityId: community.id,
              ),
            );
          }
        }
      }
    } else {
      if (selectedPlanType != null) {
        final response = await cloudFunctionsPaymentsService
            .createSubscriptionCheckoutSession(
          CreateSubscriptionCheckoutSessionRequest(
            type: selectedPlanType,
            appliedCommunityId: community.id,
            returnRedirectPath:
                'space/${community.displayId}/admin?tab=billing',
          ),
        );
        GetIt.instance<StripeClientService>()
            .redirectToCheckout(sessionId: response.sessionId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserBillingManager =
        context.watch<CommunityPermissionsProvider>().isUserBillingManager;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUserBillingManager)
          _buildTitle(widget.subscription?.type ?? _freeSubscriptionType),
        SizedBox(height: 20),
        if (isUserBillingManager)
          _buildUserIsBillingManager()
        else
          _buildUserNotBillingManager(),
        SizedBox(height: 20),
        if (isUserBillingManager)
          Wrap(
            children: [
              _buildPlansDropdown(),
              SizedBox(width: 10),
              ActionButton(
                text: 'Update Plan',
                color: AppColor.darkBlue,
                textColor: AppColor.brightGreen,
                onPressed: _newPlanSelected
                    ? () => alertOnError(context, _updatePlanPressed)
                    : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTitle(String type) {
    final planType = EnumToString.fromString(PlanType.values, type).name;
    final community = context.watch<CommunityProvider>().community;

    return HeightConstrainedText(
      '${community.name ?? 'This Community'} is on the $planType Plan',
      style:
          AppTextStyle.subhead.copyWith(fontSize: 22, color: AppColor.darkBlue),
    );
  }

  Widget _buildPlansDropdown() => Container(
        constraints: BoxConstraints(maxWidth: 270),
        padding: const EdgeInsets.only(left: 15, right: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: AppColor.gray4,
          ),
        ),
        child: DropdownButton<Plan>(
          isExpanded: true,
          underline: SizedBox.shrink(),
          borderRadius: BorderRadius.circular(10),
          value: _selectedPlan,
          onChanged: (val) =>
              val != null ? setState(() => _selectedPlan = val) : null,
          items: <DropdownMenuItem<Plan>>[
            for (final plan in plans)
              DropdownMenuItem<Plan>(
                value: plan,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: HeightConstrainedText(
                        plan.name,
                        style:
                            AppTextStyle.body.copyWith(color: AppColor.gray1),
                      ),
                    ),
                    SizedBox(width: 8),
                    HeightConstrainedText(
                      plan.cost,
                      style: AppTextStyle.body.copyWith(color: AppColor.gray3),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _buildUserNotBillingManager() {
    final community = context.watch<CommunityProvider>().community;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HeightConstrainedText(
          'Contact the billing manager to update plan:',
          style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray3),
        ),
        UserInfoBuilder(
          userId: context.watch<CommunityProvider>().community.creatorId,
          builder: (
            BuildContext context,
            bool isLoading,
            AsyncSnapshot<PublicUserInfo?> snapshot,
          ) {
            final userInfo = snapshot.data;

            if (isLoading || userInfo == null) {
              return CircularProgressIndicator();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileChip(
                  imageUrl: userInfo.imageUrl,
                  imageHeight: 35,
                ),
                Flexible(
                  child: UserAdminDetailsBuilder(
                    userId: community.creatorId!,
                    communityId: community.id,
                    builder: (_, isLoading, snapshot) {
                      final emailText = snapshot.data?.email?.isNotEmpty == true
                          ? '(${snapshot.data?.email}) '
                          : '';
                      return HeightConstrainedText(
                        '${userInfo.displayName ?? 'The community owner'} ${emailText}is the billing manager',
                        style:
                            AppTextStyle.body.copyWith(color: AppColor.gray2),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserIsBillingManager() {
    return UserInfoBuilder(
      userId: context.watch<CommunityProvider>().community.creatorId,
      builder: (
        BuildContext context,
        bool isLoading,
        AsyncSnapshot<PublicUserInfo?> snapshot,
      ) {
        final userInfo = snapshot.data;

        if (isLoading || userInfo == null) return CircularProgressIndicator();
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ProfileChip(
              imageUrl: userInfo.imageUrl,
              imageHeight: 35,
            ),
            HeightConstrainedText(
              'You are the billing manager',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            ),
            SizedBox(width: 10),
            ActionButton(
              text: 'Update billing',
              color: Colors.transparent,
              textStyle: TextStyle(
                decoration: TextDecoration.underline,
                color: AppColor.darkBlue,
              ),
              sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
              onPressed: () async {
                final community = context.read<CommunityProvider>().community;
                final response = await cloudFunctionsPaymentsService
                    .getStripeBillingPortalLink(
                  GetStripeBillingPortalLinkRequest(
                    responsePath:
                        'space/${community.displayId}/admin?tab=billing',
                  ),
                );

                html.window.location.assign(response.url);
              },
            ),
          ],
        );
      },
    );
  }
}

class Plan {
  final String name;
  final String cost;
  final String typeCode;
  final PlanType? planType;

  const Plan({
    required this.name,
    required this.cost,
    required this.typeCode,
    required this.planType,
  });
}

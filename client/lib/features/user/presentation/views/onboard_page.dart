import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/community/features/create_community/presentation/views/create_community_dialog.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/custom_scaffold.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/routing/locations.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/memoized_builder.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

enum OnboardStep {
  agreement,
  paymentSetup,
  communityAttributes,
  communityImages,
}

/// To enable onboarding for a customer, add firestore entry to /partner-agreements with:
///
/// doc id = <random unguessable string>
/// {
///   id: <random unguessable string, same value as doc id>,
///   allowPayments: <true if client will receive funds>,
///   takeRate: <Our share of proceeds, as a decimal between 0 and 1>,
///   planOverride:
///     <(optional) overrides plan type for community covered by this agreement. make sure plan type
///     exists in plan-capability-lists collection>
/// }
///
class OnboardPage extends StatefulHookWidget {
  final String? agreementId;
  final String redirectFrom;

  const OnboardPage({this.agreementId, required this.redirectFrom});

  @override
  _OnboardPageState createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  late OnboardStep _step;
  late bool _agreeToTerms;
  late bool _skipStripe;

  @override
  void initState() {
    super.initState();
    if (widget.agreementId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        routerDelegate.beamTo(NewSpaceLocation());
      });
    }
    _agreeToTerms = false;
    _skipStripe = false;
    if (widget.redirectFrom == 'stripe') {
      _step = OnboardStep.paymentSetup;
    } else {
      _step = OnboardStep.agreement;
    }
  }

  Future<void> _createCommunity(
    Community community,
    PartnerAgreement agreement,
  ) async {
    await cloudFunctionsCommunityService.createCommunity(
      CreateCommunityRequest(
        agreementId: agreement.id,
        community: community,
      ),
    );
    analytics
        .logEvent(AnalyticsCreateCommunityEvent(communityId: agreement.id));
    setState(() => _step = OnboardStep.communityImages);
  }

  Future<void> _updateCommunityAttributes(Community community) async {
    await cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: community,
        keys: [
          Community.kFieldName,
          Community.kFieldTagLine,
          Community.kFieldDescription,
          Community.kFieldIsPublic,
        ],
      ),
    );
    analytics.logEvent(
      AnalyticsUpdateCommunityMetadataEvent(communityId: community.id),
    );
    setState(() => _step = OnboardStep.communityImages);
  }

  Future<void> _updateCommunityImages(Community community) async {
    await cloudFunctionsCommunityService.updateCommunity(
      UpdateCommunityRequest(
        community: community,
        keys: [
          Community.kFieldProfileImageUrl,
          Community.kFieldBannerImageUrl,
        ],
      ),
    );
    analytics.logEvent(
      AnalyticsUpdateCommunityImageEvent(communityId: community.id),
    );
    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: community.displayId)
          .communityHome,
    );
  }

  void _finishAgreementToTerms() {
    analytics.logEvent(
      AnalyticsAgreeToTermsAndConditionsEvent(
        userId: Provider.of<UserService>(context).currentUserId!,
      ),
    );
    setState(() => _step = OnboardStep.paymentSetup);
  }

  Widget _buildNavButton({
    required String text,
    void Function()? onNextPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        text: text,
        onPressed: onNextPressed,
        color: Theme.of(context).primaryColor,
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.left,
      ),
    );
  }

  Widget _buildTitle({String? title, int? stepNum, int? totalSteps}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeightConstrainedText(
            'STEP $stepNum OF $totalSteps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
          ),
          HeightConstrainedText(
            '$title',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStripeConnectLink(
    BuildContext context,
    PartnerAgreement agreement,
    bool skip,
  ) {
    final isAccountCreated =
        paymentUtils.isStripeAccountAlreadyCreated(agreement);

    return ActionButton(
      type: ActionButtonType.outline,
      height: 48,
      expand: true,
      color: context.theme.colorScheme.surfaceContainerLowest,
      text: '${isAccountCreated ? 'Edit' : 'Set'} Linked Payee Account',
      onPressed: skip
          ? null
          : () => alertOnError(
                context,
                () => paymentUtils.proceedToConnectWithStripePage(
                  agreement,
                  widget.agreementId,
                  cloudFunctionsPaymentsService,
                ),
              ),
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
    );
  }

  Widget _buildAgreement(
    BuildContext context,
    PartnerAgreement agreement,
    Community community,
    int numSteps,
  ) {
    final takeRate = agreement.takeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: context.l10n.welcomeToApp(Environment.appName),
          stepNum: 1,
          totalSteps: numSteps,
        ),
        Center(
          child: HeightConstrainedText(
            'Please read and agree to our services agreement to continue.',
          ),
        ),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) => setState(() {
                  if (value != null) {
                    _agreeToTerms = value;
                  }
                }),
              ),
              HeightConstrainedText(context.l10n.iAgreeToThe),
              TextButton(
                child: HeightConstrainedText(
                  '${Environment.appName} Subscription Services Agreement',
                ),
                onPressed: () =>
                    launch(Environment.subscriptionServicesAgreementUrl),
              ),
            ],
          ),
        ),
        if (takeRate != null) ...[
          SizedBox(height: 10),
          Center(
            child: HeightConstrainedText(
              'As part of this payment plan, ${takeRate * 100}% of all end user payments will be withheld as a platform fee.',
            ),
          ),
        ],
        SizedBox(height: 20),
        _buildNavButton(
          text: 'Agree and Continue',
          onNextPressed: _agreeToTerms ? _finishAgreementToTerms : null,
        ),
      ],
    );
  }

  Widget _buildPaymentSetup(
    BuildContext context,
    PartnerAgreement agreement,
    int numSteps,
  ) {
    final hasAccount = agreement.stripeConnectedAccountId != null;
    final takeRate = agreement.takeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: context.l10n.setPayeeAccountDetails,
          stepNum: 2,
          totalSteps: numSteps,
        ),
        HeightConstrainedText(
          '${Environment.appName} partners with Stripe to facilitate payments to you.${!hasAccount ? ' To continue, click the button below to create an account with Stripe (or link your existing account).' : ''}',
        ),
        SizedBox(height: 10),
        Center(child: _buildStripeConnectLink(context, agreement, _skipStripe)),
        if (!hasAccount)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _skipStripe,
                  onChanged: (value) => setState(() {
                    if (value != null) {
                      _skipStripe = value;
                    }
                  }),
                ),
                HeightConstrainedText(
                    context.l10n.skipStripeAccountSetupForNow),
                SizedBox(width: 8),
              ],
            ),
          ),
        if (takeRate != null) ...[
          SizedBox(height: 10),
          HeightConstrainedText(
            '${takeRate * 100}% of proceeds will be withheld as a platform fee.',
          ),
        ],
        SizedBox(height: 30),
        _buildNavButton(
          text: 'Agree and Continue',
          onNextPressed: (hasAccount || _skipStripe)
              ? () => setState(() => _step = OnboardStep.communityAttributes)
              : null,
        ),
      ],
    );
  }

  Widget _buildCommunityAttributes(
    BuildContext context,
    PartnerAgreement agreement,
    Community? community,
    int numSteps,
  ) {
    final create = community == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: context.l10n.buildCommunitySpace,
          stepNum: numSteps - 1,
          totalSteps: numSteps,
        ),
        CreateCommunityDialog(
          community: community,
          createFunction: (community) => _createCommunity(community, agreement),
          updateFunction: _updateCommunityAttributes,
          submitText: '${create ? 'Create' : 'Update'} and Continue',
          compact: true,
          showTitle: false,
          showImageEdit: false,
        ),
      ],
    );
  }

  Widget _buildCommunityImages(
    BuildContext context,
    PartnerAgreement agreement,
    Community community,
    int numSteps,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: context.l10n.addCommunityImages,
          stepNum: numSteps,
          totalSteps: numSteps,
        ),
        CreateCommunityDialog(
          community: community,
          updateFunction: _updateCommunityImages,
          submitText: 'Update and Finish',
          compact: true,
          showTitle: false,
          showAttributeEdit: false,
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    Stream<PartnerAgreement?> agreementStream,
  ) {
    return CustomListView(
      shrinkWrap: true,
      children: [
        CustomStreamBuilder<PartnerAgreement?>(
          entryFrom: '_OnboardPageState._buildContent1',
          stream: agreementStream,
          builder: (_, agreement) {
            if (_step == OnboardStep.paymentSetup &&
                !(agreement?.allowPayments == true)) {
              _step = OnboardStep.communityAttributes;
            }

            return MemoizedBuilder<Stream<Community>>(
              getter: () => agreement?.communityId != null
                  ? firestoreDatabase
                      .communityStream(agreement?.communityId ?? '')
                  : Stream.empty(),
              keys: [agreement?.communityId ?? ''],
              builder: (_, communityStream) {
                return CustomStreamBuilder<Community>(
                  entryFrom: '_OnboardPageState._buildContent2',
                  stream: communityStream,
                  builder: (context, community) {
                    if (agreement == null || community == null) {
                      return SizedBox.shrink();
                    }

                    // if payments not enabled, skip that step
                    final numSteps = agreement.allowPayments == true ? 4 : 3;

                    switch (_step) {
                      case OnboardStep.communityAttributes:
                        return _buildCommunityAttributes(
                          context,
                          agreement,
                          community,
                          numSteps,
                        );
                      case OnboardStep.communityImages:
                        return _buildCommunityImages(
                          context,
                          agreement,
                          community,
                          numSteps,
                        );
                      case OnboardStep.paymentSetup:
                        return _buildPaymentSetup(context, agreement, numSteps);
                      case OnboardStep.agreement:
                      default:
                        return _buildAgreement(
                          context,
                          agreement,
                          community,
                          numSteps,
                        );
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return CustomListView(
      shrinkWrap: true,
      children: [
        Column(
          children: [
            HeightConstrainedText(
              'To create your community, first sign in.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            ActionButton(
              text: 'Sign In',
              onPressed: () => SignInDialog.show(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final agreementId = widget.agreementId;
    final signedIn = Provider.of<UserService>(context).isSignedIn;
    final Stream<PartnerAgreement?> agreementStream = useMemoized(
      () => (signedIn && widget.agreementId != null)
          ? firestoreAgreementsService.getAgreementStream(agreementId ?? '')
          : Stream.empty(),
      [widget.agreementId, signedIn],
    );

    return CustomScaffold(
      fillViewport: true,
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.all(10).copyWith(bottom: 60),
        child: widget.agreementId == null
            ? SizedBox.shrink()
            : Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.colorScheme.scrim.withScrimOpacity,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxWidth: 540),
                child: signedIn
                    ? _buildContent(context, agreementStream)
                    : _buildSignIn(context),
              ),
      ),
    );
  }
}

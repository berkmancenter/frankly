import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/home/creation_dialog/create_junto_dialog.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/junto_scaffold.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/memoized_builder.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:provider/provider.dart';

enum OnboardStep {
  agreement,
  paymentSetup,
  juntoAttributes,
  juntoImages,
}

/// To enable onboarding for a customer, add firestore entry to /partner-agreements with:
///
/// doc id = <random unguessable string>
/// {
///   id: <random unguessable string, same value as doc id>,
///   allowPayments: <true if client will receive funds>,
///   takeRate: <Frankly's share of proceeds, as a decimal between 0 and 1>,
///   planOverride:
///     <(optional) overrides plan type for junto covered by this agreement. make sure plan type
///     exists in plan-capability-lists collection>
/// }
///
/// Provide client with URL: https://myjunto.app/home/onboard/<agreementId>
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
      WidgetsBinding.instance?.addPostFrameCallback((_) {
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

  Future<void> _createJunto(Junto junto, PartnerAgreement agreement) async {
    await cloudFunctionsService
        .createJunto(CreateJuntoRequest(agreementId: agreement.id, junto: junto));
    analytics.logEvent(AnalyticsCreateJuntoEvent(juntoId: agreement.id));
    setState(() => _step = OnboardStep.juntoImages);
  }

  Future<void> _updateJuntoAttributes(Junto junto) async {
    await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: junto,
      keys: [
        Junto.kFieldName,
        Junto.kFieldTagLine,
        Junto.kFieldDescription,
        Junto.kFieldIsPublic,
      ],
    ));
    analytics.logEvent(AnalyticsUpdateJuntoMetadataEvent(juntoId: junto.id));
    setState(() => _step = OnboardStep.juntoImages);
  }

  Future<void> _updateJuntoImages(Junto junto) async {
    await cloudFunctionsService.updateJunto(UpdateJuntoRequest(
      junto: junto,
      keys: [
        Junto.kFieldProfileImageUrl,
        Junto.kFieldBannerImageUrl,
      ],
    ));
    analytics.logEvent(AnalyticsUpdateJuntoImageEvent(juntoId: junto.id));
    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: junto.displayId).juntoHome);
  }

  void _finishAgreementToTerms() {
    analytics.logEvent(AnalyticsAgreeToTermsAndConditionsEvent());
    setState(() => _step = OnboardStep.paymentSetup);
  }

  Widget _buildNavButton({required String text, void Function()? onNextPressed}) {
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
          JuntoText(
            'STEP $stepNum OF $totalSteps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColor.gray3,
            ),
          ),
          JuntoText(
            '$title',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStripeConnectLink(BuildContext context, PartnerAgreement agreement, bool skip) {
    final isAccountCreated = paymentUtils.isStripeAccountAlreadyCreated(agreement);

    return ActionButton(
      type: ActionButtonType.outline,
      height: 48,
      expand: true,
      borderRadius: BorderRadius.circular(10),
      color: AppColor.white,
      textStyle: body.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor.withOpacity(skip ? .35 : 1),
      ),
      borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(skip ? .35 : 1)),
      text: '${isAccountCreated ? 'Edit' : 'Set'} Linked Payee Account',
      onPressed: skip
          ? null
          : () => alertOnError(
                context,
                () => paymentUtils.proceedToConnectWithStripePage(
                  agreement,
                  widget.agreementId,
                  cloudFunctionsService,
                ),
              ),
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
    );
  }

  Widget _buildAgreement(
    BuildContext context,
    PartnerAgreement agreement,
    Junto junto,
    int numSteps,
  ) {
    final takeRate = agreement.takeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: 'Welcome to Frankly',
          stepNum: 1,
          totalSteps: numSteps,
        ),
        Center(child: JuntoText('Please read and agree to our services agreement to continue.')),
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
              JuntoText('I agree to the '),
              TextButton(
                child: JuntoText('Frankly Subscription Services Agreement'),
                onPressed: () => launch(
                    'https://docs.google.com/document/d/e/2PACX-1vS4-fXOL4U_sB_vR5x5I8Vdc0NMRpMtvF0egGpGYMy_bW2cXsbze1BXbk06kX8klg/pub'),
              ),
            ],
          ),
        ),
        if (takeRate != null) ...[
          SizedBox(height: 10),
          Center(
            child: JuntoText(
                'As part of this payment plan, ${takeRate * 100}% of all end user payments will be withheld as a platform fee.'),
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

  Widget _buildPaymentSetup(BuildContext context, PartnerAgreement agreement, int numSteps) {
    final hasAccount = agreement.stripeConnectedAccountId != null;
    final takeRate = agreement.takeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: 'Set your payee account details',
          stepNum: 2,
          totalSteps: numSteps,
        ),
        JuntoText(
            'Frankly partners with Stripe to facilitate payments to you.${!hasAccount ? ' To continue, click the button below to create an account with Stripe (or link your existing account).' : ''}'),
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
                JuntoText('Skip Stripe account setup for now'),
                SizedBox(width: 8),
              ],
            ),
          ),
        if (takeRate != null) ...[
          SizedBox(height: 10),
          JuntoText('${takeRate * 100}% of proceeds will be withheld as a platform fee.'),
        ],
        SizedBox(height: 30),
        _buildNavButton(
          text: 'Agree and Continue',
          onNextPressed: (hasAccount || _skipStripe)
              ? () => setState(() => _step = OnboardStep.juntoAttributes)
              : null,
        ),
      ],
    );
  }

  Widget _buildJuntoAttributes(
    BuildContext context,
    PartnerAgreement agreement,
    Junto? junto,
    int numSteps,
  ) {
    final create = junto == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: 'Build your community space',
          stepNum: numSteps - 1,
          totalSteps: numSteps,
        ),
        CreateJuntoDialog(
          junto: junto,
          createFunction: (junto) => _createJunto(junto, agreement),
          updateFunction: _updateJuntoAttributes,
          submitText: '${create ? 'Create' : 'Update'} and Continue',
          compact: true,
          showTitle: false,
          showImageEdit: false,
        ),
      ],
    );
  }

  Widget _buildJuntoImages(
      BuildContext context, PartnerAgreement agreement, Junto junto, int numSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          title: 'Add community images',
          stepNum: numSteps,
          totalSteps: numSteps,
        ),
        CreateJuntoDialog(
          junto: junto,
          updateFunction: _updateJuntoImages,
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
    return JuntoListView(
      shrinkWrap: true,
      children: [
        JuntoStreamBuilder<PartnerAgreement?>(
          entryFrom: '_OnboardPageState._buildContent1',
          stream: agreementStream,
          builder: (_, agreement) {
            if (_step == OnboardStep.paymentSetup && !(agreement?.allowPayments == true)) {
              _step = OnboardStep.juntoAttributes;
            }

            return MemoizedBuilder<Stream<Junto>>(
              getter: () => agreement?.juntoId != null
                  ? firestoreDatabase.juntoStream(agreement?.juntoId ?? '')
                  : Stream.empty(),
              keys: [agreement?.juntoId ?? ''],
              builder: (_, juntoStream) {
                return JuntoStreamBuilder<Junto>(
                  entryFrom: '_OnboardPageState._buildContent2',
                  stream: juntoStream,
                  builder: (context, junto) {
                    if (agreement == null || junto == null) {
                      return SizedBox.shrink();
                    }

                    // if payments not enabled, skip that step
                    final numSteps = agreement.allowPayments == true ? 4 : 3;

                    switch (_step) {
                      case OnboardStep.juntoAttributes:
                        return _buildJuntoAttributes(context, agreement, junto, numSteps);
                      case OnboardStep.juntoImages:
                        return _buildJuntoImages(context, agreement, junto, numSteps);
                      case OnboardStep.paymentSetup:
                        return _buildPaymentSetup(context, agreement, numSteps);
                      case OnboardStep.agreement:
                      default:
                        return _buildAgreement(context, agreement, junto, numSteps);
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
    return JuntoListView(
      shrinkWrap: true,
      children: [
        Column(
          children: [
            JuntoText(
              'To create your community, first sign in.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            ActionButton(
              text: 'Sign In',
              onPressed: () => SignInDialog.show(),
            )
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

    return JuntoScaffold(
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
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.35),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxWidth: 540),
                child: signedIn ? _buildContent(context, agreementStream) : _buildSignIn(context),
              ),
      ),
    );
  }
}

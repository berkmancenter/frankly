import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/profile_picture.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/admin/data/services/stripe_client_service.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';

class DonateWidget extends StatefulWidget {
  final Community community;

  final String headline;
  final String subHeader;

  const DonateWidget({
    required this.community,
    required this.headline,
    required this.subHeader,
  });

  @override
  _DonateWidgetState createState() => _DonateWidgetState();

  Future<void> show() async {
    if (!userService.isSignedIn) return;
    return showCustomDialog(builder: (_) => this);
  }
}

class _DonateWidgetState extends State<DonateWidget> {
  int? _donationInCents;
  bool _isOtherSelected = false;

  final _otherAmountController = TextEditingController();

  int? get _otherCentsParsed {
    final amount = _otherAmountController.text.trim().replaceAll('\$', '');
    final parsed = double.tryParse(amount);
    // ignore: avoid_returning_null
    if (parsed == null) return null;

    return (parsed * 100).round();
  }

  Future<void> _donate() async {
    final donationInCents = _donationInCents;

    if (donationInCents == null) {
      loggingService.log(
        '_DonateWidgetState._donate: Donation in cents is null',
        logType: LogType.error,
      );
      return;
    }

    final response =
        await cloudFunctionsPaymentsService.createDonationCheckoutSession(
      CreateDonationCheckoutSessionRequest(
        amountInCents: donationInCents,
        communityId: widget.community.id,
      ),
    );

    GetIt.instance<StripeClientService>()
        .redirectToCheckout(sessionId: response.sessionId);
  }

  Widget _buildExitButton() {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.all(30),
      child: CustomInkWell(
        onTap: () => Navigator.of(context).pop(),
        boxShape: BoxShape.circle,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.close,
            color: context.theme.colorScheme.onPrimary,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityDescriptor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 34,
          width: 34,
          child:
              ProfilePicture(imageUrl: widget.community.profileImageUrl ?? ''),
        ),
        SizedBox(width: 20),
        Flexible(
          child: HeightConstrainedText(
            widget.community.name ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationButton(int dollars) {
    final selected = _donationInCents == dollars * 100 && !_isOtherSelected;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _donationInCents = dollars * 100;
          _isOtherSelected = false;
        }),
        child: Container(
          alignment: Alignment.center,
          color: selected
              ? context.theme.colorScheme.onPrimary
              : Colors.transparent,
          child: HeightConstrainedText(
            '\$$dollars',
            style: TextStyle(
              color: selected
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _isOtherSelected = true;
          if (_otherCentsParsed != null) {
            _donationInCents = _otherCentsParsed;
          }
        }),
        child: Container(
          alignment: Alignment.center,
          color: _isOtherSelected
              ? context.theme.colorScheme.onPrimary
              : Colors.transparent,
          child: HeightConstrainedText(
            'Other',
            style: TextStyle(
              color: _isOtherSelected
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherTextInput() {
    final hasError = !isNullOrEmpty(_otherAmountController.text) &&
        _otherCentsParsed == null;
    final style = TextStyle(color: context.theme.colorScheme.onPrimary);

    return TextFormField(
      controller: _otherAmountController,
      style: style,
      decoration: InputDecoration(
        labelText: 'Enter Amount',
        prefixText: '\$',
        errorText: hasError ? 'Please enter a valid amount' : null,
        hintStyle: style,
        helperStyle: style,
        labelStyle: style,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {
        if (_otherCentsParsed != null) {
          _donationInCents = _otherCentsParsed;
        }
      }),
    );
  }

  Widget _buildDonationButtons() {
    final borderRadius = BorderRadius.circular(8);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: context.theme.colorScheme.onPrimary),
      ),
      height: 50,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDonationButton(10),
            Container(width: 1, color: context.theme.colorScheme.onPrimary),
            _buildDonationButton(25),
            Container(width: 1, color: context.theme.colorScheme.onPrimary),
            _buildDonationButton(50),
            Container(width: 1, color: context.theme.colorScheme.onPrimary),
            _buildDonationButton(100),
            Container(width: 1, color: context.theme.colorScheme.onPrimary),
            _buildOtherButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDonate() {
    final int? donationInCents = _donationInCents;
    final bool enabled = donationInCents != null;
    String? donationDisplay;

    if (enabled) {
      final donationInDollars = donationInCents / 100.0;
      final remainder = donationInCents % 100 != 0;
      donationDisplay = remainder
          ? donationInDollars.toStringAsFixed(2)
          : donationInDollars.toString();
    }

    return ActionButton(
      text: enabled ? 'Donate \$$donationDisplay' : 'Donate',
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.interior,
      color: enabled
          ? context.theme.colorScheme.onPrimary
          : context.theme.colorScheme.onPrimaryContainer,
      height: 55,
      textStyle: TextStyle(
        color: enabled
            ? context.theme.colorScheme.primary
            : context.theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      onPressed: enabled ? () => alertOnError(context, () => _donate()) : null,
    );
  }

  Widget _buildSkip() {
    return ActionButton(
      text: 'Skip',
      color: Colors.transparent,
      height: 55,
      textStyle: TextStyle(
        color: context.theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.theme.colorScheme.primary,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 25),
                    if (!isNullOrEmpty(widget.subHeader)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: HeightConstrainedText(
                          widget.subHeader.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                    ],
                    HeightConstrainedText(
                      widget.headline,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.headline1.copyWith(
                        color: context.theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 18),
                    HeightConstrainedText(
                      widget.community.donationDialogText ??
                          'If you enjoyed this event, support ${widget.community.name}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 18),
                    _buildCommunityDescriptor(),
                    SizedBox(height: 18),
                    _buildDonationButtons(),
                    if (_isOtherSelected) ...[
                      SizedBox(height: 18),
                      _buildOtherTextInput(),
                    ],
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSkip(),
                        _buildDonate(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: _buildExitButton(),
            ),
          ],
        ),
      ),
    );
  }
}

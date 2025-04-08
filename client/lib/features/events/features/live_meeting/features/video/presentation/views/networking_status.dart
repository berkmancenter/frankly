import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/networking_status_contract.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/models/networking_status_model.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/networking_status_presenter.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:provider/provider.dart';

class NetworkingStatus extends StatefulWidget {
  final Widget child;

  const NetworkingStatus({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  _NetworkingStatusState createState() => _NetworkingStatusState();
}

class _NetworkingStatusState extends State<NetworkingStatus>
    implements NetworkingStatusView {
  late final NetworkingStatusModel _model;
  late final NetworkingStatusPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = NetworkingStatusModel();
    _presenter = NetworkingStatusPresenter(context, this, _model);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConferenceRoom>(
      builder: (_, __, ___) {
        _presenter.updateNetworkQuality();
        final child = _presenter.getCorrectWidget(
          nothing: SizedBox.shrink(),
          networkStatusAlert: NetworkStatusAlert(
            isMobile: responsiveLayoutService.isMobile(context),
            onDismiss: () => _presenter.dismissLowNetworkQualityMessage(),
          ),
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            AnimatedSwitcher(duration: kTabScrollDuration, child: child),
          ],
        );
      },
    );
  }

  @override
  void updateView() {
    setState(() {});
  }
}

@visibleForTesting
class NetworkStatusAlert extends StatelessWidget {
  final bool isMobile;
  final Function() onDismiss;

  const NetworkStatusAlert({
    Key? key,
    required this.isMobile,
    required this.onDismiss,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          children: [
            Spacer(),
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.lightRed,
                ),
                padding: EdgeInsets.all(isMobile ? 10 : 20),
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LowBandwidth(),
        SizedBox(width: 10),
        ExplanationText(onDismiss: onDismiss),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        LowBandwidth(),
        SizedBox(width: 10),
        Flexible(
          child: ExplanationText(onDismiss: onDismiss),
        ),
      ],
    );
  }
}

@visibleForTesting
class LowBandwidth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAsset.kExclamationSvg.path,
          width: 20,
          height: 20,
          color: AppColor.redLightMode,
        ),
        SizedBox(width: 10),
        Text(
          'Low Bandwidth',
          style: AppTextStyle.subhead.copyWith(color: AppColor.redLightMode),
        ),
      ],
    );
  }
}

@visibleForTesting
class ExplanationText extends StatelessWidget {
  final void Function() onDismiss;

  const ExplanationText({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            'Try turning off your camera for a smoother experience',
            style: AppTextStyle.subhead.copyWith(color: AppColor.gray2),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onDismiss,
          child: SvgPicture.asset(
            AppAsset.kXSvg.path,
            width: 20,
            height: 20,
            color: AppColor.gray1,
          ),
        ),
      ],
    );
  }
}

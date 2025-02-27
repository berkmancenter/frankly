import 'dart:math';

import 'package:client/core/utils/extensions.dart';
import 'package:client/core/utils/image_utils.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/av_check/data/providers/av_check_provider.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/audio_video_error.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/troubleshoot_av.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class AvCheckPage extends StatelessWidget {
  const AvCheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AvCheckProvider>(
      create: (_) => AvCheckProvider(context: context)..initialize(),
      child: _AvCheckPage(),
    );
  }
}

class _PleaseAcceptPermissionsPage extends StatelessWidget {
  const _PleaseAcceptPermissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UIMigration(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 30),
            TroubleshootIssuesButton(),
          ],
        ),
      ),
    );
  }
}

class _AvCheckPage extends StatefulWidget {
  const _AvCheckPage({Key? key}) : super(key: key);

  @override
  State<_AvCheckPage> createState() => _AvCheckPageState();
}

class _AvCheckPageState extends State<_AvCheckPage> {
  AvCheckProvider get provider => context.watch<AvCheckProvider>();

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AvCheckProvider>().errorText;
    if (error != null) {
      return UIMigration(
        child: Center(
          child: AudioVideoErrorDisplay(
            error: error,
            textColor: AppColor.gray1,
          ),
        ),
      );
    }

    final devicesList = provider.devicesList;
    if (devicesList == null) {
      return _PleaseAcceptPermissionsPage();
    }

    return Container(
      alignment: Alignment.center,
      color: AppColor.darkBlue,
      child: UserInfoBuilder(
        userId: userService.currentUserId,
        builder: (context, loading, user) {
          final data = user.data;
          if (loading || data == null) return CircularProgressIndicator();

          final name = data.displayName;
          final userImage =
              data.imageUrl ?? generateRandomImageUrl(seed: data.hashCode);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeightConstrainedText(
                'Hi${name != null ? ' $name' : ''}, ready to join?',
                style: AppTextStyle.headline3,
              ),
              SizedBox(height: 20),
              _buildVideoContainer(userImage),
              SizedBox(height: 16),
              _buildSelectMic(),
              SizedBox(height: 16),
              _buildSelectVideo(),
              SizedBox(height: 36),
              _buildJoinNowButton(),
              SizedBox(height: 20),
              if (!responsiveLayoutService.isMobile(context)) ...[
                _buildDiagnoseIssuesButton(),
                SizedBox(height: 20),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiagnoseIssuesButton() => UIMigration(
        child: TroubleshootIssuesButton(linkColor: AppColor.brightGreen),
      );

  Widget _buildVideoContainer(String image) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.brightGreen),
        borderRadius: BorderRadius.circular(10),
      ),
      width: 334,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (provider.cameraOn)
                _buildVideoElement()
              else
                ProxiedImage(
                  image,
                  height: 50,
                  width: 50,
                  borderRadius: BorderRadius.circular(25),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAVIcons(),
                      _buildAudioLevelIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoElement() => Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: SizedBox(
              width: AvCheckProvider.requestedSize.width,
              height: AvCheckProvider.requestedSize.height,
              child: HtmlElementView(viewType: provider.viewKey),
            ),
          ),
        ),
      );

  Widget _buildAVIcons() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvIcon(
            onTap: provider.toggleVideo,
            asset: provider.cameraOn
                ? AppAsset.kCameraPng
                : AppAsset.kCameraOffPng,
          ),
          SizedBox(width: 10),
          _buildAvIcon(
            onTap: provider.toggleMic,
            asset: provider.micOn
                ? AppAsset.kAudioOnPngWhite
                : AppAsset.kAudioOffPngWhite,
          ),
        ],
      );

  Widget _buildAvIcon({
    required void Function() onTap,
    required AppAsset asset,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.white),
          ),
          alignment: Alignment.center,
          child: ProxiedImage(
            null,
            asset: asset,
            height: 20,
          ),
        ),
      );

  Widget _buildAudioLevelIndicator() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          9,
          (i) {
            return Container(
              height: 20,
              width: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: i < provider.currentAudioLevel && provider.micOn
                    ? AppColor.brightGreen
                    : AppColor.gray3,
              ),
            );
          },
        ).intersperse(SizedBox(width: 5)).toList(),
      );

  Widget _buildSelectMic() => _buildDevicesDropdown(
        deviceKind: 'audioinput',
        currentDeviceId: provider.defaultMic,
        onChanged: provider.selectMic,
        asset: AppAsset.kAudioOnPngWhite,
      );

  Widget _buildSelectVideo() => _buildDevicesDropdown(
        deviceKind: 'videoinput',
        currentDeviceId: provider.defaultCamera,
        onChanged: provider.selectCamera,
        asset: AppAsset.kCameraPng,
      );

  Widget _buildJoinNowButton() => ActionButton(
        color: AppColor.white,
        minWidth: 335,
        height: 68,
        text: 'Join Now',
        onPressed: provider.joinNowPressed,
      );

  Widget _buildDevicesDropdown({
    required Function(String) onChanged,
    required String? currentDeviceId,
    required String deviceKind,
    required AppAsset asset,
  }) {
    final devices =
        provider.devicesList?.where((d) => d.kind == deviceKind).toList() ?? [];

    final currentDeviceFound =
        devices.any((d) => d.deviceId == currentDeviceId);
    if (!currentDeviceFound) {
      // ignore: parameter_assignments
      currentDeviceId = devices.firstOrNull?.deviceId;
      if (currentDeviceId != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          onChanged(currentDeviceId!);
        });
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          width: 48,
          height: 48,
          child: ProxiedImage(
            null,
            asset: asset,
            height: 30,
          ),
        ),
        Container(
          width: 287,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.gray6),
            borderRadius: BorderRadius.circular(10),
            color: AppColor.darkBlue,
          ),
          child: Builder(
            builder: (context) {
              if (devices.isEmpty) {
                return HeightConstrainedText(
                  'No alternative devices detected',
                  style: AppTextStyle.body.copyWith(color: AppColor.white),
                );
              } else {
                return DropdownButton<String>(
                  underline: SizedBox(),
                  onChanged: (deviceId) {
                    final id = devices
                        .firstWhere((d) => d.deviceId == deviceId)
                        .deviceId;
                    if (id != null) {
                      onChanged(id);
                    }
                  },
                  value: currentDeviceId,
                  icon: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.gray6,
                      size: 20,
                    ),
                  ),
                  selectedItemBuilder: (context) =>
                      devices.map(_buildDropdownItem).toList(),
                  items: [
                    for (final device in devices)
                      DropdownMenuItem(
                        value: device.deviceId,
                        child: _buildDropdownItem(
                          device,
                          textColor: AppColor.black,
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownItem(device, {Color textColor = Colors.white}) => Center(
        child: SizedBox(
          width: 240,
          child: HeightConstrainedText(
            '${device.deviceId == 'default' ? '(Default) ' : ''}${device.label}',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body.copyWith(color: textColor),
          ),
        ),
      );
}

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/troubleshoot_av.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class AudioVideoSettingsDialog extends HookWidget {
  final ConferenceRoom conferenceRoom;

  const AudioVideoSettingsDialog({required this.conferenceRoom});

  Future<void> show() {
    return showCustomDialog(builder: (context) => this);
  }

  List<Widget> _buildVideoDevicesDropdown({
    required List<VideoDeviceInfo> allDevices,
    required Function(VideoDeviceInfo) onChanged,
    String? currentDeviceId,
    required String title,
  }) {
    loggingService.log(
      'AudioVideoSettingsDialog._buildDevicesDropdown: deviceId: $currentDeviceId',
    );
    final devices = allDevices;

    final currentDeviceFound =
        devices.any((d) => d.deviceId == currentDeviceId);
    if (!currentDeviceFound) {
      // ignore: parameter_assignments
      currentDeviceId = devices.firstOrNull?.deviceId;
    }

    return [
      HeightConstrainedText(
        title,
        style: body.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 8),
      if (devices.isEmpty)
        HeightConstrainedText('No devices found.')
      else
        Container(
          width: 287,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.gray3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            underline: SizedBox(),
            onChanged: (deviceId) =>
                onChanged(devices.firstWhere((d) => d.deviceId == deviceId)),
            value: currentDeviceId,
            isExpanded: true,
            items: [
              for (final device in devices)
                DropdownMenuItem(
                  value: device.deviceId,
                  child: HeightConstrainedText(
                    '${device.deviceId == 'default' ? '(Default) ' : ''}${device.deviceName}',
                    softWrap: false,
                    style: body.copyWith(color: AppColor.black),
                  ),
                ),
            ],
          ),
        ),
      SizedBox(height: 12),
    ];
  }

  List<Widget> _buildAudioDevicesDropdown({
    required List<AudioDeviceInfo> allDevices,
    required Function(AudioDeviceInfo) onChanged,
    String? currentDeviceId,
    required String title,
  }) {
    loggingService.log(
      'AudioVideoSettingsDialog._buildDevicesDropdown: deviceId: $currentDeviceId',
    );
    final devices = allDevices;

    final currentDeviceFound =
        devices.any((d) => d.deviceId == currentDeviceId);
    if (!currentDeviceFound) {
      // ignore: parameter_assignments
      currentDeviceId = devices.firstOrNull?.deviceId;
    }

    return [
      HeightConstrainedText(
        title,
        style: body.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 8),
      if (devices.isEmpty)
        HeightConstrainedText('No devices found.')
      else
        Container(
          width: 287,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.gray3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            underline: SizedBox(),
            onChanged: (deviceId) =>
                onChanged(devices.firstWhere((d) => d.deviceId == deviceId)),
            value: currentDeviceId,
            isExpanded: true,
            items: [
              for (final device in devices)
                DropdownMenuItem(
                  value: device.deviceId,
                  child: HeightConstrainedText(
                    '${device.deviceId == 'default' ? '(Default) ' : ''}${device.deviceName}',
                    softWrap: false,
                    style: body.copyWith(color: AppColor.black),
                  ),
                ),
            ],
          ),
        ),
      SizedBox(height: 12),
    ];
  }

  Future<List<VideoDeviceInfo>> _getVideoDevices() async {
    try {
      return await conferenceRoom.room?.engine
              .getVideoDeviceManager()
              .enumerateVideoDevices() ??
          [];
    } catch (e) {
      loggingService
          .log('Error in AudioVideoSettingsDialog.getVideoDevices: $e');
      return [];
    }
  }

  Future<List<AudioDeviceInfo>> _getAudioDevices() async {
    try {
      return await conferenceRoom.room?.engine
              .getAudioDeviceManager()
              .enumerateRecordingDevices() ??
          [];
    } catch (e) {
      loggingService
          .log('Error in AudioVideoSettingsDialog.getAudioDevices: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioDevicesFuture = useMemoized(() => _getAudioDevices());
    final videoDevicesFuture = useMemoized(() => _getVideoDevices());
    return AnimatedBuilder(
      animation: conferenceRoom,
      builder: (_, __) => Dialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color(0xFF5568FF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: CustomStreamBuilder<List<AudioDeviceInfo>>(
                  entryFrom: 'AudioVideoSettingsDialog.build',
                  stream: audioDevicesFuture.asStream(),
                  builder: (context, audioDevicesList) =>
                      CustomStreamBuilder<List<VideoDeviceInfo>>(
                    entryFrom: 'AudioVideoSettingsDialog.build',
                    stream: videoDevicesFuture.asStream(),
                    builder: (context, videoDevicesList) {
                      if (videoDevicesList == null ||
                          audioDevicesList == null) {
                        return CircularProgressIndicator();
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeightConstrainedText(
                            'Audio/Video Settings',
                            style: body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 12),
                          ..._buildAudioDevicesDropdown(
                            onChanged: (device) {
                              final id = device.deviceId;
                              if (id != null &&
                                  sharedPreferencesService
                                          .getDefaultMicrophoneId() !=
                                      id) {
                                sharedPreferencesService
                                    .setDefaultMicrophoneId(id);
                                if (conferenceRoom.audioEnabled) {
                                  conferenceRoom.toggleAudioEnabled(
                                    setEnabled: true,
                                  );
                                }
                              }
                            },
                            currentDeviceId: sharedPreferencesService
                                .getDefaultMicrophoneId(),
                            allDevices: audioDevicesList,
                            title: 'Audio Input Device:',
                          ),
                          ..._buildVideoDevicesDropdown(
                            onChanged: (device) {
                              final id = device.deviceId;
                              if (id != null &&
                                  sharedPreferencesService
                                          .getDefaultCameraId() !=
                                      id) {
                                sharedPreferencesService.setDefaultCameraId(id);
                                if (conferenceRoom.videoEnabled) {
                                  conferenceRoom.toggleVideoEnabled(
                                    setEnabled: true,
                                  );
                                }
                              }
                            },
                            currentDeviceId:
                                sharedPreferencesService.getDefaultCameraId(),
                            allDevices: videoDevicesList,
                            title: 'Video Input Device:',
                          ),
                          if (!responsiveLayoutService.isMobile(context)) ...[
                            SizedBox(height: 10),
                            TroubleshootIssuesButton(),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

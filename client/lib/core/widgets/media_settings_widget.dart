import 'dart:async';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import 'package:client/core/utils/media_device_service.dart';

const _kTotalDialogContentPadding = 88.0;

class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({
    super.key,
    required this.conferenceRoom,
    required this.shouldShowVideoPreview,
  });

  final ConferenceRoom conferenceRoom;
  final bool shouldShowVideoPreview;

  @override
  State<MediaSettingsWidget> createState() => _MediaSettingsWidgetState();
}

class _MediaSettingsWidgetState extends State<MediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  late html.VideoElement _videoElement;
  final String _viewType =
      'video-preview-element-${DateTime.now().millisecondsSinceEpoch}';

  String? initialAudioDeviceId;
  // Since this doesn't have a preview, just store current selection in a String.
  String? selectedAudioDeviceId;
  String? initialVideoDeviceId;
  // Used to ensure A/V maintains the same state (e.g. person stays muted even if
  // they change devices).
  bool userVideoEnabled = false;
  bool userAudioEnabled = false;

  bool isLoading = true;
  bool isLoadingCameraChange = false;

  @override
  void initState() {
    super.initState();
    initAll();

    if (!widget.shouldShowVideoPreview) {
      _videoElement = html.VideoElement();
      isLoading = false;
      return;
    }

    _videoElement = html.VideoElement()
      ..id = _viewType
      ..autoplay = true
      ..muted = true
      // Stops preview from going fullscreen on iOS Safari
      ..setAttribute(
        'playsinline',
        'true',
      )
      ..setAttribute('webkit-playsinline', 'true')
      ..setAttribute('disablePictureInPicture', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      // Mirror preview to match Agora local preview.
      ..style.transform = 'scaleX(-1)';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement,
    );
  }

  Future<void> initAll() async {
    await _mediaService.init();

    initialAudioDeviceId = _mediaService.selectedAudioInputId;
    selectedAudioDeviceId = _mediaService.selectedAudioInputId;
    initialVideoDeviceId = _mediaService.selectedVideoInputId;

    userAudioEnabled = widget.conferenceRoom.audioEnabled;
    userVideoEnabled = widget.conferenceRoom.videoEnabled;

    await updatePreview();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updatePreview() async {
    if (!widget.shouldShowVideoPreview) return;
    try {
      await _mediaService.getUserMedia();
      _videoElement.srcObject = _mediaService.previewMediaStream;
    } catch (e) {
      _videoElement.srcObject = null;
    }
  }

  @override
  void dispose() async {
    super.dispose();
    if (!widget.shouldShowVideoPreview) return;
    _mediaService.stopPreviewMediaStream();
    // If user doesn't save, we need to reset the video preview device.
    // getUserMedia is called in updatePreview.
    await _mediaService.selectVideoDevice(
      deviceId: initialVideoDeviceId ?? '',
      shouldUpdatePreview: false,
    );
    await updatePreview();
    _videoElement.srcObject = null;
    _videoElement.remove();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: responsiveLayoutService.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)
          : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Input Device',
            style: context.theme.textTheme.titleMedium,
          ),
          _mediaService.audioInputs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'No audio devices available. Please check permissions.',
                    style: context.theme.textTheme.bodyMedium!.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : DropdownButton<String>(
                  // Prevent dropdown errors by first checking that the selected
                  // device still exists in available inputs.
                  value: _mediaService.audioInputs.any(
                    (device) => device.deviceId == selectedAudioDeviceId,
                  )
                      ? selectedAudioDeviceId
                      : null,
                  items: _mediaService.audioInputs.map((device) {
                    return DropdownMenuItem<String>(
                      value: device.deviceId,
                      child: Text(
                        device.label!,
                        style: context.theme.textTheme.titleMedium,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return _mediaService.audioInputs.map<Widget>((device) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        constraints: BoxConstraints(
                          maxWidth: 320,
                        ),
                        // 24px for the dropdown arrow
                        width: MediaQuery.of(context).size.width -
                            _kTotalDialogContentPadding -
                            24,
                        child: Text(
                          device.label!,
                          style: context.theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() {
                        selectedAudioDeviceId = val;
                      });
                    }
                  },
                  hint: const Text('Select audio input'),
                ),
          const SizedBox(height: 24),
          Text(
            'Video Input Device',
            style: context.theme.textTheme.titleMedium,
          ),
          _mediaService.videoInputs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'No video devices available. Please check permissions.',
                    style: context.theme.textTheme.bodyMedium!.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : DropdownButton<String>(
                  // Prevent dropdown errors by first checking that the selected
                  // device still exists in available inputs.
                  value: _mediaService.videoInputs.any(
                    (device) =>
                        device.deviceId == _mediaService.selectedVideoInputId,
                  )
                      ? _mediaService.selectedVideoInputId
                      : null,
                  items: _mediaService.videoInputs.map((device) {
                    return DropdownMenuItem<String>(
                      value: device.deviceId,
                      child: Text(
                        device.label!,
                        style: context.theme.textTheme.titleMedium,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return _mediaService.videoInputs.map<Widget>((device) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        constraints: BoxConstraints(
                          maxWidth: 320,
                        ),
                        // 24px for the dropdown arrow
                        width: MediaQuery.of(context).size.width -
                            _kTotalDialogContentPadding -
                            24,
                        child: Text(
                          device.label!,
                          style: context.theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() {
                        isLoading = true;
                      });
                      await _mediaService.selectVideoDevice(
                        deviceId: val,
                        shouldUpdatePreview: widget.shouldShowVideoPreview,
                      );
                      await updatePreview();
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  hint: const Text('Select video input'),
                ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  if (widget.shouldShowVideoPreview)
                    Column(
                      children: [
                        Text(
                          'Video Preview',
                          style: context.theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 240,
                              maxWidth: 320,
                            ),
                            width: MediaQuery.of(context).size.width -
                                _kTotalDialogContentPadding,
                            decoration: BoxDecoration(
                              color: context
                                  .theme.colorScheme.surfaceContainerHighest,
                            ),
                            child: _mediaService.videoInputs.isEmpty
                                ? Center(
                                    child: Text(
                                      'No video devices available.',
                                      style: context.theme.textTheme.bodyMedium!
                                          .copyWith(
                                        color: context
                                            .theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      HtmlElementView(viewType: _viewType),
                                      isLoadingCameraChange
                                          ?
                                          // Cover the video element while setting video source
                                          Container(
                                              color: context.theme.colorScheme
                                                  .surfaceContainerHighest,
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color: context
                                                        .theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Updating your meeting video...',
                                                    style: context.theme
                                                        .textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: context.theme
                                                        .colorScheme.onPrimary,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  ActionButton(
                    text: 'Save',
                    onPressed: (_mediaService.selectedVideoInputId ==
                                initialVideoDeviceId &&
                            selectedAudioDeviceId == initialAudioDeviceId)
                        ? null
                        : () async {
                            final savedInitialVideoDeviceId =
                                initialVideoDeviceId;
                            final savedInitialAudioId = initialAudioDeviceId;

                            try {
                              if (_mediaService.selectedVideoInputId !=
                                  initialVideoDeviceId) {
                                setState(() {
                                  isLoadingCameraChange = true;
                                });

                                // Turn the video off and on again to ensure a successful device update.
                                await widget.conferenceRoom.toggleVideoEnabled(
                                  setEnabled: false,
                                );

                                if (!userVideoEnabled ||
                                    !widget.shouldShowVideoPreview) {
                                  // If user's video isn't on or we don't show
                                  // a video preview, we still need to attempt
                                  // an Agora device update to catch any errors.
                                  // Attempt to update the Agora
                                  // device to catch any errors.
                                  await widget
                                      .conferenceRoom.room?.localParticipant
                                      ?.updateAgoraVideoDevice();
                                }

                                if (userVideoEnabled) {
                                  await widget.conferenceRoom
                                      .toggleVideoEnabled(
                                    setEnabled: true,
                                  );
                                }
                                initialVideoDeviceId =
                                    _mediaService.selectedVideoInputId;

                                if (widget.shouldShowVideoPreview) {
                                  // Re-enable the preview after the update.
                                  await updatePreview();
                                }
                                if (context.mounted) {
                                  showRegularToast(
                                    context,
                                    'Video device updated.',
                                    toastType: ToastType.success,
                                  );
                                }
                              }
                              if (selectedAudioDeviceId !=
                                  initialAudioDeviceId) {
                                await _mediaService.selectAudioDevice(
                                  deviceId: selectedAudioDeviceId!,
                                  shouldUpdatePreview:
                                      widget.shouldShowVideoPreview,
                                );
                                await widget.conferenceRoom.toggleAudioEnabled(
                                  setEnabled: false,
                                );
                                if (userAudioEnabled) {
                                  await widget.conferenceRoom
                                      .toggleAudioEnabled(
                                    setEnabled: true,
                                  );
                                } else {
                                  // Still need to attempt to update the Agora
                                  // device to catch any errors.
                                  await widget
                                      .conferenceRoom.room?.localParticipant
                                      ?.updateAgoraAudioDevice();
                                }
                                initialAudioDeviceId = selectedAudioDeviceId;
                                if (context.mounted) {
                                  showRegularToast(
                                    context,
                                    'Audio device updated.',
                                    toastType: ToastType.success,
                                  );
                                }
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              // Reset to initial values if save fails
                              _mediaService.selectedVideoInputId =
                                  savedInitialVideoDeviceId;
                              initialAudioDeviceId = savedInitialVideoDeviceId;
                              initialAudioDeviceId = savedInitialAudioId;
                              if (userAudioEnabled) {
                                await widget.conferenceRoom.toggleAudioEnabled(
                                  setEnabled: true,
                                );
                              }
                              if (userVideoEnabled) {
                                await widget.conferenceRoom.toggleVideoEnabled(
                                  setEnabled: true,
                                );
                              }
                              if (context.mounted) {
                                showRegularToast(
                                  context,
                                  'Error saving media settings. Please try again or contact support.',
                                  toastType: ToastType.failed,
                                );
                              }
                              if (widget.shouldShowVideoPreview) {
                                // Re-enable the preview.
                                await updatePreview();
                              }
                            }
                            setState(() {
                              isLoadingCameraChange = false;
                            });
                          },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

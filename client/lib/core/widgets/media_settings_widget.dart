import 'dart:async';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import 'package:client/core/utils/media_device_service.dart';

/// This widget is only designed for web. When expanding to other platforms,
/// this widget should be refactored to ensure compatibility.
class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({super.key, required this.conferenceRoom});

  final ConferenceRoom conferenceRoom;

  @override
  State<MediaSettingsWidget> createState() => _MediaSettingsWidgetState();
}

class _MediaSettingsWidgetState extends State<MediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  late html.VideoElement _videoElement;
  final String _viewType =
      'video-preview-element-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _videoElement = html.VideoElement()
      ..id = _viewType
      ..autoplay = true
      ..muted = true
      ..setAttribute(
        'playsinline',
        'true',
      ) // Stop iOS Safari from going fullscreen
      ..setAttribute('webkit-playsinline', 'true')
      ..setAttribute('disablePictureInPicture', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.transform = 'scaleX(-1)'; // Mirror view

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement,
    );
    initAll();
  }

  Future<void> initAll() async {
    await _mediaService.init(
      requestMic: true,
      requestCamera: true,
    );
    await updatePreview();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> updatePreview() async {
    try {
      await _mediaService.getUserMedia();
      _videoElement.srcObject = _mediaService.previewMediaStream;
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
    }
  }

  @override
  void dispose() {
    _mediaService.stopPreviewMediaStream();
    _videoElement.srcObject = null;
    _videoElement.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                    (device) =>
                        device.deviceId == _mediaService.selectedAudioInputId,
                  )
                      ? _mediaService.selectedAudioInputId
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
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() {});
                      await widget.conferenceRoom
                          .selectAudioDevice(deviceId: val);
                      // No need to update preview for now as audio is not previewed.
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
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() {});
                      await widget.conferenceRoom.selectVideoDevice(
                        deviceId: val,
                        updateLocalPreview: () async {
                          await updatePreview();
                        },
                      );
                    }
                  },
                  hint: const Text('Select video input'),
                ),
          const SizedBox(height: 24),
          Text(
            'Video Preview',
            style: context.theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 320,
              height: 240,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary,
              ),
              child: HtmlElementView(viewType: _viewType),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import 'package:client/core/utils/media_device_service.dart';

/// This widget is only designed for web. When expanding to other platforms,
/// this widget should be refactored to ensure compatibility.
class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({super.key});

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
    await _mediaService.init();
    await updatePreview();
    setState(() {});
  }

  Future<void> updatePreview() async {
    try {
      await _mediaService.getUserMedia(
        mediaStreamLocation: MediaStreamLocation.preview,
      );
      _videoElement.srcObject = _mediaService.previewMediaStream;
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
    }
  }

  @override
  void dispose() {
    _mediaService.stopMediaStream(
      mediaStreamLocation: MediaStreamLocation.preview,
    );
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
          DropdownButton<String>(
            value: _mediaService.selectedAudioInputId,
            items: _mediaService.audioInputs.map((device) {
              return DropdownMenuItem<String>(
                value: device.deviceId,
                child: Text(
                  (device.label == null || device.label!.isEmpty)
                      ? 'Unnamed Microphone'
                      : device.label!,
                ),
              );
            }).toList(),
            onChanged: (val) async {
              if (val != null) {
                setState(() {});
                await _mediaService.selectAudioDevice(val);
                await updatePreview();
              }
            },
            hint: const Text('Select audio input'),
          ),
          const SizedBox(height: 24),
          Text(
            'Video Input Device',
            style: context.theme.textTheme.titleMedium,
          ),
          DropdownButton<String>(
            value: _mediaService.selectedVideoInputId,
            items: _mediaService.videoInputs.map((device) {
              return DropdownMenuItem<String>(
                value: device.deviceId,
                child: Text(
                  (device.label == null || device.label!.isEmpty)
                      ? 'Unnamed Camera'
                      : device.label!,
                ),
              );
            }).toList(),
            onChanged: (val) async {
              if (val != null) {
                setState(() {});
                await _mediaService.selectVideoDevice(val);
                await updatePreview();
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

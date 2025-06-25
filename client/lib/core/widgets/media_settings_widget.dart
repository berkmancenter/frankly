import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import '../utils/media_device_service.dart';
import '../data/providers/dialog_provider.dart';

class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({super.key});

  @override
  State<MediaSettingsWidget> createState() => _MediaSettingsWidgetState();
}

class _MediaSettingsWidgetState extends State<MediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  late html.VideoElement _videoElement;
  final String _viewType = 'video-preview-element';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _videoElement = html.VideoElement()
        ..id = _viewType
        ..autoplay = true
        ..muted = true // Mute preview to avoid feedback loop if mic is on
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)'; // Mirror view

      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement,
      );
    }
    initAll();
  }

  Future<void> initAll() async {
    await _mediaService.init();
    if (kIsWeb) {
      // Only attempt to get user media and update preview if on web
      // and after _videoElement has been initialized.
      await updatePreview();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updatePreview() async {
    if (!kIsWeb) return;
    try {
      final stream = await _mediaService.getUserMedia();
      _videoElement.srcObject = stream; // This can accept null to clear the stream
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      // Stop the tracks and clear srcObject
      final stream = _videoElement.srcObject;
      if (stream is html.MediaStream) {
        stream.getTracks().forEach((track) => track.stop());
      }
      _videoElement.srcObject = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator until media service is initialized (and devices are listed on web)
    // For non-web, audioInputs will remain empty as per MediaDeviceService, so it might show loading indefinitely
    // or an empty state depending on how MediaDeviceService.init() behaves for non-web.
    // Current MediaDeviceService.init() makes them empty lists for non-web.
    if (kIsWeb && _mediaService.audioInputs.isEmpty && _mediaService.videoInputs.isEmpty) {
        // If on web and no devices yet, could be still loading or no devices found.
        // Consider a more specific loading state if _mediaService.init() is still running.
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Audio Input Device'),
        DropdownButton<String>(
          value: _mediaService.selectedAudioInputId,
          // If audioInputs is empty, map will produce an empty list, which is fine.
          items: _mediaService.audioInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              // device.label is non-nullable String in html.MediaDeviceInfo
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Microphone' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _mediaService.selectAudio(val);
              });
              await updatePreview();
            }
          },
          hint: const Text('Select audio input'),
        ),
        const SizedBox(height: 16),
        const Text('Video Input Device'),
        DropdownButton<String>(
          value: _mediaService.selectedVideoInputId,
          items: _mediaService.videoInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Camera' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _mediaService.selectVideo(val);
              });
              await updatePreview();
            }
          },
          hint: const Text('Select video input'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _mediaService.toggleMic(!_mediaService.micEnabled);
                });
                await updatePreview();
              },
              icon: Icon(_mediaService.micEnabled ? Icons.mic : Icons.mic_off),
              label: Text(_mediaService.micEnabled ? 'Mute Microphone' : 'Unmute Microphone'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _mediaService.toggleCam(!_mediaService.camEnabled);
                });
                await updatePreview();
              },
              icon: Icon(_mediaService.camEnabled ? Icons.videocam : Icons.videocam_off),
              label: Text(_mediaService.camEnabled ? 'Turn Off Camera' : 'Turn On Camera'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (kIsWeb) ...[
          const Text('🎥 Video Preview'),
          Container(
            width: 320,
            height: 240,
            color: Colors.black,
            child: HtmlElementView(viewType: _viewType),
          ),
        ] else ...[
          const Text('🎥 Video Preview (Not available on this platform)'),
          Container(
            width: 320,
            height: 240,
            color: Colors.grey,
            child: const Center(child: Text('Preview N/A')),
          ),
        ],
      ],
    );
  }
}

class AudioVideoSettingsDialog extends StatelessWidget {
  final dynamic conferenceRoom; // Keep parameter for interface compatibility but not used

  const AudioVideoSettingsDialog({
    super.key,
    required this.conferenceRoom,
  });

  Future<void> show() async {
    return showCustomDialog(builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Audio/Video Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  _CompactMediaSettingsWidget(),
                ],
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
    );
  }
}

class _CompactMediaSettingsWidget extends StatefulWidget {
  const _CompactMediaSettingsWidget();

  @override
  State<_CompactMediaSettingsWidget> createState() => _CompactMediaSettingsWidgetState();
}

class _CompactMediaSettingsWidgetState extends State<_CompactMediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  late html.VideoElement _videoElement;
  final String _viewType = 'compact-video-preview-element';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _videoElement = html.VideoElement()
        ..id = _viewType
        ..autoplay = true
        ..muted = true // Mute preview to avoid feedback loop if mic is on
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)'; // Mirror view

      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement,
      );
    }
    initAll();
  }

  Future<void> initAll() async {
    await _mediaService.init();
    if (kIsWeb) {
      await updatePreview();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updatePreview() async {
    if (!kIsWeb) return;
    try {
      final stream = await _mediaService.getUserMedia();
      _videoElement.srcObject = stream;
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      final stream = _videoElement.srcObject;
      if (stream is html.MediaStream) {
        stream.getTracks().forEach((track) => track.stop());
      }
      _videoElement.srcObject = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _mediaService.audioInputs.isEmpty && _mediaService.videoInputs.isEmpty) {
      // Still loading or no devices
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎙 Audio Input Device'),
        DropdownButton<String>(
          value: _mediaService.selectedAudioInputId,
          items: _mediaService.audioInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Microphone' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _mediaService.selectAudio(val);
              });
              await updatePreview();
            }
          },
          hint: const Text('Select audio input'),
        ),
        const SizedBox(height: 16),
        const Text('📷 Video Input Device'),
        DropdownButton<String>(
          value: _mediaService.selectedVideoInputId,
          items: _mediaService.videoInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Camera' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _mediaService.selectVideo(val);
              });
              await updatePreview();
            }
          },
          hint: const Text('Select video input'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _mediaService.toggleMic(!_mediaService.micEnabled);
                });
                await updatePreview();
              },
              icon: Icon(_mediaService.micEnabled ? Icons.mic : Icons.mic_off),
              label: Text(_mediaService.micEnabled ? 'Mute Microphone' : 'Unmute Microphone'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _mediaService.toggleCam(!_mediaService.camEnabled);
                });
                await updatePreview();
              },
              icon: Icon(_mediaService.camEnabled ? Icons.videocam : Icons.videocam_off),
              label: Text(_mediaService.camEnabled ? 'Turn Off Camera' : 'Turn On Camera'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (kIsWeb) ...[
          const Text('🎥 Video Preview'),
          Container(
            width: 200,
            height: 150,
            color: Colors.black,
            child: HtmlElementView(viewType: _viewType),
          ),
        ] else ...[
          const Text('🎥 Video Preview (Not available on this platform)'),
          Container(
            width: 200,
            height: 150,
            color: Colors.grey,
            child: const Center(child: Text('Preview N/A')),
          ),
        ],
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import '../utils/media_device_service.dart';
import '../data/providers/dialog_provider.dart';
import '../../services.dart';

class AudioVideoSettingsDialog extends StatelessWidget {
  const AudioVideoSettingsDialog({
    super.key,
  });

  Future<void> show() async {
    return showCustomDialog(builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<MediaSettingsWidgetState> settingsKey = GlobalKey<MediaSettingsWidgetState>();
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Ensure final sync before closing
          await settingsKey.currentState?.finalizeDeviceSettings();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
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
                    MediaSettingsWidget(key: settingsKey),
                  ],
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () async {
                      // Ensure final sync before closing
                      await settingsKey.currentState?.finalizeDeviceSettings();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
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

class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({Key? key}) : super(key: key);

  @override
  State<MediaSettingsWidget> createState() => MediaSettingsWidgetState();
}

class MediaSettingsWidgetState extends State<MediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  late html.VideoElement _videoElement;
  final String _viewType = 'compact-video-preview-element';
  
  // Independent preview stream management
  html.MediaStream? _independentPreviewStream;
  String? _previewAudioDeviceId;
  String? _previewVideoDeviceId;

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
      // Initialize independent preview with current device selection
      _previewAudioDeviceId = _mediaService.selectedAudioInputId;
      _previewVideoDeviceId = _mediaService.selectedVideoInputId;
      await updatePreview();
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// Create completely independent preview stream
  Future<html.MediaStream?> _createIndependentPreviewStream() async {
    if (!kIsWeb) return null;

    final dynamic audioConstraint = _previewAudioDeviceId != null && _previewAudioDeviceId!.isNotEmpty
        ? {'deviceId': {'exact': _previewAudioDeviceId}}
        : true;

    final dynamic videoConstraint = _previewVideoDeviceId != null && _previewVideoDeviceId!.isNotEmpty
        ? {'deviceId': {'exact': _previewVideoDeviceId}}
        : true;

    final Map<String, dynamic> constraints = {
      'audio': audioConstraint,
      'video': videoConstraint,
    };

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      print('Created completely independent preview stream with audio: $_previewAudioDeviceId, video: $_previewVideoDeviceId');
      return stream;
    } catch (e) {
      print('Error creating independent preview stream: $e');
      return null;
    }
  }

  Future<void> updatePreview() async {
    if (!kIsWeb) return;
    
    // Stop old preview stream
    if (_independentPreviewStream != null) {
      _independentPreviewStream!.getTracks().forEach((track) => track.stop());
      _independentPreviewStream = null;
    }
    
    try {
      _independentPreviewStream = await _createIndependentPreviewStream();
      _videoElement.srcObject = _independentPreviewStream;
      print('Updated independent video preview');

      // Listen for video stream end event, auto refresh
      if (_independentPreviewStream != null) {
        final videoTracks = _independentPreviewStream!.getVideoTracks();
        for (final track in videoTracks) {
          track.onEnded.listen((_) {
            print('Independent preview track ended, refreshing...');
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                updatePreview();
              }
            });
          });
        }
      }
    } catch (e) {
      print('Error updating independent preview: $e');
      _videoElement.srcObject = null;

      // If failed to get stream, try again after a short delay
      try {
        await Future.delayed(Duration(milliseconds: 500));
        _independentPreviewStream = await _createIndependentPreviewStream();
        _videoElement.srcObject = _independentPreviewStream;
        print('Successfully refreshed independent preview after error');
      } catch (e2) {
        print('Failed to refresh independent preview: $e2');
      }
    }
  }

  /// Sync device selection to all related systems
  Future<void> _syncDeviceSelection({
    String? audioDeviceId,
    String? videoDeviceId,
  }) async {
    try {
      // 1. Update SharedPreferences (default devices for meeting)
      if (audioDeviceId != null) {
        await sharedPreferencesService.setDefaultMicrophoneId(audioDeviceId);
        print('Synced audio device to SharedPreferences: $audioDeviceId');
      }

      if (videoDeviceId != null) {
        await sharedPreferencesService.setDefaultCameraId(videoDeviceId);
        print('Synced video device to SharedPreferences: $videoDeviceId');
      }

      // 2. Force sync device settings to bridge service and Agora SDK
      await _mediaService.forceSyncToSDK();

      print('Device selection fully synced');
    } catch (e) {
      print('Error syncing device selection: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      // Stop independent preview stream
      if (_independentPreviewStream != null) {
        _independentPreviewStream!.getTracks().forEach((track) => track.stop());
        print('Stopped independent preview stream tracks');
        _independentPreviewStream = null;
      }
      _videoElement.srcObject = null;
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _mediaService.audioInputs.isEmpty && _mediaService.videoInputs.isEmpty) {
      // Still loading or no devices
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Audio Input Device'),
        DropdownButton<String>(
          value: _previewAudioDeviceId,
          items: _mediaService.audioInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Microphone' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _previewAudioDeviceId = val;
                _mediaService.selectAudio(val);
              });

              // Sync device selection to all systems
              await _syncDeviceSelection(audioDeviceId: val);

              // Update independent preview with new device
              await updatePreview();
            }
          },
          hint: const Text('Select audio input'),
        ),
        const SizedBox(height: 16),
        const Text('Video Input Device'),
        DropdownButton<String>(
          value: _previewVideoDeviceId,
          items: _mediaService.videoInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Camera' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _previewVideoDeviceId = val;
                _mediaService.selectVideo(val);
              });

              // Sync device selection to all systems
              await _syncDeviceSelection(videoDeviceId: val);
              
              // Update independent preview with new device
              await updatePreview();
            }
          },
          hint: const Text('Select video input'),
        ),
        const SizedBox(height: 20),
        if (kIsWeb) ...[
          const Text('Video Preview'),
          Container(
            width: 200,
            height: 150,
            color: Colors.black,
            child: HtmlElementView(viewType: _viewType),
          ),
        ] else ...[
          const Text('Video Preview (Not available on this platform)'),
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

  /// Finalize device settings when closing the dialog
  /// This ensures that the selected devices are applied to the actual media streams
  Future<void> finalizeDeviceSettings() async {
    try {
      print('Finalizing device settings...');
      
      // 1. Ensure MediaDeviceService has the latest device selection
      if (_previewAudioDeviceId != null) {
        _mediaService.selectAudio(_previewAudioDeviceId!);
        await sharedPreferencesService.setDefaultMicrophoneId(_previewAudioDeviceId!);
        print('Finalized audio device: $_previewAudioDeviceId');
      }
      
      if (_previewVideoDeviceId != null) {
        _mediaService.selectVideo(_previewVideoDeviceId!);
        await sharedPreferencesService.setDefaultCameraId(_previewVideoDeviceId!);
        print('Finalized video device: $_previewVideoDeviceId');
      }
      
      // 2. Force refresh the actual media stream to use new devices
      await _mediaService.forceRefreshStream();
      
      // 3. Force sync to SDK to ensure bridge services get the new devices
      await _mediaService.forceSyncToSDK();
      
      print('Device settings finalized successfully');
    } catch (e) {
      print('Error finalizing device settings: $e');
    }
  }
}
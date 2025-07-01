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
  late html.VideoElement _videoElement;
  // 使用唯一的 viewType 避免註冊衝突
  final String _viewType = 'compact-video-preview-element-${DateTime.now().millisecondsSinceEpoch}';
  
  // Completely independent device management (no MediaDeviceService dependency for preview)
  final List<html.MediaDeviceInfo> _audioInputs = [];
  final List<html.MediaDeviceInfo> _videoInputs = [];
  html.MediaStream? _independentPreviewStream;
  String? _previewAudioDeviceId;
  String? _previewVideoDeviceId;
  
  // 初始化狀態追蹤
  bool _isInitializing = true;

  // MediaDeviceService instance for one-way notification only
  final MediaDeviceService _mediaService = MediaDeviceService();

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
    print('Starting initAll...');
    _isInitializing = true;
    if (mounted) setState(() {});
    
    await _initDevicesIndependently();
    if (kIsWeb) {
      // Load current device selection from SharedPreferences
      _previewAudioDeviceId = sharedPreferencesService.getDefaultMicrophoneId();
      _previewVideoDeviceId = sharedPreferencesService.getDefaultCameraId();
      
      print('Loaded from SharedPreferences - Audio: $_previewAudioDeviceId, Video: $_previewVideoDeviceId');
      print('Available devices - Audio: ${_audioInputs.length}, Video: ${_videoInputs.length}');
      
      // Set defaults if none selected
      if (_previewAudioDeviceId == null && _audioInputs.isNotEmpty) {
        _previewAudioDeviceId = _audioInputs.first.deviceId;
        print('Set default audio device: $_previewAudioDeviceId');
      }
      if (_previewVideoDeviceId == null && _videoInputs.isNotEmpty) {
        _previewVideoDeviceId = _videoInputs.first.deviceId;
        print('Set default video device: $_previewVideoDeviceId');
      }
      
      print('Final device selection - Audio: $_previewAudioDeviceId, Video: $_previewVideoDeviceId');
      await updatePreview();
    }
    
    _isInitializing = false;
    if (mounted) {
      setState(() {});
    }
    print('initAll completed');
  }

  /// Initialize devices completely independently (no MediaDeviceService)
  Future<void> _initDevicesIndependently() async {
    if (!kIsWeb) return;
    
    try {
      final devices = await html.window.navigator.mediaDevices?.enumerateDevices();
      if (devices != null) {
        _audioInputs.clear();
        _videoInputs.clear();
        
        for (final device in devices) {
          if (device is html.MediaDeviceInfo) {
            if (device.kind == 'audioinput') {
              _audioInputs.add(device);
            } else if (device.kind == 'videoinput') {
              _videoInputs.add(device);
            }
          }
        }
        print('Independently enumerated ${_audioInputs.length} audio and ${_videoInputs.length} video devices');
      }
    } catch (e) {
      print('Error enumerating devices independently: $e');
      _audioInputs.clear();
      _videoInputs.clear();
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

    print('Creating independent preview stream with constraints: $constraints');

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      if (stream != null) {
        final videoTracks = stream.getVideoTracks();
        final audioTracks = stream.getAudioTracks();
        print('Created completely independent preview stream with ${videoTracks.length} video tracks and ${audioTracks.length} audio tracks');
        print('Audio device: $_previewAudioDeviceId, Video device: $_previewVideoDeviceId');
      } else {
        print('getUserMedia returned null stream');
      }
      return stream;
    } catch (e) {
      print('Error creating independent preview stream: $e');
      return null;
    }
  }

  Future<void> updatePreview() async {
    if (!kIsWeb) return;
    
    print('Starting updatePreview with audio: $_previewAudioDeviceId, video: $_previewVideoDeviceId');
    
    // Stop old preview stream
    if (_independentPreviewStream != null) {
      _independentPreviewStream!.getTracks().forEach((track) => track.stop());
      _independentPreviewStream = null;
    }
    
    try {
      _independentPreviewStream = await _createIndependentPreviewStream();
      
      if (_independentPreviewStream != null) {
        print('Setting video element srcObject with stream: ${_independentPreviewStream!.getVideoTracks().length} video tracks');
        _videoElement.srcObject = _independentPreviewStream;
        
        // Wait for video element to be ready
        await _videoElement.onLoadedMetadata.first;
        print('Video element loaded metadata successfully');

        // Listen for video stream end event, auto refresh
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
        
        print('Updated independent video preview successfully');
      } else {
        print('Failed to create independent preview stream');
        _videoElement.srcObject = null;
      }
    } catch (e) {
      print('Error updating independent preview: $e');
      _videoElement.srcObject = null;

      // If failed to get stream, try again after a short delay
      try {
        await Future.delayed(Duration(milliseconds: 500));
        _independentPreviewStream = await _createIndependentPreviewStream();
        if (_independentPreviewStream != null) {
          _videoElement.srcObject = _independentPreviewStream;
          print('Successfully refreshed independent preview after error');
        }
      } catch (e2) {
        print('Failed to refresh independent preview: $e2');
      }
    }
  }

  /// Sync device selection to SharedPreferences and notify MediaDeviceService (one-way)
  Future<void> _syncDeviceSelection({
    String? audioDeviceId,
    String? videoDeviceId,
  }) async {
    try {
      // 1. Save to SharedPreferences (for future sessions)
      if (audioDeviceId != null) {
        await sharedPreferencesService.setDefaultMicrophoneId(audioDeviceId);
        print('Synced audio device to SharedPreferences: $audioDeviceId');
      }

      if (videoDeviceId != null) {
        await sharedPreferencesService.setDefaultCameraId(videoDeviceId);
        print('Synced video device to SharedPreferences: $videoDeviceId');
      }

      // 2. One-way notification to MediaDeviceService (affects main video stream)
      if (audioDeviceId != null) {
        _mediaService.selectAudio(audioDeviceId);
        print('Notified MediaDeviceService of audio device: $audioDeviceId');
      }

      if (videoDeviceId != null) {
        _mediaService.selectVideo(videoDeviceId);
        print('Notified MediaDeviceService of video device: $videoDeviceId');
      }

      print('Device selection synced: SharedPreferences + MediaDeviceService notification');
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
    // 只在初始化過程中顯示 loading
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Audio Input Device'),
        DropdownButton<String>(
          value: _previewAudioDeviceId,
          items: _audioInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Microphone' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _previewAudioDeviceId = val;
              });

              // Sync device selection to SharedPreferences only
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
          items: _videoInputs.map((device) {
            return DropdownMenuItem<String>(
              value: device.deviceId,
              child: Text((device.label == null || device.label!.isEmpty) ? 'Unnamed Camera' : device.label!),
            );
          }).toList(),
          onChanged: (val) async {
            if (val != null) {
              setState(() {
                _previewVideoDeviceId = val;
              });

              // Sync device selection to SharedPreferences only
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
  /// Saves to SharedPreferences and notifies MediaDeviceService (one-way notification)
  Future<void> finalizeDeviceSettings() async {
    try {
      print('Finalizing device settings with one-way notification...');
      
      // 1. Save to SharedPreferences (for future sessions)
      if (_previewAudioDeviceId != null) {
        await sharedPreferencesService.setDefaultMicrophoneId(_previewAudioDeviceId!);
        print('Finalized audio device to SharedPreferences: $_previewAudioDeviceId');
      }
      
      if (_previewVideoDeviceId != null) {
        await sharedPreferencesService.setDefaultCameraId(_previewVideoDeviceId!);
        print('Finalized video device to SharedPreferences: $_previewVideoDeviceId');
      }
      
      // 2. One-way notification to MediaDeviceService (affects current session)
      if (_previewAudioDeviceId != null) {
        _mediaService.selectAudio(_previewAudioDeviceId!);
        print('Notified MediaDeviceService of finalized audio device: $_previewAudioDeviceId');
      }
      
      if (_previewVideoDeviceId != null) {
        _mediaService.selectVideo(_previewVideoDeviceId!);
        print('Notified MediaDeviceService of finalized video device: $_previewVideoDeviceId');
      }
      
      // 3. Force sync to ensure the main video stream uses new devices
      await _mediaService.forceSyncToSDK();
      
      print('Device settings finalized: SharedPreferences + MediaDeviceService notification complete');
    } catch (e) {
      print('Error finalizing device settings: $e');
    }
  }
}
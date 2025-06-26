import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
import '../utils/media_device_service.dart';
import '../data/providers/dialog_provider.dart';
import '../../features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import '../../services.dart';

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
      print('Updated video preview with cloned stream');
      
      // 監聽視訊流結束事件，自動刷新
      if (stream != null) {
        final videoTracks = stream.getVideoTracks();
        for (final track in videoTracks) {
          track.onEnded.listen((_) {
            print('Video track ended, refreshing preview...');
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                updatePreview();
              }
            });
          });
        }
      }
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
      
      // 如果獲取流失敗，嘗試強制刷新
      try {
        await _mediaService.forceRefreshStream();
        final retryStream = await _mediaService.getUserMedia();
        _videoElement.srcObject = retryStream;
        print('Successfully refreshed video preview after error');
      } catch (e2) {
        print('Failed to refresh video preview: $e2');
      }
    }
  }

  /// 同步設備選擇到所有相關系統
  Future<void> _syncDeviceSelection({
    String? audioDeviceId,
    String? videoDeviceId,
  }) async {
    try {
      // 1. 更新 SharedPreferences（會議使用的預設設備）
      if (audioDeviceId != null) {
        await sharedPreferencesService.setDefaultMicrophoneId(audioDeviceId);
        print('Synced audio device to SharedPreferences: $audioDeviceId');
      }
      
      if (videoDeviceId != null) {
        await sharedPreferencesService.setDefaultCameraId(videoDeviceId);
        print('Synced video device to SharedPreferences: $videoDeviceId');
      }
      
      // 2. 強制同步設備設置到橋接服務和 Agora SDK
      await _mediaService.forceSyncToSDK();
      
      print('Device selection fully synced');
    } catch (e) {
      print('Error syncing device selection: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      // 停止預覽流（這是克隆的流）
      final stream = _videoElement.srcObject;
      if (stream is html.MediaStream) {
        _mediaService.stopMediaStream(stream);
      }
      _videoElement.srcObject = null;
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _mediaService.audioInputs.isEmpty && _mediaService.videoInputs.isEmpty) {
        // If on web and no devices yet, could be still loading or no devices found.
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
              
              // 同步設備選擇到所有系統
              await _syncDeviceSelection(audioDeviceId: val);
              
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
              
              // 同步設備選擇到所有系統
              await _syncDeviceSelection(videoDeviceId: val);
              
              await updatePreview();
            }
          },
          hint: const Text('Select video input'),
        ),
        const SizedBox(height: 16),
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
  
  const AudioVideoSettingsDialog({
    super.key,
  });

  Future<void> show() async {
    return showCustomDialog(builder: (context) => this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  _CompactMediaSettingsWidget(),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
      print('Updated compact video preview with cloned stream');
      
      // 監聽視訊流結束事件，自動刷新
      if (stream != null) {
        final videoTracks = stream.getVideoTracks();
        for (final track in videoTracks) {
          track.onEnded.listen((_) {
            print('Video track ended, refreshing preview...');
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                updatePreview();
              }
            });
          });
        }
      }
    } catch (e) {
      print('Error updating preview: $e');
      _videoElement.srcObject = null;
      
      // 如果獲取流失敗，嘗試強制刷新
      try {
        await _mediaService.forceRefreshStream();
        final retryStream = await _mediaService.getUserMedia();
        _videoElement.srcObject = retryStream;
        print('Successfully refreshed video preview after error');
      } catch (e2) {
        print('Failed to refresh video preview: $e2');
      }
    }
  }

  /// 同步設備選擇到所有相關系統
  Future<void> _syncDeviceSelection({
    String? audioDeviceId,
    String? videoDeviceId,
  }) async {
    try {
      // 1. 更新 SharedPreferences（會議使用的預設設備）
      if (audioDeviceId != null) {
        await sharedPreferencesService.setDefaultMicrophoneId(audioDeviceId);
        print('Synced audio device to SharedPreferences: $audioDeviceId');
      }
      
      if (videoDeviceId != null) {
        await sharedPreferencesService.setDefaultCameraId(videoDeviceId);
        print('Synced video device to SharedPreferences: $videoDeviceId');
      }
      
      // 2. 強制同步設備設置到橋接服務和 Agora SDK
      await _mediaService.forceSyncToSDK();
      
      print('Device selection fully synced');
    } catch (e) {
      print('Error syncing device selection: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      // 停止預覽流（這是克隆的流）
      final stream = _videoElement.srcObject;
      if (stream is html.MediaStream) {
        _mediaService.stopMediaStream(stream);
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
              
              // 同步設備選擇到所有系統
              await _syncDeviceSelection(audioDeviceId: val);
              
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
              
              // 同步設備選擇到所有系統
              await _syncDeviceSelection(videoDeviceId: val);
              
              await updatePreview();
            }
          },
          hint: const Text('Select video input'),
        ),
        const SizedBox(height: 16),
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
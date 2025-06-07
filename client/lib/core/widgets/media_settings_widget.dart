import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../utils/media_device_service.dart';

class MediaSettingsWidget extends StatefulWidget {
  const MediaSettingsWidget({super.key});

  @override
  State<MediaSettingsWidget> createState() => _MediaSettingsWidgetState();
}

class _MediaSettingsWidgetState extends State<MediaSettingsWidget> {
  final MediaDeviceService _mediaService = MediaDeviceService();
  final RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    await _renderer.initialize();
    await _mediaService.init();
    await updatePreview();
    setState(() {});
  }

  Future<void> updatePreview() async {
    final stream = await _mediaService.getUserMedia();
    _renderer.srcObject = stream;
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mediaService.audioInputs.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎙 Audio Input Device'),
              DropdownButton<String>(
                value: _mediaService.selectedAudioInputId,
                items: _mediaService.audioInputs.map((device) {
                  return DropdownMenuItem<String>(
                    value: device.deviceId,
                    child: Text(device.label.isNotEmpty ? device.label : 'Unnamed Microphone'),
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
              ),
              const SizedBox(height: 16),
              const Text('📷 Video Input Device'),
              DropdownButton<String>(
                value: _mediaService.selectedVideoInputId,
                items: _mediaService.videoInputs.map((device) {
                  return DropdownMenuItem<String>(
                    value: device.deviceId,
                    child: Text(device.label.isNotEmpty ? device.label : 'Unnamed Camera'),
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
              const Text('🎥 Video Preview'),
              Container(
                width: 320,
                height: 240,
                color: Colors.black,
                child: RTCVideoView(_renderer, mirror: true),
              ),
            ],
          );
  }
}
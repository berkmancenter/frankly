import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async' show unawaited;

class MediaDeviceService {
  List<MediaDeviceInfo> audioInputs = [];
  List<MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  bool micEnabled = true;
  bool camEnabled = true;

  Future<void> init() async {
    await Permission.microphone.request();
    await Permission.camera.request();

    final devices = await navigator.mediaDevices.enumerateDevices();
    audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    selectedAudioInputId ??= audioInputs.isNotEmpty ? audioInputs.first.deviceId : null;
    selectedVideoInputId ??= videoInputs.isNotEmpty ? videoInputs.first.deviceId : null;
  }

  void selectAudio(String deviceId) {
    selectedAudioInputId = deviceId;
  }

  void selectVideo(String deviceId) {
    selectedVideoInputId = deviceId;
  }

  void toggleMic(bool enabled) {
    micEnabled = enabled;
  }

  void toggleCam(bool enabled) {
    camEnabled = enabled;
  }

  Future<MediaStream> getUserMedia() async {
    // Correctly define constraints to handle null device IDs by requesting default devices
    final dynamic audioConstraint;
    if (micEnabled) {
      audioConstraint = selectedAudioInputId != null
          ? {'deviceId': selectedAudioInputId}
          : true; // Request default audio input if no ID is selected
    } else {
      audioConstraint = false;
    }

    final dynamic videoConstraint;
    if (camEnabled) {
      videoConstraint = selectedVideoInputId != null
          ? {'deviceId': selectedVideoInputId}
          : true; // Request default video input if no ID is selected
    } else {
      videoConstraint = false;
    }

    final Map<String, dynamic> constraints = {
      'audio': audioConstraint,
      'video': videoConstraint,
    };

    // For all platforms, including web, use flutter_webrtc's getUserMedia directly.
    // flutter_webrtc handles the platform-specifics internally.
    return await navigator.mediaDevices.getUserMedia(constraints);
  }

  void stopMediaStream(MediaStream? stream) {
    if (stream == null) return;
    stream.getTracks().forEach((track) => track.stop());
  }
}

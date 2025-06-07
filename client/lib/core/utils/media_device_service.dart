
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final Map<String, dynamic> constraints = {
      'audio': micEnabled
          ? {'deviceId': selectedAudioInputId}
          : false,
      'video': camEnabled
          ? {'deviceId': selectedVideoInputId}
          : false,
    };

    return await navigator.mediaDevices.getUserMedia(constraints);
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

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

  Future<html.MediaStream> getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': micEnabled
          ? {'deviceId': selectedAudioInputId}
          : false,
      'video': camEnabled
          ? {'deviceId': selectedVideoInputId}
          : false,
    };

    if (kIsWeb) {
      // 在 Web 平台上，直接返回 html.MediaStream
      return await html.window.navigator.mediaDevices!.getUserMedia(constraints);
    } else {
      // 在原生平台上，將 flutter_webrtc 的 MediaStream 轉換為 html.MediaStream
      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      return stream as html.MediaStream;
    }
  }

  // 修改方法以接受 html.MediaStream
  void stopMediaStream(html.MediaStream? stream) {
    if (stream == null) return;

    final tracks = stream.getTracks();
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].stop();
    }
  }
}

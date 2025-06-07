import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class MediaDeviceService {
  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  bool micEnabled = true;
  bool camEnabled = true;

  Future<void> init() async {
    // Request permissions first
    await Permission.microphone.request();
    await Permission.camera.request();

    if (kIsWeb) {
      try {
        final devices = await html.window.navigator.mediaDevices?.enumerateDevices();
        if (devices != null) {
          // Filter for MediaDeviceInfo and correct kind
          audioInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where((d) => d.kind == 'audioinput')
              .toList();
          videoInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where((d) => d.kind == 'videoinput')
              .toList();
        }
        // Set default selected device if none is selected and list is not empty
        selectedAudioInputId ??= audioInputs.isNotEmpty ? audioInputs.first.deviceId : null;
        selectedVideoInputId ??= videoInputs.isNotEmpty ? videoInputs.first.deviceId : null;
      } catch (e) {
        print('Error enumerating devices: $e');
        audioInputs = [];
        videoInputs = [];
      }
    } else {
      // For non-web platforms, initialize as empty lists for this minimal web version
      audioInputs = [];
      videoInputs = [];
      // Alternatively, one might throw UnimplementedError here in a stricter setup.
    }
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

  Future<html.MediaStream?> getUserMedia() async {
    if (kIsWeb) {
      final dynamic audioConstraint;
      if (micEnabled) {
        // Use 'exact' for deviceId constraint for stricter matching if an ID is provided
        audioConstraint = selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
            ? {'deviceId': {'exact': selectedAudioInputId}}
            : true; // Request default audio input
      } else {
        audioConstraint = false;
      }

      final dynamic videoConstraint;
      if (camEnabled) {
        videoConstraint = selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
            ? {'deviceId': {'exact': selectedVideoInputId}}
            : true; // Request default video input
      } else {
        videoConstraint = false;
      }

      final Map<String, dynamic> constraints = {
        if (audioConstraint != null) 'audio': audioConstraint,
        if (videoConstraint != null) 'video': videoConstraint,
      };

      // If both are false, return null or handle as an error, as getUserMedia might fail.
      if (audioConstraint == false && videoConstraint == false) {
        print('Both audio and video are disabled. Cannot getUserMedia.');
        return null;
      }

      try {
        return await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      } catch (e) {
        print('Error getting user media: $e');
        return null;
      }
    } else {
      // For non-web platforms, this functionality is not implemented in this version
      throw UnimplementedError('getUserMedia is not implemented for non-web platforms in this version.');
    }
  }

  void stopMediaStream(html.MediaStream? stream) {
    if (kIsWeb) {
      if (stream == null) return;
      stream.getTracks().forEach((track) {
        track.stop();
      });
    } else {
      // For non-web platforms, do nothing or throw UnimplementedError
      // throw UnimplementedError('stopMediaStream is not implemented for non-web platforms in this version.');
    }
  }
}

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

enum MediaStreamLocation {
  all,
  meeting,
  preview,
}

/// Currently only implemented for web.
class MediaDeviceService {
  // Singleton class
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;
  MediaDeviceService._internal();

  // Displayed media stream
  html.MediaStream? _mediaStream;
  html.MediaStream? get mediaStream => _mediaStream;
  // Preview media stream
  html.MediaStream? _previewMediaStream;
  html.MediaStream? get previewMediaStream => _previewMediaStream;

  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  bool micEnabled = true;
  bool camEnabled = true;

  Future<void> init() async {
    await Permission.microphone.request();
    await Permission.camera.request();

    if (kIsWeb) {
      try {
        final devices =
            await html.window.navigator.mediaDevices?.enumerateDevices();
        if (devices != null) {
          audioInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where((d) => d.kind == 'audioinput')
              .toList();
          videoInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where((d) => d.kind == 'videoinput')
              .toList();
        }

        // Set the default selected device if it's currently null.
        selectedAudioInputId ??=
            audioInputs.isNotEmpty ? audioInputs.first.deviceId : null;
        selectedVideoInputId ??=
            videoInputs.isNotEmpty ? videoInputs.first.deviceId : null;
      } catch (e) {
        loggingService.log('Error listing available devices: $e');
        audioInputs = [];
        videoInputs = [];
      }
    } else {
      // Only web is supported for now.
      audioInputs = [];
      videoInputs = [];
    }
  }

  Future<void> selectAudio(String deviceId) async {
    selectedAudioInputId = deviceId;
    await getUserMedia(mediaStreamLocation: MediaStreamLocation.all);
  }

  Future<void> selectVideo(String deviceId) async {
    selectedVideoInputId = deviceId;
    await getUserMedia(mediaStreamLocation: MediaStreamLocation.all);
  }

  void toggleMic(bool enabled) {
    micEnabled = enabled;
  }

  void toggleCam(bool enabled) {
    camEnabled = enabled;
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia({
    required MediaStreamLocation mediaStreamLocation,
  }) async {
    if (kIsWeb) {
      if (!micEnabled && !camEnabled) {
        return;
      }

      final dynamic audioConstraint;
      if (micEnabled) {
        // If a specific audio input was selected, pass it into 'exact'.
        audioConstraint =
            selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
                ? {
                    'deviceId': {'exact': selectedAudioInputId},
                  }
                : true; // Default
      } else {
        audioConstraint = false;
      }

      final dynamic videoConstraint;
      if (camEnabled) {
        videoConstraint =
            selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
                ? {
                    'deviceId': {'exact': selectedVideoInputId},
                  }
                : true; // Default
      } else {
        videoConstraint = false;
      }

      final Map<String, dynamic> constraints = {
        if (audioConstraint != null) 'audio': audioConstraint,
        if (videoConstraint != null) 'video': videoConstraint,
      };

      // If both are false, return null or handle as an error, as getUserMedia might fail.
      if (audioConstraint == false && videoConstraint == false) {
        loggingService
            .log('Both audio and video are disabled. Cannot getUserMedia.');
        return;
      }

      try {
        final newMediaStream =
            await html.window.navigator.mediaDevices?.getUserMedia(constraints);
        switch (mediaStreamLocation) {
          case MediaStreamLocation.all:
            _mediaStream = newMediaStream;
            _previewMediaStream = newMediaStream;
            break;
          case MediaStreamLocation.meeting:
            _mediaStream = newMediaStream;
            break;
          case MediaStreamLocation.preview:
            _previewMediaStream = newMediaStream;
            break;
        }
      } catch (e) {
        loggingService.log('Error getting user media: $e');
        _mediaStream = null;
      }
    } else {
      throw UnimplementedError(
        'getUserMedia error: Only web is supported.',
      );
    }
  }

  void stopMediaStream({required MediaStreamLocation mediaStreamLocation}) {
    if (kIsWeb) {
      if (_mediaStream == null && _previewMediaStream == null) return;
      if (mediaStreamLocation == MediaStreamLocation.preview ||
          mediaStreamLocation == MediaStreamLocation.all) {
        _previewMediaStream?.getTracks().forEach((track) {
          track.stop();
        });
        _previewMediaStream = null;
      }
      if (mediaStreamLocation == MediaStreamLocation.meeting ||
          mediaStreamLocation == MediaStreamLocation.all) {
        _mediaStream?.getTracks().forEach((track) {
          track.stop();
        });
        _mediaStream = null;
      }
    } else {
      throw UnimplementedError('stopMediaStream error: Only web is supported.');
    }
  }
}

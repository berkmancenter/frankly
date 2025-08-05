import 'dart:async';

import 'package:client/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Currently only implemented for web.
class MediaDeviceService {
  // Singleton class
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;
  MediaDeviceService._internal();

  // Media stream for local A/V preview
  html.MediaStream? _previewMediaStream;
  html.MediaStream? get previewMediaStream => _previewMediaStream;

  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  bool micEnabled = true;
  bool camEnabled = true;

  Future<void> init() async {
    if (kIsWeb) {
      try {
        final devices =
            await html.window.navigator.mediaDevices?.enumerateDevices();
        if (devices != null) {
          audioInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where(
                (d) =>
                    d.kind == 'audioinput' &&
                    d.label != null &&
                    d.label!.isNotEmpty,
              )
              .toList();
          videoInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where(
                (d) =>
                    d.kind == 'videoinput' &&
                    d.label != null &&
                    d.label!.isNotEmpty,
              )
              .toList();
        }

        // First, check for defaults from shared preferences.
        selectedAudioInputId =
            sharedPreferencesService.getDefaultMicrophoneId();
        selectedVideoInputId = sharedPreferencesService.getDefaultCameraId();

        // If no defaults, use the first available device.
        selectedAudioInputId ??=
            audioInputs.isNotEmpty ? audioInputs.first.deviceId : null;
        selectedVideoInputId ??=
            videoInputs.isNotEmpty ? videoInputs.first.deviceId : null;

        // Update shared preferences with default devices
        if (selectedAudioInputId != null) {
          await sharedPreferencesService
              .setDefaultMicrophoneId(selectedAudioInputId!);
        }
        if (selectedVideoInputId != null) {
          await sharedPreferencesService
              .setDefaultCameraId(selectedVideoInputId!);
        }
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

  Future<void> selectAudioDevice({
    required String deviceId,
  }) async {
    selectedAudioInputId = deviceId;
    await getUserMedia();
    await sharedPreferencesService
        .setDefaultMicrophoneId(selectedAudioInputId!);
  }

  Future<void> selectVideoDevice({
    required String deviceId,
  }) async {
    selectedVideoInputId = deviceId;
    await getUserMedia();
    await sharedPreferencesService.setDefaultCameraId(selectedVideoInputId!);
  }

  void toggleMic(bool enabled) {
    micEnabled = enabled;
  }

  void toggleCam(bool enabled) {
    camEnabled = enabled;
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia() async {
    if (kIsWeb) {
      if (!micEnabled && !camEnabled) {
        return;
      }

      final dynamic audioConstraint;
      if (micEnabled) {
        final micPermissions = await Permission.microphone.request();
        if (micPermissions.isDenied || micPermissions.isPermanentlyDenied) {
          audioConstraint = false;
        } else {
          // If a specific audio input was selected, pass it into 'exact'.
          audioConstraint =
              selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
                  ? {
                      'deviceId': {'exact': selectedAudioInputId},
                    }
                  : true;
        }
      } else {
        audioConstraint = false;
      }

      final dynamic videoConstraint;
      if (camEnabled) {
        final camPermissions = await Permission.camera.request();
        if (camPermissions.isDenied || camPermissions.isPermanentlyDenied) {
          videoConstraint = false;
        } else {
          videoConstraint =
              selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
                  ? {
                      'deviceId': {'exact': selectedVideoInputId},
                    }
                  : true;
        }
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
        _previewMediaStream = newMediaStream;
      } catch (e) {
        loggingService.log('Error getting user media: $e');
        _previewMediaStream = null;
      }
    } else {
      throw UnimplementedError(
        'getUserMedia error: Only web is supported.',
      );
    }
  }

  void stopPreviewMediaStream() {
    if (kIsWeb) {
      if (_previewMediaStream == null) return;
      _previewMediaStream?.getTracks().forEach((track) {
        track.stop();
      });
      _previewMediaStream = null;
    } else {
      throw UnimplementedError('stopMediaStream error: Only web is supported.');
    }
  }
}

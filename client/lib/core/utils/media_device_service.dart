import 'dart:async';

import 'package:client/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Currently only implemented for web.
class MediaDeviceService {
  // Singleton class
  MediaDeviceService._internal();
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;

  // Media stream for local A/V preview
  html.MediaStream? _previewMediaStream;
  html.MediaStream? get previewMediaStream => _previewMediaStream;

  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  Future<void> init({
    required bool requestMic,
    required bool requestCamera,
  }) async {
    if (kIsWeb) {
      try {
        // Start by requesting permissions so that devices can be listed.
        if (requestMic) {
          await Permission.microphone.request();
        }
        if (requestCamera) {
          await Permission.camera.request();
        }

        final devices =
            await html.window.navigator.mediaDevices?.enumerateDevices();
        if (devices != null) {
          audioInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where(
                (d) =>
                    d.kind == 'audioinput' &&
                    d.label != null &&
                    d.label!.isNotEmpty &&
                    d.label != 'default',
              )
              .toList();
          videoInputs = devices
              .whereType<html.MediaDeviceInfo>()
              .where(
                (d) =>
                    d.kind == 'videoinput' &&
                    d.label != null &&
                    d.label!.isNotEmpty &&
                    d.label != 'default',
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
    // await getUserMedia();
    await sharedPreferencesService
        .setDefaultMicrophoneId(selectedAudioInputId!);
  }

  Future<void> selectVideoDevice({
    required String deviceId,
  }) async {
    selectedVideoInputId = deviceId;
    // await getUserMedia();
    await sharedPreferencesService.setDefaultCameraId(selectedVideoInputId!);
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia() async {
    if (false) {
      final Map<String, dynamic>? audioConstraint;

      final micPermissions = await Permission.microphone.request();
      if (micPermissions.isDenied || micPermissions.isPermanentlyDenied) {
        audioConstraint = null;
      } else {
        // If a specific audio input was selected, pass it into 'exact'.
        audioConstraint =
            selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
                ? {
                    'deviceId': {'exact': selectedAudioInputId},
                  }
                : null;
      }

      final Map<String, dynamic>? videoConstraint;

      final camPermissions = await Permission.camera.request();
      if (camPermissions.isDenied || camPermissions.isPermanentlyDenied) {
        videoConstraint = null;
      } else {
        videoConstraint =
            selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
                ? {
                    'deviceId': {'exact': selectedVideoInputId},
                  }
                : null;
      }

      final Map<String, dynamic> constraints = {
        if (audioConstraint != null) 'audio': audioConstraint,
        if (videoConstraint != null) 'video': videoConstraint,
      };
      print('getUserMedia constraints: $constraints');

      try {
        final newMediaStream =
            await html.window.navigator.mediaDevices?.getUserMedia(constraints);
        _previewMediaStream = newMediaStream;
      } catch (e) {
        loggingService.log('Error getting user media: $e');
        _previewMediaStream = null;
        // Clear stored device preferences if getUserMedia fails.
        if (selectedAudioInputId != null) {
          await sharedPreferencesService.clearDefaultCameraId();
        }
        if (selectedVideoInputId != null) {
          await sharedPreferencesService.clearDefaultCameraId();
        }
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

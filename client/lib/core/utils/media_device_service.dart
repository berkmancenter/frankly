import 'dart:async';

import 'package:client/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class MediaDeviceService {
  // Singleton class
  MediaDeviceService._internal();
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;

  late PermissionStatus micPermissionStatus;
  late PermissionStatus cameraPermissionStatus;

  // Media stream for local A/V preview
  html.MediaStream? _previewMediaStream;
  html.MediaStream? get previewMediaStream => _previewMediaStream;

  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  Future<PermissionStatus> requestPermissions(Permission permission) async {
    try {
      // The ".status" call does not work on all platforms - catch the exception.
      PermissionStatus status = await permission.status;
      return status.isGranted ? status : await permission.request();
    } catch (e) {
      // If permission request fails, just return denied.
      try {
        return await permission.request();
      } catch (e) {
        return PermissionStatus.denied;
      }
    }
  }

  Future<void> init() async {
    try {
      // Start by requesting permissions so that devices can be listed.
      micPermissionStatus = await requestPermissions(Permission.microphone);
      cameraPermissionStatus = await requestPermissions(Permission.camera);

      final devices =
          await html.window.navigator.mediaDevices?.enumerateDevices();

      if (devices?.isNotEmpty ?? false) {
        audioInputs = devices!
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
      selectedAudioInputId = sharedPreferencesService.getDefaultMicrophoneId();
      selectedVideoInputId = sharedPreferencesService.getDefaultCameraId();

      // If no defaults, use the first available device.
      // Don't save this as a default preference as it wasn't explicitly chosen.
      if (selectedAudioInputId == null && audioInputs.isNotEmpty) {
        selectedAudioInputId = audioInputs.first.deviceId;
      }

      if (selectedVideoInputId == null && videoInputs.isNotEmpty) {
        selectedVideoInputId = videoInputs.first.deviceId;
      }
    } catch (e) {
      loggingService.log('Error listing available devices: $e');
      audioInputs = [];
      videoInputs = [];
    }
  }

  Future<void> selectAudioDevice({
    required String deviceId,
    required bool shouldUpdatePreview,
  }) async {
    selectedAudioInputId = deviceId;
    if (shouldUpdatePreview) {
      await getUserMedia();
    }
    await sharedPreferencesService
        .setDefaultMicrophoneId(selectedAudioInputId!);
  }

  Future<void> selectVideoDevice({
    required String deviceId,
    required bool shouldUpdatePreview,
  }) async {
    selectedVideoInputId = deviceId;
    if (shouldUpdatePreview) {
      await getUserMedia();
    }
    await sharedPreferencesService.setDefaultCameraId(selectedVideoInputId!);
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia() async {
    Map<String, dynamic>? audioConstraint;

    if (!micPermissionStatus.isGranted) {
      // Try requesting permission again in case it's not granted.
      try {
        micPermissionStatus = await requestPermissions(Permission.microphone);
      } catch (e) {
        audioConstraint = null;
      }
    }

    if (!micPermissionStatus.isGranted) {
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

    Map<String, dynamic>? videoConstraint;

    if (!cameraPermissionStatus.isGranted) {
      try {
        cameraPermissionStatus = await requestPermissions(Permission.camera);
      } catch (e) {
        videoConstraint = null;
      }
    }

    if (!cameraPermissionStatus.isGranted) {
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

    try {
      final newMediaStream =
          await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      _previewMediaStream = newMediaStream;
    } catch (e) {
      loggingService.log('Error getting user media: $e');
      _previewMediaStream = null;
      // Clear stored device preferences if getUserMedia fails.
      if (selectedAudioInputId != null) {
        await sharedPreferencesService.clearDefaultMicrophoneId();
      }
      if (selectedVideoInputId != null) {
        await sharedPreferencesService.clearDefaultCameraId();
      }
    }
  }

  void stopPreviewMediaStream() {
    if (_previewMediaStream == null) return;
    _previewMediaStream?.getTracks().forEach((track) {
      track.stop();
    });
    _previewMediaStream = null;
  }
}

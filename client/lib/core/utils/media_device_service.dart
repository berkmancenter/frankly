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

      await _refreshDeviceList();
    } catch (e) {
      loggingService.log('Error listing available devices: $e');
      audioInputs = [];
      videoInputs = [];
    }
  }

  /// Re-enumerates devices when we hold a live stream but have no labelled
  /// devices to show for it. Browser expose device labels only once
  /// permission has actually been granted, so whenever permission is granted
  /// during [getUserMedia] itself, lists built by [init]
  /// are still empty and the UI has nothing to render even though the camera was acquired.
  Future<void> _refreshDeviceListIfStale() async {
    if (_previewMediaStream == null) return;
    if (audioInputs.isNotEmpty && videoInputs.isNotEmpty) return;
    await _refreshDeviceList();
  }

  /// Re-enumerates available devices and updates [audioInputs]/[videoInputs]
  /// (and the selected device ids, if unset).
  Future<void> _refreshDeviceList() async {
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
    selectedAudioInputId ??= sharedPreferencesService.getDefaultMicrophoneId();
    selectedVideoInputId ??= sharedPreferencesService.getDefaultCameraId();

    // If no defaults, use the first available device.
    // Don't save this as a default preference as it wasn't explicitly chosen.
    if (selectedAudioInputId == null && audioInputs.isNotEmpty) {
      selectedAudioInputId = audioInputs.first.deviceId;
    }

    if (selectedVideoInputId == null && videoInputs.isNotEmpty) {
      selectedVideoInputId = videoInputs.first.deviceId;
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

  bool _isPermissionError(Object error) =>
      error.toString().contains('NotAllowedError');

  Future<Map<String, dynamic>> _resolveConstraints() async {
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

    return {
      if (audioConstraint != null) 'audio': audioConstraint,
      if (videoConstraint != null) 'video': videoConstraint,
    };
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia() async {
    // Stop any existing preview stream first - otherwise its tracks
    // are orphaned once we overwrite _previewMediaStream below.
    stopPreviewMediaStream();

    final constraints = await _resolveConstraints();

    try {
      _previewMediaStream =
          await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      await _refreshDeviceListIfStale();
    } catch (e) {
      // On Firefox, permission.status (navigator.permissions.query) can
      // report "granted" from a stale permission-store entry even after the
      // underlying grant has expired (e.g. after a page refresh), so the
      // first live getUserMedia() call since the refresh fails with
      // NotAllowedError despite looking granted. Force a fresh permission
      // check and retry once before giving up.
      Object error = e;
      final hadGrantedStatus =
          micPermissionStatus.isGranted || cameraPermissionStatus.isGranted;
      if (_isPermissionError(error) && hadGrantedStatus) {
        loggingService.log(
          'getUserMedia failed despite granted permission status, retrying with a fresh permission check: $error',
        );
        micPermissionStatus = PermissionStatus.denied;
        cameraPermissionStatus = PermissionStatus.denied;
        try {
          final retryConstraints = await _resolveConstraints();
          _previewMediaStream = await html.window.navigator.mediaDevices
              ?.getUserMedia(retryConstraints);
          await _refreshDeviceListIfStale();
          return;
        } catch (retryError) {
          error = retryError;
        }
      }

      loggingService.log('Error getting user media: $error');
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

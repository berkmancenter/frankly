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
    try {
      await _refreshDeviceList();
    } catch (e) {
      loggingService.log('Error refreshing device list: $e');
    }
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

  /// Whether the requested device itself is the problem - a deviceId stored
  /// before a refresh can name something the browser will no longer admit to
  /// having, which fails the 'exact' constraint.
  bool _isDeviceError(Object error) {
    final text = error.toString();
    return text.contains('OverconstrainedError') ||
        text.contains('NotFoundError');
  }

  /// A specific device when one is selected, otherwise any device of that
  /// kind. This must never be omitted for a granted permission: getUserMedia
  /// rejects a request with neither 'audio' nor 'video' as
  /// "audio and/or video is required".
  Object _deviceConstraint(String? deviceId) =>
      deviceId != null && deviceId.isNotEmpty
          ? {
              'deviceId': {'exact': deviceId},
            }
          : true;

  /// Forgets remembered devices, both here and in storage, so the next
  /// request asks for whatever the browser is willing to provide.
  Future<void> _forgetSelectedDevices() async {
    if (selectedAudioInputId != null) {
      await sharedPreferencesService.clearDefaultMicrophoneId();
      selectedAudioInputId = null;
    }
    if (selectedVideoInputId != null) {
      await sharedPreferencesService.clearDefaultCameraId();
      selectedVideoInputId = null;
    }
  }

  Future<Map<String, dynamic>> _resolveConstraints() async {
    if (!micPermissionStatus.isGranted) {
      // Try requesting permission again in case it's not granted.
      try {
        micPermissionStatus = await requestPermissions(Permission.microphone);
      } catch (e) {
        loggingService.log('Error requesting microphone permission: $e');
      }
    }

    if (!cameraPermissionStatus.isGranted) {
      try {
        cameraPermissionStatus = await requestPermissions(Permission.camera);
      } catch (e) {
        loggingService.log('Error requesting camera permission: $e');
      }
    }

    // Empty device lists mean labels are still hidden (permission isn't live
    // yet), not that the device is absent - so only skip a kind once we have
    // positively enumerated devices and this kind isn't among them. Asking
    // for a device that genuinely isn't there fails the whole request.
    final devicesKnown = audioInputs.isNotEmpty || videoInputs.isNotEmpty;

    return {
      if (micPermissionStatus.isGranted &&
          (!devicesKnown || audioInputs.isNotEmpty))
        'audio': _deviceConstraint(selectedAudioInputId),
      if (cameraPermissionStatus.isGranted &&
          (!devicesKnown || videoInputs.isNotEmpty))
        'video': _deviceConstraint(selectedVideoInputId),
    };
  }

  /// HTML method for getting a MediaStream based on selected devices and permissions.
  Future<void> getUserMedia() async {
    // Stop any existing preview stream first - otherwise its tracks
    // are orphaned once we overwrite _previewMediaStream below.
    stopPreviewMediaStream();

    final constraints = await _resolveConstraints();

    if (constraints.isEmpty) {
      // Neither permission is available, so there is nothing to ask for
      loggingService.log('Skipping getUserMedia: no audio or video permission');
      _previewMediaStream = null;
      return;
    }

    try {
      _previewMediaStream =
          await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      await _refreshDeviceListIfStale();
    } catch (e) {
      // If getUserMedia fails, it could be due to either a permission error
      // (user denied access) or a device error (requested device not available).
      // In either case, we attempt to recover by clearing the relevant state
      // and retrying once.
      Object error = e;
      if (_isPermissionError(error) || _isDeviceError(error)) {
        loggingService.log('getUserMedia failed, retrying once: $error');
        if (_isPermissionError(error)) {
          micPermissionStatus = PermissionStatus.denied;
          cameraPermissionStatus = PermissionStatus.denied;
        }
        if (_isDeviceError(error)) {
          await _forgetSelectedDevices();
        }
        try {
          final retryConstraints = await _resolveConstraints();
          if (retryConstraints.isNotEmpty) {
            _previewMediaStream = await html.window.navigator.mediaDevices
                ?.getUserMedia(retryConstraints);
            await _refreshDeviceListIfStale();
            return;
          }
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

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:universal_html/html.dart' as html;

class MediaDeviceService extends ChangeNotifier {
  List<html.MediaDeviceInfo> audioInputs = [];
  List<html.MediaDeviceInfo> videoInputs = [];

  String? selectedAudioInputId;
  String? selectedVideoInputId;

  bool micEnabled = true;
  bool camEnabled = true;

  // Added: Control whether to publish media stream to external SDK (e.g., Agora)
  bool _publishAudioToSDK = false;
  bool _publishVideoToSDK = false;

  // Track if we're currently providing a stream to SDK to avoid unnecessary null calls
  bool _isProvidingStreamToSDK = false;

  // Singleton pattern to ensure only one instance globally
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;
  MediaDeviceService._internal();

  // Shared main media stream
  html.MediaStream? _sharedStream;

  // Record current stream device IDs for device change detection
  String? _currentAudioDeviceId;
  String? _currentVideoDeviceId;
  bool _currentMicEnabled = true;
  bool _currentCamEnabled = true;

  // Bridge callback functions to notify external SDK of state changes
  Function(bool enabled, String? deviceId)? _onAudioPublishChanged;
  Function(bool enabled, String? deviceId)? _onVideoPublishChanged;
  Function(html.MediaStream? stream)? _onVideoStreamChanged;

  // Getters for publish states
  bool get publishAudioToSDK => _publishAudioToSDK;
  bool get publishVideoToSDK => _publishVideoToSDK;

  /// Register bridge callback for audio
  void registerAudioBridge(Function(bool enabled, String? deviceId) callback) {
    _onAudioPublishChanged = callback;
  }

  void registerVideoBridge(Function(bool enabled, String? deviceId) callback) {
    _onVideoPublishChanged = callback;
  }

  void registerVideoStreamBridge(Function(html.MediaStream? stream) callback) {
    _onVideoStreamChanged = callback;
  }

  /// Control audio publishing to external SDK
  Future<void> setAudioPublishToSDK(bool enabled) async {
    if (_publishAudioToSDK == enabled) return;

    _publishAudioToSDK = enabled;
    print('Audio publish to SDK: $enabled');

    // If starting to publish audio, ensure microphone is enabled
    if (enabled && !micEnabled) {
      print('Enabling microphone for audio publishing');
      micEnabled = true;
      _invalidateSharedStream(); // Recreate stream
    }

    // Notify external SDK of audio publish state change
    _onAudioPublishChanged?.call(enabled && micEnabled, selectedAudioInputId);

    // Notify listeners of state change
    notifyListeners();
  }

  /// Control video publishing to external SDK
  Future<void> setVideoPublishToSDK(bool enabled) async {
    if (_publishVideoToSDK == enabled) return;

    _publishVideoToSDK = enabled;
    print('Video publish to SDK: $enabled');

    // If starting to publish video, ensure camera is enabled
    if (enabled && !camEnabled) {
      print('Enabling camera for video publishing');
      camEnabled = true;
      _invalidateSharedStream(); // Recreate stream
    }

    // Notify external SDK of video publish state change
    _onVideoPublishChanged?.call(enabled && camEnabled, selectedVideoInputId);

    // Only provide/remove stream when there's an actual state change that requires it
    if (enabled && camEnabled) {
      final stream = await _getSharedStream();
      if (stream != null) {
        _onVideoStreamChanged?.call(stream);
        _isProvidingStreamToSDK = true;
      }
    } else if (enabled) {
      // If enabled but camera is off, don't call the stream callback
      // The publish state callback above already handles the disable case
      
      
      print('Video publish enabled but camera is off, not updating stream');
    } else {
      if (_isProvidingStreamToSDK) {
        // _onVideoStreamChanged?.call(null);
        _isProvidingStreamToSDK = false;
      }
    }

    // Notify listeners of state change
    notifyListeners();
  }

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
    }
  }

  /// Select audio device
  void selectAudio(String deviceId) {
    selectedAudioInputId = deviceId;
    // If device changes, need to recreate main stream
    if (_currentAudioDeviceId != deviceId) {
      _invalidateSharedStream();
    }

    // Always notify bridge service of device change (regardless of publishing)
    _onAudioPublishChanged?.call(micEnabled && _publishAudioToSDK, deviceId);

    // Notify listeners of state change
    notifyListeners();
  }

  /// Select video device
  void selectVideo(String deviceId) {
    selectedVideoInputId = deviceId;
    // If device changes, need to recreate main stream
    if (_currentVideoDeviceId != deviceId) {
      _invalidateSharedStream();
    }

    // Always notify bridge service of device change (regardless of publishing)
    _onVideoPublishChanged?.call(camEnabled && _publishVideoToSDK, deviceId);
    // If currently publishing video, update media stream
    if (_publishVideoToSDK) {
      _updateVideoStreamToSDK();
    }

    // Notify listeners of state change
    notifyListeners();
  }

  /// Toggle microphone on/off
  void toggleMic(bool enabled) {
    micEnabled = enabled;
    // When audio state changes, need to recreate stream
    if (_currentMicEnabled != enabled) {
      _invalidateSharedStream();
    }

    // If currently publishing to SDK, notify change
    if (_publishAudioToSDK) {
      _onAudioPublishChanged?.call(enabled, selectedAudioInputId);
    }

    // Notify listeners of state change
    notifyListeners();
  }

  /// Toggle camera on/off
  void toggleCam(bool enabled) {
    camEnabled = enabled;
    // When video state changes, need to recreate stream
    if (_currentCamEnabled != enabled) {
      _invalidateSharedStream();
    }

    // If currently publishing to SDK, notify change
    if (_publishVideoToSDK) {
      _onVideoPublishChanged?.call(enabled, selectedVideoInputId);
      // Update media stream
      _updateVideoStreamToSDK();
    }

    // Notify listeners of state change
    notifyListeners();
  }

  /// Update video stream to SDK
  Future<void> _updateVideoStreamToSDK() async {
    if (_publishVideoToSDK && camEnabled) {
      final stream = await _getSharedStream();
      if (stream != null) {
        _onVideoStreamChanged?.call(stream);
        _isProvidingStreamToSDK = true;
      }
    } else if (_publishVideoToSDK) {
      // Publishing is enabled but camera is off - don't update stream
      print('Video publishing enabled but camera off, not updating stream');
    } else {
      // Not publishing - only call null if we were previously providing a stream
      if (_isProvidingStreamToSDK) {
        _onVideoStreamChanged?.call(null);
        _isProvidingStreamToSDK = false;
      }
    }
  }

  /// Invalidate shared stream, will recreate on next get
  void _invalidateSharedStream() {
    if (_sharedStream != null) {
      print('Stopping shared stream tracks');
      _sharedStream!.getTracks().forEach((track) => track.stop());
      _sharedStream = null;
      _currentAudioDeviceId = null;
      _currentVideoDeviceId = null;
    }
  }

  /// Get or create shared media stream
  Future<html.MediaStream?> _getSharedStream() async {
    if (!kIsWeb) {
      throw UnimplementedError(
          'getUserMedia is not implemented for non-web platforms in this version.',);
    }

    // If shared stream exists and devices have not changed, return it
    if (_sharedStream != null &&
        _currentAudioDeviceId == selectedAudioInputId &&
        _currentVideoDeviceId == selectedVideoInputId &&
        _currentMicEnabled == micEnabled &&
        _currentCamEnabled == camEnabled) {
      return _sharedStream;
    }

    // Stop old stream
    _invalidateSharedStream();

    final dynamic audioConstraint;
    if (micEnabled) {
      audioConstraint = selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
          ? {'deviceId': {'exact': selectedAudioInputId}}
          : true;
    } else {
      audioConstraint = false;
    }

    final dynamic videoConstraint;
    if (camEnabled) {
      videoConstraint = selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
          ? {'deviceId': {'exact': selectedVideoInputId}}
          : true;
    } else {
      videoConstraint = false;
    }

    final Map<String, dynamic> constraints = {
      if (audioConstraint != null) 'audio': audioConstraint,
      if (videoConstraint != null) 'video': videoConstraint,
    };

    // If both audio and video are disabled, return null
    if (audioConstraint == false && videoConstraint == false) {
      print('Both audio and video are disabled. Cannot getUserMedia.');
      return null;
    }

    try {
      _sharedStream = await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      _currentAudioDeviceId = selectedAudioInputId;
      _currentVideoDeviceId = selectedVideoInputId;
      _currentMicEnabled = micEnabled;
      _currentCamEnabled = camEnabled;
      print('Created new shared stream with audio: $selectedAudioInputId, video: $selectedVideoInputId');
      return _sharedStream;
    } catch (e) {
      print('Error getting user media: $e');
      return null;
    }
  }

  /// Force refresh media stream (for handling external camera resource changes)
  Future<void> forceRefreshStream() async {
    print('Force refreshing media stream...');
    _invalidateSharedStream();
    // Re-acquire stream
    await _getSharedStream();

    // If currently publishing video to SDK, update stream
    if (_publishVideoToSDK) {
      await _updateVideoStreamToSDK();
    }
  }

  /// Check if shared stream is still active
  bool get isStreamActive {
    if (_sharedStream == null) return false;
    
    final videoTracks = _sharedStream!.getVideoTracks();
    final audioTracks = _sharedStream!.getAudioTracks();
    
    final hasActiveVideo = videoTracks.any((track) => track.readyState == 'live');
    final hasActiveAudio = audioTracks.any((track) => track.readyState == 'live');
    
    return (camEnabled ? hasActiveVideo : true) && (micEnabled ? hasActiveAudio : true);
    // Check if tracks are still live
  }

  /// Get a cloned version of the media stream (for track splitting)
  Future<html.MediaStream?> getUserMedia() async {
    // If shared stream is inactive, try to refresh
    if (!isStreamActive) {
      print('Shared stream is inactive, refreshing...');
      await forceRefreshStream();
    }

    final sharedStream = await _getSharedStream();
    if (sharedStream == null) return null;

    try {
      // Create a clone of the shared stream
      final clonedStream = sharedStream.clone();
      print('Created cloned stream for consumer');
      return clonedStream;
    } catch (e) {
      print('Error cloning shared stream: $e');
      // If cloning fails, try to refresh stream
      await forceRefreshStream();
      final freshStream = await _getSharedStream();
      if (freshStream != null) {
        try {
          return freshStream.clone();
        } catch (e2) {
          print('Error cloning fresh stream: $e2');
          // Last resort: return original stream
          return freshStream;
        }
      }
      return null;
    }
  }

  /// Get a media stream specifically for preview purposes (ignores current enable states)
  /// This is used by MediaSettingsWidget to always show preview regardless of current device states
  Future<html.MediaStream?> getPreviewStream() async {
    if (!kIsWeb) {
      throw UnimplementedError(
          'getUserMedia is not implemented for non-web platforms in this version.',);
    }

    final dynamic audioConstraint = selectedAudioInputId != null && selectedAudioInputId!.isNotEmpty
        ? {'deviceId': {'exact': selectedAudioInputId}}
        : true;

    final dynamic videoConstraint = selectedVideoInputId != null && selectedVideoInputId!.isNotEmpty
        ? {'deviceId': {'exact': selectedVideoInputId}}
        : true;

    final Map<String, dynamic> constraints = {
      'audio': audioConstraint,
      'video': videoConstraint,
    };

    try {
      final previewStream = await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      print('Created independent preview stream with audio: $selectedAudioInputId, video: $selectedVideoInputId');
      return previewStream;
    } catch (e) {
      print('Error getting preview media: $e');
      return null;
    }
  }

  /// Get the original shared media stream (not cloned, for direct control scenarios)
  Future<html.MediaStream?> getSharedMediaStream() async {
    return await _getSharedStream();
  }

  /// Stop a media stream
  void stopMediaStream(html.MediaStream? stream) {
    if (kIsWeb) {
      if (stream == null) return;

      // If it's the shared stream, do not stop, only stop cloned streams
      if (stream == _sharedStream) {
        print(
            'Warning: Attempting to stop shared stream. Use dispose() instead.',);
        return;
      }

      // Stop tracks of the cloned stream
      stream.getTracks().forEach((track) {
        track.stop();
      });
      print('Stopped cloned stream tracks');
    }
  }

  /// Completely clean up all media resources
  @override
  void dispose() {
    _invalidateSharedStream();
    _onAudioPublishChanged = null;
    _onVideoPublishChanged = null;
    _onVideoStreamChanged = null;
    _publishAudioToSDK = false;
    _publishVideoToSDK = false;
    _isProvidingStreamToSDK = false;
    super.dispose();
  }

  /// Force sync current device settings to bridge service
  Future<void> forceSyncToSDK() async {
    print('Force syncing current device settings to SDK...');

    // Force trigger audio device sync
    if (_onAudioPublishChanged != null) {
      _onAudioPublishChanged!(
          micEnabled && _publishAudioToSDK, selectedAudioInputId,);
    }

    // Force trigger video device sync
    if (_onVideoPublishChanged != null) {
      _onVideoPublishChanged!(
          camEnabled && _publishVideoToSDK, selectedVideoInputId,);
    }

    // If currently publishing video, update media stream
    if (_publishVideoToSDK) {
      await _updateVideoStreamToSDK();
    }

    print('Force sync completed');
  }
}

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

  // 單例模式，確保全域只有一個實例
  static final MediaDeviceService _instance = MediaDeviceService._internal();
  factory MediaDeviceService() => _instance;
  MediaDeviceService._internal();

  // 共享的主要媒體流
  html.MediaStream? _sharedStream;
  
  // 記錄當前流的設備 ID，用於檢測設備變更
  String? _currentAudioDeviceId;
  String? _currentVideoDeviceId;
  bool _currentMicEnabled = true;
  bool _currentCamEnabled = true;

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

  void selectAudio(String deviceId) {
    selectedAudioInputId = deviceId;
    // 如果設備變更，需要重新創建主要流
    if (_currentAudioDeviceId != deviceId) {
      _invalidateSharedStream();
    }
  }

  void selectVideo(String deviceId) {
    selectedVideoInputId = deviceId;
    // 如果設備變更，需要重新創建主要流
    if (_currentVideoDeviceId != deviceId) {
      _invalidateSharedStream();
    }
  }

  void toggleMic(bool enabled) {
    micEnabled = enabled;
    // 音訊開關變更時需要重新創建流
    if (_currentMicEnabled != enabled) {
      _invalidateSharedStream();
    }
  }

  void toggleCam(bool enabled) {
    camEnabled = enabled;
    // 視訊開關變更時需要重新創建流
    if (_currentCamEnabled != enabled) {
      _invalidateSharedStream();
    }
  }

  /// 使共享流失效，下次獲取時會重新創建
  void _invalidateSharedStream() {
    if (_sharedStream != null) {
      print('Stopping shared stream tracks');
      _sharedStream!.getTracks().forEach((track) => track.stop());
      _sharedStream = null;
      _currentAudioDeviceId = null;
      _currentVideoDeviceId = null;
    }
  }

  /// 獲取或創建共享媒體流
  Future<html.MediaStream?> _getSharedStream() async {
    if (!kIsWeb) {
      throw UnimplementedError('getUserMedia is not implemented for non-web platforms in this version.');
    }

    // 如果共享流已存在且設備沒有變更，直接返回
    if (_sharedStream != null && 
        _currentAudioDeviceId == selectedAudioInputId &&
        _currentVideoDeviceId == selectedVideoInputId &&
        _currentMicEnabled == micEnabled &&
        _currentCamEnabled == camEnabled) {
      return _sharedStream;
    }

    // 停止舊的流
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

    // 如果音訊和視訊都關閉，返回 null
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

  /// 強制重新獲取媒體流（用於處理外部攝像頭資源變更）
  Future<void> forceRefreshStream() async {
    print('Force refreshing media stream...');
    _invalidateSharedStream();
    // 重新獲取流
    await _getSharedStream();
  }

  /// 檢查共享流是否仍然有效
  bool get isStreamActive {
    if (_sharedStream == null) return false;
    
    final videoTracks = _sharedStream!.getVideoTracks();
    final audioTracks = _sharedStream!.getAudioTracks();
    
    // 檢查軌道是否仍然活躍
    final hasActiveVideo = videoTracks.any((track) => track.readyState == 'live');
    final hasActiveAudio = audioTracks.any((track) => track.readyState == 'live');
    
    return (camEnabled ? hasActiveVideo : true) && (micEnabled ? hasActiveAudio : true);
  }

  /// 獲取媒體流的克隆版本（用於分軌）
  Future<html.MediaStream?> getUserMedia() async {
    // 如果共享流無效，嘗試重新獲取
    if (!isStreamActive) {
      print('Shared stream is inactive, refreshing...');
      await forceRefreshStream();
    }
    
    final sharedStream = await _getSharedStream();
    if (sharedStream == null) return null;

    try {
      // 創建共享流的克隆
      final clonedStream = sharedStream.clone();
      print('Created cloned stream for consumer');
      return clonedStream;
    } catch (e) {
      print('Error cloning shared stream: $e');
      // 如果克隆失敗，嘗試重新獲取流
      await forceRefreshStream();
      final freshStream = await _getSharedStream();
      if (freshStream != null) {
        try {
          return freshStream.clone();
        } catch (e2) {
          print('Error cloning fresh stream: $e2');
          // 最後手段：返回原始流
          return freshStream;
        }
      }
      return null;
    }
  }

  /// 獲取原始的共享媒體流（不克隆，用於需要直接控制的場景）
  Future<html.MediaStream?> getSharedMediaStream() async {
    return await _getSharedStream();
  }

  void stopMediaStream(html.MediaStream? stream) {
    if (kIsWeb) {
      if (stream == null) return;
      
      // 如果是共享流，不要停止，只停止克隆的流
      if (stream == _sharedStream) {
        print('Warning: Attempting to stop shared stream. Use dispose() instead.');
        return;
      }
      
      // 停止克隆流的軌道
      stream.getTracks().forEach((track) {
        track.stop();
      });
      print('Stopped cloned stream tracks');
    }
  }

  /// 完全清理所有媒體資源
  void dispose() {
    _invalidateSharedStream();
    print('MediaDeviceService disposed');
  }
}

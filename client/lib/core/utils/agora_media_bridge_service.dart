import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:typed_data';
import 'media_device_service.dart';

/// Agora 媒體橋接服務
/// 負責將 MediaDeviceService 的媒體流橋接到 Agora SDK
class AgoraMediaBridgeService {
  static final AgoraMediaBridgeService _instance = AgoraMediaBridgeService._internal();
  factory AgoraMediaBridgeService() => _instance;
  AgoraMediaBridgeService._internal();

  RtcEngine? _engine;
  final MediaDeviceService _mediaService = MediaDeviceService();
  
  // 當前狀態
  bool _isInitialized = false;
  bool _videoPublishEnabled = false;
  bool _isCustomVideoSourceSet = false;
  
  // 視訊幀推送相關
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _canvasContext;
  Timer? _frameTimer;
  
  /// 暴露 MediaDeviceService 實例
  MediaDeviceService get mediaService => _mediaService;

  /// 初始化橋接服務
  Future<void> initialize(RtcEngine engine) async {
    if (_isInitialized) return;
    
    _engine = engine;
    
    // 註冊回調函數
    _mediaService.registerAudioBridge(_onAudioPublishChanged);
    _mediaService.registerVideoBridge(_onVideoPublishChanged);
    _mediaService.registerVideoStreamBridge(_onVideoStreamChanged);
    
    _isInitialized = true;
    print('AgoraMediaBridgeService initialized');
  }

  /// 處理音訊發布狀態變更
  Future<void> _onAudioPublishChanged(bool enabled, String? deviceId) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Audio publish changed: enabled=$enabled, deviceId=$deviceId');
    
    // 總是設置音訊設備（不管是否發布）
    if (deviceId != null) {
      try {
        await _engine!.getAudioDeviceManager().setRecordingDevice(deviceId);
        print('Set audio device: $deviceId');
      } catch (e) {
        print('Error setting audio device: $e');
      }
    }
    
    // 根據發布狀態控制音訊發布
    if (enabled) {
      // 啟用本地音訊
      await _engine!.enableLocalAudio(true);
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishMicrophoneTrack: true),
      );
      print('Enabled audio publishing to Agora');
    } else {
      // 停用音訊發布，但保持設備連接
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishMicrophoneTrack: false),
      );
      print('Disabled audio publishing to Agora');
    }
  }

  /// 處理視訊發布狀態變更
  Future<void> _onVideoPublishChanged(bool enabled, String? deviceId) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Video publish changed: enabled=$enabled, deviceId=$deviceId');
    
    // 設置自定義視訊源（如果還沒設置）
    if (!_isCustomVideoSourceSet) {
      await _setupCustomVideoSource();
    }
    
    // 總是設置視訊設備（不管是否發布）
    if (deviceId != null) {
      try {
        await _engine!.getVideoDeviceManager().setDevice(deviceId);
        print('Set video device: $deviceId');
      } catch (e) {
        print('Error setting video device: $e');
      }
    }
    
    // 根據發布狀態控制視訊發布
    _videoPublishEnabled = enabled;
    if (enabled) {
      // 啟用視訊發布
      await _engine!.enableLocalVideo(true);
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishCameraTrack: true),
      );
      print('Enabled video publishing to Agora');
    } else {
      // 停用視訊發布
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishCameraTrack: false),
      );
      print('Disabled video publishing to Agora');
      // 停止視訊幀推送
      _stopVideoFramePushing();
    }
  }

  /// 處理視訊流變更
  Future<void> _onVideoStreamChanged(html.MediaStream? stream) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Video stream changed: ${stream != null ? 'stream provided' : 'stream removed'}');
    
    if (stream != null && _videoPublishEnabled) {
      await _startVideoFramePushing(stream);
    } else {
      _stopVideoFramePushing();
    }
  }

  /// 設置自定義視訊源
  Future<void> _setupCustomVideoSource() async {
    if (_engine == null || _isCustomVideoSourceSet) return;
    
    try {
      // 獲取 MediaEngine 並設置外部視訊源
      final mediaEngine = _engine!.getMediaEngine();
      await mediaEngine.setExternalVideoSource(
        enabled: true,
        useTexture: false, // 使用 byte array 模式
        sourceType: ExternalVideoSourceType.videoFrame,
      );
      
      _isCustomVideoSourceSet = true;
      print('Custom video source enabled in Agora SDK');
      
      // 準備視訊幀處理元素
      if (kIsWeb) {
        _videoElement = html.VideoElement()
          ..autoplay = true
          ..muted = true
          ..style.display = 'none'; // 隱藏元素
        
        _canvas = html.CanvasElement()
          ..style.display = 'none'; // 隱藏元素
        
        _canvasContext = _canvas!.getContext('2d') as html.CanvasRenderingContext2D?;
        
        print('Video processing elements created');
      }
    } catch (e) {
      print('Error setting up custom video source: $e');
    }
  }

  /// 開始推送視訊幀
  Future<void> _startVideoFramePushing(html.MediaStream stream) async {
    if (!kIsWeb || _videoElement == null || _canvas == null || _canvasContext == null) {
      print('Cannot start video frame pushing: missing web elements');
      return;
    }
    
    try {
      // 設置視訊流到元素
      _videoElement!.srcObject = stream;
      
      // 等待視訊元素載入
      await _videoElement!.onLoadedMetadata.first;
      
      final width = _videoElement!.videoWidth;
      final height = _videoElement!.videoHeight;
      
      if (width == 0 || height == 0) {
        print('Invalid video dimensions: ${width}x$height');
        return;
      }
      
      // 設置 canvas 尺寸
      _canvas!.width = width;
      _canvas!.height = height;
      
      print('Starting video frame pushing: ${width}x$height');
      
      // 開始定期推送視訊幀 (30 FPS)
      _frameTimer?.cancel();
      _frameTimer = Timer.periodic(Duration(milliseconds: 33), (_) {
        _pushVideoFrame(width, height);
      });
      
    } catch (e) {
      print('Error starting video frame pushing: $e');
    }
  }

  /// 推送單個視訊幀
  Future<void> _pushVideoFrame(int width, int height) async {
    if (_videoElement == null || _canvas == null || _canvasContext == null || _engine == null) {
      return;
    }
    
    try {
      // 將視訊幀繪製到 canvas
      _canvasContext!.drawImageScaled(_videoElement!, 0, 0, width, height);
      
      // 獲取 RGBA 像素數據
      final imageData = _canvasContext!.getImageData(0, 0, width, height);
      final rgbaData = Uint8List.fromList(imageData.data);
      
      // 直接使用 RGBA 格式推送到 Agora（不需要轉換）
      final mediaEngine = _engine!.getMediaEngine();
      await mediaEngine.pushVideoFrame(
        frame: ExternalVideoFrame(
          type: VideoBufferType.videoBufferRawData,
          format: VideoPixelFormat.videoPixelRgba, // 直接使用 RGBA
          buffer: rgbaData,
          stride: width, // 對於 RGBA，stride 是像素寬度
          height: height,
          cropLeft: 0,
          cropTop: 0,
          cropRight: width,
          cropBottom: height,
          rotation: 0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      // 避免在控制台中產生過多錯誤訊息
      if (e.toString().contains('pushVideoFrame')) {
        // 可能是 API 調用問題，暫時忽略
      } else {
        print('Error pushing video frame: $e');
      }
    }
  }

  /// 停止推送視訊幀
  void _stopVideoFramePushing() {
    _frameTimer?.cancel();
    _frameTimer = null;
    
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
    
    print('Stopped video frame pushing');
  }

  /// 清理資源
  void dispose() {
    _stopVideoFramePushing();
    
    _videoElement?.remove();
    _videoElement = null;
    _canvas?.remove();
    _canvas = null;
    _canvasContext = null;
    
    _engine = null;
    _isInitialized = false;
    _isCustomVideoSourceSet = false;
    
    print('AgoraMediaBridgeService disposed');
  }
} 
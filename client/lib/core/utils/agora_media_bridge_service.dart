import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'dart:typed_data';
import 'media_device_service.dart';

/// Agora Media Bridge Service
/// Responsible for bridging media streams from MediaDeviceService to Agora SDK
class AgoraMediaBridgeService {
  static final AgoraMediaBridgeService _instance = AgoraMediaBridgeService._internal();
  factory AgoraMediaBridgeService() => _instance;
  AgoraMediaBridgeService._internal();

  RtcEngine? _engine;
  final MediaDeviceService _mediaService = MediaDeviceService();
  
  // Current state
  bool _isInitialized = false;
  bool _videoPublishEnabled = false;
  bool _isCustomVideoSourceSet = false;
  
  // Video frame pushing related
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _canvasContext;
  Timer? _frameTimer;
  
  // Optimized frame pushing
  int? _animationFrameId;
  Uint8List? _lastFrameData;
  int _frameSkipCounter = 0;
  static const int _frameSkipInterval = 2; // push every 2nd frame, from 30fps to 15fps
  
  /// Expose MediaDeviceService instance
  MediaDeviceService get mediaService => _mediaService;

  /// Initialize bridge service
  Future<void> initialize(RtcEngine engine) async {
    if (_isInitialized) return;
    
    _engine = engine;
    
    // Register callback functions
    _mediaService.registerAudioBridge(_onAudioPublishChanged);
    _mediaService.registerVideoBridge(_onVideoPublishChanged);
    _mediaService.registerVideoStreamBridge(_onVideoStreamChanged);
    
    _isInitialized = true;
    print('AgoraMediaBridgeService initialized');
  }

  /// Handle audio publish state changes
  Future<void> _onAudioPublishChanged(bool enabled, String? deviceId) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Audio publish changed: enabled=$enabled, deviceId=$deviceId');
    
    // Always set audio device (regardless of whether it's publishing)
    if (deviceId != null) {
      try {
        await _engine!.getAudioDeviceManager().setRecordingDevice(deviceId);
        print('Set audio device: $deviceId');
      } catch (e) {
        print('Error setting audio device: $e');
      }
    }
    
    // Control audio publishing based on publishing state
    if (enabled) {
      // Enable local audio
      await _engine!.enableLocalAudio(true);
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishMicrophoneTrack: true),
      );
      print('Enabled audio publishing to Agora');
    } else {
      // Disable audio publishing but keep device connected
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishMicrophoneTrack: false),
      );
      print('Disabled audio publishing to Agora');
    }
  }

  /// Handle video publish state changes
  Future<void> _onVideoPublishChanged(bool enabled, String? deviceId) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Video publish changed: enabled=$enabled, deviceId=$deviceId');
    
    // Set custom video source (if not already set)
    if (!_isCustomVideoSourceSet) {
      await _setupCustomVideoSource();
    }
    
    // Always set video device (regardless of whether it's publishing)
    if (deviceId != null) {
      try {
        await _engine!.getVideoDeviceManager().setDevice(deviceId);
        print('Set video device: $deviceId');
      } catch (e) {
        print('Error setting video device: $e');
      }
    }
    
    // Control video publishing based on publishing state
    _videoPublishEnabled = enabled;
    if (enabled) {
      // Enable video publishing
      await _engine!.enableLocalVideo(true);
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishCameraTrack: true),
      );
      print('Enabled video publishing to Agora');
    } else {
      // Disable video publishing
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(publishCameraTrack: false),
      );
      print('Disabled video publishing to Agora');
      // Stop video frame pushing but keep video stream for independent preview
      _stopVideoFramePushingOnly();
    }
  }

  /// Handle video stream changes
  Future<void> _onVideoStreamChanged(html.MediaStream? stream) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Video stream changed: ${stream != null ? 'stream provided' : 'stream removed'}');
    
    if (stream != null) {
      // Always set video stream for independent preview
      await _setVideoStream(stream);
      
      // Only start pushing to SDK if publishing is enabled
      if (_videoPublishEnabled) {
        await _startVideoFramePushingFromExistingStream();
      } else {
        // Stream is available but publishing is disabled - only stop pushing, keep stream for preview
        _stopVideoFramePushingOnly();
      }
    } else {
      // Stream is null - completely stop and clean up
      _stopVideoFramePushing();
    }
  }

  /// Set video stream to element (for both independent preview and SDK pushing)
  Future<void> _setVideoStream(html.MediaStream stream) async {
    if (!kIsWeb || _videoElement == null) return;
    
    try {
      // Set video stream to element
      _videoElement!.srcObject = stream;
      
      // Wait for video element to load
      await _videoElement!.onLoadedMetadata.first;
      
      print('Video stream set for preview and potential SDK pushing');
    } catch (e) {
      print('Error setting video stream: $e');
    }
  }

  /// Start pushing frames from already set video stream
  Future<void> _startVideoFramePushingFromExistingStream() async {
    if (!kIsWeb || _videoElement == null || _canvas == null || _canvasContext == null) {
      print('Cannot start video frame pushing: missing web elements');
      return;
    }
    
    try {
      final width = _videoElement!.videoWidth;
      final height = _videoElement!.videoHeight;
      
      if (width == 0 || height == 0) {
        print('Invalid video dimensions: ${width}x$height');
        return;
      }
      
      // Set canvas size
      _canvas!.width = width;
      _canvas!.height = height;
      
      print('Starting optimized video frame pushing: ${width}x$height');
      
      // Stop any existing timer/animation frame
      _stopVideoFramePushingOnly();
      
      // Start requestAnimationFrame based pushing
      _startAnimationFramePushing(width, height);
      
    } catch (e) {
      print('Error starting video frame pushing from existing stream: $e');
    }
  }

  /// Set custom video source
  Future<void> _setupCustomVideoSource() async {
    if (_engine == null || _isCustomVideoSourceSet) return;
    
    try {
      // Get MediaEngine and set external video source
      final mediaEngine = _engine!.getMediaEngine();
      await mediaEngine.setExternalVideoSource(
        enabled: true,
        useTexture: false, // Use byte array mode
        sourceType: ExternalVideoSourceType.videoFrame,
      );
      
      _isCustomVideoSourceSet = true;
      print('Custom video source enabled in Agora SDK');
      
      // Prepare video frame processing elements
      if (kIsWeb) {
        _videoElement = html.VideoElement()
          ..autoplay = true
          ..muted = true
          ..style.display = 'none'; // Hide element
        
        _canvas = html.CanvasElement()
          ..style.display = 'none'; // Hide element
        
        _canvasContext = _canvas!.getContext('2d') as html.CanvasRenderingContext2D?;
        
        print('Video processing elements created');
      }
    } catch (e) {
      print('Error setting up custom video source: $e');
    }
  }

  /// Start pushing video frames
  Future<void> _startVideoFramePushing(html.MediaStream stream) async {
    if (!kIsWeb || _videoElement == null || _canvas == null || _canvasContext == null) {
      print('Cannot start video frame pushing: missing web elements');
      return;
    }
    
    try {
      // Set video stream to element
      _videoElement!.srcObject = stream;
      
      // Wait for video element to load
      await _videoElement!.onLoadedMetadata.first;
      
      final width = _videoElement!.videoWidth;
      final height = _videoElement!.videoHeight;
      
      if (width == 0 || height == 0) {
        print('Invalid video dimensions: ${width}x$height');
        return;
      }
      
      // Set canvas size
      _canvas!.width = width;
      _canvas!.height = height;
      
      print('Starting optimized video frame pushing: ${width}x$height');
      
      // Stop any existing timer/animation frame
      _stopVideoFramePushing();
      
      // Start requestAnimationFrame based pushing
      _startAnimationFramePushing(width, height);
      
    } catch (e) {
      print('Error starting video frame pushing: $e');
    }
  }

  /// Start animation frame based pushing (更高效)
  void _startAnimationFramePushing(int width, int height) {
    void pushFrame() {
      if (_videoElement?.srcObject == null || !_videoPublishEnabled) {
        // 視訊流已停止或不再需要推送
        return;
      }
      
      // 幀率控制：跳過部分幀
      _frameSkipCounter++;
      if (_frameSkipCounter % _frameSkipInterval != 0) {
        _animationFrameId = html.window.requestAnimationFrame((_) => pushFrame());
        return;
      }
      
      _pushVideoFrameOptimized(width, height);
      
      // 繼續下一幀
      _animationFrameId = html.window.requestAnimationFrame((_) => pushFrame());
    }
    
    // 開始動畫幀循環
    _animationFrameId = html.window.requestAnimationFrame((_) => pushFrame());
  }

  /// 優化的視訊幀推送 - 加入幀差檢測
  Future<void> _pushVideoFrameOptimized(int width, int height) async {
    if (_videoElement == null || _canvas == null || _canvasContext == null || _engine == null) {
      return;
    }
    
    try {
      // Draw video frame to canvas
      _canvasContext!.drawImageScaled(_videoElement!, 0, 0, width, height);
      
      // Get RGBA pixel data
      final imageData = _canvasContext!.getImageData(0, 0, width, height);
      final rgbaData = Uint8List.fromList(imageData.data);
      
      // 幀差檢測：只推送有變化的幀
      if (_lastFrameData != null && _isFrameDataSimilar(rgbaData, _lastFrameData!)) {
        // 畫面沒有明顯變化，跳過推送
        return;
      }
      
      // 保存當前幀數據用於下次比較
      _lastFrameData = Uint8List.fromList(rgbaData);
      
      // Push to Agora
      final mediaEngine = _engine!.getMediaEngine();
      await mediaEngine.pushVideoFrame(
        frame: ExternalVideoFrame(
          type: VideoBufferType.videoBufferRawData,
          format: VideoPixelFormat.videoPixelRgba,
          buffer: rgbaData,
          stride: width,
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
      if (!e.toString().contains('pushVideoFrame')) {
        print('Error pushing optimized video frame: $e');
      }
    }
  }

  /// 檢測兩幀之間是否相似（簡化版幀差檢測）
  bool _isFrameDataSimilar(Uint8List current, Uint8List previous) {
    if (current.length != previous.length) return false;
    
    // 採樣檢測：每隔N個像素檢查一次，減少計算量
    const sampleInterval = 1000; // 每1000個像素檢查一次
    int diffCount = 0;
    const maxDiffThreshold = 20; // 允許的最大差異像素數
    const pixelDiffThreshold = 30; // 單個像素的差異閾值
    
    for (int i = 0; i < current.length && i < previous.length; i += sampleInterval) {
      if ((current[i] - previous[i]).abs() > pixelDiffThreshold) {
        diffCount++;
        if (diffCount > maxDiffThreshold) {
          return false; // 變化太大，認為是不同的幀
        }
      }
    }
    
    return true; // 變化很小，認為是相似的幀
  }

  /// Push single video frame (保留原方法作為後備)
  Future<void> _pushVideoFrame(int width, int height) async {
    if (_videoElement == null || _canvas == null || _canvasContext == null || _engine == null) {
      return;
    }
    
    try {
      // Draw video frame to canvas
      _canvasContext!.drawImageScaled(_videoElement!, 0, 0, width, height);
      
      // Get RGBA pixel data
      final imageData = _canvasContext!.getImageData(0, 0, width, height);
      final rgbaData = Uint8List.fromList(imageData.data);
      
      // Push directly to Agora using RGBA format (no conversion needed)
      final mediaEngine = _engine!.getMediaEngine();
      await mediaEngine.pushVideoFrame(
        frame: ExternalVideoFrame(
          type: VideoBufferType.videoBufferRawData,
          format: VideoPixelFormat.videoPixelRgba, // Use RGBA directly
          buffer: rgbaData,
          stride: width, // For RGBA, stride is pixel width
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
      // Avoid generating too many error messages in the console
      if (e.toString().contains('pushVideoFrame')) {
        // Possible API call issue, temporarily ignore
      } else {
        print('Error pushing video frame: $e');
      }
    }
  }

  /// Stop pushing video frames only (keep video stream for independent preview)
  void _stopVideoFramePushingOnly() {
    // 停止 Timer 和 requestAnimationFrame
    _frameTimer?.cancel();
    _frameTimer = null;
    
    if (_animationFrameId != null) {
      html.window.cancelAnimationFrame(_animationFrameId!);
      _animationFrameId = null;
    }
    
    // 不清理 video element 的 srcObject，讓獨立預覽可以繼續使用
    // _videoElement!.srcObject = null; // 註釋掉這行
    
    // 清理幀數據
    _lastFrameData = null;
    _frameSkipCounter = 0;
    
    print('Stopped video frame pushing (keeping video stream for independent preview)');
  }

  /// Stop pushing video frames and clean up video stream completely
  void _stopVideoFramePushing() {
    // 停止 Timer 和 requestAnimationFrame
    _frameTimer?.cancel();
    _frameTimer = null;
    
    if (_animationFrameId != null) {
      html.window.cancelAnimationFrame(_animationFrameId!);
      _animationFrameId = null;
    }
    
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
    
    // 清理幀數據
    _lastFrameData = null;
    _frameSkipCounter = 0;
    
    print('Stopped video frame pushing');
  }

  /// Clean up resources
  void dispose() {
    _stopVideoFramePushing();
    
    _videoElement?.remove();
    _videoElement = null;
    _canvas?.remove();
    _canvas = null;
    _canvasContext = null;
    
    // 清理優化相關的資源
    _lastFrameData = null;
    _frameSkipCounter = 0;
    _animationFrameId = null;
    
    _engine = null;
    _isInitialized = false;
    _isCustomVideoSourceSet = false;
    
    print('AgoraMediaBridgeService disposed');
  }
} 
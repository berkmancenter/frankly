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
      // Stop video frame pushing
      _stopVideoFramePushing();
    }
  }

  /// Handle video stream changes
  Future<void> _onVideoStreamChanged(html.MediaStream? stream) async {
    if (!_isInitialized || _engine == null) return;
    
    print('Video stream changed: ${stream != null ? 'stream provided' : 'stream removed'}');
    
    if (stream != null && _videoPublishEnabled) {
      await _startVideoFramePushing(stream);
    } else {
      _stopVideoFramePushing();
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
      
      print('Starting video frame pushing: ${width}x$height');
      
      // Start periodic video frame pushing (30 FPS)
      _frameTimer?.cancel();
      _frameTimer = Timer.periodic(Duration(milliseconds: 33), (_) {
        _pushVideoFrame(width, height);
      });
      
    } catch (e) {
      print('Error starting video frame pushing: $e');
    }
  }

  /// Push single video frame
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

  /// Stop pushing video frames
  void _stopVideoFramePushing() {
    _frameTimer?.cancel();
    _frameTimer = null;
    
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
    
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
    
    _engine = null;
    _isInitialized = false;
    _isCustomVideoSourceSet = false;
    
    print('AgoraMediaBridgeService disposed');
  }
} 
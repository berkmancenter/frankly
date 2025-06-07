import 'dart:async';
import 'dart:math';
import 'dart:js_util' as js_util;

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:client/features/events/features/live_meeting/features/video/data/providers/audio_levels_model.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:client/core/utils/media_device_service.dart';

import 'package:universal_html/html.dart' as html;

class AvCheckProvider with ChangeNotifier {
  static const Size requestedSize = Size(720, 480);

  final MediaDeviceService _mediaService = MediaDeviceService();
  html.MediaStream? _mediaStream;
  late html.VideoElement _div;
  late String _viewKey;
  late StreamSubscription _devicesSubscription;
  final BuildContext context;

  bool _cameraOn = true;
  bool _micOn = true;
  ParticipantAudioLevelTracker? _tracker;
  String? _errorText;

  AvCheckProvider({required this.context});

  html.MediaStream? get mediaStream => _mediaStream;

  html.VideoElement get div => _div;

  bool get cameraOn => _cameraOn;

  bool get micOn => _micOn;

  String? get defaultMic => _mediaService.selectedAudioInputId;

  String? get defaultCamera => _mediaService.selectedVideoInputId;

  String get viewKey => _viewKey;

  String? get errorText => _errorText;

  List<html.MediaDeviceInfo>? get devicesList => [
        ..._mediaService.audioInputs,
        ..._mediaService.videoInputs,
      ];

  int get currentAudioLevel {
    double level = max(_tracker?.currentAudioLevel?.volume ?? -100, -100);
    final adjustedLevel = ((level + 100) / 9).round().clamp(0, 9);
    return adjustedLevel;
  }

  void initialize() async {
    _viewKey = 'avCheck-${Random().nextDouble()}';
    _div = html.VideoElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..muted = true
      ..autoplay = true;
    registerWebViewFactory(_viewKey, (_) {
      return _div;
    });

    try {
      await _mediaService.init();
      await _updateMediaStream();
    } catch (e) {
      _errorText = e.toString();
      notifyListeners();
    }

    _devicesSubscription = Stream.periodic(const Duration(seconds: 2)).listen((_) async {
      await _mediaService.init();
      if (defaultMic == null || defaultCamera == null) {
        _setDefaults();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> _updateMediaStream() async {
    final stream = await _mediaService.getUserMedia();
    _mediaService.stopMediaStream(_mediaStream);
    _mediaStream = stream;
    _div.srcObject = _mediaStream; // _mediaStream is now html.MediaStream?

    if (_mediaService.micEnabled && defaultMic != null) {
      _tracker?.dispose();
      _tracker = ParticipantAudioLevelTracker(
        onUpdate: () => notifyListeners(),
        mediaStream: _mediaStream!, // _mediaStream is now html.MediaStream
        trackName: defaultMic!,
      )..initialize();
    }
  }

  @override
  void dispose() {
    _tracker?.dispose();
    _mediaService.stopMediaStream(_mediaStream);
    _div.srcObject = null;
    _devicesSubscription.cancel();
    super.dispose();
  }

  void joinNowPressed() {
    sharedPreferencesService.setAvCheckComplete(
      cameraOnByDefault: _cameraOn,
      micOnByDefault: _micOn,
      defaultCamera: defaultCamera ?? '',
      defaultMic: defaultMic ?? '',
    );
    updateQueryParameterToJoinEvent();
  }

  void _setDefaults() {
    final cameraDevices = _mediaService.videoInputs;
    final micDevices = _mediaService.audioInputs;
    
    _mediaService.selectedVideoInputId ??= cameraDevices
          .firstWhereOrNull(
            (d) => d.deviceId == sharedPreferencesService.getDefaultCameraId(),
          )
          ?.deviceId ??
          cameraDevices.firstOrNull?.deviceId;
    
    _mediaService.selectedAudioInputId ??= micDevices
          .firstWhereOrNull(
            (d) => d.deviceId == sharedPreferencesService.getDefaultMicrophoneId(),
          )
          ?.deviceId ??
          micDevices.firstOrNull?.deviceId;
  }

  void toggleVideo() {
    _cameraOn = !_cameraOn;
    _mediaService.toggleCam(_cameraOn);
    if (_cameraOn) {
      _updateMediaStream();
    } else {
      _div.srcObject = null;
    }
    notifyListeners();
  }

  void toggleMic() {
    _micOn = !_micOn;
    _mediaService.toggleMic(_micOn);
    _updateMediaStream();
    notifyListeners();
  }

  void selectMic(String deviceId) {
    _mediaService.selectAudio(deviceId);
    _updateMediaStream();
    notifyListeners();
  }

  void selectCamera(String deviceId) {
    _mediaService.selectVideo(deviceId);
    _updateMediaStream();
    notifyListeners();
  }
}

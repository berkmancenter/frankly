import 'dart:async';
import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/audio_levels_model.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:universal_html/html.dart' as html;

class AvCheckProvider with ChangeNotifier {
  static const Size requestedSize = Size(720, 480);

  html.MediaStream? _mediaStream;
  late html.VideoElement _div;
  late String _viewKey;
  BehaviorSubjectWrapper<List?>? _devicesStream;
  late StreamSubscription _devicesSubscription;
  final BuildContext context;

  bool _cameraOn = true;
  bool _micOn = true;
  String? _defaultMic;
  String? _defaultCamera;
  ParticipantAudioLevelTracker? _tracker;
  String? _errorText;

  AvCheckProvider({required this.context});

  html.MediaStream? get mediaStream => _mediaStream;

  html.VideoElement get div => _div;

  bool get cameraOn => _cameraOn;

  bool get micOn => _micOn;

  String? get defaultMic => _defaultMic;

  String? get defaultCamera => _defaultCamera;

  String get viewKey => _viewKey;

  String? get errorText => _errorText;

  List<html.MediaDeviceInfo>? get devicesList =>
      _devicesStream?.value?.map((e) => e as html.MediaDeviceInfo).toList();

  int get currentAudioLevel {
    double level = max(_tracker?.currentAudioLevel?.volume ?? -100, -100);
    final adjustedLevel = ((level + 100) / 9).round().clamp(0, 9);
    return adjustedLevel;
  }

  void initialize() async {
    // Add a random string in case this page is accessed a second time before the tab is reloaded
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
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': true,
        'video': {
          'width': {'ideal': requestedSize.width},
          'height': {'ideal': requestedSize.height},
          'frameRate': {'ideal': 24},
        },
      });
    } catch (e) {
      _errorText = e.toString();
      notifyListeners();
    }
    _devicesStream = wrapInBehaviorSubject(
        html.window.navigator.mediaDevices?.enumerateDevices().asStream() ?? Stream.value(null));

    _devicesSubscription = _devicesStream!.listen((devices) {
      if (_defaultMic == null || _defaultCamera == null) {
        _setDefaults();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void _getMediaStream() async {
    final newMediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
      'video': {
        'deviceId': _defaultCamera,
        'width': {'ideal': requestedSize.width},
        'height': {'ideal': requestedSize.height},
        'frameRate': {'ideal': 24},
      },
      'audio': {'deviceId': _defaultMic}
    });

    _mediaStream?.getTracks().forEach((track) => stopMediaTrack(track));
    _mediaStream = newMediaStream;
    _div.srcObject = _mediaStream;

    _tracker?.dispose();
    _tracker = ParticipantAudioLevelTracker(
      onUpdate: () => notifyListeners(),
      mediaStream: _mediaStream!,
      trackName: _defaultMic!,
    )..initialize();
  }

  @override
  void dispose() {
    _tracker?.dispose();
    _mediaStream?.getTracks().forEach((track) => stopMediaTrack(track));
    _div.srcObject = null;
    _devicesStream?.dispose();
    _devicesSubscription.cancel();
    super.dispose();
  }

  void joinNowPressed() {
    sharedPreferencesService.setAvCheckComplete(
      cameraOnByDefault: _cameraOn,
      micOnByDefault: _micOn,
      defaultCamera: _defaultCamera ?? '',
      defaultMic: _defaultMic ?? '',
    );
    updateQueryParameterToJoinDiscussion();
  }

  void _setDefaults() {
    final cameraDevices = devicesList?.where((d) => d.kind == 'videoInput');
    final micDevices = devicesList?.where((d) => d.kind == 'audioInput');
    _defaultCamera ??= cameraDevices
            ?.firstWhereOrNull((d) => d.deviceId == sharedPreferencesService.getDefaultCameraId())
            ?.deviceId ??
        cameraDevices?.firstOrNull?.deviceId;
    _defaultMic ??= micDevices
            ?.firstWhereOrNull(
                (d) => d.deviceId == sharedPreferencesService.getDefaultMicrophoneId())
            ?.deviceId ??
        micDevices?.firstOrNull?.deviceId;
  }

  void toggleVideo() {
    _cameraOn = !_cameraOn;
    if (_cameraOn) _div.srcObject = _mediaStream;
    notifyListeners();
  }

  void toggleMic() {
    _micOn = !_micOn;
    notifyListeners();
  }

  void selectMic(String info) {
    _defaultMic = info;
    _getMediaStream();
    notifyListeners();
  }

  void selectCamera(String info) {
    _defaultCamera = info;
    _getMediaStream();
    notifyListeners();
  }
}

import 'package:rxdart/rxdart.dart';

enum AVDeviceChange {
  enableVideo,
  enableAudio,
  disableVideo,
  disableAudio,
  updateVideoDevice,
  updateAudioDevice,
}

abstract class AppEvent {}

// Event emitted when the AV device state changes (e.g., microphone or camera is enabled/disabled)
class AVDeviceChangedEvent extends AppEvent { 
  final List<AVDeviceChange> changes;

  AVDeviceChangedEvent({this.changes = const []});
 }

// Event bus for emitting and listening to application-wide events
class EventBus {
  final _subject = PublishSubject<AppEvent>();
  Stream<AppEvent> get stream => _subject.stream;
  void emit(AppEvent event) => _subject.add(event);
  void dispose() => _subject.close();
}
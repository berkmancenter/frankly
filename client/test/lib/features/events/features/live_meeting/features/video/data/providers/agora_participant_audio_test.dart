import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/agora_room.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the audio calls made on the engine. Other members are unused.
class _RecordingRtcEngine implements RtcEngine {
  final calls = <String>[];

  @override
  Future<void> enableLocalAudio(bool enabled) async {
    calls.add('enableLocalAudio($enabled)');
  }

  @override
  Future<void> muteLocalAudioStream(bool mute) async {
    calls.add('muteLocalAudioStream($mute)');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _RecordingRtcEngine engine;
  late AgoraParticipant participant;

  setUp(() {
    engine = _RecordingRtcEngine();
    participant = AgoraParticipant(
      rtcEngine: engine,
      agoraUid: 0,
      isLocal: true,
      userId: 'user',
    );
  });

  test('joining muted never starts capture', () async {
    await participant.enableAudio(setEnabled: false);

    expect(engine.calls, ['muteLocalAudioStream(true)']);
    expect(participant.audioIsStreaming, isFalse);
  });

  test('first unmute starts capture then publishes', () async {
    await participant.enableAudio(setEnabled: true);

    expect(
      engine.calls,
      ['enableLocalAudio(true)', 'muteLocalAudioStream(false)'],
    );
    expect(participant.audioIsStreaming, isTrue);
  });

  test('mute and unmute only toggle publication, never capture', () async {
    await participant.enableAudio(setEnabled: true);
    engine.calls.clear();

    for (var i = 0; i < 5; i++) {
      await participant.enableAudio(setEnabled: false);
      expect(participant.audioIsStreaming, isFalse);
      await participant.enableAudio(setEnabled: true);
      expect(participant.audioIsStreaming, isTrue);
    }

    expect(engine.calls, [
      for (var i = 0; i < 5; i++) ...[
        'muteLocalAudioStream(true)',
        'muteLocalAudioStream(false)',
      ],
    ]);
    expect(
      engine.calls.where((c) => c.startsWith('enableLocalAudio')),
      isEmpty,
    );
  });
}

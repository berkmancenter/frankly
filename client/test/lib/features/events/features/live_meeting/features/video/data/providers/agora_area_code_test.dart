import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/agora_room.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('agoraAreaCode', () {
    test('ignores surrounding whitespace and case', () {
      expect(agoraAreaCode(' eu '), AreaCode.areaCodeEu.value());
    });

    test('falls back to global for unknown values', () {
      expect(agoraAreaCode('bogus'), AreaCode.areaCodeGlob.value());
    });
  });
}

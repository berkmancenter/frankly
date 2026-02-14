import 'package:test/test.dart';
import 'package:whisper_transcriber/whisper_transcriber.dart';

void main() {
  group('TranscriptionOptions', () {
    test('creates options with audio URL', () {
      final options = TranscriptionOptions(
        audioUrl: 'https://example.com/audio.mp3',
        model: 'turbo',
      );

      final json = options.toJson();
      expect(json['input']['audio'], 'https://example.com/audio.mp3');
      expect(json['input']['model'], 'turbo');
      expect(json['input']['transcription'], 'plain_text');
    });

    test('creates options with base64 audio', () {
      final options = TranscriptionOptions(
        audioBase64: 'SGVsbG8gV29ybGQ=',
        model: 'base',
        translate: true,
      );

      final json = options.toJson();
      expect(json['input']['audio_base64'], 'SGVsbG8gV29ybGQ=');
      expect(json['input']['translate'], true);
    });

    test('includes all parameters in JSON', () {
      final options = TranscriptionOptions(
        audioUrl: 'https://example.com/audio.mp3',
        model: 'large-v3',
        transcription: 'srt',
        translate: true,
        language: 'en',
        temperature: 0.5,
        beamSize: 10,
        bestOf: 3,
        enableVad: true,
        wordTimestamps: true,
      );

      final json = options.toJson();
      final input = json['input'] as Map<String, dynamic>;

      expect(input['model'], 'large-v3');
      expect(input['transcription'], 'srt');
      expect(input['translate'], true);
      expect(input['language'], 'en');
      expect(input['temperature'], 0.5);
      expect(input['beam_size'], 10);
      expect(input['best_of'], 3);
      expect(input['enable_vad'], true);
      expect(input['word_timestamps'], true);
    });
  });

  group('TranscriptionResult', () {
    test('parses result from JSON', () {
      final json = {
        'output': {
          'transcription': 'Hello world',
          'detected_language': 'en',
          'model': 'turbo',
          'device': 'cuda',
          'translation_time': 0.5,
          'segments': [
            {'id': 0, 'start': 0.0, 'end': 1.5, 'text': 'Hello world'},
          ],
        },
      };

      final result = TranscriptionResult.fromJson(json);

      expect(result.transcription, 'Hello world');
      expect(result.detectedLanguage, 'en');
      expect(result.model, 'turbo');
      expect(result.device, 'cuda');
      expect(result.translationTime, 0.5);
      expect(result.segments.length, 1);
      expect(result.segments[0].text, 'Hello world');
    });
  });

  group('JobStatus', () {
    test('parses completed job status', () {
      final json = {
        'id': 'job-123',
        'status': 'COMPLETED',
        'output': {
          'transcription': 'Test',
          'model': 'base',
          'device': 'cuda',
        },
      };

      final status = JobStatus.fromJson(json);

      expect(status.id, 'job-123');
      expect(status.status, 'COMPLETED');
      expect(status.isCompleted, true);
      expect(status.result?.transcription, 'Test');
    });

    test('parses in-progress job status', () {
      final json = {
        'id': 'job-456',
        'status': 'IN_PROGRESS',
      };

      final status = JobStatus.fromJson(json);

      expect(status.id, 'job-456');
      expect(status.status, 'IN_PROGRESS');
      expect(status.isInProgress, true);
      expect(status.result, null);
    });

    test('parses failed job status', () {
      final json = {
        'id': 'job-789',
        'status': 'FAILED',
        'error': 'Audio file not found',
      };

      final status = JobStatus.fromJson(json);

      expect(status.id, 'job-789');
      expect(status.status, 'FAILED');
      expect(status.isFailed, true);
      expect(status.error, 'Audio file not found');
    });
  });
}

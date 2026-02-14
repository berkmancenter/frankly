/// Options for audio transcription using RunPod's Whisper API.
class TranscriptionOptions {
  /// URL to the audio file (required if audioBase64 is not provided).
  final String? audioUrl;

  /// Base64-encoded audio data (required if audioUrl is not provided).
  final String? audioBase64;

  /// Whisper model to use for transcription.
  /// Options: tiny, base, small, medium, large-v1, large-v2, large-v3,
  /// distil-large-v2, distil-large-v3, turbo
  final String model;

  /// Output format: plain_text, formatted_text, srt, vtt
  final String transcription;

  /// Translate the transcription to English.
  final bool translate;

  /// Language code for the audio. Set to null for auto-detection.
  final String? language;

  /// Sampling temperature (0 for deterministic output).
  final double temperature;

  /// Beam search width.
  final int beamSize;

  /// Number of sampling candidates.
  final int bestOf;

  /// Enable voice activity detection filtering.
  final bool enableVad;

  /// Include word-level timestamps in the output.
  final bool wordTimestamps;

  const TranscriptionOptions({
    this.audioUrl,
    this.audioBase64,
    this.model = 'base',
    this.transcription = 'plain_text',
    this.translate = false,
    this.language,
    this.temperature = 0,
    this.beamSize = 5,
    this.bestOf = 5,
    this.enableVad = false,
    this.wordTimestamps = false,
  }) : assert(
          audioUrl != null || audioBase64 != null,
          'Either audioUrl or audioBase64 must be provided',
        );

  Map<String, dynamic> toJson() {
    final input = <String, dynamic>{
      'model': model,
      'transcription': transcription,
      'translate': translate,
      'temperature': temperature,
      'beam_size': beamSize,
      'best_of': bestOf,
      'enable_vad': enableVad,
      'word_timestamps': wordTimestamps,
    };

    if (audioUrl != null) {
      input['audio'] = audioUrl;
    }
    if (audioBase64 != null) {
      input['audio_base64'] = audioBase64;
    }
    if (language != null) {
      input['language'] = language;
    }

    return {'input': input};
  }

  static const availableModels = [
    'tiny',
    'base',
    'small',
    'medium',
    'large-v1',
    'large-v2',
    'large-v3',
    'distil-large-v2',
    'distil-large-v3',
    'turbo',
  ];

  static const availableFormats = [
    'plain_text',
    'formatted_text',
    'srt',
    'vtt',
  ];
}

/// Result of a transcription request.
class TranscriptionResult {
  final String? transcription;
  final String? translation;
  final String? detectedLanguage;
  final String model;
  final String device;
  final double? translationTime;
  final List<TranscriptionSegment> segments;

  const TranscriptionResult({
    this.transcription,
    this.translation,
    this.detectedLanguage,
    required this.model,
    required this.device,
    this.translationTime,
    this.segments = const [],
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    final output = json['output'] as Map<String, dynamic>? ?? json;

    return TranscriptionResult(
      transcription: output['transcription'] as String?,
      translation: output['translation'] as String?,
      detectedLanguage: output['detected_language'] as String?,
      model: output['model'] as String? ?? 'unknown',
      device: output['device'] as String? ?? 'unknown',
      translationTime: (output['translation_time'] as num?)?.toDouble(),
      segments: (output['segments'] as List<dynamic>?)
              ?.map((s) => TranscriptionSegment.fromJson(s))
              .toList() ??
          [],
    );
  }
}

/// A segment of transcribed audio with timing information.
class TranscriptionSegment {
  final int id;
  final double start;
  final double end;
  final String text;

  const TranscriptionSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] as int? ?? 0,
      start: (json['start'] as num?)?.toDouble() ?? 0,
      end: (json['end'] as num?)?.toDouble() ?? 0,
      text: json['text'] as String? ?? '',
    );
  }
}

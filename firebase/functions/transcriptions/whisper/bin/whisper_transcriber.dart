import 'dart:io';

import 'package:args/args.dart';
import 'package:whisper_transcriber/whisper_transcriber.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'api-key',
      abbr: 'k',
      help: 'RunPod API key (or set RUNPOD_API_KEY env var)',
    )
    ..addOption(
      'endpoint',
      abbr: 'e',
      help: 'RunPod endpoint ID (or set RUNPOD_ENDPOINT_ID env var)',
    )
    ..addOption(
      'audio',
      abbr: 'a',
      help: 'Path to local audio file or URL to remote audio',
    )
    ..addOption(
      'model',
      abbr: 'm',
      defaultsTo: 'base',
      help: 'Whisper model to use',
      allowed: TranscriptionOptions.availableModels,
    )
    ..addOption(
      'format',
      abbr: 'f',
      defaultsTo: 'plain_text',
      help: 'Output format',
      allowed: TranscriptionOptions.availableFormats,
    )
    ..addOption(
      'language',
      abbr: 'l',
      help: 'Language code (e.g., en, es, fr). Auto-detected if not specified',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output file path (prints to stdout if not specified)',
    )
    ..addFlag(
      'translate',
      abbr: 't',
      negatable: false,
      help: 'Translate transcription to English',
    )
    ..addFlag(
      'timestamps',
      negatable: false,
      help: 'Include word-level timestamps',
    )
    ..addFlag(
      'vad',
      negatable: false,
      help: 'Enable voice activity detection filtering',
    )
    ..addFlag(
      'async',
      negatable: false,
      help: 'Use async API (returns job ID immediately)',
    )
    ..addOption(
      'status',
      help: 'Check status of an async job by ID',
    )
    ..addOption(
      'wait',
      help: 'Wait for an async job to complete and get result',
    )
    ..addFlag(
      'health',
      negatable: false,
      help: 'Check endpoint health status',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show verbose output',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    _printUsage(parser);
    exit(1);
  }

  if (args['help'] as bool) {
    _printUsage(parser);
    exit(0);
  }

  // Get API credentials
  final apiKey = args['api-key'] as String? ??
      Platform.environment['RUNPOD_API_KEY'];
  final endpointId = args['endpoint'] as String? ??
      Platform.environment['RUNPOD_ENDPOINT_ID'];

  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Error: API key is required. Use --api-key or set RUNPOD_API_KEY');
    exit(1);
  }

  if (endpointId == null || endpointId.isEmpty) {
    stderr.writeln('Error: Endpoint ID is required. Use --endpoint or set RUNPOD_ENDPOINT_ID');
    exit(1);
  }

  final client = RunPodClient(apiKey: apiKey, endpointId: endpointId);
  final verbose = args['verbose'] as bool;

  try {
    // Health check
    if (args['health'] as bool) {
      await _healthCheck(client, verbose);
      exit(0);
    }

    // Check job status
    final statusJobId = args['status'] as String?;
    if (statusJobId != null) {
      await _checkJobStatus(client, statusJobId, verbose);
      exit(0);
    }

    // Wait for job
    final waitJobId = args['wait'] as String?;
    if (waitJobId != null) {
      await _waitForJob(client, waitJobId, args, verbose);
      exit(0);
    }

    // Transcription requires audio input
    final audioInput = args['audio'] as String?;
    if (audioInput == null || audioInput.isEmpty) {
      stderr.writeln('Error: Audio input is required. Use --audio');
      _printUsage(parser);
      exit(1);
    }

    await _transcribe(client, args, audioInput, verbose);
  } on RunPodException catch (e) {
    stderr.writeln('Error: ${e.message}');
    exit(1);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } finally {
    client.close();
  }
}

Future<void> _healthCheck(RunPodClient client, bool verbose) async {
  if (verbose) stderr.writeln('Checking endpoint health...');

  final health = await client.healthCheck();
  print('Endpoint Health:');
  print('  Jobs: ${health.jobs}');
  print('  Workers: ${health.workers}');
}

Future<void> _checkJobStatus(RunPodClient client, String jobId, bool verbose) async {
  if (verbose) stderr.writeln('Checking job status: $jobId');

  final status = await client.getJobStatus(jobId);
  print('Job ID: ${status.id}');
  print('Status: ${status.status}');

  if (status.error != null) {
    print('Error: ${status.error}');
  }

  if (status.isCompleted && status.result != null) {
    print('Detected Language: ${status.result!.detectedLanguage}');
    print('Model: ${status.result!.model}');
    print('\nTranscription:');
    print(status.result!.transcription);
  }
}

Future<void> _waitForJob(
  RunPodClient client,
  String jobId,
  ArgResults args,
  bool verbose,
) async {
  if (verbose) stderr.writeln('Waiting for job: $jobId');

  final result = await client.waitForJob(jobId);
  await _outputResult(result, args, verbose);
}

Future<void> _transcribe(
  RunPodClient client,
  ArgResults args,
  String audioInput,
  bool verbose,
) async {
  String? audioUrl;
  String? audioBase64;

  // Determine if input is URL or file path
  if (audioInput.startsWith('http://') || audioInput.startsWith('https://')) {
    audioUrl = audioInput;
    if (verbose) stderr.writeln('Using audio URL: $audioUrl');
  } else {
    // Local file - encode as base64
    if (verbose) stderr.writeln('Encoding local file: $audioInput');
    audioBase64 = await encodeAudioFile(audioInput);
    if (verbose) {
      final size = (audioBase64.length * 0.75 / 1024).toStringAsFixed(1);
      stderr.writeln('Encoded file size: ${size}KB');
    }
  }

  final options = TranscriptionOptions(
    audioUrl: audioUrl,
    audioBase64: audioBase64,
    model: args['model'] as String,
    transcription: args['format'] as String,
    translate: args['translate'] as bool,
    language: args['language'] as String?,
    enableVad: args['vad'] as bool,
    wordTimestamps: args['timestamps'] as bool,
  );

  if (args['async'] as bool) {
    // Async mode - return job ID immediately
    if (verbose) stderr.writeln('Starting async transcription...');
    final jobId = await client.transcribeAsync(options);
    print('Job ID: $jobId');
    print('Use --status $jobId to check status');
    print('Use --wait $jobId to wait for completion');
  } else {
    // Sync mode - wait for result
    if (verbose) stderr.writeln('Starting transcription (sync)...');
    final result = await client.transcribeSync(options);
    await _outputResult(result, args, verbose);
  }
}

Future<void> _outputResult(
  TranscriptionResult result,
  ArgResults args,
  bool verbose,
) async {
  final outputPath = args['output'] as String?;

  if (verbose) {
    stderr.writeln('Detected Language: ${result.detectedLanguage}');
    stderr.writeln('Model: ${result.model}');
    stderr.writeln('Device: ${result.device}');
    if (result.translationTime != null) {
      stderr.writeln('Translation Time: ${result.translationTime}s');
    }
    stderr.writeln('');
  }

  final output = StringBuffer();

  // For formats like srt/vtt, the transcription field contains the formatted output
  if (result.transcription != null) {
    output.write(result.transcription);
  }

  if (args['translate'] as bool && result.translation != null) {
    if (output.isNotEmpty) output.writeln('\n');
    output.writeln('--- Translation ---');
    output.write(result.translation);
  }

  if (args['timestamps'] as bool && result.segments.isNotEmpty) {
    if (output.isNotEmpty) output.writeln('\n');
    output.writeln('--- Segments ---');
    for (final segment in result.segments) {
      output.writeln(
        '[${_formatTime(segment.start)} -> ${_formatTime(segment.end)}] ${segment.text}',
      );
    }
  }

  final outputStr = output.toString();

  if (outputPath != null) {
    final file = File(outputPath);
    await file.writeAsString(outputStr);
    if (verbose) stderr.writeln('Output written to: $outputPath');
  } else {
    print(outputStr);
  }
}

String _formatTime(double seconds) {
  final duration = Duration(milliseconds: (seconds * 1000).round());
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
  final ms = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
  return '$hours:$minutes:$secs.$ms';
}

void _printUsage(ArgParser parser) {
  print('Whisper Transcriber - Audio transcription using RunPod API\n');
  print('Usage: whisper_transcriber [options]\n');
  print('Options:');
  print(parser.usage);
  print('\nExamples:');
  print('  # Transcribe a local audio file');
  print('  whisper_transcriber -a audio.mp3 -m turbo');
  print('');
  print('  # Transcribe from URL with translation');
  print('  whisper_transcriber -a https://example.com/audio.wav -t');
  print('');
  print('  # Get SRT subtitles');
  print('  whisper_transcriber -a audio.mp3 -f srt -o subtitles.srt');
  print('');
  print('  # Async transcription');
  print('  whisper_transcriber -a audio.mp3 --async');
  print('  whisper_transcriber --wait <job-id>');
  print('');
  print('Environment variables:');
  print('  RUNPOD_API_KEY      - Your RunPod API key');
  print('  RUNPOD_ENDPOINT_ID  - Your RunPod endpoint ID');
}

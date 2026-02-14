import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'transcription_options.dart';

/// Client for interacting with RunPod's Faster Whisper API.
class RunPodClient {
  final String apiKey;
  final String endpointId;
  final http.Client _httpClient;

  /// Base URL for RunPod serverless API.
  static const _baseUrl = 'https://api.runpod.ai/v2';

  RunPodClient({
    required this.apiKey,
    required this.endpointId,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Transcribes audio synchronously (waits for completion).
  ///
  /// Use this for shorter audio files where you want to wait for the result.
  Future<TranscriptionResult> transcribeSync(TranscriptionOptions options) async {
    final url = Uri.parse('$_baseUrl/$endpointId/runsync');
    final response = await _makeRequest(url, options);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw RunPodException(
        'Transcription failed: ${json['error'] ?? response.body}',
        statusCode: response.statusCode,
      );
    }

    final status = json['status'] as String?;
    if (status == 'FAILED') {
      throw RunPodException(
        'Transcription failed: ${json['error'] ?? 'Unknown error'}',
      );
    }

    return TranscriptionResult.fromJson(json);
  }

  /// Starts an async transcription job.
  ///
  /// Returns a job ID that can be used to check status and retrieve results.
  Future<String> transcribeAsync(TranscriptionOptions options) async {
    final url = Uri.parse('$_baseUrl/$endpointId/run');
    final response = await _makeRequest(url, options);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw RunPodException(
        'Failed to start transcription: ${json['error'] ?? response.body}',
        statusCode: response.statusCode,
      );
    }

    final jobId = json['id'] as String?;
    if (jobId == null) {
      throw RunPodException('No job ID returned from API');
    }

    return jobId;
  }

  /// Checks the status of an async transcription job.
  Future<JobStatus> getJobStatus(String jobId) async {
    final url = Uri.parse('$_baseUrl/$endpointId/status/$jobId');

    final response = await _httpClient.get(
      url,
      headers: _headers,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw RunPodException(
        'Failed to get job status: ${json['error'] ?? response.body}',
        statusCode: response.statusCode,
      );
    }

    return JobStatus.fromJson(json);
  }

  /// Waits for an async job to complete and returns the result.
  ///
  /// Polls the job status at the specified interval until completion.
  Future<TranscriptionResult> waitForJob(
    String jobId, {
    Duration pollInterval = const Duration(seconds: 2),
    Duration? timeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (true) {
      if (timeout != null && stopwatch.elapsed > timeout) {
        throw RunPodException('Job timed out after ${timeout.inSeconds} seconds');
      }

      final status = await getJobStatus(jobId);

      switch (status.status) {
        case 'COMPLETED':
          return status.result!;
        case 'FAILED':
          throw RunPodException('Job failed: ${status.error ?? 'Unknown error'}');
        case 'CANCELLED':
          throw RunPodException('Job was cancelled');
        case 'IN_QUEUE':
        case 'IN_PROGRESS':
          await Future.delayed(pollInterval);
          break;
        default:
          await Future.delayed(pollInterval);
      }
    }
  }

  /// Cancels an async transcription job.
  Future<void> cancelJob(String jobId) async {
    final url = Uri.parse('$_baseUrl/$endpointId/cancel/$jobId');

    final response = await _httpClient.post(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw RunPodException(
        'Failed to cancel job: ${json['error'] ?? response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Health check for the endpoint.
  Future<HealthStatus> healthCheck() async {
    final url = Uri.parse('$_baseUrl/$endpointId/health');

    final response = await _httpClient.get(
      url,
      headers: _headers,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw RunPodException(
        'Health check failed: ${json['error'] ?? response.body}',
        statusCode: response.statusCode,
      );
    }

    return HealthStatus.fromJson(json);
  }

  Future<http.Response> _makeRequest(Uri url, TranscriptionOptions options) async {
    return _httpClient.post(
      url,
      headers: _headers,
      body: jsonEncode(options.toJson()),
    );
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  void close() {
    _httpClient.close();
  }
}

/// Status of an async transcription job.
class JobStatus {
  final String id;
  final String status;
  final TranscriptionResult? result;
  final String? error;

  const JobStatus({
    required this.id,
    required this.status,
    this.result,
    this.error,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    TranscriptionResult? result;
    if (json['status'] == 'COMPLETED' && json['output'] != null) {
      result = TranscriptionResult.fromJson(json);
    }

    return JobStatus(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      result: result,
      error: json['error'] as String?,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isInProgress => status == 'IN_PROGRESS' || status == 'IN_QUEUE';
}

/// Health status of a RunPod endpoint.
class HealthStatus {
  final int jobs;
  final int workers;

  const HealthStatus({
    required this.jobs,
    required this.workers,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      jobs: json['jobs'] as int? ?? 0,
      workers: json['workers'] as int? ?? 0,
    );
  }
}

/// Exception thrown by RunPod API operations.
class RunPodException implements Exception {
  final String message;
  final int? statusCode;

  const RunPodException(this.message, {this.statusCode});

  @override
  String toString() => 'RunPodException: $message';
}

/// Helper to read a local audio file and encode it as base64.
Future<String> encodeAudioFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw RunPodException('Audio file not found: $filePath');
  }

  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}

class CombineResponse {
  final bool success;
  final String? outputUrl;
  final double? durationSeconds;
  final String? error;

  CombineResponse({
    required this.success,
    this.outputUrl,
    this.durationSeconds,
    this.error,
  });

  factory CombineResponse.success({
    String? outputUrl,
    double? durationSeconds,
  }) {
    return CombineResponse(
      success: true,
      outputUrl: outputUrl,
      durationSeconds: durationSeconds,
    );
  }

  factory CombineResponse.failure(String error) {
    return CombineResponse(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        if (outputUrl != null) 'outputUrl': outputUrl,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (error != null) 'error': error,
      };
}

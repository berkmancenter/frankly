enum OutputMode {
  storage,
  download;

  static OutputMode fromString(String value) {
    return OutputMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid output mode: $value'),
    );
  }
}

class CombineRequest {
  final String bucket;
  final String m3u8Path;
  final OutputMode outputMode;
  final String? outputBucket;
  final String? outputPath;

  CombineRequest({
    required this.bucket,
    required this.m3u8Path,
    required this.outputMode,
    this.outputBucket,
    this.outputPath,
  });

  factory CombineRequest.fromJson(Map<String, dynamic> json) {
    final outputMode = OutputMode.fromString(json['outputMode'] as String);

    if (outputMode == OutputMode.storage) {
      if (json['outputBucket'] == null || json['outputPath'] == null) {
        throw ArgumentError(
          'outputBucket and outputPath are required for storage mode',
        );
      }
    }

    return CombineRequest(
      bucket: json['bucket'] as String,
      m3u8Path: json['m3u8Path'] as String,
      outputMode: outputMode,
      outputBucket: json['outputBucket'] as String?,
      outputPath: json['outputPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'bucket': bucket,
        'm3u8Path': m3u8Path,
        'outputMode': outputMode.name,
        if (outputBucket != null) 'outputBucket': outputBucket,
        if (outputPath != null) 'outputPath': outputPath,
      };
}

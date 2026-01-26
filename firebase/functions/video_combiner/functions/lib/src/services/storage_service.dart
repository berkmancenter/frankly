import 'dart:io';
import 'dart:typed_data';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart';

class StorageService {
  static const _storageScope =
      'https://www.googleapis.com/auth/devstorage.full_control';

  Storage? _storage;

  Future<Storage> _getStorage() async {
    if (_storage != null) return _storage!;

    // Use Application Default Credentials
    final client = await clientViaApplicationDefaultCredentials(
      scopes: [_storageScope],
    );

    // Get project ID from environment or metadata server
    final projectId = Platform.environment['GOOGLE_CLOUD_PROJECT'] ??
        Platform.environment['GCP_PROJECT'] ??
        Platform.environment['GCLOUD_PROJECT'] ??
        'default-project';

    _storage = Storage(client, projectId);
    return _storage!;
  }

  Future<Uint8List> downloadFile(String bucketName, String objectPath) async {
    final storage = await _getStorage();
    final bucket = storage.bucket(bucketName);

    final chunks = <List<int>>[];
    await for (final chunk in bucket.read(objectPath)) {
      chunks.add(chunk);
    }

    final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final result = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return result;
  }

  Future<String> downloadToFile(
    String bucketName,
    String objectPath,
    String localPath,
  ) async {
    final data = await downloadFile(bucketName, objectPath);
    final file = File(localPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data);
    return localPath;
  }

  Future<void> uploadFile(
    String bucketName,
    String objectPath,
    Uint8List data, {
    String contentType = 'application/octet-stream',
  }) async {
    final storage = await _getStorage();
    final bucket = storage.bucket(bucketName);

    await bucket.writeBytes(objectPath, data, contentType: contentType);
  }

  Future<void> uploadFromFile(
    String bucketName,
    String objectPath,
    String localPath, {
    String contentType = 'application/octet-stream',
  }) async {
    final file = File(localPath);
    final data = await file.readAsBytes();
    await uploadFile(bucketName, objectPath, data, contentType: contentType);
  }

  Future<String> getSignedUrl(
    String bucketName,
    String objectPath, {
    Duration expiration = const Duration(hours: 1),
  }) async {
    // For Cloud Functions with default service account,
    // use the public URL format for objects with public access
    // or generate a signed URL
    return 'https://storage.googleapis.com/$bucketName/$objectPath';
  }

  Future<Stream<List<int>>> readAsStream(
    String bucketName,
    String objectPath,
  ) async {
    final storage = await _getStorage();
    final bucket = storage.bucket(bucketName);
    return bucket.read(objectPath);
  }
}

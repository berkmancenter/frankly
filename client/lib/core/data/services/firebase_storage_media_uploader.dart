import 'dart:math';
import 'dart:typed_data';

import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A media type identified from a file's content rather than its name.
class UploadMediaType {
  final String contentType;
  final String extension;
  final bool isVideo;

  const UploadMediaType._(this.contentType, this.extension, this.isVideo);

  static const jpeg = UploadMediaType._('image/jpeg', 'jpg', false);
  static const png = UploadMediaType._('image/png', 'png', false);
  static const gif = UploadMediaType._('image/gif', 'gif', false);
  static const webp = UploadMediaType._('image/webp', 'webp', false);
  static const mp4 = UploadMediaType._('video/mp4', 'mp4', true);
  static const webm = UploadMediaType._('video/webm', 'webm', true);

  /// Recognised so it can be rejected with its own message; never uploaded.
  static const quickTime = UploadMediaType._('video/quicktime', 'mov', true);

  @override
  String toString() => contentType;
}

/// Lets a signed-in user pick an image or video and uploads it to the app's
/// Firebase Storage bucket (FIREBASE_STORAGE_BUCKET). Used instead of
/// Cloudinary when MEDIA_UPLOAD_PROVIDER is `firebase`, so uploaded media stays
/// in the same Google Cloud project, and region, as the rest of the app data.
///
/// Files are stored under `media/{uid}/` and returned as download URLs, which
/// anyone with the link can read, like Cloudinary's public URLs.
///
/// The stored content type and file extension come from the file's content,
/// not from its name, so a renamed file can't be stored as a type it isn't.
///
/// QuickTime (.mov) videos are rejected. Cloudinary transcoded them to MP4;
/// Firebase Storage keeps the bytes as they are, and browsers play QuickTime
/// unevenly (HEVC .mov files from recent phones don't play in Chrome or
/// Firefox). Labelling them `video/mp4` would misstate the content, so users
/// are asked to convert to MP4 or WebM instead.
class FirebaseStorageMediaUploader {
  /// Extensions offered in the file picker. The real type is checked after.
  static const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const videoExtensions = ['mp4', 'webm', 'mov'];

  /// Keep in sync with firebase/storage/storage.rules.
  static const maxImageBytes = 10 * 1024 * 1024;
  static const maxVideoBytes = 500 * 1024 * 1024;

  static const _mp4Brands = {'mp41', 'mp42', 'avc1', 'M4V ', 'dash', 'mmp4'};

  final FirebaseStorage? _storage;
  final FirebaseAuth? _auth;

  FirebaseStorageMediaUploader({FirebaseStorage? storage, FirebaseAuth? auth})
      : _storage = storage,
        _auth = auth;

  /// Returns the download URL, or null when the user cancels the picker.
  Future<String?> pickAndUpload({
    required bool allowImages,
    required bool allowVideos,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        if (allowImages) ...imageExtensions,
        // .mov stays selectable so the user gets the conversion hint below
        // rather than a file they can't pick.
        if (allowVideos) ...videoExtensions,
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final l10n = appLocalizationService.getLocalization();
    final bytes = result.files.first.bytes;
    if (bytes == null) {
      throw VisibleException(l10n.mediaUploadFileUnreadable);
    }

    final type = checkUploadType(
      bytes,
      allowImages: allowImages,
      allowVideos: allowVideos,
    );

    final user = (_auth ?? FirebaseAuth.instance).currentUser;
    if (user == null || user.isAnonymous) {
      throw VisibleException(l10n.mediaUploadSignInRequired);
    }

    final ref = (_storage ?? FirebaseStorage.instance)
        .ref('media/${user.uid}/${uniqueFileName(type)}');
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: type.contentType,
        cacheControl: 'public, max-age=31536000',
      ),
    );
    return ref.getDownloadURL();
  }

  /// Returns the type to store [bytes] as, or throws a [VisibleException]
  /// explaining why the file can't be uploaded.
  static UploadMediaType checkUploadType(
    Uint8List bytes, {
    required bool allowImages,
    required bool allowVideos,
  }) {
    final l10n = appLocalizationService.getLocalization();
    final type = sniffMediaType(bytes);
    if (type == UploadMediaType.quickTime && allowVideos) {
      throw VisibleException(l10n.mediaUploadQuickTimeNotSupported);
    }
    if (type == null ||
        type == UploadMediaType.quickTime ||
        (type.isVideo ? !allowVideos : !allowImages)) {
      throw VisibleException(l10n.mediaUploadUnsupportedType);
    }
    if (type.isVideo && bytes.length > maxVideoBytes) {
      throw VisibleException(
        l10n.mediaUploadVideoTooLarge(maxVideoBytes ~/ (1024 * 1024)),
      );
    }
    if (!type.isVideo && bytes.length > maxImageBytes) {
      throw VisibleException(
        l10n.mediaUploadImageTooLarge(maxImageBytes ~/ (1024 * 1024)),
      );
    }
    return type;
  }

  /// `{milliseconds}-{16 hex characters}.{extension}`, the only file name
  /// shape storage.rules accepts.
  static String uniqueFileName(UploadMediaType type, {Random? random}) {
    final source = random ?? Random.secure();
    final suffix = List.generate(
      8,
      (_) => source.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '${DateTime.now().millisecondsSinceEpoch}-$suffix.${type.extension}';
  }

  /// Identifies the media type from the file's leading bytes. Returns null for
  /// anything not recognised, including SVG and HTML.
  static UploadMediaType? sniffMediaType(Uint8List bytes) {
    bool hasBytes(List<int> expected, [int offset = 0]) {
      if (bytes.length < offset + expected.length) return false;
      for (var i = 0; i < expected.length; i++) {
        if (bytes[offset + i] != expected[i]) return false;
      }
      return true;
    }

    String ascii(int offset, int length) => bytes.length < offset + length
        ? ''
        : String.fromCharCodes(bytes.sublist(offset, offset + length));

    if (hasBytes([0xFF, 0xD8, 0xFF])) return UploadMediaType.jpeg;
    if (hasBytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return UploadMediaType.png;
    }
    if (ascii(0, 6) == 'GIF87a' || ascii(0, 6) == 'GIF89a') {
      return UploadMediaType.gif;
    }
    if (ascii(0, 4) == 'RIFF' && ascii(8, 4) == 'WEBP') {
      return UploadMediaType.webp;
    }
    if (ascii(4, 4) == 'ftyp') {
      final brand = ascii(8, 4);
      if (brand == 'qt  ') return UploadMediaType.quickTime;
      if (_mp4Brands.contains(brand) || brand.startsWith('iso')) {
        return UploadMediaType.mp4;
      }
      return null;
    }
    // Matroska and WebM share the EBML header; only the DocType differs.
    if (hasBytes([0x1A, 0x45, 0xDF, 0xA3]) &&
        ascii(0, min(bytes.length, 64)).contains('webm')) {
      return UploadMediaType.webm;
    }
    return null;
  }
}

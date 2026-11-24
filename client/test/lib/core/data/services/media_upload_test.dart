import 'dart:typed_data';

import 'package:client/core/data/services/firebase_storage_media_uploader.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

Uint8List _bytes(List<int> head, [int size = 64]) =>
    Uint8List(size)..setRange(0, head.length, head);

Uint8List _ftyp(String brand) => _bytes([
      0, 0, 0, 0x18, // box size
      ...'ftyp'.codeUnits,
      ...brand.codeUnits,
    ]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppLocalizations l10n;

  setUpAll(() async {
    GetIt.instance.registerSingleton(AppLocalizationService());
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  group('MediaHelperService.urlHasExtension', () {
    test('matches Cloudinary-style URLs', () {
      expect(
        MediaHelperService.urlHasExtension(
          'https://res.cloudinary.com/x/video/upload/v1/clip.mp4',
          'mp4',
        ),
        isTrue,
      );
    });

    test('ignores the query string of Firebase Storage download URLs', () {
      const url = 'https://firebasestorage.googleapis.com/v0/b/bucket/o/'
          'media%2Fuid%2F1700000000000-abc.mp4?alt=media&token=123';
      expect(MediaHelperService.urlHasExtension(url, '.mp4'), isTrue);
      expect(MediaHelperService.urlHasExtension(url, 'webm'), isFalse);
    });

    test('is case-insensitive', () {
      expect(
        MediaHelperService.urlHasExtension('https://a.b/c/VIDEO.MP4', 'mp4'),
        isTrue,
      );
    });
  });

  group('FirebaseStorageMediaUploader.sniffMediaType', () {
    test('identifies images from their content', () {
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(_bytes([0xFF, 0xD8, 0xFF])),
        UploadMediaType.jpeg,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(
          _bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
        ),
        UploadMediaType.png,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(_bytes('GIF89a'.codeUnits)),
        UploadMediaType.gif,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(
          _bytes([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]),
        ),
        UploadMediaType.webp,
      );
    });

    test('identifies MP4, WebM and QuickTime videos', () {
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(_ftyp('isom')),
        UploadMediaType.mp4,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(_ftyp('mp42')),
        UploadMediaType.mp4,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(_ftyp('qt  ')),
        UploadMediaType.quickTime,
      );
      expect(
        FirebaseStorageMediaUploader.sniffMediaType(
          _bytes(
              [0x1A, 0x45, 0xDF, 0xA3, 0x42, 0x82, 0x84, ...'webm'.codeUnits]),
        ),
        UploadMediaType.webm,
      );
    });

    test('rejects SVG, HTML, Matroska and unknown content', () {
      for (final head in [
        '<svg xmlns="http://www.w3.org/2000/svg">'.codeUnits,
        '<!DOCTYPE html><html>'.codeUnits,
        [0x1A, 0x45, 0xDF, 0xA3, 0x42, 0x82, 0x88, ...'matroska'.codeUnits],
        <int>[],
      ]) {
        expect(
          FirebaseStorageMediaUploader.sniffMediaType(_bytes(head)),
          isNull,
        );
      }
    });
  });

  group('FirebaseStorageMediaUploader.checkUploadType', () {
    Matcher visible(String message) =>
        isA<VisibleException>().having((e) => e.msg, 'message', message);

    test('stores a renamed file under its real type', () {
      // A JPEG picked as "photo.png" is still stored as image/jpeg.
      final type = FirebaseStorageMediaUploader.checkUploadType(
        _bytes([0xFF, 0xD8, 0xFF]),
        allowImages: true,
        allowVideos: false,
      );
      expect(type.contentType, 'image/jpeg');
      expect(type.extension, 'jpg');
    });

    test('rejects QuickTime with a conversion hint instead of relabelling it',
        () {
      expect(
        () => FirebaseStorageMediaUploader.checkUploadType(
          _ftyp('qt  '),
          allowImages: true,
          allowVideos: true,
        ),
        throwsA(visible(l10n.mediaUploadQuickTimeNotSupported)),
      );
    });

    test('rejects types the caller did not ask for', () {
      expect(
        () => FirebaseStorageMediaUploader.checkUploadType(
          _ftyp('isom'),
          allowImages: true,
          allowVideos: false,
        ),
        throwsA(visible(l10n.mediaUploadUnsupportedType)),
      );
      expect(
        () => FirebaseStorageMediaUploader.checkUploadType(
          _bytes('<svg>'.codeUnits),
          allowImages: true,
          allowVideos: true,
        ),
        throwsA(visible(l10n.mediaUploadUnsupportedType)),
      );
    });

    test('enforces the image size limit', () {
      expect(
        () => FirebaseStorageMediaUploader.checkUploadType(
          _bytes(
            [0xFF, 0xD8, 0xFF],
            FirebaseStorageMediaUploader.maxImageBytes + 1,
          ),
          allowImages: true,
          allowVideos: false,
        ),
        throwsA(visible(l10n.mediaUploadImageTooLarge(10))),
      );
    });
  });

  test('file names match the shape storage.rules accepts', () {
    final name =
        FirebaseStorageMediaUploader.uniqueFileName(UploadMediaType.webm);
    expect(name, matches(RegExp(r'^[0-9]+-[0-9a-f]{16}\.webm$')));
  });
}

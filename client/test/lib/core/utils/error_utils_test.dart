import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String networkMessage;

  setUpAll(() async {
    GetIt.instance.registerSingleton(AppLocalizationService());
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
    networkMessage = l10n.networkRequestBlocked;
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  void expectNetwork(String error) =>
      expect(sanitizeError(error), networkMessage);

  group('sanitizeError network failures', () {
    test('bare INTERNAL callable error', () {
      expectNetwork('[firebase_functions/internal] INTERNAL');
    });

    test('unavailable callable error', () {
      expectNetwork('[firebase_functions/unavailable] UNAVAILABLE');
    });

    test('Failed to fetch error', () {
      expectNetwork('TypeError: Failed to fetch');
    });

    test('DNS hostname error', () {
      expectNetwork('A server with the specified hostname could not be found');
    });
  });

  group('sanitizeError passthrough', () {
    test('leaves an unrelated error message unchanged', () {
      const message = 'Something specific broke';
      expect(sanitizeError(message), message);
    });
  });
}

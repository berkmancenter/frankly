import 'package:client/config/environment.dart';
import 'package:data_models/events/event.dart';
import 'package:client/core/localization/localization_helper.dart';

/// list of available video platforms
List<PlatformItem> allowedVideoPlatforms = [
  PlatformItem(platformKey: PlatformKey.community),
  PlatformItem(platformKey: PlatformKey.googleMeet),
  PlatformItem(platformKey: PlatformKey.zoom),
  PlatformItem(platformKey: PlatformKey.maps),
  PlatformItem(platformKey: PlatformKey.microsoftTeam),
];
const urlSubstringMapping = {
  PlatformKey.googleMeet: 'meet.google.com',
  PlatformKey.zoom: 'zoom.us',
  PlatformKey.maps: 'maps',
  PlatformKey.microsoftTeam: 'teams.microsoft.com',
};

extension PlatformKeysExtension on PlatformKey {
  String get allowedUrlSubstring => urlSubstringMapping[this] ?? '';
}

extension VideoPlatformInfoExtension on PlatformKey {
  VideoPlatformInfo get info {
    final l10n = appLocalizationService.getLocalization();
    switch (this) {
      case PlatformKey.community:
        return VideoPlatformInfo(
          title: Environment.appName,
          description: 'Best for agendas, surveys, word clouds, and more',
          logoUrl: 'media/logo-icon.png',
        );
      case PlatformKey.zoom:
        return VideoPlatformInfo(
          title: l10n.zoom,
          description: 'Web conference',
          logoUrl: 'media/zoom.png',
        );
      case PlatformKey.maps:
        return VideoPlatformInfo(
          title: l10n.maps,
          description: 'In-person meeting',
          logoUrl: 'media/map.png',
        );
      case PlatformKey.microsoftTeam:
        return VideoPlatformInfo(
          title: l10n.microsoftTeams,
          description: 'Web conference',
          logoUrl: 'media/ms-team.png',
        );
      case PlatformKey.googleMeet:
        return VideoPlatformInfo(
          title: l10n.googleMeet,
          description: 'Web conference',
          logoUrl: 'media/google-meet.png',
        );
    }
  }
}

/// Information related to displaying a particular [PlatformKey] in the UI.
class VideoPlatformInfo {
  String logoUrl;
  String title;
  String description;

  VideoPlatformInfo({
    required this.description,
    required this.logoUrl,
    required this.title,
  });
}

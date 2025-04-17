import 'package:data_models/user/public_user_info.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/services.dart';

/// list of allowed social media platforms
List<SocialMediaItem> allowedSocialPlatforms = [
  SocialMediaItem(socialMediaKey: SocialMediaKey.instagram),
  SocialMediaItem(socialMediaKey: SocialMediaKey.twitter),
  SocialMediaItem(socialMediaKey: SocialMediaKey.facebook),
  SocialMediaItem(socialMediaKey: SocialMediaKey.linkedin),
];

extension SocialMediaInfoExtension on SocialMediaKey {
  SocialMediaInfo get info {
    // Get the localization service
    final l10n = appLocalizationService.getLocalization();
    switch (this) {
      case SocialMediaKey.facebook:
        return SocialMediaInfo(
          title: l10n.socialFacebook,
          logoUrl: 'media/facebook.png',
        );
      case SocialMediaKey.instagram:
        return SocialMediaInfo(
          title: l10n.socialInstagram,
          logoUrl: 'media/instagram.png',
        );
      case SocialMediaKey.twitter:
        return SocialMediaInfo(
          title: l10n.socialTwitter,
          logoUrl: 'media/twitterLogo.png',
        );
      case SocialMediaKey.linkedin:
        return SocialMediaInfo(
          title: l10n.socialLinkedIn,
          logoUrl: 'media/linkedin.png',
        );
    }
  }
}

/// Information related to displaying a particular [SocialMediaKey] in the UI.
class SocialMediaInfo {
  String logoUrl;
  String title;

  SocialMediaInfo({
    required this.logoUrl,
    required this.title,
  });
}

import 'package:data_models/user/public_user_info.dart';

/// list of allowed social media platforms
List<SocialMediaItem> allowedSocialPlatforms = [
  SocialMediaItem(socialMediaKey: SocialMediaKey.instagram),
  SocialMediaItem(socialMediaKey: SocialMediaKey.twitter),
  SocialMediaItem(socialMediaKey: SocialMediaKey.facebook),
  SocialMediaItem(socialMediaKey: SocialMediaKey.linkedin),
];

extension SocialMediaInfoExtension on SocialMediaKey {
  SocialMediaInfo get info {
    switch (this) {
      case SocialMediaKey.facebook:
        return SocialMediaInfo(
          title: 'Facebook URL',
          logoUrl: 'media/facebook.png',
        );
      case SocialMediaKey.instagram:
        return SocialMediaInfo(
          title: 'Instagram URL',
          logoUrl: 'media/instagram.png',
        );
      case SocialMediaKey.twitter:
        return SocialMediaInfo(
          title: 'Twitter URL',
          logoUrl: 'media/twitterLogo.png',
        );
      case SocialMediaKey.linkedin:
        return SocialMediaInfo(
          title: 'LinkedIn URL',
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

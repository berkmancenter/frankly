import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card_attribute.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';

part 'pre_post_card.freezed.dart';
part 'pre_post_card.g.dart';

enum PrePostCardType {
  preEvent,
  postEvent,
}

@Freezed(makeCollectionsUnmodifiable: false)
class PrePostCard with _$PrePostCard implements SerializeableRequest {
  const PrePostCard._();

  factory PrePostCard({
    required String headline,
    required String message,
    required PrePostCardType type,
    @Default([]) List<PrePostUrlParams> prePostUrls,
  }) = _PrePostCard;

  factory PrePostCard.newCard(PrePostCardType type) {
    return PrePostCard(
      headline: '',
      message: '',
      type: type,
      prePostUrls: [],
    );
  }

  factory PrePostCard.fromJson(Map<String, dynamic> json) => _$PrePostCardFromJson(json);

  /// Returns [surveyUrl] with dynamically added query parameters from [attributes].
  String getFinalisedUrl({
    String? userId,
    Discussion? discussion,
    String? email,
    PrePostUrlParams? urlInfo,
  }) {
    final surveyUrl = urlInfo?.surveyUrl;
    if (surveyUrl == null || surveyUrl.isEmpty) {
      return '';
    }

    final surveyUri = Uri.tryParse(surveyUrl);
    if (surveyUri == null) {
      return '';
    }

    final Map<String, String> queryParams = Map.of(surveyUri.queryParameters);
    for (PrePostCardAttribute attribute in urlInfo?.attributes ?? []) {
      final String? queryValue;
      queryValue =
          attribute.type.getQueryValue(userId: userId, discussion: discussion, email: email) ??
              'value';

      final queryParam =
          attribute.queryParam.isNotEmpty ? attribute.queryParam : attribute.defaultQueryParam;
      queryParams[queryParam] = queryValue;
    }

    final uri = surveyUri.replace(queryParameters: queryParams);
    String urlResult = uri.toString();
    if (urlResult.contains('typeform')) {
      urlResult = urlResult.replaceAll('?', '#');
    }
    return urlResult;
  }

  bool isNew() {
    return this == PrePostCard.newCard(type);
  }

  bool get hasData {
    final hasHeadline = headline.trim().isNotEmpty;
    final hasMessage = message.trim().isNotEmpty;
    final hasUrl = prePostUrls
        .any((url) => url.surveyUrl != null && (url.surveyUrl?.trim().isNotEmpty ?? false));

    return hasHeadline || hasMessage || hasUrl;
  }
}

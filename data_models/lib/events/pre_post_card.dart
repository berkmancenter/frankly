import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card_attribute.dart';
import 'package:data_models/events/pre_post_url_params.dart';

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

  factory PrePostCard.fromJson(Map<String, dynamic> json) =>
      _$PrePostCardFromJson(json);

  /// Returns [surveyUrl] with dynamically added query parameters from [attributes].
  String getFinalisedUrl({
    String? userId,
    Event? event,
    String? email,
    PrePostUrlParams? urlInfo,
  }) {
    var surveyUrl = urlInfo?.surveyUrl;
    if (surveyUrl == null || surveyUrl.isEmpty) {
      return '';
    }

    for (PrePostCardAttribute attribute in urlInfo?.attributes ?? []) {
      final String? queryValue;
      queryValue = attribute.type
              .getQueryValue(userId: userId, event: event, email: email) ??
          'value';

      final queryParam = attribute.queryParam.isNotEmpty
          ? attribute.queryParam
          : attribute.defaultQueryParam;

      if (surveyUrl!.contains("?")) {
        surveyUrl = '$surveyUrl&$queryParam=$queryValue';
      } else {
        surveyUrl = '$surveyUrl?$queryParam=$queryValue';
      }
    }

    return surveyUrl!;
  }

  bool isNew() {
    return this == PrePostCard.newCard(type);
  }

  bool get hasData {
    final hasHeadline = headline.trim().isNotEmpty;
    final hasMessage = message.trim().isNotEmpty;
    final hasUrl = prePostUrls.any((url) =>
        url.surveyUrl != null && (url.surveyUrl?.trim().isNotEmpty ?? false));

    return hasHeadline || hasMessage || hasUrl;
  }
}

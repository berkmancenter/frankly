import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/pre_post_card_attribute.dart';

part 'pre_post_url_params.freezed.dart';
part 'pre_post_url_params.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PrePostUrlParams with _$PrePostUrlParams implements SerializeableRequest {
  const PrePostUrlParams._();

  factory PrePostUrlParams({
    String? buttonText,
    String? surveyUrl,
    @Default([]) List<PrePostCardAttribute> attributes,
  }) = _PrePostUrlParams;

  factory PrePostUrlParams.fromJson(Map<String, dynamic> json) =>
      _$PrePostUrlParamsFromJson(json);
}

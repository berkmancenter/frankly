import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'template.freezed.dart';
part 'template.g.dart';

String defaultTemplateImage(String? id) => 'https://picsum.photos/seed/$id/300';

enum TemplateStatus {
  active,
  removed,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Template with _$Template implements SerializeableRequest {
  static const String fieldPrerequisiteTemplate = 'prerequisiteTemplateId';
  static const String kFieldAgendaItems = 'agendaItems';
  static const String kFieldTemplateImage = 'image';
  static const String kFieldTemplateStatus = 'status';
  static const String kFieldTemplateUrl = 'url';
  static const String kFieldTemplateTitle = 'title';
  static const String kFieldTemplateDescription = 'description';
  static const String kFieldPreEventCardData = 'preEventCardData';
  static const String kFieldPostEventCardData = 'postEventCardData';
  static const String kFieldEventSettings = 'eventSettings';

  const Template._();

  const factory Template({
    required String id,
    String? collectionPath,

    /// If set indicates where in the order this template should be. Lower priorities are shown first
    /// followed by any templates with null.
    ///
    /// Currently only applies to the "What we're talking about" section.
    int? orderingPriority,
    String? creatorId,
    String? prerequisiteTemplateId,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    String? title,
    String? url,
    String? image,
    String? description,
    String? category,
    EventSettings? eventSettings,
    @Default(true) bool isOfficial,
    @Default(TemplateStatus.active)
    @JsonKey(
        defaultValue: TemplateStatus.active,
        unknownEnumValue: TemplateStatus.active)
    TemplateStatus status,
    @Default([]) List<AgendaItem> agendaItems,
    PrePostCard? preEventCardData,
    PrePostCard? postEventCardData,
  }) = _Template;

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);

  String get communityId {
    final pathSegments = (collectionPath ?? "").split('/');
    return pathSegments[1];
  }
}

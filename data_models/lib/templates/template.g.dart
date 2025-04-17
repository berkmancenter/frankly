// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Template _$$_TemplateFromJson(Map<String, dynamic> json) => _$_Template(
      id: json['id'] as String,
      collectionPath: json['collectionPath'] as String?,
      orderingPriority: json['orderingPriority'] as int?,
      creatorId: json['creatorId'] as String?,
      prerequisiteTemplateId: json['prerequisiteTemplateId'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      title: json['title'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      eventSettings: json['eventSettings'] == null
          ? null
          : EventSettings.fromJson(
              json['eventSettings'] as Map<String, dynamic>),
      isOfficial: json['isOfficial'] as bool? ?? true,
      status: $enumDecodeNullable(_$TemplateStatusEnumMap, json['status'],
              unknownValue: TemplateStatus.active) ??
          TemplateStatus.active,
      agendaItems: (json['agendaItems'] as List<dynamic>?)
              ?.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      preEventCardData: json['preEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['preEventCardData'] as Map<String, dynamic>),
      postEventCardData: json['postEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['postEventCardData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_TemplateToJson(_$_Template instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionPath': instance.collectionPath,
      'orderingPriority': instance.orderingPriority,
      'creatorId': instance.creatorId,
      'prerequisiteTemplateId': instance.prerequisiteTemplateId,
      'createdDate': serverTimestamp(instance.createdDate),
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
      'description': instance.description,
      'category': instance.category,
      'eventSettings': instance.eventSettings?.toJson(),
      'isOfficial': instance.isOfficial,
      'status': _$TemplateStatusEnumMap[instance.status]!,
      'agendaItems': instance.agendaItems.map((e) => e.toJson()).toList(),
      'preEventCardData': instance.preEventCardData?.toJson(),
      'postEventCardData': instance.postEventCardData?.toJson(),
    };

const _$TemplateStatusEnumMap = {
  TemplateStatus.active: 'active',
  TemplateStatus.removed: 'removed',
};

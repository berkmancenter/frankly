// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_capability_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PlanCapabilityList _$$_PlanCapabilityListFromJson(
        Map<String, dynamic> json) =>
    _$_PlanCapabilityList(
      type: json['type'] as String?,
      userHours: json['userHours'] as int?,
      adminCount: json['adminCount'] as int?,
      facilitatorCount: json['facilitatorCount'] as int?,
      takeRate: (json['takeRate'] as num?)?.toDouble(),
      hasSmartMatching: json['hasSmartMatching'] as bool?,
      hasLivestreams: json['hasLivestreams'] as bool?,
      hasCustomUrls: json['hasCustomUrls'] as bool?,
      hasAdvancedBranding: json['hasAdvancedBranding'] as bool?,
      hasBasicAnalytics: json['hasBasicAnalytics'] as bool?,
      hasCustomAnalytics: json['hasCustomAnalytics'] as bool?,
      hasIntegrations: json['hasIntegrations'] as bool?,
      hasPrePost: json['hasPrePost'] as bool?,
    );

Map<String, dynamic> _$$_PlanCapabilityListToJson(
        _$_PlanCapabilityList instance) =>
    <String, dynamic>{
      'type': instance.type,
      'userHours': instance.userHours,
      'adminCount': instance.adminCount,
      'facilitatorCount': instance.facilitatorCount,
      'takeRate': instance.takeRate,
      'hasSmartMatching': instance.hasSmartMatching,
      'hasLivestreams': instance.hasLivestreams,
      'hasCustomUrls': instance.hasCustomUrls,
      'hasAdvancedBranding': instance.hasAdvancedBranding,
      'hasBasicAnalytics': instance.hasBasicAnalytics,
      'hasCustomAnalytics': instance.hasCustomAnalytics,
      'hasIntegrations': instance.hasIntegrations,
      'hasPrePost': instance.hasPrePost,
    };

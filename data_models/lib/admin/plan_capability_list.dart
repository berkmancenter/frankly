import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_capability_list.freezed.dart';
part 'plan_capability_list.g.dart';

/// Non-exhaustive list of known plan types
enum PlanType { individual, club, pro, unrestricted }

extension PlanTypeName on PlanType? {
  String get name {
    switch (this) {
      case PlanType.individual:
        return 'Individual';
      case PlanType.club:
        return 'Club';
      case PlanType.pro:
        return 'Pro';
      case PlanType.unrestricted:
        return 'Custom';
      default:
        return 'Free';
    }
  }
}

const subscriptionGracePeriod = Duration(days: 3);

/// Capabilities afforded by a given plan type
/// Note: Any field can be null in Firestore
@Freezed(makeCollectionsUnmodifiable: false)
class PlanCapabilityList with _$PlanCapabilityList {
  static const kFieldType = 'type';

  factory PlanCapabilityList({
    String? type,
    int? userHours,
    int? adminCount,
    int? facilitatorCount,
    double? takeRate,
    bool? hasSmartMatching,
    bool? hasLivestreams,
    bool? hasCustomUrls,
    bool? hasAdvancedBranding,
    bool? hasBasicAnalytics,
    bool? hasCustomAnalytics,
    bool? hasIntegrations,
    bool? hasPrePost,
  }) = _PlanCapabilityList;

  factory PlanCapabilityList.fromJson(Map<String, dynamic> json) =>
      _$PlanCapabilityListFromJson(json);
}

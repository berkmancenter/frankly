const defaultFunctionsRegion = 'us-central1';

String functionRegionOrDefault(String? configuredRegion) {
  final region = configuredRegion?.trim() ?? '';
  return region.isEmpty ? defaultFunctionsRegion : region;
}

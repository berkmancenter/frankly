import 'package:functions/utils/infra/function_region.dart';
import 'package:test/test.dart';

void main() {
  test('uses the configured Functions region after trimming whitespace', () {
    expect(functionRegionOrDefault(' europe-west1 '), equals('europe-west1'));
  });

  test('falls back to the upstream default for missing or blank values', () {
    expect(functionRegionOrDefault(null), equals(defaultFunctionsRegion));
    expect(functionRegionOrDefault('  '), equals(defaultFunctionsRegion));
  });
}

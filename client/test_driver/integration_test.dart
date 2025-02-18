import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  const myvar =
      String.fromEnvironment('myVar', defaultValue: 'SOME_DEFAULT_VALUE');
  print('MyVar: $myvar');

  return integrationDriver();
}

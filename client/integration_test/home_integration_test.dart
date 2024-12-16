import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:junto/dev_main.dart' as dev_main;
import 'package:junto/routing/locations.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign in to the app', (WidgetTester tester) async {
    dev_main.main();

    await tester.pump();

    await wait(tester, timeout: Duration(seconds: 5));

    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: 'danny-test').juntoHome);

    await wait(tester);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign in to the app', (WidgetTester tester) async {
    await runClient();

    await tester.pump();

    await wait(tester, timeout: Duration(seconds: 5));

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: 'danny-test').communityHome,
    );

    await wait(tester);
  });
}

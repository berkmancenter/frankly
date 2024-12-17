import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/app/community/events/event_page/widgets/event_info.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/app.dart';
import 'package:client/routing/locations.dart';
import 'firestore_scale_test_service.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run event scale test', (WidgetTester tester) async {
    useBotControls = true;

    await runClient();

    await tester.pump();

    await wait(tester, timeout: Duration(seconds: 10));
    final scaleTestInfo = await FirestoreScaleTestService().getScaleTestInfo();
    print(scaleTestInfo);

    final testerId = uuid.v4();

    final name = 'Test ${testerId.substring(0, 4)}';
    final email = '$testerId@mycommunity.test';
    const password = 'tester123';

    await signUpForApp(
      tester,
      name: name,
      email: email,
      password: password,
    );

    await wait(tester, timeout: Duration(seconds: 10));

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: scaleTestInfo.communityId)
          .eventPage(
        templateId: scaleTestInfo.templateId,
        eventId: scaleTestInfo.eventId,
      ),
    );

    await wait(tester, timeout: Duration(seconds: 10));

    await waitAndTap(tester, find.byKey(EventInfo.rsvpButtonKey));

    await waitAndTap(
      tester,
      find.byKey(EventInfo.enterEventButtonKey),
    );

    await waitAndTap(
      tester,
      find.byKey(ConfirmDialog.confirmButtonKey),
      timeout: Duration(minutes: 20),
    );

    await wait(tester, timeout: Duration(minutes: 40));
  });
}

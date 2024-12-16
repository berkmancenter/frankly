import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_info.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/dev_main.dart' as dev_main;
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/firestore/firestore_scale_test_service.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run discussion scale test', (WidgetTester tester) async {
    useBotControls = true;

    dev_main.main();

    await tester.pump();

    await wait(tester, timeout: Duration(seconds: 10));
    final scaleTestInfo = await FirestoreScaleTestService().getScaleTestInfo();
    print(scaleTestInfo);

    final testerId = uuid.v4();

    final name = 'Test ${testerId.substring(0, 4)}';
    final email = '$testerId@myjunto.test';
    const password = 'tester123';

    await signUpForApp(
      tester,
      name: name,
      email: email,
      password: password,
    );

    await wait(tester, timeout: Duration(seconds: 10));

    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: scaleTestInfo.juntoId).discussionPage(
      topicId: scaleTestInfo.topicId,
      discussionId: scaleTestInfo.discussionId,
    ));

    await wait(tester, timeout: Duration(seconds: 10));

    await waitAndTap(tester, find.byKey(DiscussionInfo.rsvpButtonKey));

    await waitAndTap(tester, find.byKey(DiscussionInfo.enterConversationButtonKey));

    await waitAndTap(tester, find.byKey(ConfirmDialog.confirmButtonKey), timeout: Duration(minutes: 20));

    await wait(tester, timeout: Duration(minutes: 40));
  });
}

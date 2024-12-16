import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_info.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/dev_main.dart' as dev_main;
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run discussion scale test', (WidgetTester tester) async {
    final goalTestCount = 500;
    final answerMaskLength = 7;
    final percentageWithMasks = 0.8;

    final matchIdGroups = 6;
    final matchIdSize = 5;

    final matchId = random.nextDouble() < matchIdGroups * matchIdSize / goalTestCount
        ? random.nextInt(matchIdGroups).toString()
        : null;
    final answerMask = random.nextDouble() < percentageWithMasks
        ? [for (int i = 0; i < answerMaskLength; i++) random.nextInt(2).toString()].join()
        : null;

    botJoinParameters = {
      if (answerMask != null) 'am': answerMask,
      if (matchId != null) 'match_id': matchId,
    };
    useBotControls = true;

    dev_main.main();

    await tester.pump();

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

    // https://juntochat-dev.web.app/home/junto/ben-dev-junto/discuss/R0J1QJcLKZQJEgkGKlvJ/6vSzqRL33Abc5G0M3oOD
    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: 'ben-dev-junto').discussionPage(
      topicId: 'R0J1QJcLKZQJEgkGKlvJ',
      discussionId: '6vSzqRL33Abc5G0M3oOD',
    ));

    await wait(tester, timeout: Duration(seconds: 10));

    await waitAndTap(tester, find.byKey(DiscussionInfo.rsvpButtonKey));

    await waitAndTap(tester, find.byKey(DiscussionInfo.enterConversationButtonKey));

    await wait(tester, timeout: Duration(minutes: 40));

    await waitAndTap(tester, find.byKey(DiscussionInfo.enterConversationButtonKey));
  });
}

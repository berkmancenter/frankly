import 'package:client/core/utils/random_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_info.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run event scale test', (WidgetTester tester) async {
    const goalTestCount = 500;
    const answerMaskLength = 7;
    const percentageWithMasks = 0.8;

    const matchIdGroups = 6;
    const matchIdSize = 5;

    final matchId =
        random.nextDouble() < matchIdGroups * matchIdSize / goalTestCount
            ? random.nextInt(matchIdGroups).toString()
            : null;
    final answerMask = random.nextDouble() < percentageWithMasks
        ? [
            for (int i = 0; i < answerMaskLength; i++)
              random.nextInt(2).toString(),
          ].join()
        : null;

    botJoinParameters = {
      if (answerMask != null) 'am': answerMask,
      if (matchId != null) 'match_id': matchId,
    };
    useBotControls = true;

    await runClient();

    await tester.pump();

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
      CommunityPageRoutes(communityDisplayId: 'ben-dev').eventPage(
        templateId: 'R0J1QJcLKZQJEgkGKlvJ',
        eventId: '6vSzqRL33Abc5G0M3oOD',
      ),
    );

    await wait(tester, timeout: Duration(seconds: 10));

    await waitAndTap(tester, find.byKey(EventInfo.rsvpButtonKey));

    await waitAndTap(
      tester,
      find.byKey(EventInfo.enterEventButtonKey),
    );

    await wait(tester, timeout: Duration(minutes: 40));

    await waitAndTap(
      tester,
      find.byKey(EventInfo.enterEventButtonKey),
    );
  });
}

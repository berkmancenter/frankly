import 'package:client/features/events/features/live_meeting/presentation/widgets/live_meeting_desktop.dart';
import 'package:client/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/control_bar.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_info.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'scale_test_service.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run event scale test', (WidgetTester tester) async {
    useBotControls = true;

    final testerId = uuid.v4();

    final name = 'Test ${testerId.substring(0, 4)}';
    final email = '$testerId@mycommunity.test';
    const password = 'tester123';
    loggingService.log('Beginning event scale test - user $testerId.');
    await runClient();

    await tester.pump();

    await wait(tester, timeout: Duration(seconds: 10));

    final scaleTestInfo = ScaleTestService().getScaleTestInfo();

    await signUpForApp(
      tester,
      name: name,
      email: email,
      password: password,
    );

    await wait(tester, timeout: Duration(seconds: 3));

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: scaleTestInfo.communityId)
          .eventPage(
        templateId: scaleTestInfo.templateId,
        eventId: scaleTestInfo.eventId,
      ),
    );

    await wait(tester, timeout: Duration(seconds: 3));

    await waitAndTap(tester, find.byKey(EventInfo.rsvpButtonKey));

    await waitAndTap(
      tester,
      find.byKey(EventInfo.enterEventButtonKey),
    );

    await wait(tester, timeout: Duration(seconds: 5));

    print('Event not started yet');
    await waitAndTap(
      tester,
      find.byKey(ConfirmDialog.confirmButtonKey),
    );

    // Turn on video.
    await waitAndTap(
      tester,
      find.byKey(ControlBar.videoToggleButtonKey),
      timeout: Duration(minutes: 5),
    );

    await wait(tester, timeout: Duration(minutes: 60));
  });
}

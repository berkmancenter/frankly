import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/meeting_dialog.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitAndTap(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    const checkDuration = Duration(seconds: 1);
    Duration timeWaited = Duration.zero;

    while (timeWaited < timeout) {
      if (tester.any(finder)) {
        loggingService.log('waitAndTap: Widget found, tapping...');
        await tester.tap(finder);
        break;
      } else {
        loggingService.log('waitAndTap: Widget not found, waiting...');
        timeWaited += checkDuration;
        await tester.pump(checkDuration);
      }
    }
  }

  Future<void> wait(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    const checkDuration = Duration(seconds: 1);
    Duration timeWaited = Duration.zero;

    while (timeWaited < timeout) {
      timeWaited += checkDuration;
      await tester.pump(checkDuration);
    }
  }

  testWidgets('sign in to the app', (WidgetTester tester) async {
    await runClient();

    await tester.pump();

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: 'danny-test')
          .instantPage(meetingId: 'drive-instant-test')
        ..update((state) => state),
    );

    await waitAndTap(
      tester,
      find.byKey(MeetingDialog.enterMeetingPromptButton),
    );

    await wait(tester, timeout: Duration(minutes: 10));

    await wait(tester);
  });
}

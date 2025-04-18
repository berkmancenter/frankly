import 'dart:async';

import 'package:client/core/utils/random_utils.dart';
import 'package:client/services.dart';

/// Class that runs some action after a delay if the action has not been completed.
///
/// This is used for hostless meetings to pick some number of users at random and have them run
/// the action. This is determined by using a random number generator and having each user draw a
/// number and see if it is in the bottom target percentage.
///
/// This means that more or less participants than the target could execute the action. Generally
/// this is just a failsafe in case something goes wrong on the server so it shouldn't usually be
/// necessary. An example of this is sending users into breakout rooms after the hostless waiting
/// room is complete.
class HostlessActionFallbackController {
  static const _maxCheckTime = Duration(minutes: 5);

  final int totalParticipants;
  final int targetActionCount;
  final Future<void> Function() action;
  final Future<bool> Function() checkIsActionCompleted;
  final Duration delay;

  HostlessActionFallbackController({
    required this.totalParticipants,
    required this.targetActionCount,
    required this.action,
    required this.delay,
    required this.checkIsActionCompleted,
  });

  late Timer _actionTimer;

  void initialize() {
    if (totalParticipants == 0) return;

    final initializedTime = clockService.now();
    _actionTimer = Timer.periodic(delay, (_) async {
      loggingService.log('Checking if action was completed in fallback.');
      final isActionCompleted = await checkIsActionCompleted();
      loggingService.log('Action completed: $isActionCompleted');

      final shouldDoAction = random.nextDouble() <
          (targetActionCount.toDouble() / totalParticipants);

      final timeSinceStart = clockService.now().difference(initializedTime);
      if (isActionCompleted || timeSinceStart > _maxCheckTime) {
        loggingService
            .log('Action was completed so canceling action fallback.');
        cancel();
      } else if (!isActionCompleted && shouldDoAction) {
        await action();
      }
    });
  }

  void cancel() {
    _actionTimer.cancel();
  }
}

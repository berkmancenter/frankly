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
  static const _pollInterval = Duration(seconds: 5);

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

  Timer? _initialTimer;
  Timer? _actionTimer;
  bool _isCancelled = false;
  DateTime? _checkStartedTime;

  void initialize() {
    if (totalParticipants == 0) return;

    _isCancelled = false;
    final initializedTime = clockService.now();
    _initialTimer = Timer(delay, () async {
      _checkStartedTime = clockService.now();
      loggingService.log(
        '[TEMP breakout-fallback] tick '
        'stage=initial '
        'now=${clockService.now()} '
        'initializedTime=$initializedTime '
        'delayMs=${delay.inMilliseconds}',
      );
      await _checkAndMaybeAct(initializedTime, stage: 'initial');

      if (_isCancelled) return;

      _actionTimer = Timer.periodic(_pollInterval, (_) async {
        if (_isCancelled) return;
        await _checkAndMaybeAct(initializedTime, stage: 'poll');
      });
    });
  }

  Future<void> _checkAndMaybeAct(
    DateTime initializedTime, {
    required String stage,
  }) async {
    loggingService.log(
      '[TEMP breakout-fallback] tick '
      'stage=$stage '
      'now=${clockService.now()} '
      'initializedTime=$initializedTime '
      'delayMs=${delay.inMilliseconds}',
    );

    final isActionCompleted = await checkIsActionCompleted();
    loggingService.log(
      '[TEMP breakout-fallback] checkIsActionCompleted '
      'result=$isActionCompleted',
    );

    final shouldDoAction = random.nextDouble() <
        (targetActionCount.toDouble() / totalParticipants);

    final checkStart = _checkStartedTime ?? initializedTime;
    final timeSinceStart = clockService.now().difference(checkStart);
    if (isActionCompleted) {
      loggingService.log(
        '[TEMP breakout-fallback] cancel '
        'reason=completed '
        'timeSinceStartMs=${timeSinceStart.inMilliseconds}',
      );
      cancel();
    } else if (timeSinceStart > _maxCheckTime) {
      loggingService.log(
        '[TEMP breakout-fallback] cancel '
        'reason=timeout '
        'timeSinceStartMs=${timeSinceStart.inMilliseconds} '
        'maxCheckTimeMs=${_maxCheckTime.inMilliseconds}',
      );
      cancel();
    } else if (shouldDoAction) {
      loggingService.log(
        '[TEMP breakout-fallback] action '
        'shouldDoAction=$shouldDoAction '
        'timeSinceStartMs=${timeSinceStart.inMilliseconds}',
      );
      await action();
    } else {
      loggingService.log(
        '[TEMP breakout-fallback] skip '
        'shouldDoAction=$shouldDoAction '
        'timeSinceStartMs=${timeSinceStart.inMilliseconds}',
      );
    }
  }

  void cancel() {
    _isCancelled = true;
    _initialTimer?.cancel();
    _actionTimer?.cancel();
  }
}

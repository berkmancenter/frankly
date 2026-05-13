import * as functions from 'firebase-functions';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { CloudFunction } from '../../cloud_function';
import { EventType } from '../../types';

export class UpdateLiveStreamParticipantCount implements CloudFunction {
  readonly functionName = 'UpdateLiveStreamParticipantCount';

  private static readonly TIMES_PER_MINUTE = 4;
  private readonly updateIntervalMs = Math.round((60_000 / UpdateLiveStreamParticipantCount.TIMES_PER_MINUTE));

  async action(_context: functions.EventContext): Promise<void> {
    try {
      const now = new Date();
      const tomorrow = new Date(now.getTime() + 86400_000);

      const activeLivestreams = await firestore
        .collectionGroup('events')
        .where('eventType', '!=', EventType.hosted)
        .where('scheduledTime', '>=', now)
        .where('scheduledTime', '<', tomorrow)
        .select()
        .get();

      if (activeLivestreams.empty) {
        console.log('No active/upcoming livestreams found.');
        return;
      }

      const timesPerMinute = UpdateLiveStreamParticipantCount.TIMES_PER_MINUTE;
      await Promise.all(
        Array.from({ length: timesPerMinute }, (_, i) =>
          new Promise<void>((resolve) =>
            setTimeout(() => this._updateLiveStreamParticipants(i).then(resolve), this.updateIntervalMs * i)
          )
        )
      );
    } catch (e) {
      console.error(`Error during action ${this.functionName}`, e);
      throw e;
    }
  }

  private async _updateLiveStreamParticipants(i: number): Promise<void> {
    console.log(`Starting livestream participant calculation ${i}`);
    const stopwatch = Date.now();
    await this._updateAllLivestreamCounts();
    console.log(`finished run ${i}: ${Date.now() - stopwatch}ms`);
  }

  private async _updateAllLivestreamCounts(): Promise<void> {
    const updateWindow = new Date(Date.now() - this.updateIntervalMs - 4000);
    console.log('Checking last update time greater than:', updateWindow);

    const eventParticipants = await firestore
      .collectionGroup('event-participants')
      .where('lastUpdatedTime', '>=', updateWindow)
      .where('isPresent', '==', true)
      .get();

    const eventPaths = new Set<string>();
    for (const doc of eventParticipants.docs) {
      const parts = doc.ref.path.split('/');
      const eventParticipantsIdx = parts.indexOf('event-participants');
      if (eventParticipantsIdx >= 0) {
        eventPaths.add(parts.slice(0, eventParticipantsIdx).join('/'));
      }
    }

    await Promise.all(
      Array.from(eventPaths).map(async (eventPath) => {
        const participants = await firestore
          .collection(`${eventPath}/event-participants`)
          .where('isPresent', '==', true)
          .get();

        await firestore.doc(eventPath).update({ liveParticipantCount: participants.size });
      })
    );
  }

  register(_functions: typeof functions): functions.CloudFunction<unknown> {
    return _functions
      .runWith({ timeoutSeconds: 60, memory: '1GB', minInstances: 0 })
      .pubsub.schedule('every 1 minutes')
      .onRun((context) => this.action(context));
  }
}

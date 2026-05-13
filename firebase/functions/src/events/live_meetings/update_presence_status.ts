import * as functions from 'firebase-functions';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { CloudFunction } from '../../cloud_function';
import { Participant, ParticipantStatus } from '../../types';

export class UpdatePresenceStatus implements CloudFunction {
  readonly functionName = 'UpdatePresenceStatus';

  async action(change: functions.Change<functions.database.DataSnapshot>, context: functions.EventContext): Promise<void> {
    try {
      const realtimeDatabasePresence = change.after.val() as Record<string, unknown>;
      const afterPresenceUpdateTime = new Date(realtimeDatabasePresence['last_changed'] as number);

      if (realtimeDatabasePresence['state'] !== 'offline') return;

      console.log('change in presence:', realtimeDatabasePresence);

      const currentPresenceSnapshot = await change.after.ref.once('value');
      const currentPresenceValue = currentPresenceSnapshot.val() as Record<string, unknown>;
      const currentPresenceTimestamp = new Date(currentPresenceValue['last_changed'] as number);

      if (currentPresenceTimestamp > afterPresenceUpdateTime) {
        console.log('presence already changed so ignoring');
        return;
      }

      console.log('updating all participants to disconnected');
      await this._updateEventStatusesToOffline({
        userId: context.params['uid']!,
        updateTime: afterPresenceUpdateTime,
      });
    } catch (e) {
      console.error(`Error during action ${this.functionName}`, e);
      throw e;
    }
  }

  private async _updateEventStatusesToOffline({
    userId,
    updateTime,
  }: {
    userId: string;
    updateTime: Date;
  }): Promise<void> {
    const documentsToUpdate = await firestore
      .collectionGroup('event-participants')
      .where('id', '==', userId)
      .where('isPresent', '==', true)
      .get();

    await Promise.all(
      documentsToUpdate.docs.map((doc) =>
        firestore.runTransaction(async (transaction) => {
          const liveParticipantSnap = await transaction.get(doc.ref);
          const participant = firestoreUtils.fromFirestoreJson(liveParticipantSnap.data() ?? {}) as unknown as Participant;
          const lastUpdatedTime = (participant as any).lastUpdatedTime as Date | undefined;

          if (lastUpdatedTime && lastUpdatedTime > updateTime) {
            console.log('status already updated so ignoring');
            return;
          }

          transaction.update(doc.ref, {
            isPresent: false,
            currentBreakoutRoomId: '',
            lastUpdatedTime: updateTime,
          });
        })
      )
    );
  }

  register(_functions: typeof functions): functions.CloudFunction<unknown> {
    return _functions
      .runWith({ timeoutSeconds: 60, memory: '1GB', minInstances: 0 })
      .database.ref('/status/{uid}')
      .onUpdate((change, context) => this.action(change, context));
  }
}

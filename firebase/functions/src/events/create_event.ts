import { OnCallMethod } from '../on_call_function'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { isEmulator } from '../utils/infra/emulator_utils'
import {
    Event,
    Membership,
    EventType,
    getEventType,
    getEventFullPath,
    EventEmailType,
} from '../types'
import { membershipIsMod } from '../types'
import { EventEmails } from './notifications/event_emails'
import { CheckHostlessGoToBreakouts } from './live_meetings/breakouts/check_hostless_go_to_breakouts'
import * as functions from 'firebase-functions'

interface CreateEventRequest {
    eventPath: string
}

export class CreateEvent extends OnCallMethod<CreateEventRequest> {
    private eventEmailUtils: EventEmails
    private checkHostlessGoToBreakouts: CheckHostlessGoToBreakouts

    constructor() {
        super('CreateEvent', (jsonMap) => jsonMap as CreateEventRequest)
        this.eventEmailUtils = new EventEmails()
        this.checkHostlessGoToBreakouts = new CheckHostlessGoToBreakouts()
    }

    async action(
        request: CreateEventRequest,
        context: functions.https.CallableContext
    ): Promise<void> {
        const event: Event = await firestoreUtils.getFirestoreObject({
            path: request.eventPath,
            constructor: (map) => map as unknown as Event,
        })

        const membershipDoc = await firestore
            .doc(`memberships/${context.auth?.uid}/community-membership/${event.communityId}`)
            .get()
        const membership: Membership = firestoreUtils.fromFirestoreJson(
            membershipDoc.data() ?? {}
        ) as unknown as Membership
        const isModOrCreator =
            event.creatorId === context.auth?.uid || membershipIsMod(membership.status)

        if (!isEmulator && !isModOrCreator) {
            throw new functions.https.HttpsError('failed-precondition', 'unauthorized')
        }

        await this._handleEmailNotifications(event)

        if (getEventType(event) === EventType.hostless) {
            await this.checkHostlessGoToBreakouts.enqueueScheduledCheck(event)
        }
    }

    private async _handleEmailNotifications(event: Event): Promise<void> {
        await this.eventEmailUtils.sendEmailsToUsers({
            eventPath: getEventFullPath(event),
            userIds: [event.creatorId!],
            emailType: EventEmailType.initialSignUp,
        })

        await this.eventEmailUtils.enqueueReminders(event)
    }
}

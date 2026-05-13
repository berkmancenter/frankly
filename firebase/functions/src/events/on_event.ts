import * as functions from 'firebase-functions'
import {
    OnFirestoreFunction,
    AppFirestoreFunctionData,
    FirestoreEventType,
} from '../on_firestore_function'
import { firestoreUtils } from '../utils/infra/firestore_utils'
import { onboardingStepsHelper } from '../utils/onboarding_steps_helper'
import { firestoreHelper, FirestoreHelper } from '../utils/infra/on_firestore_helper'
import { Event, EventStatus, EventType, getEventType, OnboardingStep } from '../types'
import { getEventFullPath, timeUntilWaitingRoomFinished, EventEmailType } from '../types'
import { EventEmails } from './notifications/event_emails'
import { CheckHostlessGoToBreakouts } from './live_meetings/breakouts/check_hostless_go_to_breakouts'

export class OnEvent extends OnFirestoreFunction<Event> {
    private eventEmails: EventEmails

    constructor() {
        super(
            [
                { functionName: 'EventOnUpdate', firestoreEventType: FirestoreEventType.onUpdate },
                { functionName: 'EventOnCreate', firestoreEventType: FirestoreEventType.onCreate },
            ],
            (snapshot) => ({
                ...(firestoreUtils.fromFirestoreJson(snapshot.data() ?? {}) as unknown as Event),
                id: snapshot.id,
            })
        )
        this.eventEmails = new EventEmails()
    }

    get documentPath(): string {
        return 'community/{communityId}/templates/{templateId}/events/{eventId}'
    }

    async onUpdate(
        change: functions.Change<FirebaseFirestore.DocumentSnapshot>,
        before: Event,
        after: Event,
        updateTime: Date,
        context: functions.EventContext
    ): Promise<void> {
        console.log('Starting onUpdate for', getEventFullPath(before))
        if (before.status === EventStatus.canceled) {
            console.log('Event was canceled before. Not sending emails.')
            return
        }

        await Promise.all([
            this._swallowErrors(
                () => this._checkHostlessUpdates(before, after, updateTime, context),
                'check hostless update'
            ),
            this._swallowErrors(
                () => this._sendEmailUpdates(before, after, updateTime, context),
                'send email updates'
            ),
        ])
    }

    private async _swallowErrors(fn: () => Promise<void>, description: string): Promise<void> {
        try {
            await fn()
        } catch (e) {
            console.error('Error during', description, e)
        }
    }

    private async _sendEmailUpdates(
        before: Event,
        after: Event,
        _updateTime: Date,
        _context: functions.EventContext
    ): Promise<void> {
        let emailType: EventEmailType | null = null
        if (before.status !== EventStatus.canceled && after.status === EventStatus.canceled) {
            emailType = EventEmailType.canceled
        } else if (before.scheduledTime?.getTime() !== after.scheduledTime?.getTime()) {
            emailType = EventEmailType.updated
        }

        if (emailType === null) return

        const community = await firestoreUtils.getFirestoreObject({
            path: `/community/${after.communityId}`,
            constructor: (map) => map as unknown as any,
        })

        if (
            !(
                after.eventSettings?.reminderEmails ??
                community.eventSettingsMigration?.reminderEmails ??
                true
            )
        )
            return

        if (emailType === EventEmailType.updated) {
            await this.eventEmails.enqueueReminders(after)
        }
    }

    private async _checkHostlessUpdates(
        before: Event,
        after: Event,
        _updateTime: Date,
        _context: functions.EventContext
    ): Promise<void> {
        const eventTypeChanged = getEventType(before) !== getEventType(after)
        const now = new Date()
        const waitingRoomFinishedTimeChanged =
            timeUntilWaitingRoomFinished(before, now) !== timeUntilWaitingRoomFinished(after, now)

        if (
            getEventType(after) === EventType.hostless &&
            (eventTypeChanged || waitingRoomFinishedTimeChanged)
        ) {
            await new CheckHostlessGoToBreakouts().enqueueScheduledCheck(after)
        }
    }

    async onCreate(
        snapshot: FirebaseFirestore.DocumentSnapshot,
        parsedData: Event,
        _updateTime: Date,
        context: { params: Record<string, string> }
    ): Promise<void> {
        console.log('Event', snapshot.id, 'has been created')
        const communityId = context.params[FirestoreHelper.kCommunityId]
        if (!communityId) throw new Error('communityId is null')

        await onboardingStepsHelper.updateOnboardingSteps(
            communityId,
            snapshot,
            firestoreHelper,
            OnboardingStep.hostEvent
        )
    }
}

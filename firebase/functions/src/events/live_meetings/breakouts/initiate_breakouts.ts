import * as functions from 'firebase-functions'
import { AssignToBreakouts } from './assign_to_breakouts'
import { OnCallMethod } from '../../../on_call_function'
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils'
import { Event, Membership, BreakoutAssignmentMethod, membershipIsMod } from '../../../types'

interface InitiateBreakoutsRequest {
    eventPath: string
    breakoutSessionId: string
    assignmentMethod?: BreakoutAssignmentMethod
    targetParticipantsPerRoom: number
    includeWaitingRoom?: boolean
}

export class InitiateBreakouts extends OnCallMethod<InitiateBreakoutsRequest> {
    constructor() {
        super('InitiateBreakouts', (json) => json as InitiateBreakoutsRequest, {
            runWithOptions: { timeoutSeconds: 120, memory: '4GB', minInstances: 0 },
        })
    }

    async action(
        request: InitiateBreakoutsRequest,
        context: functions.https.CallableContext
    ): Promise<void> {
        const event: Event = await firestoreUtils.getFirestoreObject({
            path: request.eventPath,
            constructor: (map) => map as unknown as Event,
        })

        await this._verifyCallerIsAuthorized(event, context)

        await this.initiateBreakouts({ request, event, creatorId: context.auth!.uid })
    }

    private async _verifyCallerIsAuthorized(
        event: Event,
        context: functions.https.CallableContext
    ): Promise<void> {
        const membershipSnap = await firestore
            .doc(
                `memberships/${context.auth?.uid}/community-membership/${
                    (event as any).communityId
                }`
            )
            .get()
        const membership = firestoreUtils.fromFirestoreJson(
            membershipSnap.data() ?? {}
        ) as unknown as Membership

        const isAuthorized =
            (event as any).creatorId === context.auth?.uid ||
            membershipIsMod((membership as any).status)
        if (!isAuthorized) {
            throw new functions.https.HttpsError('failed-precondition', 'unauthorized')
        }
    }

    async initiateBreakouts({
        request,
        event,
        creatorId,
    }: {
        request: InitiateBreakoutsRequest
        event: Event
        creatorId: string
    }): Promise<void> {
        if ((event as any).isHosted || (event as any).eventType === 'hosted') {
            console.log('Assigning users to breakouts.')
            await new AssignToBreakouts().assignToBreakouts({
                targetParticipantsPerRoom: request.targetParticipantsPerRoom,
                breakoutSessionId: request.breakoutSessionId,
                assignmentMethod:
                    request.assignmentMethod ?? BreakoutAssignmentMethod.targetPerRoom,
                includeWaitingRoom: request.includeWaitingRoom ?? false,
                event,
                creatorId,
            })
        } else {
            console.log('Pinging breakout availability.')
            await this._pingBreakoutsAvailability({ event, request })
        }
    }

    private async _pingBreakoutsAvailability({
        event,
        request,
    }: {
        event: Event
        request: InitiateBreakoutsRequest
    }): Promise<void> {
        const breakoutRoomSessionId = request.breakoutSessionId
        const liveMeetingPath = `${(event as any).fullPath}/live-meetings/${(event as any).id}`

        const smartMatchingWaitMs = 30_000
        const nowMillis = Date.now()
        const scheduledMs = Math.floor((nowMillis + smartMatchingWaitMs) / 1000) * 1000
        const scheduledTime = new Date(scheduledMs)

        const newlyInitiated = await firestore.runTransaction(async (transaction) => {
            const liveMeetingRef = firestore.doc(liveMeetingPath)
            const liveMeetingDoc = await transaction.get(liveMeetingRef)
            const liveMeeting = firestoreUtils.fromFirestoreJson(liveMeetingDoc.data() ?? {})

            if (
                (liveMeeting as any).currentBreakoutSession?.breakoutRoomSessionId ===
                breakoutRoomSessionId
            ) {
                console.log('Breakout session already initiated. Returning')
                return false
            }

            const breakoutSession = {
                breakoutRoomSessionId,
                breakoutRoomStatus: 'pending',
                assignmentMethod: request.assignmentMethod,
                targetParticipantsPerRoom: request.targetParticipantsPerRoom,
                hasWaitingRoom: request.includeWaitingRoom,
                scheduledTime,
            }

            transaction.set(
                liveMeetingRef,
                {
                    currentBreakoutSession: firestoreUtils.toFirestoreJson(
                        breakoutSession as Record<string, unknown>
                    ),
                },
                { merge: true }
            )
            return true
        })

        if (newlyInitiated) {
            console.log('scheduling assign to breakouts server check')
            const { CheckAssignToBreakoutsServer } = await import(
                './check_assign_to_breakouts_server'
            )
            await new CheckAssignToBreakoutsServer().schedule(
                { eventPath: (event as any).fullPath, breakoutSessionId: breakoutRoomSessionId },
                scheduledTime
            )
        }
    }
}

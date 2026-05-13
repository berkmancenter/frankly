import * as functions from 'firebase-functions'
import { firestore, firestoreUtils } from './infra/firestore_utils'
import { Community, Event, EventStatus } from '../types'

const ics = require('ics') as {
    createEvents: (events: IcsEventInput[]) => { error: unknown; value?: string }
}

interface IcsEventInput {
    start: number[]
    startInputType: string
    duration: { minutes: number }
    title: string
    url: string
    uid: string
    productId: string
}

const icsProdId = () => (functions.config().ics?.prod_id as string) ?? '-//frankly//EN'

const emptyIcs = () => `BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:${icsProdId()}
METHOD:PUBLISH
X-PUBLISHED-TTL:PT1H
END:VCALENDAR
`

export const icsUtil = {
    async getIcsForUpcomingEvents({ community }: { community: Community }): Promise<string> {
        const now = new Date()
        const domain = functions.config().app?.domain as string

        const eventDocs = await firestore
            .collectionGroup('events')
            .where('communityId', '==', community.id)
            .where('isPublic', '==', true)
            .where('status', '==', EventStatus.active)
            .where('scheduledTime', '>=', now)
            .orderBy('scheduledTime')
            .get()

        const events = eventDocs.docs.map((doc) => ({
            ...(firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Event),
            id: doc.id,
        }))

        const scheduledEvents = events
            .filter((e) => e.scheduledTime != null)
            .map((event) => {
                const t = event.scheduledTime!
                const d = t instanceof Date ? t : new Date(t)
                return {
                    title: event.title ?? 'Event',
                    url: `https://${domain}/space/${
                        community.displayIds?.[0] ?? community.id
                    }/discuss/${event.templateId}/${event.id}`,
                    uid: event.id,
                    startInputType: 'utc',
                    start: [
                        d.getUTCFullYear(),
                        d.getUTCMonth() + 1,
                        d.getUTCDate(),
                        d.getUTCHours(),
                        d.getUTCMinutes(),
                    ],
                    duration: { minutes: 60 },
                    productId: icsProdId(),
                } as IcsEventInput
            })

        if (scheduledEvents.length === 0) {
            return emptyIcs()
        }

        const result = ics.createEvents(scheduledEvents)
        if (result.error) {
            console.error('ICS error:', result.error)
            throw new Error('Could not generate feed')
        }
        if (!result.value) {
            throw new Error('Could not generate feed')
        }
        return result.value
    },
}

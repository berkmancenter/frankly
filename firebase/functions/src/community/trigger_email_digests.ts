import * as functions from 'firebase-functions'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { firebaseAuthUtils } from '../utils/infra/firebase_auth_utils'
import { sendEmailClient } from '../utils/send_email_client'
import { isNullOrEmpty } from '../utils/utils'
import { getUnsubscribeUrl } from '../utils/encrypt_util'
import {
    Community,
    Membership,
    MembershipStatus,
    CommunityUserSettings,
    NotificationEmailType,
    Event,
    EventStatus,
    SendGridEmail,
    SendGridEmailMessage,
} from '../types'
import { membershipIsMember } from '../types'
import { TemplateUtils } from '../utils/template_utils'

interface CommunityWithEvents {
    community: Community
    events: Array<{ event: Event; template: import('../types').Template }>
}

const noReplyEmailAddr = () => functions.config().app?.no_reply_email as string

export class TriggerEmailDigests {
    readonly functionName = 'TriggerEmailDigests'

    async action(_context: functions.EventContext): Promise<void> {
        const now = new Date()
        const endTime = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)

        console.log('Getting email digests')
        const eventsListFiltered = await this._getUpcomingEvents(now, endTime)

        console.log(
            'Generating emails for communities:',
            eventsListFiltered.map((d) => `${d.community.id}: ${d.events.length} events`)
        )

        const emails = await this._generateAllUserEmails(eventsListFiltered, now)
        console.log(`Sending ${emails.length} emails.`)

        await sendEmailClient.sendEmails(emails)
    }

    private async _getUpcomingEvents(now: Date, endTime: Date): Promise<CommunityWithEvents[]> {
        const communityDocs = await firestore.collection('/community').get()
        const communities = communityDocs.docs
            .map((doc) => ({ ...(doc.data() as Community), id: doc.id }))
            .filter((c) => !(c.communitySettings?.disableEmailDigests ?? false))

        const results = await Promise.all(
            communities.map(async (community) => {
                const eventDocs = await firestore
                    .collectionGroup('events')
                    .where('communityId', '==', community.id)
                    .where('scheduledTime', '>', now)
                    .where('scheduledTime', '<=', endTime)
                    .where('status', '==', EventStatus.active)
                    .where('isPublic', '==', true)
                    .orderBy('scheduledTime')
                    .limit(10)
                    .get()

                const events = await Promise.all(
                    eventDocs.docs.map(async (doc) => {
                        const event = {
                            ...(firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Event),
                            id: doc.id,
                        }
                        const templatePath = `community/${community.id}/templates/${event.templateId}`
                        const templateDoc = await firestore.doc(templatePath).get()
                        const template = TemplateUtils.templateFromSnapshot(templateDoc)
                        return { event, template }
                    })
                )

                return { community, events } as CommunityWithEvents
            })
        )

        return results.filter((r) => r.events.length > 0)
    }

    private async _generateAllUserEmails(
        eventsListFiltered: CommunityWithEvents[],
        now: Date
    ): Promise<SendGridEmail[]> {
        const emails: SendGridEmail[] = []

        await Promise.all(
            eventsListFiltered.map(async ({ community, events }) => {
                const membershipDocs = await firestore
                    .collectionGroup('community-membership')
                    .where('communityId', '==', community.id)
                    .where('status', '!=', MembershipStatus.nonmember)
                    .get()

                const members = membershipDocs.docs
                    .map((doc) => doc.data() as Membership)
                    .filter((m) => (m.status ? membershipIsMember(m.status) : false))

                await Promise.all(
                    members.map(async (membership) => {
                        try {
                            const users = await firebaseAuthUtils.getUsers([membership.userId])
                            if (!users.length || isNullOrEmpty(users[0].email)) return
                            const user = users[0]

                            const settingsDoc = await firestore
                                .doc(
                                    `privateUserData/${membership.userId}/communityUserSettings/${community.id}`
                                )
                                .get()
                            const settings = settingsDoc.data() as CommunityUserSettings | undefined

                            if (settings?.notifyEvents === NotificationEmailType.none) return

                            emails.push({
                                to: [user.email!],
                                from: `${community.name} <${noReplyEmailAddr()}>`,
                                message: {
                                    subject: `Upcoming events in ${community.name}`,
                                    html: `<p>You have ${events.length} upcoming events in ${
                                        community.name
                                    }!</p>
                         <p><a href="${getUnsubscribeUrl({
                             userId: user.uid,
                         })}">Unsubscribe</a></p>`,
                                },
                            })
                        } catch (e) {
                            console.error(
                                `Error processing email for user ${membership.userId}:`,
                                e
                            )
                        }
                    })
                )
            })
        )

        return emails
    }

    register(): functions.CloudFunction<unknown> {
        return functions
            .runWith({ timeoutSeconds: 540, memory: '1GB' })
            .pubsub.schedule('every 24 hours')
            .onRun((context) => this.action(context))
    }
}

import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { firestore, firestoreUtils } from './infra/firestore_utils'
import { firebaseAuthUtils } from './infra/firebase_auth_utils'
import { sendEmailClient } from './send_email_client'
import { isNullOrEmpty } from './utils'
import { getUnsubscribeUrl, decryptUnsubscribeData, UnsubscribeData } from './encrypt_util'
import {
    Community,
    Membership,
    MembershipStatus,
    CommunityUserSettings,
    NotificationEmailType,
    Event,
    Template,
    Participant,
    ParticipantStatus,
    SendGridEmail,
    SendGridEmailMessage,
    EventEmailType,
} from '../types'
import { membershipIsMember } from '../types'

const noReplyEmailAddr = () => functions.config().app?.no_reply_email as string

export { decryptUnsubscribeData, UnsubscribeData }

export class NotificationsUtils {
    async sendCommunityNotifications({
        communityId,
        creatorUserId,
        filterUsersBy,
        generateMessage,
    }: {
        communityId: string
        creatorUserId?: string
        filterUsersBy: (settings: CommunityUserSettings) => boolean
        generateMessage: (opts: {
            community: Community
            user: admin.auth.UserRecord
            unsubscribeUrl: string
        }) => SendGridEmailMessage
    }): Promise<void> {
        const communityRef = await firestore.doc(`/community/${communityId}`).get()
        const communityData = communityRef.data() as Community
        communityData.id = communityRef.id

        const membershipsData = await firestore
            .collectionGroup('community-membership')
            .where('communityId', '==', communityId)
            .where('status', '!=', MembershipStatus.nonmember)
            .get()

        const userIds = membershipsData.docs
            .map((doc) => doc.data() as Membership)
            .filter((m) => membershipIsMember(m.status ?? MembershipStatus.nonmember))
            .map((m) => m.userId)
            .filter((id) => id !== creatorUserId)

        console.log('Got user IDs')

        const userSettingsFutures = userIds.map(async (userId) => {
            const snapshot = await firestore
                .doc(`/privateUserData/${userId}/communityUserSettings/${communityId}`)
                .get()
            const record = snapshot.data() as CommunityUserSettings | undefined
            if (record?.userId) return record
            return {
                userId,
                communityId,
                notifyAnnouncements: null,
                notifyEvents: null,
            } as CommunityUserSettings
        })

        const userSettings = await Promise.all(userSettingsFutures)

        const filteredUserIds = userSettings
            .filter(filterUsersBy)
            .map((s) => s.userId ?? '')
            .filter((id) => id !== '')

        console.log('user IDs filtered')

        const users = await firebaseAuthUtils.getUsers(filteredUserIds)

        console.log('Got users')

        const usersWithoutEmail = users.filter((u) => isNullOrEmpty(u.email))
        if (usersWithoutEmail.length > 0) {
            console.log('Some users dont have email:', usersWithoutEmail)
        }

        const emails: SendGridEmail[] = users
            .filter((u) => !isNullOrEmpty(u.email))
            .map((user) => ({
                to: [user.email!],
                from: `${communityData.name} <${noReplyEmailAddr()}>`,
                message: generateMessage({
                    community: communityData,
                    user,
                    unsubscribeUrl: getUnsubscribeUrl({ userId: user.uid }),
                }),
            }))

        console.log('Emails generated')
        await sendEmailClient.sendEmails(emails)
    }

    async sendEmailToEventParticipants({
        communityId,
        template,
        event,
        generateMessage,
    }: {
        communityId: string
        template: Template
        event: Event
        generateMessage: (opts: {
            community: Community
            user: admin.auth.UserRecord
            unsubscribeUrl: string
        }) => SendGridEmailMessage
    }): Promise<void> {
        const communityDoc = await firestore.collection('community').doc(communityId).get()
        const community = { ...(communityDoc.data() as Community), id: communityDoc.id }

        const eventParticipantsSnapshots = await firestore
            .collection('community')
            .doc(communityId)
            .collection('templates')
            .doc(template.id)
            .collection('events')
            .doc(event.id)
            .collection('event-participants')
            .get()

        const eventParticipants = eventParticipantsSnapshots.docs.map(
            (doc) => doc.data() as Participant
        )

        const eventParticipantIds = eventParticipants
            .filter((p) => p.status === ParticipantStatus.active)
            .map((p) => p.id)

        const users = await firebaseAuthUtils.getUsers(eventParticipantIds)

        const usersWithoutEmail = users.filter((u) => isNullOrEmpty(u.email))
        if (usersWithoutEmail.length > 0) {
            console.log('Some users do not have an email:', usersWithoutEmail)
        }

        const emails: SendGridEmail[] = users
            .filter((u) => !isNullOrEmpty(u.email))
            .map((user) => ({
                to: [user.email!],
                from: `${community.name} <${noReplyEmailAddr()}>`,
                message: generateMessage({
                    community,
                    user,
                    unsubscribeUrl: getUnsubscribeUrl({ userId: user.uid }),
                }),
            }))

        console.log(
            'Sending event message email to:',
            emails.map((e) => e.to)
        )
        await sendEmailClient.sendEmails(emails)
    }

    async sendEventEndedEmail({
        communityId,
        event,
        emailType,
        userIds,
        generateMessage,
    }: {
        communityId: string
        event: Event
        emailType: EventEmailType
        userIds: string[]
        generateMessage: (community: Community, user: admin.auth.UserRecord) => SendGridEmailMessage
    }): Promise<void> {
        const communityDoc = await firestore.collection('community').doc(communityId).get()
        const community = { ...(communityDoc.data() as Community), id: communityDoc.id }

        const users = await firebaseAuthUtils.getUsers(userIds)
        const emails: SendGridEmail[] = users
            .filter((u) => !isNullOrEmpty(u.email))
            .map((user) => ({
                to: [user.email!],
                from: `${community.name} <${noReplyEmailAddr()}>`,
                message: generateMessage(community, user),
            }))

        await sendEmailClient.sendEmails(emails)
    }
}

export let notificationsUtils = new NotificationsUtils()
export function setNotificationsUtils(instance: NotificationsUtils): void {
    notificationsUtils = instance
}

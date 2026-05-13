import * as functions from 'firebase-functions'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { OnCallMethod } from '../on_call_function'
import {
    CreateAnnouncementRequest,
    Membership,
    CommunityUserSettings,
    NotificationEmailType,
    SendGridEmailMessage,
} from '../types'
import { NotificationsUtils } from '../utils/notifications_utils'
import { membershipIsAdmin } from '../types'

export class CreateAnnouncement extends OnCallMethod<CreateAnnouncementRequest> {
    notificationsUtils: NotificationsUtils

    constructor(opts?: { notificationsUtils?: NotificationsUtils }) {
        super('sendAnnouncement', (json) => json as CreateAnnouncementRequest)
        this.notificationsUtils = opts?.notificationsUtils ?? new NotificationsUtils()
    }

    async action(
        request: CreateAnnouncementRequest,
        context: functions.https.CallableContext
    ): Promise<void> {
        const membershipDoc = await firestore
            .doc(`memberships/${context.auth?.uid}/community-membership/${request.communityId}`)
            .get()
        const membership = membershipDoc.data() as Membership | undefined

        if (!membership?.status || !membershipIsAdmin(membership.status)) {
            throw new HttpsError('failed-precondition', 'unauthorized')
        }

        const docRef = firestore.collection(`/community/${request.communityId}/announcements`).doc()
        await docRef.set(
            firestoreUtils.toFirestoreJson(
                request.announcement as unknown as Record<string, unknown>
            )
        )

        console.log('Sending notification')
        await this.notificationsUtils.sendCommunityNotifications({
            communityId: request.communityId,
            filterUsersBy: (settings: CommunityUserSettings) =>
                settings.notifyAnnouncements === NotificationEmailType.immediate ||
                settings.notifyAnnouncements == null,
            generateMessage: ({ community, user, unsubscribeUrl }) => ({
                subject: `New Announcement: ${request.announcement?.title}`,
                html: `<p>New announcement in ${community.name}</p><p>Unsubscribe: ${unsubscribeUrl}</p>`,
            }),
        })
    }
}

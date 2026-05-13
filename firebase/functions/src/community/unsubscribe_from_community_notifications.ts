import * as functions from 'firebase-functions'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { OnCallMethod } from '../on_call_function'
import {
    UnsubscribeFromCommunityNotificationsRequest,
    Membership,
    MembershipStatus,
    CommunityUserSettings,
    NotificationEmailType,
} from '../types'
import { decryptUnsubscribeData } from '../utils/encrypt_util'

export class UnsubscribeFromCommunityNotifications extends OnCallMethod<UnsubscribeFromCommunityNotificationsRequest> {
    constructor() {
        super(
            'unsubscribeFromCommunityNotifications',
            (json) => json as UnsubscribeFromCommunityNotificationsRequest
        )
    }

    async action(
        request: UnsubscribeFromCommunityNotificationsRequest,
        _context: functions.https.CallableContext
    ): Promise<void> {
        const decrypted = decryptUnsubscribeData(request.data)

        const membershipsData = await firestore
            .collectionGroup('community-membership')
            .where('userId', '==', decrypted.userId)
            .where('status', '!=', MembershipStatus.nonmember)
            .get()

        const communityIds = membershipsData.docs.map(
            (doc) => (doc.data() as Membership).communityId
        )

        await Promise.all(
            communityIds.map((communityId) => {
                const settings: CommunityUserSettings = {
                    userId: decrypted.userId,
                    communityId,
                    notifyAnnouncements: NotificationEmailType.none,
                    notifyEvents: NotificationEmailType.none,
                }

                return firestore
                    .doc(`privateUserData/${decrypted.userId}/communityUserSettings/${communityId}`)
                    .set(
                        firestoreUtils.toFirestoreJson(
                            settings as unknown as Record<string, unknown>
                        ),
                        { merge: true }
                    )
            })
        )
    }
}

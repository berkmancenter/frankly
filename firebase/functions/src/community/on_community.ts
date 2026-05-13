import * as admin from 'firebase-admin'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import {
    OnFirestoreFunction,
    AppFirestoreFunctionData,
    FirestoreEventType,
} from '../on_firestore_function'
import { Community, OnboardingStep } from '../types'

export class OnCommunity extends OnFirestoreFunction<Community> {
    constructor() {
        super(
            [
                {
                    functionName: 'CommunityOnCreate',
                    firestoreEventType: FirestoreEventType.onCreate,
                },
            ],
            (snapshot) => {
                const data = firestoreUtils.fromFirestoreJson(
                    snapshot.data() ?? {}
                ) as unknown as Community
                return { ...data, id: snapshot.id }
            }
        )
    }

    get documentPath(): string {
        return 'community/{communityId}'
    }

    async onCreate(
        documentSnapshot: admin.firestore.DocumentSnapshot,
        _parsedData: Community,
        _updateTime: Date,
        _context: import('firebase-functions').EventContext
    ): Promise<void> {
        console.log(`Community (${documentSnapshot.id}) has been created`)
        await documentSnapshot.ref.update({
            onboardingSteps: [OnboardingStep.brandSpace],
        })
    }
}

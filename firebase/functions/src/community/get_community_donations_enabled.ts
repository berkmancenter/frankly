import * as functions from 'firebase-functions'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { OnCallMethod } from '../on_call_function'
import { GetCommunityDonationsEnabledRequest, Community, PartnerAgreement } from '../types'
import { kShowStripeFeatures } from '../utils/subscription_plan_util'
import { orElseNotFound } from '../utils/utils'

export class GetCommunityDonationsEnabled extends OnCallMethod<GetCommunityDonationsEnabledRequest> {
    constructor() {
        super('GetCommunityDonationsEnabled', (json) => json as GetCommunityDonationsEnabledRequest)
    }

    async action(
        request: GetCommunityDonationsEnabledRequest,
        _context: functions.https.CallableContext
    ): Promise<{ donationsEnabled: boolean }> {
        return { donationsEnabled: await this._isEnabled({ communityId: request.communityId }) }
    }

    private async _isEnabled({ communityId }: { communityId: string }): Promise<boolean> {
        const communitySnapshot = await firestore.doc(`/community/${communityId}`).get()
        orElseNotFound(communitySnapshot.exists)
        const community = communitySnapshot.data() as Community

        if (!kShowStripeFeatures) return false

        const communitySettings = community.communitySettings
        if (!communitySettings?.allowDonations) return false

        const agreementDocs = await firestore
            .collection('partner-agreements')
            .where('communityId', '==', communityId)
            .get()

        if (!agreementDocs.empty) {
            const agreement = agreementDocs.docs[0].data() as PartnerAgreement
            return agreement.stripeConnectedAccountActive ?? false
        }

        return false
    }
}

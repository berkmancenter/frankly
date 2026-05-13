import * as functions from 'firebase-functions'
import { OnCallMethod } from '../on_call_function'
import { GetCommunityPrePostEnabledRequest } from '../types'
import { subscriptionPlanUtil } from '../utils/subscription_plan_util'

export class GetCommunityPrePostEnabled extends OnCallMethod<GetCommunityPrePostEnabledRequest> {
    constructor() {
        super('GetCommunityPrePostEnabled', (json) => json as GetCommunityPrePostEnabledRequest)
    }

    async action(
        request: GetCommunityPrePostEnabledRequest,
        _context: functions.https.CallableContext
    ): Promise<{ prePostEnabled: boolean }> {
        const capabilities = await subscriptionPlanUtil.calculateCapabilities(request.communityId)
        return { prePostEnabled: capabilities.hasPrePost ?? false }
    }
}

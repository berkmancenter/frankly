import * as functions from 'firebase-functions';
import { OnCallMethod } from '../on_call_function';
import { GetCommunityCapabilitiesRequest, PlanCapabilityList } from '../types';
import { orElseUnauthorized } from '../utils/utils';
import { subscriptionPlanUtil } from '../utils/subscription_plan_util';

export class GetCommunityCapabilities extends OnCallMethod<GetCommunityCapabilitiesRequest> {
  constructor() {
    super('getCommunityCapabilities', (json) => json as GetCommunityCapabilitiesRequest);
  }

  async action(
    request: GetCommunityCapabilitiesRequest,
    context: functions.https.CallableContext
  ): Promise<PlanCapabilityList> {
    orElseUnauthorized(context.auth?.uid != null, { logMessage: 'Context auth ID was null' });

    return subscriptionPlanUtil.calculateCapabilities(request.communityId, {
      requesterUserId: context.auth!.uid,
    });
  }
}

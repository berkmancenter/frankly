import * as functions from 'firebase-functions'
import { firestore, firestoreUtils } from './infra/firestore_utils'
import {
    Community,
    Membership,
    MembershipStatus,
    PlanCapabilityList,
    PlanType,
    BillingSubscription,
    PartnerAgreement,
} from '../types'
import { orElseUnauthorized } from './utils'
import { membershipIsAdmin } from '../types'

export const kShowStripeFeatures = false

export class SubscriptionPlanUtil {
    getDefaultCapabilities(): PlanCapabilityList {
        return {
            userHours: 100000,
            adminCount: 100000,
            facilitatorCount: 100000,
            takeRate: 0,
            hasSmartMatching: true,
            hasLivestreams: true,
            hasCustomUrls: true,
            hasAdvancedBranding: true,
            hasBasicAnalytics: true,
            hasCustomAnalytics: true,
            hasIntegrations: true,
            hasPrePost: true,
        }
    }

    async calculateCapabilities(
        communityId: string,
        opts?: { requesterUserId?: string }
    ): Promise<PlanCapabilityList> {
        let isMod = false

        if (opts?.requesterUserId) {
            const membershipDoc = await firestore
                .doc(`memberships/${opts.requesterUserId}/community-membership/${communityId}`)
                .get()
            const membership = membershipDoc.data() as Membership | undefined
            isMod = membership?.status ? membershipIsAdmin(membership.status) : false
        }

        orElseUnauthorized(opts?.requesterUserId == null || isMod, {
            logMessage: 'Only mods or above can access capabilities.',
        })

        if (!kShowStripeFeatures) {
            return this._getCapabilitiesForType({ type: 'unrestricted' })
        }

        const overridePlan = await this._getOverridePlan({ communityId })
        const subscriptionPlan = await this._getSubscriptionPlan({ communityId })

        return [this.getDefaultCapabilities(), subscriptionPlan, overridePlan]
            .filter((p): p is PlanCapabilityList => p != null)
            .reduce(this._combineCapabilities.bind(this))
    }

    private async _getOverridePlan({
        communityId,
    }: {
        communityId: string
    }): Promise<PlanCapabilityList | null> {
        const agreementDocs = await firestore
            .collection('partner-agreements')
            .where('communityId', '==', communityId)
            .limit(1)
            .get()

        if (!agreementDocs.empty) {
            const agreement = agreementDocs.docs[0].data() as PartnerAgreement
            if (agreement.planOverride) {
                return this._getCapabilitiesForType({ type: agreement.planOverride })
            }
        }

        return null
    }

    private async _getSubscriptionPlan({
        communityId,
    }: {
        communityId: string
    }): Promise<PlanCapabilityList | null> {
        const activeSubscriptions = await firestore
            .collectionGroup('subscriptions')
            .where('activeUntil', '>', new Date())
            .where('appliedCommunityId', '==', communityId)
            .get()

        if (!activeSubscriptions.empty) {
            const subscriptions = activeSubscriptions.docs.map(
                (doc) => doc.data() as BillingSubscription
            )
            const types = [...new Set(subscriptions.map((s) => s.type).filter(Boolean))] as string[]
            const plans = await Promise.all(
                types.map((t) => this._getCapabilitiesForType({ type: t }))
            )
            return plans.reduce(this._combineCapabilities.bind(this))
        }

        return null
    }

    private async _getCapabilitiesForType({ type }: { type: string }): Promise<PlanCapabilityList> {
        const matchingCapabilities = await firestore
            .collection('plan-capability-lists')
            .where('type', '==', type)
            .limit(1)
            .get()

        if (!matchingCapabilities.empty) {
            return matchingCapabilities.docs[0].data() as PlanCapabilityList
        }

        console.log('Using default capabilities')
        return this.getDefaultCapabilities()
    }

    private _combineCapabilities(a: PlanCapabilityList, b: PlanCapabilityList): PlanCapabilityList {
        const applyReducer = <T>(f: (a: T, b: T) => T, av?: T, bv?: T): T | undefined => {
            if (av == null) return bv
            if (bv == null) return av
            return f(av, bv)
        }

        return {
            type: applyReducer(this._getOverridingType.bind(this), a.type, b.type),
            userHours: applyReducer(Math.max, a.userHours, b.userHours),
            adminCount: applyReducer(Math.max, a.adminCount, b.adminCount),
            facilitatorCount: applyReducer(Math.max, a.facilitatorCount, b.facilitatorCount),
            takeRate: applyReducer(Math.min, a.takeRate, b.takeRate),
            hasSmartMatching: applyReducer(
                (x, y) => x || y,
                a.hasSmartMatching,
                b.hasSmartMatching
            ),
            hasLivestreams: applyReducer((x, y) => x || y, a.hasLivestreams, b.hasLivestreams),
            hasCustomUrls: applyReducer((x, y) => x || y, a.hasCustomUrls, b.hasCustomUrls),
            hasAdvancedBranding: applyReducer(
                (x, y) => x || y,
                a.hasAdvancedBranding,
                b.hasAdvancedBranding
            ),
            hasBasicAnalytics: applyReducer(
                (x, y) => x || y,
                a.hasBasicAnalytics,
                b.hasBasicAnalytics
            ),
            hasCustomAnalytics: applyReducer(
                (x, y) => x || y,
                a.hasCustomAnalytics,
                b.hasCustomAnalytics
            ),
            hasIntegrations: applyReducer((x, y) => x || y, a.hasIntegrations, b.hasIntegrations),
            hasPrePost: applyReducer((x, y) => x || y, a.hasPrePost, b.hasPrePost),
        }
    }

    private _getOverridingType(a: string, b: string): string {
        const ordering = [
            PlanType.unrestricted,
            PlanType.pro,
            PlanType.club,
            PlanType.individual,
        ] as string[]
        return ordering.indexOf(a) < ordering.indexOf(b) ? a : b
    }
}

export let subscriptionPlanUtil = new SubscriptionPlanUtil()
export function setSubscriptionPlanUtil(instance: SubscriptionPlanUtil): void {
    subscriptionPlanUtil = instance
}

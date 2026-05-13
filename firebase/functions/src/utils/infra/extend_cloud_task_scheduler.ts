import { OnRequestMethod } from '../../on_request_method'
import { scheduledFunctions } from './scheduled_functions'
import { ExtendCloudTaskSchedulerRequest } from '../../types'

/**
 * Reschedules Cloud Tasks that exceed the 30-day scheduling quota.
 * Corresponds to Dart's ExtendCloudTaskScheduler.
 */
export class ExtendCloudTaskScheduler extends OnRequestMethod<ExtendCloudTaskSchedulerRequest> {
    constructor() {
        super('ExtendCloudTaskScheduler', (jsonMap) => jsonMap as ExtendCloudTaskSchedulerRequest)
    }

    async action(request: ExtendCloudTaskSchedulerRequest): Promise<string> {
        await scheduledFunctions.enqueueCall(
            request.functionName,
            request.payload,
            new Date(request.scheduledTime)
        )
        return ''
    }
}

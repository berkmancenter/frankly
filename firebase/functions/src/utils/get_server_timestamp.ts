import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { OnCallMethod } from '../on_call_function'
import { GetServerTimestampRequest, GetServerTimestampResponse } from '../types'

export class GetServerTimestamp extends OnCallMethod<GetServerTimestampRequest> {
    constructor() {
        super('serverTimestamp', (data) => (data ?? {}) as GetServerTimestampRequest, {
            runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 1 },
        })
    }

    async action(
        _request: GetServerTimestampRequest,
        _context: functions.https.CallableContext
    ): Promise<GetServerTimestampResponse> {
        return {
            serverTimestamp: new Date().toISOString(),
        }
    }
}

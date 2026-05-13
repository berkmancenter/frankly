import { HttpsFunction, CloudFunction as FirebaseCloudFunction } from 'firebase-functions'

/**
 * Base interface for all Cloud Functions.
 */
export interface CloudFunction {
    readonly functionName: string
    register(
        functions: typeof import('firebase-functions'),
        cors: typeof import('cors')
    ): HttpsFunction | FirebaseCloudFunction<unknown> | void
}

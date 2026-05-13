import * as admin from 'firebase-admin'
import { firebaseApp } from './firestore_utils'

export class FirebaseAuthUtils {
    async getUser(uid: string): Promise<admin.auth.UserRecord> {
        return firebaseApp.auth().getUser(uid)
    }

    async getUsers(uids: string[]): Promise<admin.auth.UserRecord[]> {
        const promises = uids.map((id) =>
            firebaseApp
                .auth()
                .getUser(id)
                .catch((e) => {
                    console.error(`Failed to get user ${id}:`, e)
                    return null
                })
        )
        const results = await Promise.all(promises)
        return results.filter((r): r is admin.auth.UserRecord => r !== null)
    }
}

export let firebaseAuthUtils = new FirebaseAuthUtils()
export function setFirebaseAuthUtils(instance: FirebaseAuthUtils): void {
    firebaseAuthUtils = instance
}

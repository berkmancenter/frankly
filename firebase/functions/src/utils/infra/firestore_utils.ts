import * as admin from 'firebase-admin'

// Initialize Firebase Admin SDK (only once)
if (!admin.apps.length) {
    admin.initializeApp()
}

export const firebaseApp = admin.app()
export const firestore = admin.firestore()

export const isEmulator = process.env.FUNCTIONS_EMULATOR === 'true'

export class FirestoreUtils {
    async getFirestoreObject<T>({
        path,
        constructor,
        transaction,
    }: {
        path: string
        constructor: (map: Record<string, unknown>) => T
        transaction?: admin.firestore.Transaction
    }): Promise<T> {
        const ref = firestore.doc(path)
        const snapshot = transaction ? await transaction.get(ref) : await ref.get()
        const map = this.fromFirestoreJson(snapshot.data() ?? {})
        // Populate `id` from the document reference if missing or empty
        if (!map['id'] || typeof map['id'] !== 'string' || (map['id'] as string).length === 0) {
            map['id'] = ref.id
        }
        return constructor(map)
    }

    fromFirestoreJson(json: Record<string, unknown>): Record<string, unknown> {
        const formatted: Record<string, unknown> = {}
        for (const [key, value] of Object.entries(json)) {
            if (value instanceof admin.firestore.Timestamp) {
                formatted[key] = value.toDate()
            } else if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
                formatted[key] = this.fromFirestoreJson(value as Record<string, unknown>)
            } else if (Array.isArray(value)) {
                formatted[key] = value.map((v) =>
                    v !== null && typeof v === 'object' && !Array.isArray(v)
                        ? this.fromFirestoreJson(v as Record<string, unknown>)
                        : v
                )
            } else {
                formatted[key] = value
            }
        }
        return formatted
    }

    toFirestoreJson(json: Record<string, unknown>): Record<string, unknown> {
        const formatted: Record<string, unknown> = {}
        for (const [key, value] of Object.entries(json)) {
            if (value === 'SERVER_TIMESTAMP') {
                formatted[key] = admin.firestore.FieldValue.serverTimestamp()
            } else if (value instanceof Date) {
                formatted[key] = admin.firestore.Timestamp.fromDate(value)
            } else if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
                formatted[key] = this.toFirestoreJson(value as Record<string, unknown>)
            } else if (Array.isArray(value)) {
                formatted[key] = value.map((v) =>
                    v !== null && typeof v === 'object' && !Array.isArray(v)
                        ? this.toFirestoreJson(v as Record<string, unknown>)
                        : v
                )
            } else {
                formatted[key] = value
            }
        }
        return formatted
    }
}

// Global singleton — can be replaced in tests
export let firestoreUtils = new FirestoreUtils()
export function setFirestoreUtils(instance: FirestoreUtils): void {
    firestoreUtils = instance
}

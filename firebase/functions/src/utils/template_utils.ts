import * as admin from 'firebase-admin'
import { Template } from '../types'

export class TemplateUtils {
    static templateFromSnapshot(snapshot: admin.firestore.DocumentSnapshot): Template {
        if (snapshot.id === 'misc') {
            return {
                id: 'misc',
                creatorId: '',
                collectionPath: snapshot.ref.path,
            }
        }
        const data = snapshot.data() ?? {}
        return {
            ...(data as Partial<Template>),
            id: snapshot.id,
            collectionPath: snapshot.ref.parent.path,
        } as Template
    }
}

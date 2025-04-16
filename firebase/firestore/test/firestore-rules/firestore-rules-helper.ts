import CollectionReference = firestore.CollectionReference

type CollectionDocumentPair = {
    collection: string
    document: string
}

export enum Membership {
    attendee = 'attendee',
    nonmember = 'nonmember',
    member = 'member',
    facilitator = 'facilitator',
    mod = 'mod',
    admin = 'admin',
    owner = 'owner',
}

import { firestore } from 'firebase-admin/lib/firestore'
import DocumentReference = firestore.DocumentReference

export class CommunityRulesHelper {
    _admin: firestore.Firestore
    _colDocPairs: CollectionDocumentPair[]

    // Initialise with admin user and preferred collection and document pairs.
    constructor(
        admin: FirebaseFirestore.Firestore,
        collectionDocumentPairs: CollectionDocumentPair[]
    ) {
        this._admin = admin
        this._colDocPairs = collectionDocumentPairs
    }

    /**
     * Returns DocumentReference by the given user.
     * If [{collection:a, document:a1}, {collection:b, document:b1}, {collection:c, document:c1}], then result will be
     * ..collection(a).document(a1).collection(b).document(b1).collection(c).document(c1)
     *
     * @param user is the user which will have its DocumentReference to.
     */
    getDocumentRef(user: firestore.Firestore): DocumentReference {
        let docRef = user
            .collection(this._colDocPairs[0].collection)
            .doc(this._colDocPairs[0].document)
        for (let i = 1; i < this._colDocPairs.length; i++) {
            const colDocPair = this._colDocPairs[i]
            docRef = docRef.collection(colDocPair.collection).doc(colDocPair.document)
        }
        return docRef
    }

    /**
     * Returns CollectionReference by the given user.
     * If [{collection:a, document:a1}, {collection:b, document:b1}, {collection:c, document:c1}], then result will be
     * ..collection(a).document(a1).collection(b).document(b1).collection(c)
     *
     * @param user is the user which will have its CollectionReference to.
     */
    getCollectionRef(user: firestore.Firestore): CollectionReference {
        let colRef = user.collection(this._colDocPairs[0].collection)
        for (let i = 1; i < this._colDocPairs.length; i++) {
            colRef = colRef
                .doc(this._colDocPairs[i - 1].document)
                .collection(this._colDocPairs[i].collection)
        }
        return colRef
    }

    /**
     * Adds new field `creatorId` with given userId.
     * @param userId is the user id which will be added into the field.
     */
    async makeDocCreator(userId: string): Promise<void> {
        await this.getDocumentRef(this._admin).set({ creatorId: userId }, { merge: true })
    }

    /**
     * Adds new field `creatorId` with given userId.
     * @param communityId is the id of community.
     * @param templateId is the id of template.
     * @param eventId is the id of event.
     * @param userId is the user id which will be added into the field.
     */
    async makeParticipant(
        communityId: string,
        templateId: string,
        eventId: string,
        userId: string
    ): Promise<void> {
        await this._admin
            .collection('community')
            .doc(communityId)
            .collection('templates')
            .doc(templateId)
            .collection('events')
            .doc(eventId)
            .collection('event-participants')
            .doc(userId)
            .set({ status: 'active' })
    }

    /**
     * Updates existing document with new data.
     * @param dataMap is the new data set that will be merged into the document.
     */
    async updateDocumentsField(dataMap: {}): Promise<void> {
        await this.getDocumentRef(this._admin).set(dataMap, { merge: true })
    }

    /**
     * Creates new membership document and add specified values.
     * @param documentId is where this community-membership document will exist.
     * @param membership is the membership of the membership.
     */
    async createMembership(documentId: string, membership: string): Promise<void> {
        await this._admin
            .collection('memberships')
            .doc(documentId)
            .collection('community-membership')
            .doc('communityId')
            .set({ status: membership })
    }
}

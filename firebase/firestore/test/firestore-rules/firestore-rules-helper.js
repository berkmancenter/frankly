"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommunityRulesHelper = exports.Membership = void 0;
var Membership;
(function (Membership) {
    Membership["attendee"] = "attendee";
    Membership["nonmember"] = "nonmember";
    Membership["member"] = "member";
    Membership["facilitator"] = "facilitator";
    Membership["mod"] = "mod";
    Membership["admin"] = "admin";
    Membership["owner"] = "owner";
})(Membership || (exports.Membership = Membership = {}));
class CommunityRulesHelper {
    // Initialise with admin user and preferred collection and document pairs.
    constructor(admin, collectionDocumentPairs) {
        this._admin = admin;
        this._colDocPairs = collectionDocumentPairs;
    }
    /**
     * Returns DocumentReference by the given user.
     * If [{collection:a, document:a1}, {collection:b, document:b1}, {collection:c, document:c1}], then result will be
     * ..collection(a).document(a1).collection(b).document(b1).collection(c).document(c1)
     *
     * @param user is the user which will have its DocumentReference to.
     */
    getDocumentRef(user) {
        let docRef = user
            .collection(this._colDocPairs[0].collection)
            .doc(this._colDocPairs[0].document);
        for (let i = 1; i < this._colDocPairs.length; i++) {
            const colDocPair = this._colDocPairs[i];
            docRef = docRef.collection(colDocPair.collection).doc(colDocPair.document);
        }
        return docRef;
    }
    /**
     * Returns CollectionReference by the given user.
     * If [{collection:a, document:a1}, {collection:b, document:b1}, {collection:c, document:c1}], then result will be
     * ..collection(a).document(a1).collection(b).document(b1).collection(c)
     *
     * @param user is the user which will have its CollectionReference to.
     */
    getCollectionRef(user) {
        let colRef = user.collection(this._colDocPairs[0].collection);
        for (let i = 1; i < this._colDocPairs.length; i++) {
            colRef = colRef
                .doc(this._colDocPairs[i - 1].document)
                .collection(this._colDocPairs[i].collection);
        }
        return colRef;
    }
    /**
     * Adds new field `creatorId` with given userId.
     * @param userId is the user id which will be added into the field.
     */
    makeDocCreator(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.getDocumentRef(this._admin).set({ creatorId: userId }, { merge: true });
        });
    }
    /**
     * Adds new field `creatorId` with given userId.
     * @param communityId is the id of community.
     * @param templateId is the id of template.
     * @param eventId is the id of event.
     * @param userId is the user id which will be added into the field.
     */
    makeParticipant(communityId, templateId, eventId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._admin
                .collection('community')
                .doc(communityId)
                .collection('templates')
                .doc(templateId)
                .collection('events')
                .doc(eventId)
                .collection('event-participants')
                .doc(userId)
                .set({ status: 'active' });
        });
    }
    /**
     * Updates existing document with new data.
     * @param dataMap is the new data set that will be merged into the document.
     */
    updateDocumentsField(dataMap) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.getDocumentRef(this._admin).set(dataMap, { merge: true });
        });
    }
    /**
     * Creates new membership document and add specified values.
     * @param documentId is where this community-membership document will exist.
     * @param membership is the membership of the membership.
     */
    createMembership(documentId, membership) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._admin
                .collection('memberships')
                .doc(documentId)
                .collection('community-membership')
                .doc('communityId')
                .set({ status: membership });
        });
    }
}
exports.CommunityRulesHelper = CommunityRulesHelper;

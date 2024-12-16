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
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.JuntoRulesHelper = exports.Membership = void 0;
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
var JuntoRulesHelper = /** @class */ (function () {
    // Initialise with admin user and preferred collection and document pairs.
    function JuntoRulesHelper(admin, collectionDocumentPairs) {
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
    JuntoRulesHelper.prototype.getDocumentRef = function (user) {
        var docRef = user
            .collection(this._colDocPairs[0].collection)
            .doc(this._colDocPairs[0].document);
        for (var i = 1; i < this._colDocPairs.length; i++) {
            var colDocPair = this._colDocPairs[i];
            docRef = docRef.collection(colDocPair.collection).doc(colDocPair.document);
        }
        return docRef;
    };
    /**
     * Returns CollectionReference by the given user.
     * If [{collection:a, document:a1}, {collection:b, document:b1}, {collection:c, document:c1}], then result will be
     * ..collection(a).document(a1).collection(b).document(b1).collection(c)
     *
     * @param user is the user which will have its CollectionReference to.
     */
    JuntoRulesHelper.prototype.getCollectionRef = function (user) {
        var colRef = user.collection(this._colDocPairs[0].collection);
        for (var i = 1; i < this._colDocPairs.length; i++) {
            colRef = colRef
                .doc(this._colDocPairs[i - 1].document)
                .collection(this._colDocPairs[i].collection);
        }
        return colRef;
    };
    /**
     * Adds new field `creatorId` with given userId.
     * @param userId is the user id which will be added into the field.
     */
    JuntoRulesHelper.prototype.makeDocCreator = function (userId) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.getDocumentRef(this._admin).set({ creatorId: userId }, { merge: true })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Adds new field `creatorId` with given userId.
     * @param juntoId is the id of junto.
     * @param topicId is the id of topic.
     * @param discussionId is the id of discussion.
     * @param userId is the user id which will be added into the field.
     */
    JuntoRulesHelper.prototype.makeParticipant = function (juntoId, topicId, discussionId, userId) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._admin
                            .collection('junto')
                            .doc(juntoId)
                            .collection('topics')
                            .doc(topicId)
                            .collection('discussions')
                            .doc(discussionId)
                            .collection('discussion-participants')
                            .doc(userId)
                            .set({ status: 'active' })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Updates existing document with new data.
     * @param dataMap is the new data set that will be merged into the document.
     */
    JuntoRulesHelper.prototype.updateDocumentsField = function (dataMap) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.getDocumentRef(this._admin).set(dataMap, { merge: true })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Creates new membership document and add specified values.
     * @param documentId is where this junto-membership document will exist.
     * @param membership is the membership of the membership.
     */
    JuntoRulesHelper.prototype.createMembership = function (documentId, membership) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this._admin
                            .collection('memberships')
                            .doc(documentId)
                            .collection('junto-membership')
                            .doc('juntoId')
                            .set({ status: membership })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    return JuntoRulesHelper;
}());
exports.JuntoRulesHelper = JuntoRulesHelper;

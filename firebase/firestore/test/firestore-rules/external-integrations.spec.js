"use strict";
/**
 * Security rules tests for external integrations (webhooks).
 *
 * Self-contained: loads the rules and clears data itself, so it can run on
 * its own or together with firestore.spec.js.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
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
const path = __importStar(require("path"));
require("mocha");
const firebase = require("@firebase/rules-unit-testing");
const fs = require("fs");
const PROJECT_ID = "firestore-emulator-example";
process.env.FIRESTORE_EMULATOR_HOST =
    process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
const COMMUNITY_ID = "communityId";
const EVENT_PATH = `community/${COMMUNITY_ID}/templates/templateId/events/eventId`;
const INTEGRATION_ID = "integrationId";
function authed(uid) {
    return firebase
        .initializeTestApp({
        projectId: PROJECT_ID,
        auth: uid ? { uid } : null,
    })
        .firestore();
}
const admin = firebase.initializeAdminApp({ projectId: PROJECT_ID }).firestore();
function setMembership(uid, status) {
    return __awaiter(this, void 0, void 0, function* () {
        yield admin
            .doc(`memberships/${uid}/community-membership/${COMMUNITY_ID}`)
            .set({ status });
    });
}
describe("External integration rules", () => {
    before(() => __awaiter(void 0, void 0, void 0, function* () {
        const rules = fs.readFileSync(path.join(__dirname, "../", "../", "firestore.rules"), "utf8");
        yield firebase.loadFirestoreRules({ projectId: PROJECT_ID, rules });
    }));
    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
        yield firebase.clearFirestoreData({ projectId: PROJECT_ID });
        yield admin.doc(`community/${COMMUNITY_ID}`).set({ name: "c" });
        yield admin.doc(EVENT_PATH).set({ creatorId: "host", communityId: COMMUNITY_ID });
    }));
    describe("/external-integration-secrets/{id}", () => {
        const secretPath = `external-integration-secrets/${INTEGRATION_ID}`;
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield admin
                .doc(secretPath)
                .set({ communityId: COMMUNITY_ID, secret: "whsec_test" });
        }));
        for (const status of ["owner", "admin", "moderator", "member", "nonmember"]) {
            it(`cannot be read or written by a community ${status}`, () => __awaiter(void 0, void 0, void 0, function* () {
                yield setMembership("alice", status);
                const db = authed("alice");
                yield firebase.assertFails(db.doc(secretPath).get());
                yield firebase.assertFails(db.collection("external-integration-secrets").get());
                yield firebase.assertFails(db.doc(secretPath).set({ secret: "x" }));
                yield firebase.assertFails(db.doc(secretPath).delete());
            }));
        }
        it("cannot be read without auth", () => __awaiter(void 0, void 0, void 0, function* () {
            yield firebase.assertFails(authed().doc(secretPath).get());
        }));
    });
    describe("/community/{c}/external-integrations/{id}", () => {
        const integrationPath = `community/${COMMUNITY_ID}/external-integrations/${INTEGRATION_ID}`;
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield admin.doc(integrationPath).set({
                id: INTEGRATION_ID,
                communityId: COMMUNITY_ID,
                displayName: "Example",
            });
        }));
        it("is readable by any signed-in user", () => __awaiter(void 0, void 0, void 0, function* () {
            yield firebase.assertSucceeds(authed("bob").doc(integrationPath).get());
        }));
        it("is not readable without auth", () => __awaiter(void 0, void 0, void 0, function* () {
            yield firebase.assertFails(authed().doc(integrationPath).get());
        }));
        it("cannot be written by clients, even owners", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("alice", "owner");
            const db = authed("alice");
            yield firebase.assertFails(db.doc(integrationPath).set({ displayName: "Changed" }));
            yield firebase.assertFails(db.doc(integrationPath).delete());
        }));
    });
    describe("/community/{c}/external-integration-endpoints/{id}", () => {
        const endpointPath = `community/${COMMUNITY_ID}/external-integration-endpoints/${INTEGRATION_ID}`;
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield admin
                .doc(endpointPath)
                .set({ integrationId: INTEGRATION_ID, webhookUrl: "https://example.com" });
        }));
        it("is readable by admins and owners", () => __awaiter(void 0, void 0, void 0, function* () {
            for (const status of ["owner", "admin"]) {
                yield setMembership("alice", status);
                yield firebase.assertSucceeds(authed("alice").doc(endpointPath).get());
            }
        }));
        it("is not readable by moderators or members", () => __awaiter(void 0, void 0, void 0, function* () {
            for (const status of ["moderator", "member", "nonmember"]) {
                yield setMembership("alice", status);
                yield firebase.assertFails(authed("alice").doc(endpointPath).get());
            }
        }));
        it("cannot be written by clients", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("alice", "owner");
            yield firebase.assertFails(authed("alice").doc(endpointPath).set({ webhookUrl: "https://evil.example" }));
        }));
    });
    describe("event external-integration-settings", () => {
        const settingsPath = `${EVENT_PATH}/external-integration-settings/${INTEGRATION_ID}`;
        const valid = (uid) => ({
            integrationId: INTEGRATION_ID,
            enabled: true,
            externalReference: "project-123",
            updatedBy: uid,
        });
        it("can be written by the event host", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("host", "member");
            yield firebase.assertSucceeds(authed("host").doc(settingsPath).set(valid("host")));
        }));
        it("can be written by a community moderator", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("mod", "moderator");
            yield firebase.assertSucceeds(authed("mod").doc(settingsPath).set(valid("mod")));
        }));
        it("cannot be written by other members", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("bob", "member");
            yield firebase.assertFails(authed("bob").doc(settingsPath).set(valid("bob")));
        }));
        it("rejects unknown fields and mismatched ids", () => __awaiter(void 0, void 0, void 0, function* () {
            const db = authed("host");
            yield firebase.assertFails(db.doc(settingsPath).set(Object.assign(Object.assign({}, valid("host")), { webhookUrl: "https://x.example" })));
            yield firebase.assertFails(db.doc(settingsPath).set(Object.assign(Object.assign({}, valid("host")), { integrationId: "other" })));
            yield firebase.assertFails(db.doc(settingsPath).set(Object.assign(Object.assign({}, valid("host")), { enabled: "yes" })));
            yield firebase.assertFails(db.doc(settingsPath).set(Object.assign(Object.assign({}, valid("host")), { updatedBy: "someoneElse" })));
        }));
        it("is readable by signed-in users", () => __awaiter(void 0, void 0, void 0, function* () {
            yield admin.doc(settingsPath).set(valid("host"));
            yield firebase.assertSucceeds(authed("bob").doc(settingsPath).get());
        }));
    });
    describe("/external-integration-deliveries/{id}", () => {
        const deliveryPath = "external-integration-deliveries/dlv_1";
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield admin.doc(deliveryPath).set({
                id: "dlv_1",
                communityId: COMMUNITY_ID,
                eventId: "eventId",
                status: "pending",
            });
        }));
        it("is readable by community moderators and above", () => __awaiter(void 0, void 0, void 0, function* () {
            for (const status of ["owner", "admin", "moderator"]) {
                yield setMembership("alice", status);
                yield firebase.assertSucceeds(authed("alice").doc(deliveryPath).get());
                yield firebase.assertSucceeds(authed("alice")
                    .collection("external-integration-deliveries")
                    .where("communityId", "==", COMMUNITY_ID)
                    .where("eventId", "==", "eventId")
                    .get());
            }
        }));
        it("is not readable by members", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("alice", "member");
            yield firebase.assertFails(authed("alice").doc(deliveryPath).get());
        }));
        it("cannot be written by clients", () => __awaiter(void 0, void 0, void 0, function* () {
            yield setMembership("alice", "owner");
            yield firebase.assertFails(authed("alice").doc(deliveryPath).update({ status: "delivered" }));
        }));
    });
});

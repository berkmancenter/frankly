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
const fs = require("fs");
const path = require("path");
require("mocha");
const testing = require("@firebase/rules-unit-testing");
const projectId = "demo-frankly-537-rules";
const communityId = "livestream-community";
const eventPath = `community/${communityId}/templates/template/events/event`;
const privatePath = `${eventPath}/private-live-stream-info/event`;
const streamInfo = { streamKey: "synthetic-key", streamServerUrl: "rtmp://example.test" };
// Use the real deployed rules and a separate emulator project.
describe("Livestream creation permissions", () => {
    let admin;
    const apps = [];
    const client = (uid) => {
        const app = testing.initializeTestApp({ projectId, auth: uid ? { uid } : null });
        apps.push(app);
        return app.firestore();
    };
    before(() => __awaiter(void 0, void 0, void 0, function* () {
        yield testing.loadFirestoreRules({
            projectId,
            rules: fs.readFileSync(path.join(__dirname, "../../firestore.rules"), "utf8"),
        });
        const app = testing.initializeAdminApp({ projectId });
        apps.push(app);
        admin = app.firestore();
    }));
    beforeEach(() => testing.clearFirestoreData({ projectId }));
    after(() => Promise.all(apps.map(app => app.delete())));
    for (const role of ["owner", "admin", "moderator", "mod", "facilitator", "member", "attendee", "nonmember", "banned", "outsider", "anonymous"]) {
        const allowed = ["owner", "admin", "moderator", "mod"].includes(role);
        const setup = () => __awaiter(void 0, void 0, void 0, function* () {
            if (!["outsider", "anonymous"].includes(role)) {
                yield admin.doc(`memberships/user/community-membership/${communityId}`).set({ status: role });
            }
            return client(role === "anonymous" ? undefined : "user");
        });
        it(`${role}: ${allowed ? "allows" : "rejects"} atomic event and private stream creation`, () => __awaiter(void 0, void 0, void 0, function* () {
            const db = yield setup();
            const batch = db.batch();
            batch.set(db.doc(eventPath), { creatorId: "user", communityId, eventType: "livestream", isPublic: true });
            batch.set(db.doc(privatePath), streamInfo);
            yield (allowed ? testing.assertSucceeds(batch.commit()) : testing.assertFails(batch.commit()));
        }));
        it(`${role}: ${allowed ? "allows" : "rejects"} reading stream credentials`, () => __awaiter(void 0, void 0, void 0, function* () {
            const db = yield setup();
            yield admin.doc(privatePath).set(streamInfo);
            yield (allowed ? testing.assertSucceeds(db.doc(privatePath).get()) : testing.assertFails(db.doc(privatePath).get()));
        }));
    }
    it("rejects a moderator from a different community", () => __awaiter(void 0, void 0, void 0, function* () {
        yield admin.doc("memberships/user/community-membership/other-community").set({ status: "moderator" });
        yield admin.doc(privatePath).set(streamInfo);
        const db = client("user");
        yield testing.assertFails(db.doc(privatePath).get());
        yield testing.assertFails(db.doc(`${eventPath}/private-live-stream-info/other`).set(streamInfo));
    }));
    it("keeps updates and deletes of stream credentials forbidden", () => __awaiter(void 0, void 0, void 0, function* () {
        yield admin.doc(`memberships/user/community-membership/${communityId}`).set({ status: "moderator" });
        yield admin.doc(privatePath).set(streamInfo);
        const db = client("user");
        yield testing.assertFails(db.doc(privatePath).update({ streamKey: "changed" }));
        yield testing.assertFails(db.doc(privatePath).delete());
    }));
});

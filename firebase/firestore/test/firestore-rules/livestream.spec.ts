import * as fs from "fs";
import * as path from "path";
import "mocha";

const testing = require("@firebase/rules-unit-testing");
const projectId = "demo-frankly-537-rules";
const communityId = "livestream-community";
const eventPath = `community/${communityId}/templates/template/events/event`;
const privatePath = `${eventPath}/private-live-stream-info/event`;
const streamInfo = { streamKey: "synthetic-key", streamServerUrl: "rtmp://example.test" };

// Use the local Firestore rules and a separate emulator project.
describe("Livestream creation permissions", () => {
  let admin: any;
  const apps: any[] = [];
  const client = (uid?: string) => {
    const app = testing.initializeTestApp({ projectId, auth: uid ? { uid } : null });
    apps.push(app);
    return app.firestore();
  };
  before(async () => {
    await testing.loadFirestoreRules({
      projectId,
      rules: fs.readFileSync(path.join(__dirname, "../../firestore.rules"), "utf8"),
    });
    const app = testing.initializeAdminApp({ projectId });
    apps.push(app);
    admin = app.firestore();
  });
  beforeEach(() => testing.clearFirestoreData({ projectId }));
  after(() => Promise.all(apps.map(app => app.delete())));

  for (const role of ["owner", "admin", "moderator", "mod", "facilitator", "member", "attendee", "nonmember", "banned", "outsider", "anonymous"]) {
    const allowed = ["owner", "admin", "moderator", "mod"].includes(role);
    const setup = async () => {
      if (!["outsider", "anonymous"].includes(role)) {
        await admin.doc(`memberships/user/community-membership/${communityId}`).set({ status: role });
      }
      return client(role === "anonymous" ? undefined : "user");
    };
    it(`${role}: ${allowed ? "allows" : "rejects"} atomic event and private stream creation`, async () => {
      const db = await setup();
      const batch = db.batch();
      batch.set(db.doc(eventPath), { creatorId: "user", communityId, eventType: "livestream", isPublic: true });
      batch.set(db.doc(privatePath), streamInfo);
      await (allowed ? testing.assertSucceeds(batch.commit()) : testing.assertFails(batch.commit()));
    });
    it(`${role}: ${allowed ? "allows" : "rejects"} reading stream credentials`, async () => {
      const db = await setup();
      await admin.doc(privatePath).set(streamInfo);
      await (allowed ? testing.assertSucceeds(db.doc(privatePath).get()) : testing.assertFails(db.doc(privatePath).get()));
    });
  }

  it("rejects a moderator from a different community", async () => {
    await admin.doc("memberships/user/community-membership/other-community").set({ status: "moderator" });
    await admin.doc(privatePath).set(streamInfo);
    const db = client("user");
    await testing.assertFails(db.doc(privatePath).get());
    await testing.assertFails(db.doc(`${eventPath}/private-live-stream-info/other`).set(streamInfo));
  });

  it("keeps updates and deletes of stream credentials forbidden", async () => {
    await admin.doc(`memberships/user/community-membership/${communityId}`).set({ status: "moderator" });
    await admin.doc(privatePath).set(streamInfo);
    const db = client("user");
    await testing.assertFails(db.doc(privatePath).update({ streamKey: "changed" }));
    await testing.assertFails(db.doc(privatePath).delete());
  });
});

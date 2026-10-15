/**
 * Security rules tests for external integrations (webhooks).
 *
 * Self-contained: loads the rules and clears data itself, so it can run on
 * its own or together with firestore.spec.js.
 */

import * as path from "path";
import "mocha";

const firebase = require("@firebase/rules-unit-testing");
const fs = require("fs");

const PROJECT_ID = "firestore-emulator-example";
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";

const COMMUNITY_ID = "communityId";
const EVENT_PATH = `community/${COMMUNITY_ID}/templates/templateId/events/eventId`;
const INTEGRATION_ID = "integrationId";

function authed(uid?: string) {
  return firebase
    .initializeTestApp({
      projectId: PROJECT_ID,
      auth: uid ? { uid } : null,
    })
    .firestore();
}

const admin = firebase.initializeAdminApp({ projectId: PROJECT_ID }).firestore();

async function setMembership(uid: string, status: string) {
  await admin
    .doc(`memberships/${uid}/community-membership/${COMMUNITY_ID}`)
    .set({ status });
}

describe("External integration rules", () => {
  before(async () => {
    const rules = fs.readFileSync(
      path.join(__dirname, "../", "../", "firestore.rules"),
      "utf8"
    );
    await firebase.loadFirestoreRules({ projectId: PROJECT_ID, rules });
  });

  beforeEach(async () => {
    await firebase.clearFirestoreData({ projectId: PROJECT_ID });
    await admin.doc(`community/${COMMUNITY_ID}`).set({ name: "c" });
    await admin.doc(EVENT_PATH).set({ creatorId: "host", communityId: COMMUNITY_ID });
  });

  describe("/external-integration-secrets/{id}", () => {
    const secretPath = `external-integration-secrets/${INTEGRATION_ID}`;

    beforeEach(async () => {
      await admin
        .doc(secretPath)
        .set({ communityId: COMMUNITY_ID, secret: "whsec_test" });
    });

    for (const status of ["owner", "admin", "moderator", "member", "nonmember"]) {
      it(`cannot be read or written by a community ${status}`, async () => {
        await setMembership("alice", status);
        const db = authed("alice");
        await firebase.assertFails(db.doc(secretPath).get());
        await firebase.assertFails(
          db.collection("external-integration-secrets").get()
        );
        await firebase.assertFails(db.doc(secretPath).set({ secret: "x" }));
        await firebase.assertFails(db.doc(secretPath).delete());
      });
    }

    it("cannot be read without auth", async () => {
      await firebase.assertFails(authed().doc(secretPath).get());
    });
  });

  describe("/community/{c}/external-integrations/{id}", () => {
    const integrationPath = `community/${COMMUNITY_ID}/external-integrations/${INTEGRATION_ID}`;

    beforeEach(async () => {
      await admin.doc(integrationPath).set({
        id: INTEGRATION_ID,
        communityId: COMMUNITY_ID,
        displayName: "Example",
      });
    });

    it("is readable by any signed-in user", async () => {
      await firebase.assertSucceeds(authed("bob").doc(integrationPath).get());
    });

    it("is not readable without auth", async () => {
      await firebase.assertFails(authed().doc(integrationPath).get());
    });

    it("cannot be written by clients, even owners", async () => {
      await setMembership("alice", "owner");
      const db = authed("alice");
      await firebase.assertFails(
        db.doc(integrationPath).set({ displayName: "Changed" })
      );
      await firebase.assertFails(db.doc(integrationPath).delete());
    });
  });

  describe("/community/{c}/external-integration-endpoints/{id}", () => {
    const endpointPath = `community/${COMMUNITY_ID}/external-integration-endpoints/${INTEGRATION_ID}`;

    beforeEach(async () => {
      await admin
        .doc(endpointPath)
        .set({ integrationId: INTEGRATION_ID, webhookUrl: "https://example.com" });
    });

    it("is readable by admins and owners", async () => {
      for (const status of ["owner", "admin"]) {
        await setMembership("alice", status);
        await firebase.assertSucceeds(authed("alice").doc(endpointPath).get());
      }
    });

    it("is not readable by moderators or members", async () => {
      for (const status of ["moderator", "member", "nonmember"]) {
        await setMembership("alice", status);
        await firebase.assertFails(authed("alice").doc(endpointPath).get());
      }
    });

    it("cannot be written by clients", async () => {
      await setMembership("alice", "owner");
      await firebase.assertFails(
        authed("alice").doc(endpointPath).set({ webhookUrl: "https://evil.example" })
      );
    });
  });

  describe("event external-integration-settings", () => {
    const settingsPath = `${EVENT_PATH}/external-integration-settings/${INTEGRATION_ID}`;
    const valid = (uid: string) => ({
      integrationId: INTEGRATION_ID,
      enabled: true,
      externalReference: "project-123",
      updatedBy: uid,
    });

    it("can be written by the event host", async () => {
      await setMembership("host", "member");
      await firebase.assertSucceeds(
        authed("host").doc(settingsPath).set(valid("host"))
      );
    });

    it("can be written by a community moderator", async () => {
      await setMembership("mod", "moderator");
      await firebase.assertSucceeds(
        authed("mod").doc(settingsPath).set(valid("mod"))
      );
    });

    it("cannot be written by other members", async () => {
      await setMembership("bob", "member");
      await firebase.assertFails(
        authed("bob").doc(settingsPath).set(valid("bob"))
      );
    });

    it("rejects unknown fields and mismatched ids", async () => {
      const db = authed("host");
      await firebase.assertFails(
        db.doc(settingsPath).set({ ...valid("host"), webhookUrl: "https://x.example" })
      );
      await firebase.assertFails(
        db.doc(settingsPath).set({ ...valid("host"), integrationId: "other" })
      );
      await firebase.assertFails(
        db.doc(settingsPath).set({ ...valid("host"), enabled: "yes" })
      );
      await firebase.assertFails(
        db.doc(settingsPath).set({ ...valid("host"), updatedBy: "someoneElse" })
      );
    });

    it("is readable by signed-in users", async () => {
      await admin.doc(settingsPath).set(valid("host"));
      await firebase.assertSucceeds(authed("bob").doc(settingsPath).get());
    });
  });

  describe("/external-integration-deliveries/{id}", () => {
    const deliveryPath = "external-integration-deliveries/dlv_1";

    beforeEach(async () => {
      await admin.doc(deliveryPath).set({
        id: "dlv_1",
        communityId: COMMUNITY_ID,
        eventId: "eventId",
        status: "pending",
      });
    });

    it("is readable by community moderators and above", async () => {
      for (const status of ["owner", "admin", "moderator"]) {
        await setMembership("alice", status);
        await firebase.assertSucceeds(authed("alice").doc(deliveryPath).get());
        await firebase.assertSucceeds(
          authed("alice")
            .collection("external-integration-deliveries")
            .where("communityId", "==", COMMUNITY_ID)
            .where("eventId", "==", "eventId")
            .get()
        );
      }
    });

    it("is not readable by members", async () => {
      await setMembership("alice", "member");
      await firebase.assertFails(authed("alice").doc(deliveryPath).get());
    });

    it("cannot be written by clients", async () => {
      await setMembership("alice", "owner");
      await firebase.assertFails(
        authed("alice").doc(deliveryPath).update({ status: "delivered" })
      );
    });
  });
});

import { beforeEach, expect, jest, test } from "@jest/globals";

jest.mock("firebase-admin", () => ({
  auth: jest.fn(),
  firestore: jest.fn(),
  storage: jest.fn(),
}));

jest.mock("../session_artifacts", () => ({
  listSessionFiles: jest.fn(),
  mp4sOf: jest.fn(),
  vttsOf: jest.fn(),
  registerMp4s: jest.fn(),
  registerVtts: jest.fn(),
  mergeTranscript: jest.fn(),
}));

import * as admin from "firebase-admin";
import * as sessionArtifacts from "../session_artifacts";
import { repairSessionArtifacts } from "../repair_session_artifacts";
import { fakeReq, fakeCorsRes as fakeRes } from "./test_utils";

function mockAuth(uid: string | Error) {
  (admin.auth as unknown as jest.Mock).mockReturnValue({
    verifyIdToken: async () => {
      if (uid instanceof Error) throw uid;
      return { uid };
    },
  });
}

function mockFirestore(opts: {
  session?: Record<string, unknown>;
  membershipStatus?: string;
}) {
  (admin.firestore as unknown as jest.Mock).mockReturnValue({
    collection: () => ({
      doc: () => ({
        get: async () =>
          opts.session
            ? { exists: true, ref: { id: "s1" }, data: () => opts.session }
            : { exists: false },
      }),
    }),
    doc: () => ({
      get: async () =>
        opts.membershipStatus
          ? { exists: true, data: () => ({ status: opts.membershipStatus }) }
          : { exists: false },
    }),
  });
}

function mockStorage() {
  (admin.storage as unknown as jest.Mock).mockReturnValue({
    bucket: () => ({}),
  });
}

beforeEach(() => {
  jest.clearAllMocks();
});

test("returns 401 when no Authorization header is present", async () => {
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ headers: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(401);
});

test("returns 400 when sessionId is missing", async () => {
  mockAuth("u1");
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(400);
});

test("returns 404 when the session does not exist", async () => {
  mockAuth("u1");
  mockFirestore({});
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(404);
});

test("returns 403 when the caller is not an owner or admin", async () => {
  mockAuth("u1");
  mockFirestore({ session: { communityId: "c1" }, membershipStatus: "member" });
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("reports not repaired when the session has no gcsPrefix", async () => {
  mockAuth("u1");
  mockFirestore({ session: { communityId: "c1" }, membershipStatus: "owner" });
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ repaired: false, reason: "No gcsPrefix on session" });
});

test("reports nothing to repair when all artifacts are already present", async () => {
  mockAuth("u1");
  mockFirestore({
    session: {
      communityId: "c1",
      gcsPrefix: "p",
      artifactPaths: {
        complete_mp4_0: "p/a.mp4",
        transcript_vtt_0: "p/a.vtt",
        complete_trx_0: "p/a.csv",
      },
    },
    membershipStatus: "owner",
  });
  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ repaired: false, reason: "Nothing to repair" });
  expect(sessionArtifacts.listSessionFiles).not.toHaveBeenCalled();
});

test("registers missing mp4/vtt artifacts and merges the transcript", async () => {
  mockAuth("u1");
  mockFirestore({
    session: { communityId: "c1", gcsPrefix: "p", artifactPaths: {} },
    membershipStatus: "admin",
  });
  mockStorage();

  const mp4Files = [{ name: "p/a.mp4" }];
  const vttFiles = [{ name: "p/a.vtt" }];
  (sessionArtifacts.listSessionFiles as unknown as jest.Mock).mockImplementation(async () => ([
    ...mp4Files,
    ...vttFiles,
  ]));
  (sessionArtifacts.mp4sOf as unknown as jest.Mock).mockReturnValue(mp4Files);
  (sessionArtifacts.vttsOf as unknown as jest.Mock).mockReturnValue(vttFiles);
  (sessionArtifacts.registerMp4s as unknown as jest.Mock).mockImplementation(async () => (undefined));
  (sessionArtifacts.registerVtts as unknown as jest.Mock).mockImplementation(async () => (undefined));
  (sessionArtifacts.mergeTranscript as unknown as jest.Mock).mockImplementation(async () => ("p/a.csv"));

  const res = fakeRes();
  repairSessionArtifacts(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;

  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ repaired: true, mp4s: 1, vtts: 1, merged: true });
  expect(sessionArtifacts.registerMp4s).toHaveBeenCalledWith(expect.anything(), mp4Files);
  expect(sessionArtifacts.registerVtts).toHaveBeenCalledWith(expect.anything(), vttFiles);
  expect(sessionArtifacts.mergeTranscript).toHaveBeenCalled();
});

import { beforeEach, expect, jest, test } from "@jest/globals";

jest.mock("firebase-admin", () => ({
  auth: jest.fn(),
  firestore: jest.fn(),
  storage: jest.fn(),
}));

import * as admin from "firebase-admin";
import { getSessionDownloadUrl } from "../get_session_download_url";
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
            ? { exists: true, data: () => opts.session }
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

function mockStorage(signedUrls: Record<string, string> = {}) {
  (admin.storage as unknown as jest.Mock).mockReturnValue({
    bucket: () => ({
      file: (path: string) => ({
        getSignedUrl: async () => [signedUrls[path] ?? `signed:${path}`],
      }),
    }),
  });
}

beforeEach(() => {
  jest.clearAllMocks();
});

test("returns 401 when no Authorization header is present", async () => {
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ headers: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(401);
});

test("returns 500 when the ID token fails verification", async () => {
  mockAuth(new Error("bad token"));
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(500);
});

test("returns 400 when sessionId is missing", async () => {
  mockAuth("u1");
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(400);
});

test("returns 404 when the session does not exist", async () => {
  mockAuth("u1");
  mockFirestore({});
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(404);
});

test("returns 403 when the caller has no membership in the community", async () => {
  mockAuth("u1");
  mockFirestore({ session: { communityId: "c1" } });
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("returns 403 when the caller is not an owner or admin", async () => {
  mockAuth("u1");
  mockFirestore({ session: { communityId: "c1" }, membershipStatus: "member" });
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("returns an empty urls map when there are no artifacts", async () => {
  mockAuth("u1");
  mockFirestore({ session: { communityId: "c1" }, membershipStatus: "owner" });
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ urls: {} });
});

test("returns a signed url per artifact for an authorized admin", async () => {
  mockAuth("u1");
  mockFirestore({
    session: {
      communityId: "c1",
      artifactPaths: { complete_mp4_0: "p/a.mp4", complete_trx_0: "p/a.csv" },
    },
    membershipStatus: "admin",
  });
  mockStorage();
  const res = fakeRes();
  getSessionDownloadUrl(fakeReq({ body: { sessionId: "s1" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({
    urls: {
      complete_mp4_0: "signed:p/a.mp4",
      complete_trx_0: "signed:p/a.csv",
    },
  });
});

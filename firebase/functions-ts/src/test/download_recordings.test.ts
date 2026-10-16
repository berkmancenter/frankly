import { beforeEach, expect, jest, test } from "@jest/globals";

jest.mock("firebase-admin", () => ({
  auth: jest.fn(),
  firestore: jest.fn(),
  storage: jest.fn(),
}));

import * as admin from "firebase-admin";
import { downloadRecording } from "../download_recordings";
import { fakeReq, fakeCorsRes as fakeRes } from "./test_utils";

const EVENT_PATH = "community/c1/templates/t1/events/e1";

function mockAuth(uid: string | Error) {
  (admin.auth as unknown as jest.Mock).mockReturnValue({
    verifyIdToken: async () => {
      if (uid instanceof Error) throw uid;
      return { uid };
    },
  });
}

function mockFirestore(opts: {
  event?: Record<string, unknown>;
  membershipStatus?: string;
}) {
  (admin.firestore as unknown as jest.Mock).mockReturnValue({
    doc: (path: string) => ({
      get: async () => {
        if (path === EVENT_PATH) {
          return opts.event
            ? { exists: true, id: "e1", data: () => opts.event }
            : { exists: false };
        }
        return opts.membershipStatus
          ? { exists: true, data: () => ({ status: opts.membershipStatus }) }
          : { exists: false };
      },
    }),
  });
}

function mockStorage(names: string[]) {
  const files = names.map((name) => ({
    name,
    getSignedUrl: async () => [`signed:${name}`],
  }));
  (admin.storage as unknown as jest.Mock).mockReturnValue({
    bucket: () => ({
      getFiles: async () => [files],
    }),
  });
}

beforeEach(() => {
  jest.clearAllMocks();
});

test("returns 401 when no Authorization header is present", async () => {
  const res = fakeRes();
  downloadRecording(fakeReq({ headers: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(401);
});

test("returns 400 when eventPath is missing", async () => {
  mockAuth("u1");
  const res = fakeRes();
  downloadRecording(fakeReq({ body: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(400);
});

test("returns 400 when eventPath does not match the expected shape", async () => {
  mockAuth("u1");
  const res = fakeRes();
  downloadRecording(
    fakeReq({ body: { eventPath: "not/a/valid/path" } }),
    res as never,
  );
  await res.settled;
  expect(res.statusCode).toBe(400);
});

test("returns 404 when the event does not exist", async () => {
  mockAuth("u1");
  mockFirestore({});
  const res = fakeRes();
  downloadRecording(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(404);
});

test("returns 403 when the caller has no membership in the community", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" } });
  const res = fakeRes();
  downloadRecording(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("returns 403 when the caller is not an owner or admin", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" }, membershipStatus: "member" });
  const res = fakeRes();
  downloadRecording(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("returns an empty recordings list when no mp4 files exist yet", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" }, membershipStatus: "owner" });
  mockStorage([] as string[]);
  const res = fakeRes();
  downloadRecording(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ recordings: [] });
});

test("returns signed urls for mp4 files sorted by name, ignoring other files", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" }, membershipStatus: "admin" });
  mockStorage(["e1/b.mp4", "e1/notes.txt", "e1/a.mp4"]);
  const res = fakeRes();
  downloadRecording(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({
    recordings: [
      { name: "e1/a.mp4", url: "signed:e1/a.mp4" },
      { name: "e1/b.mp4", url: "signed:e1/b.mp4" },
    ],
  });
});

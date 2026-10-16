import { beforeEach, expect, jest, test } from "@jest/globals";

jest.mock("firebase-admin", () => ({
  auth: jest.fn(),
  firestore: jest.fn(),
  storage: jest.fn(),
}));

import * as admin from "firebase-admin";
import { downloadTranscripts } from "../download_transcripts";
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

interface Session {
  artifactPaths?: Record<string, string>;
  roomId?: string;
  roomType?: string;
}

function mockFirestore(opts: {
  event?: Record<string, unknown>;
  membershipStatus?: string;
  sessions?: Session[];
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
    collection: () => ({
      where: () => ({
        where: () => ({
          where: () => ({
            get: async () => ({
              empty: !opts.sessions || opts.sessions.length === 0,
              docs: (opts.sessions ?? []).map((session) => ({
                data: () => session,
              })),
            }),
          }),
        }),
      }),
    }),
  });
}

function mockStorage() {
  (admin.storage as unknown as jest.Mock).mockReturnValue({
    bucket: () => ({
      file: (path: string) => ({
        getSignedUrl: async () => [`signed:${path}`],
      }),
    }),
  });
}

beforeEach(() => {
  jest.clearAllMocks();
});

test("returns 401 when no Authorization header is present", async () => {
  const res = fakeRes();
  downloadTranscripts(fakeReq({ headers: {} }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(401);
});

test("returns 400 when eventPath does not match the expected shape", async () => {
  mockAuth("u1");
  const res = fakeRes();
  downloadTranscripts(fakeReq({ body: { eventPath: "bad" } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(400);
});

test("returns 404 when the event does not exist", async () => {
  mockAuth("u1");
  mockFirestore({});
  const res = fakeRes();
  downloadTranscripts(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(404);
});

test("returns 403 when the caller is not an owner or admin", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" }, membershipStatus: "member" });
  const res = fakeRes();
  downloadTranscripts(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(403);
});

test("returns an empty transcripts list when no stopped sessions exist", async () => {
  mockAuth("u1");
  mockFirestore({ event: { communityId: "c1" }, membershipStatus: "owner", sessions: [] });
  const res = fakeRes();
  downloadTranscripts(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({ transcripts: [] });
});

test("gathers one signed url per complete_trx_* artifact across sessions", async () => {
  mockAuth("u1");
  mockFirestore({
    event: { communityId: "c1" },
    membershipStatus: "admin",
    sessions: [
      {
        roomId: "main",
        roomType: "main",
        artifactPaths: { complete_trx_0: "p/main.csv", complete_mp4_0: "p/main.mp4" },
      },
      {
        roomId: "breakout-1",
        roomType: "breakout",
        artifactPaths: { complete_trx_0: "p/b1.csv" },
      },
    ],
  });
  mockStorage();
  const res = fakeRes();
  downloadTranscripts(fakeReq({ body: { eventPath: EVENT_PATH } }), res as never);
  await res.settled;
  expect(res.statusCode).toBe(200);
  expect(res.body).toEqual({
    transcripts: [
      { roomId: "main", roomType: "main", url: "signed:p/main.csv" },
      { roomId: "breakout-1", roomType: "breakout", url: "signed:p/b1.csv" },
    ],
  });
});

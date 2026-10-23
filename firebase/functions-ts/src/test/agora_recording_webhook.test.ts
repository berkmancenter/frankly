import { afterAll, beforeEach, expect, jest, test } from "@jest/globals";
import * as crypto from "crypto";
import { EventEmitter } from "events";
import type { Request } from "firebase-functions/v2/https";

jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    auth: jest.fn(),
    firestore: Object.assign(jest.fn(), {
      FieldValue: { serverTimestamp: jest.fn(() => "SERVER_TIMESTAMP") },
    }),
    storage: jest.fn(),
    __esModule: true,
    default: actual,
  };
});

jest.mock("https", () => ({ request: jest.fn() }));

import * as admin from "firebase-admin";
import * as https from "https";
import { agoraRecordingWebhook } from "../agora_recording_webhook";

function fakeReq(overrides: Partial<Request> = {}): Request {
  return {
    method: "POST",
    headers: {},
    body: {},
    ...overrides,
  } as unknown as Request;
}

function fakeRes() {
  return {
    statusCode: 0,
    body: undefined as unknown,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    send(body: unknown) {
      this.body = body;
      return this;
    },
  };
}

function withBody(body: Record<string, unknown>, headers: Record<string, string> = {}) {
  const raw = Buffer.from(JSON.stringify(body));
  return fakeReq({ body, headers, rawBody: raw } as never);
}

function signedReq(body: Record<string, unknown>, secret: string) {
  const raw = Buffer.from(JSON.stringify(body));
  const signature = crypto.createHmac("sha1", secret).update(raw).digest("hex");
  return fakeReq({
    body,
    headers: { "agora-signature": signature },
    rawBody: raw,
  } as never);
}

function mockHttpsSuccess(responseBody = "{}") {
  (https.request as unknown as jest.Mock).mockImplementation((...args: unknown[]) => {
    const callback = args[2] as (res: unknown) => void;
    const res = new EventEmitter() as EventEmitter & { statusCode: number };
    res.statusCode = 200;
    const req = new EventEmitter() as EventEmitter & { end: jest.Mock };
    req.end = jest.fn(() => {
      callback(res);
      res.emit("data", Buffer.from(responseBody));
      res.emit("end");
    });
    return req;
  });
}

const originalEnv = process.env;

beforeEach(() => {
  jest.clearAllMocks();
  process.env = { ...originalEnv };
  delete process.env.AGORA_WEBHOOK_SECRET;
});

afterAll(() => {
  process.env = originalEnv;
});

test("rejects non-POST methods", async () => {
  const res = fakeRes();
  await agoraRecordingWebhook(fakeReq({ method: "GET" }), res as never);
  expect(res.statusCode).toBe(405);
});

test("skips signature verification when no secret is configured", async () => {
  const res = fakeRes();
  await agoraRecordingWebhook(withBody({ eventType: 1 }), res as never);
  expect(res.statusCode).toBe(200);
});

test("rejects requests with an invalid signature when a secret is configured", async () => {
  process.env.AGORA_WEBHOOK_SECRET = "s3cret";
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 1 }, { "agora-signature": "deadbeef" }),
    res as never,
  );
  expect(res.statusCode).toBe(401);
});

test("accepts requests with a valid HMAC signature", async () => {
  process.env.AGORA_WEBHOOK_SECRET = "s3cret";
  const res = fakeRes();
  await agoraRecordingWebhook(signedReq({ eventType: 1 }, "s3cret"), res as never);
  expect(res.statusCode).toBe(200);
});

test("acknowledges and ignores event types other than recorder_leave (41)", async () => {
  (admin.firestore as unknown as jest.Mock).mockReturnValue({});
  const res = fakeRes();
  await agoraRecordingWebhook(withBody({ eventType: 1, payload: {} }), res as never);
  expect(res.statusCode).toBe(200);
  expect(admin.firestore).not.toHaveBeenCalled();
});

test("acknowledges recorder_leave with no cname without querying Firestore", async () => {
  (admin.firestore as unknown as jest.Mock).mockReturnValue({});
  const res = fakeRes();
  await agoraRecordingWebhook(withBody({ eventType: 41, payload: {} }), res as never);
  expect(res.statusCode).toBe(200);
  expect(admin.firestore).not.toHaveBeenCalled();
});

function mockFirestoreWithSession(session: Record<string, unknown> | null) {
  const update = jest.fn().mockImplementation(async () => (undefined));
  const sessionDoc = { id: "sess1", data: () => session, ref: { update } };
  (admin.firestore as unknown as jest.Mock).mockReturnValue({
    collection: () => ({
      where: () => ({
        where: () => ({
          orderBy: () => ({
            limit: () => ({
              get: async () => ({
                empty: session === null,
                docs: session === null ? [] : [sessionDoc],
              }),
            }),
          }),
        }),
      }),
    }),
  });
  return update;
}

test("does nothing when no active session matches the channel", async () => {
  mockFirestoreWithSession(null);
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 41, payload: { cname: "room1", sid: "sid1" } }),
    res as never,
  );
  expect(res.statusCode).toBe(200);
});

test("marks the matching session stopped on recorder_leave", async () => {
  const update = mockFirestoreWithSession({ roomId: "room1" });
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 41, payload: { cname: "room1", sid: "sid1" } }),
    res as never,
  );
  expect(res.statusCode).toBe(200);
  expect(update).toHaveBeenCalledWith(
    expect.objectContaining({ status: "stopped", stoppedByWebhook: true }),
  );
});

test("stops the STT agent before marking the session stopped when one is running", async () => {
  mockHttpsSuccess();
  const update = mockFirestoreWithSession({ roomId: "room1", agoraRttAgentId: "agent1" });
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 41, payload: { cname: "room1", sid: "sid1" } }),
    res as never,
  );
  expect(https.request).toHaveBeenCalled();
  expect(update).toHaveBeenCalledWith(
    expect.objectContaining({ status: "stopped" }),
  );
  expect(res.statusCode).toBe(200);
});

test("still marks the session stopped if stopping the STT agent fails", async () => {
  (https.request as unknown as jest.Mock).mockImplementation(() => {
    const req = new EventEmitter() as EventEmitter & { end: jest.Mock };
    req.end = jest.fn(() => {
      req.emit("error", new Error("stt down"));
    });
    return req;
  });
  const update = mockFirestoreWithSession({ roomId: "room1", agoraRttAgentId: "agent1" });
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 41, payload: { cname: "room1", sid: "sid1" } }),
    res as never,
  );
  expect(update).toHaveBeenCalledWith(
    expect.objectContaining({ status: "stopped" }),
  );
  expect(res.statusCode).toBe(200);
});

test("returns 200 even when updating Firestore fails", async () => {
  const sessionDoc = {
    id: "sess1",
    data: () => ({ roomId: "room1" }),
    ref: { update: jest.fn().mockImplementation(async () => { throw new Error("firestore down"); }) },
  };
  (admin.firestore as unknown as jest.Mock).mockReturnValue({
    collection: () => ({
      where: () => ({
        where: () => ({
          orderBy: () => ({
            limit: () => ({
              get: async () => ({ empty: false, docs: [sessionDoc] }),
            }),
          }),
        }),
      }),
    }),
  });
  const res = fakeRes();
  await agoraRecordingWebhook(
    withBody({ eventType: 41, payload: { cname: "room1", sid: "sid1" } }),
    res as never,
  );
  expect(res.statusCode).toBe(200);
});

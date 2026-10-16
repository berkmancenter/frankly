import { expect, jest, test } from "@jest/globals";

const TEMPLATE =
  "<html><head></head><body><script nonce=\"__SCRIPT_NONCE__\"></script>" +
  "v=__VERSION__ g=__GOOGLE_ID__</body></html>";

jest.mock("fs", () => ({
  ...(jest.requireActual("fs") as object),
  readFileSync: jest.fn(() => TEMPLATE),
}));

process.env.APP_GOOGLE_ID = "google-123";
process.env.APP_VERSION = "1.2.3";

// Imported after the env vars and fs mock are set up, since both config
// values and the template are read once at module load.
import type { Request } from "firebase-functions/v2/https";
import { ServeIndex } from "../serve_index";

function fakeReq(method: string): Request {
  return { method } as unknown as Request;
}

function fakeRes() {
  return {
    statusCode: 0,
    headers: {} as Record<string, string>,
    body: undefined as unknown,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    send(body: unknown) {
      this.body = body;
      return this;
    },
    set(key: string, value: string) {
      this.headers[key] = value;
      return this;
    },
  };
}

test("rejects non-GET/HEAD methods", () => {
  const res = fakeRes();
  ServeIndex(fakeReq("POST"), res as never);
  expect(res.statusCode).toBe(405);
});

test("serves the template with substituted config values and a nonce-matched CSP", () => {
  const res = fakeRes();
  ServeIndex(fakeReq("GET"), res as never);

  expect(res.statusCode).toBe(0); // status() never called on the success path
  expect(res.body).toContain("v=1.2.3 g=google-123");
  expect(res.headers["Cache-Control"]).toBe("no-store");
  expect(res.headers["Content-Type"]).toBe("text/html; charset=utf-8");

  const nonceMatch = (res.body as string).match(/nonce="([^"]+)"/);
  expect(nonceMatch).not.toBeNull();
  const nonce = nonceMatch![1];
  expect(res.headers["Content-Security-Policy"]).toContain(`'nonce-${nonce}'`);
});

test("issues a fresh nonce on every request", () => {
  const res1 = fakeRes();
  const res2 = fakeRes();
  ServeIndex(fakeReq("GET"), res1 as never);
  ServeIndex(fakeReq("GET"), res2 as never);

  const nonce1 = (res1.body as string).match(/nonce="([^"]+)"/)![1];
  const nonce2 = (res2.body as string).match(/nonce="([^"]+)"/)![1];
  expect(nonce1).not.toBe(nonce2);
});

test("allows HEAD requests", () => {
  const res = fakeRes();
  ServeIndex(fakeReq("HEAD"), res as never);
  expect(res.statusCode).toBe(0);
  expect(res.body).toContain("v=1.2.3");
});

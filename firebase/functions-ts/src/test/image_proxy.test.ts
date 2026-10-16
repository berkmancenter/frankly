import { afterEach, expect, jest, test } from "@jest/globals";
import { PassThrough } from "stream";
import type { Request } from "firebase-functions/v2/https";

import { imageProxy } from "../image_proxy";

class FakeResponse extends PassThrough {
  statusCode = 200;
  headers: Record<string, string> = {};
  body: unknown;

  status(code: number) {
    this.statusCode = code;
    return this;
  }

  send(body: unknown) {
    this.body = body;
    this.end();
    return this;
  }

  setHeader(key: string, value: string) {
    this.headers[key] = value;
  }

  getHeader(key: string) {
    return this.headers[key];
  }
}

function fakeReq(query: Record<string, unknown> = {}): Request {
  return {
    method: "GET",
    headers: {},
    query,
    originalUrl: "/imageProxy",
  } as unknown as Request;
}

afterEach(() => {
  (global as unknown as { fetch?: unknown }).fetch = undefined;
});

test("missing url query param returns 400", async () => {
  const res = new FakeResponse();
  await imageProxy(fakeReq({}), res as never);
  expect(res.statusCode).toBe(400);
  expect(res.body).toBe("URL parameter is required");
});

test("streams the fetched body through and forwards content-type", async () => {
  const webBody = new ReadableStream({
    start(controller) {
      controller.enqueue(new TextEncoder().encode("hello"));
      controller.close();
    },
  });
  (global as unknown as { fetch: unknown }).fetch = jest.fn(async () => ({
    headers: new Map([["content-type", "image/png"]]),
    body: webBody,
  }));

  const res = new FakeResponse();
  const chunks: Buffer[] = [];
  res.on("data", (chunk: Buffer) => chunks.push(chunk));
  const finished = new Promise<void>((resolve) => res.on("finish", resolve));

  await imageProxy(fakeReq({ url: "http://example.com/a.png" }), res as never);
  await finished;

  expect(res.headers["Content-Type"]).toBe("image/png");
  expect(Buffer.concat(chunks).toString()).toBe("hello");
});

test("returns 502 when the fetch response has no body", async () => {
  (global as unknown as { fetch: unknown }).fetch = jest.fn(async () => ({
    headers: new Map(),
    body: null,
  }));

  const res = new FakeResponse();
  await imageProxy(fakeReq({ url: "http://example.com/a.png" }), res as never);
  expect(res.statusCode).toBe(502);
});

test("returns 500 when fetch throws", async () => {
  (global as unknown as { fetch: unknown }).fetch = jest.fn(async () => {
    throw new Error("network down");
  });

  const res = new FakeResponse();
  await imageProxy(fakeReq({ url: "http://example.com/a.png" }), res as never);
  expect(res.statusCode).toBe(500);
});

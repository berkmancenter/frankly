import type { Request } from "firebase-functions/v2/https";

export function fakeReq(overrides: Partial<Request> = {}): Request {
  return {
    method: "POST",
    headers: { authorization: "Bearer tok" },
    body: {},
    ...overrides,
  } as unknown as Request;
}

// `cors(req, res, cb)` does not propagate its async callback's promise, so
// awaiting a manually-cors-wrapped handler's call doesn't wait for the
// response to actually be sent - `settled` resolves when `.json()` is
// called (every code path in these handlers finalizes via it).
export function fakeCorsRes() {
  let resolveSettled!: () => void;
  const settled = new Promise<void>((resolve) => {
    resolveSettled = resolve;
  });
  return {
    settled,
    statusCode: 0,
    body: undefined as unknown,
    headers: {} as Record<string, string>,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(body: unknown) {
      this.body = body;
      resolveSettled();
      return this;
    },
    setHeader(key: string, value: string) {
      this.headers[key] = value;
    },
    getHeader(key: string) {
      return this.headers[key];
    },
  };
}

import { vi } from "vitest";
import type { Api } from "@/api/api";

type Methods<T> = {
  [K in keyof T]?: T[K] extends (...args: infer A) => infer R
    ? (...args: A) => R
    : Methods<T[K]>;
};

/**
 * An `Api` where every method rejects with "not stubbed" unless the test supplies it, so a
 * component that touches data the test didn't set up fails loudly. Methods are `vi.fn` spies
 * (`api.threads.vote` etc.) so tests can assert calls: `expect(api.threads.vote).toHaveBeenCalled…`.
 */
export function createFakeApi(overrides: Methods<Api> = {}): Api {
  const wrap = (path: string[], source: unknown): unknown =>
    new Proxy(
      {},
      {
        get(_target, key: string) {
          const node = (source as Record<string, unknown> | undefined)?.[key];
          const here = [...path, key];
          if (typeof node === "function") return cached(here, node as never);
          if (node && typeof node === "object") return wrap(here, node);
          // A namespace (`api.threads`) is a proxy of its own; a leaf is a rejecting spy.
          return path.length === 0
            ? wrap(here, undefined)
            : cached(here, () => Promise.reject(new Error(`api.${here.join(".")} not stubbed`)));
        },
      },
    );

  const spies = new Map<string, ReturnType<typeof vi.fn>>();
  const cached = (here: string[], fn: (...args: never[]) => unknown) => {
    const id = here.join(".");
    let spy = spies.get(id);
    if (!spy) spies.set(id, (spy = vi.fn(fn)));
    return spy;
  };

  return wrap([], overrides) as Api;
}

// @vitest-environment jsdom
import { renderHook } from "@testing-library/react";
import type { ReactNode } from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { BackendProvider, useApi } from "@/api/ApiProvider";
import type { Backend } from "@/api/backend";

const mocks = vi.hoisted(() => ({ createFirebaseBackend: vi.fn() }));
vi.mock("@/api/firebaseBackend", () => mocks);

const backendWith = (): Backend => ({ api: createFakeApi() });

describe("BackendProvider", () => {
  beforeEach(() => {
    mocks.createFirebaseBackend.mockReset();
  });

  afterEach(() => {
    vi.unstubAllEnvs();
    delete (window as { __frankly?: unknown }).__frankly;
  });

  it("hands the injected backend's api to useApi, without touching Firebase", () => {
    const backend = backendWith();
    const { result } = renderHook(() => useApi(), {
      wrapper: ({ children }: { children: ReactNode }) => (
        <BackendProvider backend={backend}>{children}</BackendProvider>
      ),
    });
    expect(result.current).toBe(backend.api);
    expect(mocks.createFirebaseBackend).not.toHaveBeenCalled();
  });

  it("creates the Firebase backend once when none is injected", () => {
    const backend = backendWith();
    mocks.createFirebaseBackend.mockReturnValue(backend);
    const { result, rerender } = renderHook(() => useApi(), {
      wrapper: ({ children }: { children: ReactNode }) => <BackendProvider>{children}</BackendProvider>,
    });
    expect(result.current).toBe(backend.api);
    rerender();
    rerender();
    expect(result.current).toBe(backend.api);
    expect(mocks.createFirebaseBackend).toHaveBeenCalledTimes(1);
  });

  it("exposes the backend on window for debugging during development only", () => {
    vi.stubEnv("DEV", true);
    const dev = backendWith();
    renderHook(() => useApi(), {
      wrapper: ({ children }: { children: ReactNode }) => <BackendProvider backend={dev}>{children}</BackendProvider>,
    });
    expect((window as { __frankly?: unknown }).__frankly).toBe(dev);

    delete (window as { __frankly?: unknown }).__frankly;
    vi.stubEnv("DEV", false);
    renderHook(() => useApi(), {
      wrapper: ({ children }: { children: ReactNode }) => (
        <BackendProvider backend={backendWith()}>{children}</BackendProvider>
      ),
    });
    expect((window as { __frankly?: unknown }).__frankly).toBeUndefined();
  });
});

describe("useApi", () => {
  it("fails loudly outside a BackendProvider", () => {
    // React logs the error it rethrows; keep the output clean.
    vi.spyOn(console, "error").mockImplementation(() => {});
    expect(() => renderHook(() => useApi())).toThrow("BackendProvider is missing from the tree");
    vi.restoreAllMocks();
  });
});

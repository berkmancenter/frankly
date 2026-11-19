// @vitest-environment jsdom
import { renderHook } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { appSize } from "@/theme/tokens";
import { useIsMobile, useShowBottomNav } from "@/utils/useResponsive";

/** Make every media query report `matches`, recording the queries that were asked. */
function stubMatchMedia(matches: boolean) {
  const queries: string[] = [];
  vi.mocked(window.matchMedia).mockImplementation((query: string) => {
    queries.push(query);
    return {
      matches,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      dispatchEvent: vi.fn(),
    };
  });
  return queries;
}

describe("useResponsive", () => {
  afterEach(() => stubMatchMedia(false));

  it("is mobile when the viewport is below the breakpoint", () => {
    const queries = stubMatchMedia(true);
    expect(renderHook(() => useIsMobile()).result.current).toBe(true);
    expect(queries[0]).toContain("max-width");
    expect(queries[0]).toContain(String(appSize.mobileBreakpoint - 0.02));
  });

  it("is not mobile on a wide viewport", () => {
    stubMatchMedia(false);
    expect(renderHook(() => useIsMobile()).result.current).toBe(false);
  });

  it("shows the bottom nav exactly when mobile", () => {
    stubMatchMedia(true);
    expect(renderHook(() => useShowBottomNav()).result.current).toBe(true);
    stubMatchMedia(false);
    expect(renderHook(() => useShowBottomNav()).result.current).toBe(false);
  });
});

// @vitest-environment jsdom
import { renderHook } from "@testing-library/react";
import type { ReactNode } from "react";
import { describe, expect, it } from "vitest";
import { ClockContext, systemClock, useClock } from "@/utils/clock";

describe("useClock", () => {
  it("defaults to the system clock", () => {
    const { result } = renderHook(() => useClock());
    expect(result.current).toBe(systemClock);
    const before = Date.now();
    const now = result.current.now().getTime();
    expect(now).toBeGreaterThanOrEqual(before);
    expect(now).toBeLessThanOrEqual(Date.now());
  });

  it("returns an injected clock", () => {
    const fixed = new Date("2030-01-01T00:00:00Z");
    const wrapper = ({ children }: { children: ReactNode }) => (
      <ClockContext.Provider value={{ now: () => fixed }}>{children}</ClockContext.Provider>
    );
    const { result } = renderHook(() => useClock(), { wrapper });
    expect(result.current.now()).toBe(fixed);
  });
});

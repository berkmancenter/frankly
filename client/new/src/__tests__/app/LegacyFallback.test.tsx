// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { LegacyFallback } from "@/app/LegacyFallback";

const STORAGE_KEY = "frankly:legacy-handoff";

describe("LegacyFallback", () => {
  const replace = vi.fn();

  beforeEach(() => {
    sessionStorage.clear();
    replace.mockClear();
    // jsdom cannot navigate; capture the hand-off instead.
    vi.stubGlobal("location", { ...window.location, replace });
    vi.spyOn(window.history, "replaceState");
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it("hands the URL off to the legacy app with a full page load", () => {
    renderWithProviders(<LegacyFallback />, { route: "/settings?initialSection=events#top" });
    expect(replace).toHaveBeenCalledTimes(1);
    expect(replace).toHaveBeenCalledWith("/settings?initialSection=events#top");
  });

  it("shows a spinner while the hand-off happens", () => {
    renderWithProviders(<LegacyFallback />, { route: "/settings" });
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.queryByText("This URL was not found")).not.toBeInTheDocument();
  });

  it("gives the history entry a different URL first so Back reloads the React page", () => {
    window.history.replaceState({ idx: 3 }, "");
    vi.mocked(window.history.replaceState).mockClear();
    renderWithProviders(<LegacyFallback />, { route: "/settings?x=1" });
    // The entry's own history state is preserved.
    expect(window.history.replaceState).toHaveBeenCalledWith({ idx: 3 }, "", "/settings?__handoff=1");
    expect(vi.mocked(window.history.replaceState).mock.invocationCallOrder[0]).toBeLessThan(
      replace.mock.invocationCallOrder[0]!,
    );
  });

  it("remembers what it handed off", () => {
    renderWithProviders(<LegacyFallback />, { route: "/settings" });
    const saved = JSON.parse(sessionStorage.getItem(STORAGE_KEY)!) as { target: string; at: number };
    expect(saved.target).toBe("/settings");
    expect(saved.at).toBeGreaterThan(Date.now() - 5000);
  });

  it("shows 'not found' instead of looping when the same URL came straight back", () => {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ target: "/settings", at: Date.now() }));
    renderWithProviders(<LegacyFallback />, { route: "/settings" });
    expect(screen.getByText("This URL was not found")).toBeInTheDocument();
    expect(replace).not.toHaveBeenCalled();
  });

  it("hands off again when the previous hand-off was a different URL or long ago", () => {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ target: "/newspace", at: Date.now() }));
    const first = renderWithProviders(<LegacyFallback />, { route: "/settings" });
    expect(replace).toHaveBeenCalledTimes(1);
    first.unmount();

    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ target: "/settings", at: Date.now() - 60_000 }));
    renderWithProviders(<LegacyFallback />, { route: "/settings" });
    expect(replace).toHaveBeenCalledTimes(2);
  });

  it("still hands off when session storage is unavailable", () => {
    vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
      throw new Error("blocked");
    });
    vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
      throw new Error("blocked");
    });
    renderWithProviders(<LegacyFallback />, { route: "/settings" });
    expect(replace).toHaveBeenCalledWith("/settings");
  });
});

import "@testing-library/jest-dom/vitest";
import { i18n } from "@lingui/core";
import { cleanup } from "@testing-library/react";
import { afterEach, vi } from "vitest";

// Lingui's `t`/`msg` macros resolve against this global singleton; non-component code (e.g.
// src/api/*) calls them outside any provider, so every test needs a locale active up front.
i18n.activate("en");

// Tests opt in to jsdom with a `// @vitest-environment jsdom` docblock; in node there is nothing to set up.
if (typeof window !== "undefined") {
  afterEach(() => cleanup());

  // jsdom has no matchMedia; `useIsMobile` reads it. Desktop by default (tests call
  // `setViewport("mobile")` from `renderWithProviders` to flip it).
  if (!window.matchMedia) {
    window.matchMedia = vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));
  }
  window.scrollTo = vi.fn();
}

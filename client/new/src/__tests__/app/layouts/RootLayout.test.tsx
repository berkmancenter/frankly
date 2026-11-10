// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { Route, Routes } from "react-router";
import { me } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { RootLayout } from "@/app/layouts/RootLayout";

const page = (
  <Routes>
    <Route element={<RootLayout />}>
      <Route index element={<p>Child page</p>} />
    </Route>
  </Routes>
);

describe("RootLayout", () => {
  beforeEach(() => {
    // RootLayout logs the session error; keep the test output clean.
    vi.spyOn(console, "log").mockImplementation(() => {});
  });
  afterEach(() => vi.restoreAllMocks());

  it("shows a spinner and none of the page while the session loads", () => {
    renderWithProviders(page, { api: { me: { get: () => new Promise(() => {}) } } });
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.queryByText("Child page")).not.toBeInTheDocument();
  });

  it("renders the matched child route once the session has loaded", async () => {
    renderWithProviders(page, { api: { me: { get: async () => me() } } });
    expect(await screen.findByText("Child page")).toBeInTheDocument();
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
  });

  it("explains that the session could not be loaded, instead of rendering the page", async () => {
    renderWithProviders(page, {
      api: {
        me: {
          get: async () => {
            throw new Error("unauthenticated");
          },
        },
      },
    });
    expect(await screen.findByText(/Could not load your session\./)).toBeInTheDocument();
    expect(screen.queryByText("Child page")).not.toBeInTheDocument();
  });

  it("does not print 'false' after the message outside development", async () => {
    renderWithProviders(page, {
      api: {
        me: {
          get: async () => {
            throw new Error("unauthenticated");
          },
        },
      },
    });
    const message = await screen.findByText(/Could not load your session\./);
    expect(message.textContent).toBe("Could not load your session.");
  });
});

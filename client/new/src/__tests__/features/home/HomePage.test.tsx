// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { act } from "react";
import { describe, expect, it } from "vitest";
import { useLocation } from "react-router";
import { anonymousSession, authUser, createFakeAuth } from "@/__tests__/support/fakeAuth";
import { community } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { HomePage } from "@/features/home/HomePage";

function Location() {
  const { pathname } = useLocation();
  return <div data-testid="location">{pathname}</div>;
}

const page = (
  <>
    <HomePage />
    <Location />
  </>
);

const lab = community({ id: "c1", displayId: "civic-lab", name: "Civic Lab", tagLine: "Talk it through" });
const book = community({ id: "c2", displayId: "book-club", name: "Book Club", tagLine: undefined });

describe("HomePage", () => {
  it("shows the sign-up form to a visitor without an account, and asks for nothing", () => {
    const { api } = renderWithProviders(page, { auth: anonymousSession() });
    expect(screen.getByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
    expect(api.communities.listMine).not.toHaveBeenCalled();
  });

  it("lists a signed-in user's communities, with a placeholder note", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [lab, book] } } });
    expect(await screen.findByRole("heading", { name: "My Communities" })).toBeInTheDocument();
    expect(screen.getByText(/Placeholder/)).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Civic Lab/ })).toHaveAttribute("href", "/space/civic-lab");
    expect(screen.getByRole("link", { name: /Book Club/ })).toHaveAttribute("href", "/space/book-club");
    expect(screen.getByText("Talk it through")).toBeInTheDocument();
  });

  it("opens a community from the list", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [lab] } } });
    await userEvent.click(await screen.findByRole("link", { name: /Civic Lab/ }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab");
  });

  it("says so when a user has no communities, without redirecting", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [] } } });
    expect(await screen.findByText("You don't belong to any communities")).toBeInTheDocument();
    expect(screen.getByTestId("location")).not.toHaveTextContent("/newspace");
  });

  it("explains when the communities cannot be loaded", async () => {
    renderWithProviders(page, {
      api: { communities: { listMine: async () => { throw new Error("offline"); } } },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading communities.");
  });

  it("switches from the form to the list when the visitor signs in", async () => {
    const auth = createFakeAuth(anonymousSession());
    renderWithProviders(page, { auth, api: { communities: { listMine: async () => [lab] } } });
    expect(screen.getByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
    act(() => auth.setSession({ user: authUser() }));
    expect(await screen.findByRole("heading", { name: "My Communities" })).toBeInTheDocument();
  });
});

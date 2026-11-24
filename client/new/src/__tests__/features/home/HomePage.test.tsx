// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { act } from "react";
import { describe, expect, it, vi } from "vitest";
import { useLocation } from "react-router";
import { anonymousSession, authUser, createFakeAuth } from "@/__tests__/support/fakeAuth";
import { community, event } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { HomePage } from "@/features/home/HomePage";
import { isLocalhost } from "@/utils/appInfo";

vi.mock("@/utils/appInfo", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/appInfo")>()),
  isLocalhost: vi.fn(() => false),
}));

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

  it("shows a signed-in user's communities as a carousel", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [lab, book] } } });
    expect(await screen.findByRole("heading", { name: "My Communities" })).toBeInTheDocument();
    expect(await screen.findByRole("link", { name: /Civic Lab/ })).toHaveAttribute("href", "/space/civic-lab");
    expect(screen.getByRole("link", { name: /Book Club/ })).toHaveAttribute("href", "/space/book-club");
    expect(screen.getByText("Talk it through")).toBeInTheDocument();
  });

  it("opens a community from the list", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [lab] } } });
    await userEvent.click(await screen.findByRole("link", { name: /Civic Lab/ }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab");
  });

  it("says so when a user has no communities, without leaving the page", async () => {
    renderWithProviders(page, { api: { communities: { listMine: async () => [] } } });
    expect(await screen.findByText("You haven't joined any communities.")).toBeInTheDocument();
    expect(screen.getByTestId("location")).toHaveTextContent("/");
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

  it("offers to start a community, even to someone with none, and opens the dialog", async () => {
    vi.mocked(isLocalhost).mockReturnValueOnce(true).mockReturnValue(true);
    renderWithProviders(page, { api: { communities: { listMine: async () => [] } } });
    expect(await screen.findByText("You haven't joined any communities.")).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Start a community" }));
    expect(await screen.findByRole("heading", { name: "Create a community" })).toBeInTheDocument();
    vi.mocked(isLocalhost).mockReturnValue(false);
  });
});

describe("HomePage upcoming events", () => {
  const eventsApi = (...events: ReturnType<typeof event>[]) => ({
    communities: { listMine: async () => [lab] },
    events: { listMine: async () => events },
  });

  it("lists the user's upcoming events below their communities, soonest first", async () => {
    renderWithProviders(page, {
      api: eventsApi(
        event({ id: "later", title: "Later chat", scheduledTime: "2031-02-01T18:00:00.000Z" }),
        event({ id: "soon", title: "Sooner chat", scheduledTime: "2031-01-01T18:00:00.000Z" }),
        event({ id: "old", title: "Past chat", scheduledTime: "2020-01-01T18:00:00.000Z" }),
        event({ id: "gone", title: "Cancelled chat", status: "canceled", scheduledTime: "2031-03-01T18:00:00.000Z" }),
      ),
    });
    expect(await screen.findByRole("heading", { name: "My Upcoming Events" })).toBeInTheDocument();
    const titles = (await screen.findAllByText(/ chat$/)).map((el) => el.textContent);
    expect(titles).toEqual(["Sooner chat", "Later chat"]);
  });

  it("shows only the first twenty", async () => {
    const many = Array.from({ length: 25 }, (_, i) =>
      event({ id: `e${i}`, title: `Chat ${i}`, scheduledTime: new Date(Date.UTC(2031, 0, 1 + i)).toISOString() }),
    );
    renderWithProviders(page, { api: eventsApi(...many) });
    await screen.findByText("Chat 0");
    expect(screen.getByText("Chat 19")).toBeInTheDocument();
    expect(screen.queryByText("Chat 20")).not.toBeInTheDocument();
  });

  it("says so when there are no upcoming events", async () => {
    renderWithProviders(page, {
      api: eventsApi(event({ scheduledTime: "2020-01-01T18:00:00.000Z" })),
    });
    expect(await screen.findByText("You haven't registered for any upcoming events.")).toBeInTheDocument();
  });

  it("explains when the events cannot be loaded, leaving the communities alone", async () => {
    renderWithProviders(page, {
      api: {
        communities: { listMine: async () => [lab] },
        events: { listMine: async () => { throw new Error("offline"); } },
      },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading your events.");
    expect(await screen.findByRole("link", { name: /Civic Lab/ })).toBeInTheDocument();
  });
});

describe("HomePage title", () => {
  it('names the tab "Frankly - Home"', () => {
    renderWithProviders(<HomePage />, { auth: anonymousSession() });
    expect(document.title).toBe("Frankly - Home");
  });
});

// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiError } from "@/api/api";
import { anonymousSession } from "@/__tests__/support/fakeAuth";
import { me, user as userFixture } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CreateCommunityButton } from "@/features/community/CreateCommunity";
import { isLocalhost } from "@/utils/appInfo";

// jsdom is served from localhost, which would offer the button to everyone.
vi.mock("@/utils/appInfo", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/appInfo")>()),
  isLocalhost: vi.fn(() => false),
}));

function Location() {
  return <div data-testid="location">{useLocation().pathname}</div>;
}

const owner = { me: { get: async () => me({ user: userFixture({ isAppOwner: true }) }) } };
const created = (displayId = "civic-lab") => ({
  create: vi.fn(async () => ({ communityId: "c1", displayId })),
});

function renderButton(options: Parameters<typeof renderWithProviders>[1] = {}, onDone = vi.fn()) {
  return {
    onDone,
    ...renderWithProviders(
      <>
        <CreateCommunityButton onDone={onDone} />
        <Location />
      </>,
      options,
    ),
  };
}

async function openDialog() {
  await userEvent.click(await screen.findByRole("button", { name: "Start a community" }));
  return screen.findByRole("heading", { name: "Create a community" });
}

afterEach(() => vi.mocked(isLocalhost).mockReturnValue(false));

describe("CreateCommunityButton", () => {
  it("is offered to app owners", async () => {
    renderButton({ api: owner });
    expect(await screen.findByRole("button", { name: "Start a community" })).toBeInTheDocument();
  });

  it("is offered to everyone on localhost", async () => {
    vi.mocked(isLocalhost).mockReturnValue(true);
    renderButton({ api: { me: { get: async () => me() } } });
    expect(await screen.findByRole("button", { name: "Start a community" })).toBeInTheDocument();
  });

  it("is hidden from everyone else", async () => {
    renderButton({ api: { me: { get: async () => me() } } });
    await waitFor(() => expect(screen.queryByRole("button", { name: "Start a community" })).not.toBeInTheDocument());
  });

  it("can drop its label on narrow screens", async () => {
    renderWithProviders(<CreateCommunityButton showLabel={false} />, { api: owner });
    await screen.findByRole("button", { name: "Start a community" });
    expect(screen.queryByText("Start a community")).not.toBeInTheDocument();
  });

  it("asks a visitor without an account to sign in before the dialog opens", async () => {
    vi.mocked(isLocalhost).mockReturnValue(true);
    renderButton({ auth: anonymousSession(), api: { me: { get: async () => me() } } });
    await userEvent.click(await screen.findByRole("button", { name: "Start a community" }));
    expect(await screen.findByRole("heading", { name: "New to Frankly?" })).toBeInTheDocument();
    expect(screen.queryByRole("heading", { name: "Create a community" })).not.toBeInTheDocument();
  });
});

describe("create community dialog", () => {
  it("suggests the URL from the name as it is typed", async () => {
    renderButton({ api: owner });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic Lab");
    expect(screen.getByLabelText("Community URL")).toHaveValue("civic-lab");
    expect(screen.getByText(`${window.location.origin}/space/civic-lab`)).toBeInTheDocument();
  });

  it("stops following the name once the URL is edited by hand", async () => {
    renderButton({ api: owner });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic");
    await userEvent.type(screen.getByLabelText("Community URL"), "-x");
    await userEvent.type(screen.getByLabelText("Community Name"), " Lab");
    expect(screen.getByLabelText("Community URL")).toHaveValue("civic-x");
  });

  it("only lets lowercase letters, digits, dashes and plus into the URL", async () => {
    renderButton({ api: owner });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community URL"), "My_URL 1+");
    expect(screen.getByLabelText("Community URL")).toHaveValue("myurl1+");
  });

  it("does not create anything without a name and URL", async () => {
    const { api } = renderButton({ api: { ...owner, communities: created() } });
    await openDialog();
    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    expect(await screen.findByText("Please enter a valid name")).toBeInTheDocument();
    expect(screen.getByText("Please enter a valid community URL")).toBeInTheDocument();
    expect(api.communities.create).not.toHaveBeenCalled();
  });

  it("creates a public community, then congratulates and opens it", async () => {
    const { api, onDone } = renderButton({ api: { ...owner, communities: created() } });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic Lab");
    await userEvent.click(screen.getByRole("button", { name: "Next" }));

    expect(await screen.findByRole("heading", { name: "Congratulations!" })).toBeInTheDocument();
    expect(api.communities.create).toHaveBeenCalledWith({
      name: "Civic Lab",
      displayId: "civic-lab",
      isPublic: true,
    });
    expect(screen.getByText("Civic Lab")).toBeInTheDocument();

    await userEvent.click(screen.getByRole("button", { name: "Finish" }));
    expect(screen.getByTestId("location")).toHaveTextContent("/space/civic-lab");
    expect(onDone).toHaveBeenCalledTimes(1);
    await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
  });

  it("creates a private community when asked", async () => {
    const { api } = renderButton({ api: { ...owner, communities: created() } });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic Lab");
    await userEvent.click(screen.getByRole("checkbox", { name: "Make this space private" }));
    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    await waitFor(() => expect(api.communities.create).toHaveBeenCalled());
    expect(api.communities.create).toHaveBeenCalledWith(expect.objectContaining({ isPublic: false }));
  });

  it("shows the server's reason when it refuses, and stays on the form", async () => {
    renderButton({
      api: {
        ...owner,
        communities: {
          create: async () => {
            throw new ApiError("invalid", "The URL display name civic-lab is already taken.");
          },
        },
      },
    });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic Lab");
    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("already taken");
    expect(screen.getByLabelText("Community Name")).toBeInTheDocument();
  });

  it("shows a generic message for any other failure", async () => {
    renderButton({
      api: {
        ...owner,
        communities: {
          create: async () => {
            throw new Error("offline");
          },
        },
      },
    });
    await openDialog();
    await userEvent.type(screen.getByLabelText("Community Name"), "Civic Lab");
    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong. Please try again.");
  });

  it("can be closed without creating anything", async () => {
    const { api, onDone } = renderButton({ api: { ...owner, communities: created() } });
    await openDialog();
    await userEvent.click(screen.getByRole("button", { name: "Close" }));
    expect(onDone).toHaveBeenCalledTimes(1);
    await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
    expect(api.communities.create).not.toHaveBeenCalled();
  });
});

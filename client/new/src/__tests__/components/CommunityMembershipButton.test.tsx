// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import type { Community } from "@/api/types";
import { community, me, membership } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CommunityMembershipButton } from "@/components/CommunityMembershipButton";

const needsApproval = (): Community =>
  community({ settings: { ...community().settings, requireApprovalToJoin: true } });

const withMemberships = (...memberships: ReturnType<typeof membership>[]) => ({
  me: { get: async () => me({ memberships }) },
});

describe("CommunityMembershipButton", () => {
  it("offers Follow on an open community and follows it when pressed", async () => {
    const user = userEvent.setup();
    const { api } = renderWithProviders(<CommunityMembershipButton community={community()} />, {
      api: { ...withMemberships(), communities: { follow: async () => membership() } },
    });

    const button = screen.getByRole("button", { name: "Follow community" });
    expect(button).toHaveTextContent("Follow");
    await user.click(button);

    expect(api.communities.follow).toHaveBeenCalledWith("c1");
    // An open community has no approval step, so there is nothing to announce.
    expect(screen.queryByText("Follow request sent")).not.toBeInTheDocument();
  });

  it("offers Request To Follow when approval is required, and confirms the request", async () => {
    const user = userEvent.setup();
    const { api } = renderWithProviders(<CommunityMembershipButton community={needsApproval()} />, {
      api: { ...withMemberships(), communities: { follow: async () => membership({ requestStatus: "pending" }) } },
    });

    const button = screen.getByRole("button", { name: "Follow community" });
    expect(button).toHaveTextContent("Request To Follow");
    await user.click(button);

    expect(api.communities.follow).toHaveBeenCalledWith("c1");
    expect(await screen.findByText("Follow request sent")).toBeInTheDocument();
  });

  it("shows a disabled Follow Request Sent while the request is pending", async () => {
    renderWithProviders(<CommunityMembershipButton community={needsApproval()} />, {
      api: withMemberships(membership({ requestStatus: "pending" })),
    });

    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Follow community" })).toHaveTextContent("Follow Request Sent"),
    );
    expect(screen.getByRole("button", { name: "Follow community" })).toBeDisabled();
  });

  it("shows Follow again once a request was approved", async () => {
    renderWithProviders(<CommunityMembershipButton community={needsApproval()} />, {
      api: withMemberships(membership({ requestStatus: "approved" })),
    });

    // Starts as "Request To Follow" until `me` loads.
    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Follow community" })).toHaveTextContent(/^Follow$/),
    );
    expect(screen.getByRole("button", { name: "Follow community" })).toBeEnabled();
  });

  it("moves to the pending state after a request is sent (membership is refetched)", async () => {
    const user = userEvent.setup();
    let requested = false;
    renderWithProviders(<CommunityMembershipButton community={needsApproval()} />, {
      api: {
        me: { get: async () => me({ memberships: requested ? [membership({ requestStatus: "pending" })] : [] }) },
        communities: {
          follow: async () => {
            requested = true;
            return membership({ requestStatus: "pending" });
          },
        },
      },
    });

    await user.click(screen.getByRole("button", { name: "Follow community" }));

    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Follow community" })).toHaveTextContent("Follow Request Sent"),
    );
    expect(screen.getByRole("button", { name: "Follow community" })).toBeDisabled();
  });

  it("shows an error toast when following fails", async () => {
    const user = userEvent.setup();
    renderWithProviders(<CommunityMembershipButton community={community()} />, {
      api: {
        ...withMemberships(),
        communities: {
          follow: async () => {
            throw new Error("boom");
          },
        },
      },
    });

    await user.click(screen.getByRole("button", { name: "Follow community" }));

    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Follow community" })).toBeEnabled();
  });
});

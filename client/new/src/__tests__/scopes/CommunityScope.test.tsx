// @vitest-environment jsdom
import { act, renderHook, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it, vi } from "vitest";
import type { Community, CommunitySettings, MembershipStatus } from "@/api/types";
import { community, me, membership, template } from "@/__tests__/support/fixtures";
import { qk } from "@/queries/keys";
import { renderInCommunity, renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CommunityScope, useCommunityScope, useCommunityScopeOrNull } from "@/scopes/CommunityScope";

const settings = (over: Partial<CommunitySettings>): Community["settings"] => ({
  ...community().settings,
  ...over,
});

/** Prints what the scope provides so tests can assert on it. */
function Probe() {
  const { community: c, status, permissions, templates } = useCommunityScope();
  return (
    <div>
      <h1>{c.name}</h1>
      <p data-testid="status">{status}</p>
      <p data-testid="permissions">{JSON.stringify(permissions)}</p>
      <ul aria-label="templates">
        {templates.map((t) => (
          <li key={t.id}>{t.title}</li>
        ))}
      </ul>
    </div>
  );
}

const permissionsShown = () =>
  JSON.parse(screen.getByTestId("permissions").textContent ?? "{}") as Record<string, boolean>;

const apiFor = ({
  c = community(),
  status,
  templates = [template()],
}: {
  c?: Community;
  status?: MembershipStatus;
  templates?: ReturnType<typeof template>[];
} = {}) => ({
  communities: { getByDisplayId: vi.fn<(displayId: string) => Promise<Community>>(async () => c) },
  me: {
    get: vi.fn(async () => me({ memberships: status ? [membership({ communityId: c.id, status })] : [] })),
  },
  templates: { list: vi.fn(async () => templates) },
});

const renderScope = (api: ReturnType<typeof apiFor>, displayId = "civic-lab") =>
  renderWithProviders(
    <CommunityScope displayId={displayId}>
      <Probe />
    </CommunityScope>,
    { api },
  );

describe("CommunityScope", () => {
  describe("loading and failure", () => {
    it("shows a spinner and not the children until the community loads", async () => {
      let resolve!: (c: Community) => void;
      const api = apiFor();
      api.communities.getByDisplayId.mockReturnValue(new Promise<Community>((r) => (resolve = r)));
      renderScope(api);

      expect(screen.getByRole("progressbar")).toBeInTheDocument();
      expect(screen.queryByRole("heading", { name: "Civic Lab" })).not.toBeInTheDocument();

      await act(async () => resolve(community()));
      expect(await screen.findByRole("heading", { name: "Civic Lab" })).toBeInTheDocument();
      expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
    });

    it("shows an error instead of the children when the community fails to load", async () => {
      const api = apiFor();
      api.communities.getByDisplayId.mockRejectedValue(new Error("boom"));
      renderScope(api);

      expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading the community.");
      expect(screen.queryByRole("heading", { name: "Civic Lab" })).not.toBeInTheDocument();
    });

    it("keeps showing the cached community when a background refetch fails", async () => {
      const api = apiFor({ status: "member" });
      const { queryClient } = renderScope(api);
      await screen.findByRole("heading", { name: "Civic Lab" });

      api.communities.getByDisplayId.mockRejectedValue(new Error("offline"));
      await act(() => queryClient.invalidateQueries({ queryKey: qk.communities() }));
      await waitFor(() => expect(api.communities.getByDisplayId).toHaveBeenCalledTimes(2));

      expect(screen.getByRole("heading", { name: "Civic Lab" })).toBeInTheDocument();
    });

    it("does not look up membership or templates for a community that failed to load", async () => {
      const api = apiFor();
      api.communities.getByDisplayId.mockRejectedValue(new Error("boom"));
      renderScope(api);
      await screen.findByRole("alert");

      expect(api.templates.list).not.toHaveBeenCalled();
    });
  });

  describe("on success", () => {
    it("looks the community up by display id and provides it to its children", async () => {
      const api = apiFor({ c: community({ name: "Neighbors" }), status: "member" });
      renderScope(api, "neighbors");

      expect(await screen.findByRole("heading", { name: "Neighbors" })).toBeInTheDocument();
      expect(api.communities.getByDisplayId).toHaveBeenCalledWith("neighbors");
      expect(api.templates.list).toHaveBeenCalledWith("c1");
    });

    it("loads another community when the display id changes", async () => {
      const api = apiFor();
      api.communities.getByDisplayId.mockImplementation(async (displayId: string) =>
        community({ id: displayId, displayId, name: `Space ${displayId}` }),
      );
      function Switcher() {
        const [displayId, setDisplayId] = useState("one");
        return (
          <>
            <button onClick={() => setDisplayId("two")}>Switch</button>
            <CommunityScope displayId={displayId}>
              <Probe />
            </CommunityScope>
          </>
        );
      }
      renderWithProviders(<Switcher />, { api });
      expect(await screen.findByRole("heading", { name: "Space one" })).toBeInTheDocument();

      await userEvent.click(screen.getByRole("button", { name: "Switch" }));

      expect(await screen.findByRole("heading", { name: "Space two" })).toBeInTheDocument();
      expect(api.communities.getByDisplayId).toHaveBeenCalledWith("two");
    });

    it("keeps rendering with no templates when the templates request fails", async () => {
      const api = apiFor({ status: "member" });
      api.templates.list.mockRejectedValue(new Error("boom"));
      renderScope(api);

      expect(await screen.findByRole("heading", { name: "Civic Lab" })).toBeInTheDocument();
      await waitFor(() => expect(api.templates.list).toHaveBeenCalled());
      expect(screen.queryAllByRole("listitem")).toHaveLength(0);
    });
  });

  describe("membership status", () => {
    it("is the signed-in user's status in this community", async () => {
      renderScope(apiFor({ status: "moderator" }));
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("moderator"));
    });

    it("ignores memberships in other communities", async () => {
      const api = apiFor();
      api.me.get.mockResolvedValue(me({ memberships: [membership({ communityId: "other", status: "owner" })] }));
      renderScope(api);
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(api.me.get).toHaveBeenCalled());
      expect(screen.getByTestId("status")).toHaveTextContent("nonmember");
    });

    it("is nonmember when the user has no membership record", async () => {
      renderScope(apiFor({ status: undefined }));
      await screen.findByRole("heading", { name: "Civic Lab" });
      expect(screen.getByTestId("status")).toHaveTextContent("nonmember");
    });

    it("falls back to nonmember when the signed-in user cannot be loaded", async () => {
      const api = apiFor();
      api.me.get.mockRejectedValue(new Error("offline"));
      renderScope(api);
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(api.me.get).toHaveBeenCalled());
      expect(screen.getByTestId("status")).toHaveTextContent("nonmember");
    });

    it("updates when me resolves after the community", async () => {
      let resolveMe!: (v: ReturnType<typeof me>) => void;
      const api = apiFor();
      api.me.get.mockReturnValue(new Promise((r) => (resolveMe = r)));
      renderScope(api);

      await screen.findByRole("heading", { name: "Civic Lab" });
      expect(screen.getByTestId("status")).toHaveTextContent("nonmember");
      expect(permissionsShown().canViewCommunityLinks).toBe(false);

      await act(async () => resolveMe(me({ memberships: [membership({ status: "admin" })] })));
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("admin"));
      expect(permissionsShown().canEditCommunity).toBe(true);
    });
  });

  describe("permissions per membership status (default settings, one active template)", () => {
    it.each<[MembershipStatus, { links: boolean; event: boolean; template: boolean; edit: boolean }]>([
      ["owner", { links: true, event: true, template: true, edit: true }],
      ["admin", { links: true, event: true, template: true, edit: true }],
      ["moderator", { links: true, event: true, template: true, edit: false }],
      ["facilitator", { links: true, event: true, template: false, edit: false }],
      ["member", { links: true, event: true, template: false, edit: false }],
      ["attendee", { links: false, event: true, template: false, edit: false }],
      ["nonmember", { links: false, event: true, template: false, edit: false }],
      ["banned", { links: false, event: false, template: false, edit: false }],
    ])("%s", async (status, expected) => {
      renderScope(apiFor({ status }));
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent(status));
      // Templates arrive after the community; canCreateEvent depends on them.
      await screen.findByRole("listitem");

      expect(permissionsShown()).toEqual({
        canViewCommunityLinks: expected.links,
        canCreateEvent: expected.event,
        canCreateTemplate: expected.template,
        canEditCommunity: expected.edit,
      });
    });
  });

  describe("permissions that depend on settings and templates", () => {
    it("lets a member create events only once there is a template to use", async () => {
      let resolveTemplates!: (t: ReturnType<typeof template>[]) => void;
      const api = apiFor({ status: "member" });
      api.templates.list.mockReturnValue(new Promise((r) => (resolveTemplates = r)));
      renderScope(api);

      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("member"));
      expect(permissionsShown().canCreateEvent).toBe(false);

      await act(async () => resolveTemplates([template()]));
      await waitFor(() => expect(permissionsShown().canCreateEvent).toBe(true));
    });

    it("lets someone who can create templates create events even with no templates yet", async () => {
      renderScope(apiFor({ status: "moderator", templates: [] }));
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("moderator"));
      expect(permissionsShown().canCreateEvent).toBe(true);
    });

    it("does not count removed templates as templates when deciding who can create events", async () => {
      renderScope(apiFor({ status: "member", templates: [template({ status: "removed" })] }));
      await screen.findByRole("heading", { name: "Civic Lab" });
      await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("member"));
      expect(permissionsShown().canCreateEvent).toBe(false);
    });

    it("restricts event creation to facilitators when members may not create meetings", async () => {
      const c = community({ settings: settings({ dontAllowMembersToCreateMeetings: true }) });
      const { unmount } = renderScope(apiFor({ c, status: "member" }));
      await screen.findByRole("listitem");
      expect(permissionsShown().canCreateEvent).toBe(false);
      unmount();

      renderScope(apiFor({ c, status: "facilitator" }));
      await screen.findByRole("listitem");
      expect(permissionsShown().canCreateEvent).toBe(true);
    });

    it("requires full membership to create events when approval is needed to join", async () => {
      const c = community({ settings: settings({ requireApprovalToJoin: true }) });
      const { unmount } = renderScope(apiFor({ c, status: "attendee" }));
      await screen.findByRole("listitem");
      expect(permissionsShown().canCreateEvent).toBe(false);
      unmount();

      renderScope(apiFor({ c, status: "member" }));
      await screen.findByRole("listitem");
      expect(permissionsShown().canCreateEvent).toBe(true);
    });

    it("lets members create templates when unofficial templates are allowed", async () => {
      const c = community({ settings: settings({ allowUnofficialTemplates: true }) });
      renderScope(apiFor({ c, status: "member" }));
      await screen.findByRole("listitem");
      expect(permissionsShown().canCreateTemplate).toBe(true);
    });
  });

  describe("templates", () => {
    it("provides only the active templates", async () => {
      renderScope(
        apiFor({
          status: "member",
          templates: [
            template({ id: "t1", title: "Check-in" }),
            template({ id: "t2", title: "Retired", status: "removed" }),
            template({ id: "t3", title: "Debate" }),
          ],
        }),
      );

      expect(await screen.findByText("Check-in")).toBeInTheDocument();
      expect(screen.getByText("Debate")).toBeInTheDocument();
      expect(screen.queryByText("Retired")).not.toBeInTheDocument();
    });

    it("is empty until the templates load", async () => {
      let resolveTemplates!: (t: ReturnType<typeof template>[]) => void;
      const api = apiFor();
      api.templates.list.mockReturnValue(new Promise((r) => (resolveTemplates = r)));
      renderScope(api);

      await screen.findByRole("heading", { name: "Civic Lab" });
      expect(screen.queryAllByRole("listitem")).toHaveLength(0);

      await act(async () => resolveTemplates([template({ title: "Check-in" })]));
      expect(await screen.findByText("Check-in")).toBeInTheDocument();
    });
  });

  it("works with the shared renderInCommunity helper", async () => {
    renderInCommunity(<Probe />, { status: "owner", community: community({ name: "Helper Space" }) });
    expect(await screen.findByRole("heading", { name: "Helper Space" })).toBeInTheDocument();
    expect(screen.getByTestId("status")).toHaveTextContent("owner");
  });
});

describe("useCommunityScope", () => {
  it("throws a helpful error outside a <CommunityScope>", () => {
    const consoleError = vi.spyOn(console, "error").mockImplementation(() => undefined);
    try {
      expect(() => renderHook(() => useCommunityScope())).toThrow(
        "useCommunityScope must be used inside <CommunityScope>",
      );
    } finally {
      consoleError.mockRestore();
    }
  });
});

describe("useCommunityScopeOrNull", () => {
  it("is null outside a <CommunityScope>", () => {
    const { result } = renderHook(() => useCommunityScopeOrNull());
    expect(result.current).toBeNull();
  });

  it("is the scope's value inside one", async () => {
    function Peek() {
      const scope = useCommunityScopeOrNull();
      return <p>{scope ? `in ${scope.community.name} as ${scope.status}` : "no scope"}</p>;
    }
    renderInCommunity(<Peek />, { status: "facilitator" });
    expect(await screen.findByText("in Civic Lab as facilitator")).toBeInTheDocument();
  });

  it("does not throw where useCommunityScope would", () => {
    function Outside() {
      return <p>{useCommunityScopeOrNull() ? "scoped" : "unscoped"}</p>;
    }
    renderWithProviders(<Outside />);
    expect(screen.getByText("unscoped")).toBeInTheDocument();
  });
});

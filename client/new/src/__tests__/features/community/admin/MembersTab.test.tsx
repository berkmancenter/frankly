// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { JoinRequest, MemberDetails, MembershipStatus } from "@/api/types";
import { membership, user } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { MembersTab } from "@/features/community/admin/MembersTab";
import { downloadText } from "@/utils/csv";

vi.mock("@/utils/csv", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/csv")>()),
  downloadText: vi.fn(),
}));

const person = (
  id: string,
  displayName: string,
  status: MembershipStatus,
  over: { email?: string; invisible?: boolean } = {},
): MemberDetails => ({
  user: user({ id, displayName }),
  membership: membership({ userId: id, status, ...(over.invisible ? { invisible: true } : {}) }),
  ...(over.email ? { email: over.email } : {}),
});

const request = (id: string, displayName: string): JoinRequest => ({ user: user({ id, displayName }), communityId: "c1" });

const everyone = [
  person("u-member", "Mia Member", "member", { email: "mia@civic.test" }),
  person("u-owner", "Olga Owner", "owner", { email: "olga@civic.test" }),
  person("u-admin", "Adam Admin", "admin", { email: "adam@civic.test" }),
  person("u-attendee", "Ari Attendee", "attendee"),
  person("u-hidden", "Hana Hidden", "member", { invisible: true }),
  person("u-gone", "Gus Gone", "nonmember"),
];

function setup(api: Record<string, unknown> = {}, members = everyone, requests: JoinRequest[] = []) {
  const setRole = vi.fn(async () => {});
  const resolveJoinRequest = vi.fn<(input: { userId: string }) => Promise<void>>(async () => {});
  const view = renderInCommunity(<MembersTab />, {
    status: "admin",
    api: {
      communities: {
        getByDisplayId: async () => (await import("@/__tests__/support/fixtures")).community(),
        listMembers: async () => members,
        listJoinRequests: async () => requests,
        setRole,
        resolveJoinRequest,
        ...api,
      },
    } as never,
  });
  return { setRole, resolveJoinRequest, ...view };
}

const rowNames = () =>
  screen
    .getAllByRole("row")
    .slice(1)
    .map((row) => within(row).getAllByRole("cell")[0]!.querySelector("p")!.textContent);

beforeEach(() => vi.mocked(downloadText).mockClear());

describe("MembersTab members", () => {
  it("lists the people who belong, highest role first, without hidden ones", async () => {
    setup();
    await screen.findByText("Olga Owner");
    expect(rowNames()).toEqual(["Olga Owner", "Adam Admin", "Mia Member"]);
    expect(screen.queryByText("Ari Attendee")).not.toBeInTheDocument();
    expect(screen.queryByText("Hana Hidden")).not.toBeInTheDocument();
    expect(screen.queryByText("Gus Gone")).not.toBeInTheDocument();
  });

  it("filters by name or email", async () => {
    setup();
    await screen.findByText("Olga Owner");
    const box = screen.getByRole("textbox", { name: "Filter member list by name" });
    await userEvent.type(box, "ADAM");
    expect(rowNames()).toEqual(["Adam Admin"]);
    await userEvent.clear(box);
    await userEvent.type(box, "mia@civic");
    expect(rowNames()).toEqual(["Mia Member"]);
    await userEvent.clear(box);
    await userEvent.type(box, "nobody");
    expect(screen.getByText("No matching members found.")).toBeInTheDocument();
  });

  it("gives someone another role", async () => {
    const { setRole } = setup();
    await userEvent.click(await screen.findByRole("combobox", { name: "Role: Mia Member" }));
    await userEvent.click(screen.getByRole("option", { name: /^Moderator/ }));
    await waitFor(() => expect(setRole).toHaveBeenCalledWith("c1", "u-member", "moderator"));
  });

  it("shows the owner's role as plain text", async () => {
    setup();
    await screen.findByText("Olga Owner");
    expect(screen.queryByRole("combobox", { name: "Role: Olga Owner" })).not.toBeInTheDocument();
    expect(within(screen.getAllByRole("row")[1]!).getByText("Owner")).toBeInTheDocument();
  });

  it("does not offer to make anyone an owner", async () => {
    const { setRole } = setup();
    await userEvent.click(await screen.findByRole("combobox", { name: "Role: Mia Member" }));
    expect(screen.getByRole("option", { name: /^Owner/ })).toHaveAttribute("aria-disabled", "true");
    expect(setRole).not.toHaveBeenCalled();
  });

  it("reports a role change that failed", async () => {
    setup({
      setRole: async () => {
        throw new Error("offline");
      },
    });
    await userEvent.click(await screen.findByRole("combobox", { name: "Role: Mia Member" }));
    await userEvent.click(screen.getByRole("option", { name: /^Facilitator/ }));
    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
  });

  it("pages through a long list", async () => {
    const many = Array.from({ length: 12 }, (_, i) => person(`u${i}`, `Member ${String(i).padStart(2, "0")}`, "member"));
    setup({}, many);
    await screen.findByText("Member 00");
    expect(rowNames()).toHaveLength(10);
    await userEvent.click(screen.getByRole("button", { name: /next page/i }));
    expect(rowNames()).toEqual(["Member 10", "Member 11"]);
  });

  it("explains when the members cannot be loaded", async () => {
    setup({
      listMembers: async () => {
        throw new Error("offline");
      },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading memberships.");
  });

  it("downloads everyone but the owner and plain attendees", async () => {
    setup();
    await userEvent.click(await screen.findByRole("button", { name: "Download members data" }));
    expect(downloadText).toHaveBeenCalledTimes(1);
    const [fileName, csv] = vi.mocked(downloadText).mock.calls[0]!;
    expect(fileName).toBe("members-data-c1.csv");
    expect(csv).toBe(
      ["#,Name,Email,Member status", "1,Adam Admin,adam@civic.test,admin", "2,Mia Member,mia@civic.test,member", "3,Hana Hidden,,member"].join("\r\n"),
    );
  });

  it("has nothing to download when only the owner belongs", async () => {
    setup({}, [person("u-owner", "Olga Owner", "owner")]);
    await userEvent.click(await screen.findByRole("button", { name: "Download members data" }));
    expect(await screen.findByText("No members found to export.")).toBeInTheDocument();
    expect(downloadText).not.toHaveBeenCalled();
  });
});

describe("MembersTab requests", () => {
  const open = async () => userEvent.click(await screen.findByRole("tab", { name: /^Requests/ }));

  it("counts the people waiting", async () => {
    setup({}, everyone, [request("r1", "Rae Request"), request("r2", "Rex Request")]);
    expect(await screen.findByRole("tab", { name: /Requests \(2\)/ })).toBeInTheDocument();
  });

  it("invites the admin to share the community when nobody is waiting", async () => {
    setup();
    await open();
    expect(await screen.findByText("No follow requests currently")).toBeInTheDocument();
    expect(screen.getByText("Share your community with others")).toBeInTheDocument();
  });

  it("lets someone in as a member by default", async () => {
    const { resolveJoinRequest } = setup({}, everyone, [request("r1", "Rae Request")]);
    await open();
    await userEvent.click(await screen.findByRole("button", { name: "Approve: Rae Request" }));
    await waitFor(() =>
      expect(resolveJoinRequest).toHaveBeenCalledWith({ communityId: "c1", userId: "r1", approve: true, role: "member" }),
    );
  });

  it("lets someone in with the role the admin picked", async () => {
    const { resolveJoinRequest } = setup({}, everyone, [request("r1", "Rae Request")]);
    await open();
    await userEvent.click(await screen.findByRole("combobox", { name: "Role: Rae Request" }));
    await userEvent.click(screen.getByRole("option", { name: /^Facilitator/ }));
    await userEvent.click(screen.getByRole("button", { name: "Approve: Rae Request" }));
    await waitFor(() =>
      expect(resolveJoinRequest).toHaveBeenCalledWith({ communityId: "c1", userId: "r1", approve: true, role: "facilitator" }),
    );
  });

  it("turns someone away", async () => {
    const { resolveJoinRequest } = setup({}, everyone, [request("r1", "Rae Request")]);
    await open();
    await userEvent.click(await screen.findByRole("button", { name: "Deny: Rae Request" }));
    await waitFor(() =>
      expect(resolveJoinRequest).toHaveBeenCalledWith({ communityId: "c1", userId: "r1", approve: false }),
    );
  });

  it("approves everyone at once", async () => {
    const { resolveJoinRequest } = setup({}, everyone, [request("r1", "Rae Request"), request("r2", "Rex Request")]);
    await open();
    await userEvent.click(await screen.findByRole("button", { name: "Approve All" }));
    await waitFor(() => expect(resolveJoinRequest).toHaveBeenCalledTimes(2));
    expect(resolveJoinRequest.mock.calls.map(([call]) => call.userId)).toEqual(["r1", "r2"]);
  });

  it("explains when the requests cannot be loaded", async () => {
    setup({
      listJoinRequests: async () => {
        throw new Error("offline");
      },
    });
    await open();
    expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading requests.");
  });
});

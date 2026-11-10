import { describe, expect, it } from "vitest";
import type { CommunitySettings, MembershipStatus } from "@/api/types";
import { community } from "@/__tests__/support/fixtures";
import { computeCommunityPermissions } from "@/utils/permissions";

const compute = (
  status: MembershipStatus | undefined,
  settings: Partial<CommunitySettings> = {},
  hasTemplates = true,
) => computeCommunityPermissions(community({ settings: { ...community().settings, ...settings } }), status, hasTemplates);

describe("canViewCommunityLinks and canEditCommunity", () => {
  it("links are for members and above; editing is for admins and above", () => {
    expect(compute("nonmember").canViewCommunityLinks).toBe(false);
    expect(compute("member").canViewCommunityLinks).toBe(true);
    expect(compute("member").canEditCommunity).toBe(false);
    expect(compute("moderator").canEditCommunity).toBe(false);
    expect(compute("admin").canEditCommunity).toBe(true);
    expect(compute("owner").canEditCommunity).toBe(true);
  });

  it("treats a missing status as non-member", () => {
    const permissions = compute(undefined);
    expect(permissions.canViewCommunityLinks).toBe(false);
    expect(permissions.canEditCommunity).toBe(false);
  });
});

describe("canCreateTemplate", () => {
  it("is for moderators and above by default", () => {
    expect(compute("member").canCreateTemplate).toBe(false);
    expect(compute("facilitator").canCreateTemplate).toBe(false);
    expect(compute("moderator").canCreateTemplate).toBe(true);
  });

  it("opens up to every member when unofficial templates are allowed", () => {
    const settings = { allowUnofficialTemplates: true };
    expect(compute("nonmember", settings).canCreateTemplate).toBe(false);
    expect(compute("member", settings).canCreateTemplate).toBe(true);
  });
});

describe("canCreateEvent", () => {
  it("is open to anyone not banned by default", () => {
    expect(compute("nonmember").canCreateEvent).toBe(true);
    expect(compute("banned").canCreateEvent).toBe(false);
  });

  it("requires facilitator when members may not create meetings", () => {
    const settings = { dontAllowMembersToCreateMeetings: true };
    expect(compute("member", settings).canCreateEvent).toBe(false);
    expect(compute("facilitator", settings).canCreateEvent).toBe(true);
  });

  it("requires membership when joining needs approval", () => {
    const settings = { requireApprovalToJoin: true };
    expect(compute("nonmember", settings).canCreateEvent).toBe(false);
    expect(compute("member", settings).canCreateEvent).toBe(true);
  });

  it("lets the facilitator rule win over the approval rule", () => {
    const settings = { dontAllowMembersToCreateMeetings: true, requireApprovalToJoin: true };
    expect(compute("member", settings).canCreateEvent).toBe(false);
  });

  it("needs a template to host with, unless the person can create one", () => {
    expect(compute("member", {}, false).canCreateEvent).toBe(false);
    expect(compute("moderator", {}, false).canCreateEvent).toBe(true);
    expect(compute("member", { allowUnofficialTemplates: true }, false).canCreateEvent).toBe(true);
  });
});

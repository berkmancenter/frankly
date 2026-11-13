import { i18n } from "@lingui/core";
import { describe, expect, it } from "vitest";
import type { MembershipStatus } from "@/api/types";
import { isAdmin, isFacilitator, isMember, isMod, isNotBanned, roleLabel } from "@/utils/membership";

const ALL: MembershipStatus[] = [
  "banned",
  "nonmember",
  "attendee",
  "member",
  "facilitator",
  "moderator",
  "admin",
  "owner",
];

/** The statuses for which `predicate` holds. */
const passing = (predicate: (s: MembershipStatus) => boolean) => ALL.filter(predicate);

describe("membership hierarchy", () => {
  it("isNotBanned excludes only banned", () => {
    expect(passing(isNotBanned)).toEqual(ALL.filter((s) => s !== "banned"));
  });

  it("each level implies the ones above it in rank", () => {
    expect(passing(isMember)).toEqual(["member", "facilitator", "moderator", "admin", "owner"]);
    expect(passing(isFacilitator)).toEqual(["facilitator", "moderator", "admin", "owner"]);
    expect(passing(isMod)).toEqual(["moderator", "admin", "owner"]);
    expect(passing(isAdmin)).toEqual(["admin", "owner"]);
  });

  it("does not treat attendees or non-members as members", () => {
    expect(isMember("attendee")).toBe(false);
    expect(isMember("nonmember")).toBe(false);
  });
});

describe("roleLabel", () => {
  it("has a human-readable label for every status", () => {
    expect(i18n._(roleLabel("owner"))).toBe("Owner");
    expect(i18n._(roleLabel("nonmember"))).toBe("Non-member");
    for (const status of ALL) expect(i18n._(roleLabel(status))).toMatch(/^[A-Z]/);
  });
});

import { describe, expect, it } from "vitest";
import { eventPermissions } from "@/utils/events/eventPermissions";
import {
  effectiveMaxParticipants,
  formatCountdown,
  startState,
} from "@/utils/events/eventTiming";

const at = (iso: string) => new Date(iso);

describe("startState", () => {
  const now = at("2030-01-10T12:00:00");
  it("counts days, then tomorrow, then a same-day countdown", () => {
    expect(startState(at("2030-01-13T09:00:00"), now)).toEqual({
      kind: "days",
      days: 3,
    });
    expect(startState(at("2030-01-11T09:00:00"), now)).toEqual({
      kind: "tomorrow",
    });
    expect(startState(at("2030-01-10T15:00:00"), now)).toEqual({
      kind: "countdown",
      ms: 3 * 3_600_000,
    });
  });
  it("opens 15 minutes before the start and stays open through the day", () => {
    expect(startState(at("2030-01-10T12:15:00"), now)).toEqual({
      kind: "open",
    });
    expect(startState(at("2030-01-10T11:00:00"), now)).toEqual({
      kind: "open",
    });
  });
  it("has ended once the day has passed", () => {
    expect(startState(at("2030-01-09T20:00:00"), now)).toEqual({
      kind: "ended",
    });
  });
});

describe("formatCountdown", () => {
  it("shows hours and minutes, or minutes and seconds", () => {
    expect(formatCountdown(3_900_000)).toBe("1h 05m");
    expect(formatCountdown(750_000)).toBe("12m 30s");
    expect(formatCountdown(-5)).toBe("0m 00s");
  });
});

describe("effectiveMaxParticipants", () => {
  it("uses the host's cap, else a default for the event type", () => {
    expect(
      effectiveMaxParticipants({ eventType: "hosted", maxParticipants: 5 }),
    ).toBe(5);
    expect(effectiveMaxParticipants({ eventType: "hosted" })).toBe(8);
    expect(effectiveMaxParticipants({ eventType: "hostless" })).toBe(1000);
  });
});

describe("eventPermissions", () => {
  const base = {
    event: { creatorId: "host", isLocked: false },
    userId: "me",
    status: "member" as const,
    settings: { requireApprovalToJoin: false, allowUnofficialTemplates: false },
    isParticipant: false,
  };
  it("lets people join unless the event is locked or they are banned", () => {
    expect(eventPermissions(base).canJoin).toBe(true);
    expect(
      eventPermissions({ ...base, event: { ...base.event, isLocked: true } })
        .canJoin,
    ).toBe(false);
    expect(eventPermissions({ ...base, status: "banned" }).canJoin).toBe(false);
  });
  it("needs membership when the community requires approval", () => {
    const strict = {
      ...base,
      settings: {
        requireApprovalToJoin: true,
        allowUnofficialTemplates: false,
      },
    };
    expect(eventPermissions({ ...strict, status: "attendee" }).canJoin).toBe(
      false,
    );
    expect(eventPermissions(strict).canJoin).toBe(true);
  });
  it("lets the host and moderators cancel the event, and everyone else leave", () => {
    expect(eventPermissions({ ...base, userId: "host" }).canCancelEvent).toBe(
      true,
    );
    expect(
      eventPermissions({ ...base, status: "moderator" }).canCancelEvent,
    ).toBe(true);
    expect(eventPermissions(base).canCancelEvent).toBe(false);
    expect(
      eventPermissions({ ...base, isParticipant: true }).canCancelParticipation,
    ).toBe(true);
    expect(
      eventPermissions({ ...base, userId: "host", isParticipant: true })
        .canCancelParticipation,
    ).toBe(false);
  });
  it("lets hosts edit, but only as facilitators unless unofficial templates are allowed", () => {
    const host = { ...base, userId: "host" };
    expect(eventPermissions({ ...host, status: "member" }).canEdit).toBe(false);
    expect(eventPermissions({ ...host, status: "facilitator" }).canEdit).toBe(
      true,
    );
    const open = {
      ...host,
      settings: {
        requireApprovalToJoin: false,
        allowUnofficialTemplates: true,
      },
    };
    expect(eventPermissions({ ...open, status: "member" }).canEdit).toBe(true);
    expect(eventPermissions({ ...base, status: "moderator" }).canEdit).toBe(
      true,
    );
    expect(eventPermissions(base).canEdit).toBe(false);
  });
});

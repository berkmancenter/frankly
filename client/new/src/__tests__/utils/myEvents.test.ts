import { describe, expect, it } from "vitest";
import { event } from "@/__tests__/support/fixtures";
import { splitMyEvents } from "@/utils/events/myEvents";

const now = new Date("2030-06-01T00:00:00.000Z");
const at = (id: string, scheduledTime?: string, status: "active" | "canceled" = "active") =>
  event({ id, scheduledTime, status });

describe("splitMyEvents", () => {
  it("orders upcoming events soonest first and past events latest first", () => {
    const { upcoming, past } = splitMyEvents(
      [
        at("b", "2030-08-01T00:00:00.000Z"),
        at("a", "2030-07-01T00:00:00.000Z"),
        at("y", "2030-01-01T00:00:00.000Z"),
        at("z", "2030-03-01T00:00:00.000Z"),
      ],
      now,
    );
    expect(upcoming.map((e) => e.id)).toEqual(["a", "b"]);
    expect(past.map((e) => e.id)).toEqual(["z", "y"]);
  });

  it("drops inactive and unscheduled events", () => {
    const { upcoming, past } = splitMyEvents(
      [at("off", "2030-07-01T00:00:00.000Z", "canceled"), at("none")],
      now,
    );
    expect(upcoming).toEqual([]);
    expect(past).toEqual([]);
  });
});

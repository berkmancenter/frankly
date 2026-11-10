import { describe, expect, it } from "vitest";
import {
  addDays,
  compactNumber,
  formatLongStamp,
  formatMonthShortUpper,
  formatTimeShort,
  formatWeekdayShort,
  initials,
  isSameCalendarDay,
  pluralize,
  startOfDay,
  timeZoneAbbreviation,
} from "@/utils/format";

// Dates are built from local components so the assertions hold in any time zone.
const local = (y: number, m: number, d: number, h = 0, min = 0) => new Date(y, m - 1, d, h, min);

describe("formatTimeShort", () => {
  it("drops the minutes-suffix 'm' and lower-cases the meridiem", () => {
    expect(formatTimeShort(local(2026, 11, 4, 15, 0))).toBe("3:00p");
    expect(formatTimeShort(local(2026, 11, 4, 11, 30))).toBe("11:30a");
  });

  it("formats midnight and noon as 12", () => {
    expect(formatTimeShort(local(2026, 11, 4, 0, 5))).toBe("12:05a");
    expect(formatTimeShort(local(2026, 11, 4, 12, 0))).toBe("12:00p");
  });
});

describe("date part formatters", () => {
  it("formats the month in upper case and the weekday abbreviated", () => {
    const d = local(2026, 11, 4, 12);
    expect(formatMonthShortUpper(d)).toBe("NOV");
    expect(formatWeekdayShort(d)).toBe("Wed");
  });

  it("formats the long announcement stamp", () => {
    expect(formatLongStamp(local(2026, 11, 4, 18, 15))).toMatch(/^Nov 4, 2026,? 6:15\s?PM$/);
  });

  it("returns a time zone abbreviation", () => {
    expect(timeZoneAbbreviation(local(2026, 11, 4, 12))).not.toBe("");
  });
});

describe("calendar day helpers", () => {
  it("treats different times on the same local day as the same day", () => {
    expect(isSameCalendarDay(local(2026, 11, 4, 0, 1), local(2026, 11, 4, 23, 59))).toBe(true);
  });

  it("treats adjacent days as different, even a minute apart", () => {
    expect(isSameCalendarDay(local(2026, 11, 4, 23, 59), local(2026, 11, 5, 0, 1))).toBe(false);
  });

  it("adds days across month boundaries without mutating the input", () => {
    const start = local(2026, 11, 29, 9);
    const result = addDays(start, 3);
    expect(result.getMonth()).toBe(11); // December
    expect(result.getDate()).toBe(2);
    expect(result.getHours()).toBe(9);
    expect(start.getDate()).toBe(29);
  });

  it("supports negative offsets", () => {
    expect(addDays(local(2026, 3, 1), -1).getDate()).toBe(28);
  });

  it("truncates to the start of the local day", () => {
    const result = startOfDay(local(2026, 11, 4, 18, 45));
    expect(result.getFullYear()).toBe(2026);
    expect(result.getDate()).toBe(4);
    expect([result.getHours(), result.getMinutes(), result.getSeconds()]).toEqual([0, 0, 0]);
  });
});

describe("pluralize", () => {
  it("uses the singular only for exactly one", () => {
    expect(pluralize(1, "Comment")).toBe("1 Comment");
    expect(pluralize(0, "Comment")).toBe("0 Comments");
    expect(pluralize(3, "Comment")).toBe("3 Comments");
  });

  it("accepts an irregular plural", () => {
    expect(pluralize(2, "person", "people")).toBe("2 people");
  });
});

describe("compactNumber", () => {
  it("abbreviates large numbers", () => {
    expect(compactNumber(999)).toBe("999");
    expect(compactNumber(1200)).toBe("1.2K");
    expect(compactNumber(2_500_000)).toBe("2.5M");
  });
});

describe("initials", () => {
  it("returns the upper-cased first letter", () => {
    expect(initials("ada lovelace")).toBe("A");
    expect(initials("  grace")).toBe("G");
  });

  it("falls back to a question mark for empty names", () => {
    expect(initials("")).toBe("?");
    expect(initials("   ")).toBe("?");
    expect(initials(undefined)).toBe("?");
    expect(initials(null)).toBe("?");
  });
});

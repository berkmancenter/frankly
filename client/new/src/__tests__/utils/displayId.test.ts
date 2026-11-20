import { describe, expect, it } from "vitest";
import { displayIdFromName, filterCommunityName, filterDisplayId } from "@/utils/displayId";

describe("displayIdFromName", () => {
  it("lowercases and turns spaces and punctuation into dashes", () => {
    expect(displayIdFromName("Civic Lab")).toBe("civic-lab");
    expect(displayIdFromName("Book Club: 2025!")).toBe("book-club-2025-");
  });

  it("collapses runs of dashes and keeps underscores", () => {
    expect(displayIdFromName("a   b")).toBe("a-b");
    expect(displayIdFromName("a_b")).toBe("a_b");
  });

  it("is empty for an empty name", () => {
    expect(displayIdFromName("")).toBe("");
  });
});

describe("filterCommunityName", () => {
  it("keeps letters, digits, underscores and whitespace", () => {
    expect(filterCommunityName("Civic Lab_2 (beta)!")).toBe("Civic Lab_2 beta");
  });
});

describe("filterDisplayId", () => {
  it("keeps lowercase letters, digits, dashes and plus", () => {
    expect(filterDisplayId("Civic Lab_2+x")).toBe("civiclab2+x");
  });
});

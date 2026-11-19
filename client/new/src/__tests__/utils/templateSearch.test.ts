import { describe, expect, it } from "vitest";
import { template } from "@/__tests__/support/fixtures";
import { filterTemplates, templateCategories } from "@/utils/templateSearch";

const list = [
  template({ id: "1", title: "Town Hall", category: "Civic" }),
  template({ id: "2", title: "Book Club", category: "Social" }),
  template({ id: "3", title: "Hall Monitor", category: undefined }),
  template({ id: "4", title: "Potluck", category: "Civic hall" }),
];
const ids = (ts: { id: string }[]) => ts.map((t) => t.id);

describe("filterTemplates", () => {
  it("keeps everything, in order, for an empty query", () => {
    expect(ids(filterTemplates(list, "  "))).toEqual(["1", "2", "3", "4"]);
  });

  it("ranks title prefixes, then title matches, then category matches", () => {
    expect(ids(filterTemplates(list, "hall"))).toEqual(["3", "1", "4"]);
  });

  it("ignores case", () => {
    expect(ids(filterTemplates(list, "BOOK"))).toEqual(["2"]);
  });

  it("narrows to a category, with or without a query", () => {
    expect(ids(filterTemplates(list, "", "Civic"))).toEqual(["1"]);
    expect(ids(filterTemplates(list, "hall", "Civic"))).toEqual(["1"]);
  });

  it("finds nothing for an unknown query", () => {
    expect(filterTemplates(list, "zzz")).toEqual([]);
  });
});

describe("templateCategories", () => {
  it("lists each category once, skipping templates without one", () => {
    expect(templateCategories([...list, template({ id: "5", category: "Social" })])).toEqual([
      "Civic",
      "Social",
      "Civic hall",
    ]);
  });
});

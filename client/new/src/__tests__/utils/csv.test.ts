// @vitest-environment jsdom
import { afterEach, describe, expect, it, vi } from "vitest";
import { downloadText, toCsv } from "@/utils/csv";

describe("toCsv", () => {
  it("joins rows with line breaks and fields with commas", () => {
    expect(
      toCsv([
        ["#", "Name"],
        [1, "Ada"],
      ]),
    ).toBe("#,Name\r\n1,Ada");
  });

  it("quotes fields that hold commas, quotes or line breaks", () => {
    expect(toCsv([["a,b", 'say "hi"', "two\nlines"]])).toBe('"a,b","say ""hi""","two\nlines"');
  });

  it("writes missing values as empty fields", () => {
    expect(toCsv([[undefined, null, ""]])).toBe(",,");
  });
});

describe("downloadText", () => {
  afterEach(() => vi.restoreAllMocks());

  it("clicks a download link for the content, then cleans up", () => {
    URL.createObjectURL = vi.fn(() => "blob:test");
    URL.revokeObjectURL = vi.fn();
    const click = vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(function (this: HTMLAnchorElement) {
      expect(this.download).toBe("people.csv");
      expect(this.href).toBe("blob:test");
    });
    downloadText("people.csv", "a,b");
    expect(click).toHaveBeenCalledTimes(1);
    expect(URL.revokeObjectURL).toHaveBeenCalledWith("blob:test");
    expect(document.querySelector("a[download]")).toBeNull();
  });
});

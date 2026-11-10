import { describe, expect, it } from "vitest";
import { placeholderImage } from "@/utils/placeholder";

const decode = (uri: string) => decodeURIComponent(uri.replace("data:image/svg+xml;utf8,", ""));

describe("placeholderImage", () => {
  it("returns an SVG data URI", () => {
    const uri = placeholderImage("civic-lab");
    expect(uri.startsWith("data:image/svg+xml;utf8,")).toBe(true);
    expect(decode(uri)).toMatch(/^<svg [^>]*xmlns="http:\/\/www\.w3\.org\/2000\/svg"/);
  });

  it("is deterministic for a seed and varies across seeds", () => {
    expect(placeholderImage("a")).toBe(placeholderImage("a"));
    const variants = new Set(["a", "b", "c", "d", "e", "f", "g", "h"].map((s) => placeholderImage(s)));
    expect(variants.size).toBeGreaterThan(1);
  });

  it("only draws a glyph when one is given", () => {
    expect(decode(placeholderImage("a"))).not.toContain("<text");
    expect(decode(placeholderImage("a", "★"))).toContain("★");
  });

  it("uses the requested size", () => {
    const svg = decode(placeholderImage("a", undefined, 100));
    expect(svg).toContain('width="100"');
    expect(svg).toContain('viewBox="0 0 100 100"');
  });
});

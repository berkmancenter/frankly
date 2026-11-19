// @vitest-environment jsdom
import { renderHook } from "@testing-library/react";
import { beforeEach, describe, expect, it } from "vitest";
import { useDocumentTitle } from "@/utils/useDocumentTitle";

describe("useDocumentTitle", () => {
  beforeEach(() => {
    document.title = "Original";
  });

  it("sets the title while mounted and restores the previous one on unmount", () => {
    const { unmount } = renderHook(() => useDocumentTitle("Civic Lab"));
    expect(document.title).toBe("Civic Lab");
    unmount();
    expect(document.title).toBe("Original");
  });

  it("follows title changes", () => {
    const { rerender } = renderHook(({ title }) => useDocumentTitle(title), {
      initialProps: { title: "One" },
    });
    expect(document.title).toBe("One");
    rerender({ title: "Two" });
    expect(document.title).toBe("Two");
  });

  it("leaves the title alone while it is undefined or empty", () => {
    const { rerender } = renderHook(({ title }) => useDocumentTitle(title), {
      initialProps: { title: undefined as string | undefined },
    });
    expect(document.title).toBe("Original");
    rerender({ title: "" });
    expect(document.title).toBe("Original");
  });
});

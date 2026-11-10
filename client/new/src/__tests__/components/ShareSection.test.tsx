// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { absoluteUrl, ShareSection, type ShareType } from "@/components/ShareSection";

const enc = encodeURIComponent;
const URL_ = "https://frankly.test/c/civic-lab/e/1";

let open: ReturnType<typeof vi.spyOn>;
beforeEach(() => {
  open = vi.spyOn(window, "open").mockReturnValue(null);
});
afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

const renderShare = (props: Partial<React.ComponentProps<typeof ShareSection>> = {}) =>
  renderWithProviders(<ShareSection url={URL_} subject="Join us" body="Come talk with us" {...props} />);

describe("absoluteUrl", () => {
  it("leaves absolute URLs alone and prefixes paths with the origin", () => {
    expect(absoluteUrl("https://example.com/a")).toBe("https://example.com/a");
    expect(absoluteUrl("http://example.com/a")).toBe("http://example.com/a");
    expect(absoluteUrl("/c/civic-lab")).toBe(`${window.location.origin}/c/civic-lab`);
  });
});

describe("ShareSection", () => {
  it("renders five labeled share buttons", () => {
    renderShare();

    for (const name of ["Share on Facebook", "Share on X", "Share on LinkedIn", "Share by email", "Copy link"]) {
      expect(screen.getByRole("button", { name })).toBeInTheDocument();
    }
    expect(screen.getAllByRole("button")).toHaveLength(5);
  });

  it("opens the Facebook, X and LinkedIn share pages in a new, isolated tab", async () => {
    const user = userEvent.setup();
    renderShare();

    await user.click(screen.getByRole("button", { name: "Share on Facebook" }));
    await user.click(screen.getByRole("button", { name: "Share on X" }));
    await user.click(screen.getByRole("button", { name: "Share on LinkedIn" }));

    expect(open.mock.calls).toEqual([
      [`https://www.facebook.com/sharer/sharer.php?u=${enc(URL_)}`, "_blank", "noopener,noreferrer"],
      [`https://twitter.com/intent/tweet?url=${enc(URL_)}&text=${enc("Come talk with us")}`, "_blank", "noopener,noreferrer"],
      [`https://www.linkedin.com/sharing/share-offsite/?url=${enc(URL_)}`, "_blank", "noopener,noreferrer"],
    ]);
  });

  it("shares an absolute version of a relative URL", async () => {
    const user = userEvent.setup();
    renderShare({ url: "/c/civic-lab" });

    await user.click(screen.getByRole("button", { name: "Share on Facebook" }));

    expect(open).toHaveBeenCalledWith(
      `https://www.facebook.com/sharer/sharer.php?u=${enc(`${window.location.origin}/c/civic-lab`)}`,
      "_blank",
      "noopener,noreferrer",
    );
  });

  it("composes an email with the subject, body and link", async () => {
    const user = userEvent.setup();
    const location = { origin: "https://frankly.test", href: "" };
    vi.stubGlobal("location", location);
    renderShare();

    await user.click(screen.getByRole("button", { name: "Share by email" }));

    expect(location.href).toBe(
      `mailto:?subject=${enc("Join us")}&body=${enc(`Come talk with us\n\n${URL_}`)}`,
    );
    expect(open).not.toHaveBeenCalled();
  });

  it("copies the link and confirms with a toast", async () => {
    const user = userEvent.setup();
    renderShare();

    await user.click(screen.getByRole("button", { name: "Copy link" }));

    expect(await navigator.clipboard.readText()).toBe(URL_);
    expect(await screen.findByText("Link Copied!")).toBeInTheDocument();
    expect(open).not.toHaveBeenCalled();
  });

  it("reports which button was used through onShare", async () => {
    const user = userEvent.setup();
    const shared: ShareType[] = [];
    renderShare({ onShare: (type) => shared.push(type) });

    await user.click(screen.getByRole("button", { name: "Share on Facebook" }));
    await user.click(screen.getByRole("button", { name: "Copy link" }));
    await user.click(screen.getByRole("button", { name: "Share on X" }));

    expect(shared).toEqual(["facebook", "link", "twitter"]);
  });
});

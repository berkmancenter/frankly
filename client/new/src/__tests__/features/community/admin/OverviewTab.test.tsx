// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { useLocation } from "react-router";
import { ApiError } from "@/api/api";
import { community } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { OverviewTab } from "@/features/community/admin/OverviewTab";

function Location() {
  return <div data-testid="location">{useLocation().pathname}</div>;
}

const lab = community({
  displayId: "civic-lab",
  displayIds: ["civic-lab"],
  name: "Civic Lab",
  tagLine: "Talk it through",
  contactEmail: "hello@civic.test",
});

function setup(over: Parameters<typeof community>[0] = {}, update = vi.fn(async () => {})) {
  const current = community({ ...lab, ...over });
  const view = renderInCommunity(
    <>
      <OverviewTab />
      <Location />
    </>,
    {
      community: current,
      status: "admin",
      api: { communities: { getByDisplayId: async () => current, update } },
    },
  );
  return { update, ...view };
}

const field = (name: string | RegExp) => screen.findByRole("textbox", { name });
const save = () => userEvent.click(screen.getByRole("button", { name: "Save" }));
const refusal = () => screen.findByRole("dialog");

describe("OverviewTab", () => {
  it("shows what the community has now", async () => {
    setup({ description: "A place to talk.", websiteUrl: "https://civic.test" });
    expect(await field(/Community Name/)).toHaveValue("Civic Lab");
    expect(screen.getByRole("textbox", { name: "Community URL" })).toHaveValue("civic-lab");
    expect(screen.getByRole("textbox", { name: "Community Tagline" })).toHaveValue("Talk it through");
    expect(screen.getByRole("textbox", { name: "Community Description" })).toHaveValue("A place to talk.");
    expect(screen.getByRole("textbox", { name: "Email" })).toHaveValue("hello@civic.test");
    expect(screen.getByRole("textbox", { name: "Website URL" })).toHaveValue("https://civic.test");
  });

  it("saves the changes and says so", async () => {
    const { update } = setup();
    const name = await field(/Community Name/);
    await userEvent.clear(name);
    await userEvent.type(name, "Civic Lab West");
    await userEvent.type(screen.getByRole("textbox", { name: "Website URL" }), "https://civic.test");
    await userEvent.type(screen.getByRole("textbox", { name: "Bluesky" }), "bsky.app/profile/civic");
    await save();
    expect(await screen.findByText("Changes Saved")).toBeInTheDocument();
    expect(update).toHaveBeenCalledTimes(1);
    const [sent, patch] = update.mock.calls[0] as unknown as [{ id: string }, Record<string, string>];
    expect(sent.id).toBe("c1");
    expect(patch).toMatchObject({
      name: "Civic Lab West",
      tagLine: "Talk it through",
      contactEmail: "hello@civic.test",
      websiteUrl: "https://civic.test",
      blueskyUrl: "bsky.app/profile/civic",
    });
    // The address did not change, so it is not sent.
    expect(patch).not.toHaveProperty("displayId");
  });

  it("follows the community to its new address", async () => {
    const { update } = setup();
    const url = await field("Community URL");
    await userEvent.clear(url);
    await userEvent.type(url, "Civic-Lab-West!");
    expect(url).toHaveValue("civic-lab-west");
    await save();
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(expect.anything(), expect.objectContaining({ displayId: "civic-lab-west" })),
    );
    expect(await screen.findByText("Changes Saved")).toBeInTheDocument();
  });

  it("will not save without a name or an address", async () => {
    const { update } = setup();
    await userEvent.clear(await field(/Community Name/));
    await save();
    expect(within(await refusal()).getByText("Community name cannot be empty")).toBeInTheDocument();
    await userEvent.click(screen.getAllByRole("button", { name: "Close" }).find((b) => b.textContent === "Close")!);
    await userEvent.type(screen.getByRole("textbox", { name: /Community Name/ }), "Civic Lab");
    await userEvent.clear(screen.getByRole("textbox", { name: "Community URL" }));
    await save();
    expect(within(await refusal()).getByText("Community URL cannot be empty")).toBeInTheDocument();
    expect(update).not.toHaveBeenCalled();
  });

  it("points at links that are not the right kind of address", async () => {
    const { update } = setup();
    await userEvent.type(await field("Website URL"), "civic.test");
    await userEvent.type(screen.getByRole("textbox", { name: "Facebook" }), "https://example.com/civic");
    await userEvent.clear(screen.getByRole("textbox", { name: "Email" }));
    await userEvent.type(screen.getByRole("textbox", { name: "Email" }), "not an email");
    expect(screen.getByText(/Enter a valid web address/)).toBeInTheDocument();
    expect(screen.getByText("Enter a valid Facebook web address that includes “facebook.com”")).toBeInTheDocument();
    expect(screen.getByText("Please enter a valid email address.")).toBeInTheDocument();
    await save();
    expect(within(await refusal()).getByText(/Entries for one or more Profile settings/)).toBeInTheDocument();
    expect(update).not.toHaveBeenCalled();
  });

  it("refuses colors that are hard to read", async () => {
    const { update } = setup({ themeLightColor: "333333", themeDarkColor: "444444" });
    await field(/Community Name/);
    await save();
    expect(within(await refusal()).getByText(/do not have sufficient contrast/)).toBeInTheDocument();
    expect(update).not.toHaveBeenCalled();
  });

  it("sends a preset's colors", async () => {
    const { update } = setup();
    await field(/Community Name/);
    await userEvent.click(screen.getByRole("button", { name: "#DEF8FF #203EA0" }));
    await save();
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ themeLightColor: "DEF8FF", themeDarkColor: "203EA0" }),
      ),
    );
  });

  it("explains a refusal from the server", async () => {
    const update = vi.fn(async () => {
      throw new ApiError("invalid", "The URL display name civic-lab is already taken.");
    });
    setup({}, update);
    await field(/Community Name/);
    await save();
    expect(within(await refusal()).getByText("The URL display name civic-lab is already taken.")).toBeInTheDocument();
    expect(screen.queryByText("Changes Saved")).not.toBeInTheDocument();
  });

  it("tells the admin when saving goes wrong for another reason", async () => {
    setup({}, vi.fn(async () => {
      throw new Error("offline");
    }));
    await field(/Community Name/);
    await save();
    expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
  });

  it("replaces a removed logo with a placeholder at once", async () => {
    const { update } = setup({ profileImageUrl: "https://img.test/logo.png" });
    await userEvent.click(await screen.findByRole("button", { name: "Remove" }));
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(
        expect.anything(),
        { profileImageUrl: expect.stringMatching(/^https:\/\/picsum\.photos\/seed\/\d+\/160$/) },
      ),
    );
  });
});

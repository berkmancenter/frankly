// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import type { Template, TemplateTag } from "@/api/types";
import { template } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { TemplatesPage } from "@/features/templates/TemplatesPage";

const checkIn = template({ id: "t1", title: "Check-in", category: "Social" });
const townHall = template({ id: "t2", title: "Town Hall", category: "Civic" });
const removed = template({ id: "t3", title: "Old Thing", status: "removed" });

const setup = (list: Template[], tags: TemplateTag[] = []) =>
  renderInCommunity(<TemplatesPage />, {
    api: { templates: { list: async () => list }, tags: { listForTemplates: async () => tags } },
  });

describe("TemplatesPage", () => {
  it("shows each active template as a link to its page", async () => {
    setup([checkIn, townHall, removed]);
    expect(await screen.findByRole("link", { name: "Check-in" })).toHaveAttribute(
      "href",
      "/space/civic-lab/discuss/t1",
    );
    expect(screen.getByRole("link", { name: "Town Hall" })).toBeInTheDocument();
    expect(screen.queryByText("Old Thing")).not.toBeInTheDocument();
  });

  it("searches by title", async () => {
    setup([checkIn, townHall]);
    await userEvent.type(await screen.findByLabelText("Search templates"), "town");
    expect(screen.getByRole("link", { name: "Town Hall" })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Check-in" })).not.toBeInTheDocument();
  });

  it("says so when nothing matches", async () => {
    setup([checkIn]);
    await userEvent.type(await screen.findByLabelText("Search templates"), "zzz");
    expect(screen.getByText("No templates found.")).toBeInTheDocument();
  });

  it("filters by category, and clears the filter on a second click", async () => {
    setup([checkIn, townHall]);
    await userEvent.click(await screen.findByRole("button", { name: "Civic" }));
    expect(screen.queryByRole("link", { name: "Check-in" })).not.toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Town Hall" })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Civic" }));
    expect(screen.getByRole("link", { name: "Check-in" })).toBeInTheDocument();
  });

  it("filters by tag, and ignores tags of removed templates", async () => {
    const civic = { id: "d1", title: "civic" };
    setup(
      [checkIn, townHall, removed],
      [
        { templateId: "t2", tag: civic },
        { templateId: "t3", tag: { id: "d2", title: "old" } },
      ],
    );
    expect(screen.queryByRole("button", { name: "#old" })).not.toBeInTheDocument();
    await userEvent.click(await screen.findByRole("button", { name: "#civic" }));
    expect(screen.queryByRole("link", { name: "Check-in" })).not.toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Town Hall" })).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "#civic" }));
    expect(screen.getByRole("link", { name: "Check-in" })).toBeInTheDocument();
  });

  it("hides the tag filter when nothing is tagged", async () => {
    setup([checkIn]);
    await screen.findByRole("link", { name: "Check-in" });
    expect(screen.queryByText("Filter")).not.toBeInTheDocument();
  });

  it("shows 30 at a time", async () => {
    const many = Array.from({ length: 35 }, (_, i) => template({ id: `t${i}`, title: `Template ${i}` }));
    setup(many);
    expect(await screen.findAllByRole("link")).toHaveLength(30);
    await userEvent.click(screen.getByRole("button", { name: "View more templates" }));
    expect(screen.getAllByRole("link")).toHaveLength(35);
    expect(screen.queryByRole("button", { name: "View more templates" })).not.toBeInTheDocument();
  });

  it("explains an empty community", async () => {
    setup([removed]);
    expect(await screen.findByRole("heading", { name: /No templates/ })).toBeInTheDocument();
  });

  it("explains when the templates cannot be loaded", async () => {
    renderInCommunity(<TemplatesPage />, {
      api: { templates: { list: async () => { throw new Error("offline"); } } },
    });
    expect(await screen.findByRole("alert")).toHaveTextContent("There was an error loading event templates.");
  });
});

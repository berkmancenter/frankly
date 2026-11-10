// @vitest-environment jsdom
import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import type { MembershipStatus, CommunityResource } from "@/api/types";
import { resource } from "@/__tests__/support/fixtures";
import { renderInCommunity, type CommunityRenderOptions } from "@/__tests__/support/renderWithProviders";
import { ResourcesPage } from "@/features/resources/ResourcesPage";

// The real FAB renders into a slot owned by `AppScaffold`; a plain button stands in for it here.
vi.mock("@/components/layout/AppScaffold", async (importActual) => {
  const actual = await importActual<typeof import("@/components/layout/AppScaffold")>();
  const { createElement } = await import("react");
  return {
    ...actual,
    ScaffoldFab: ({ text, onClick }: { text: string; onClick: () => void }) =>
      createElement("button", { type: "button", onClick }, text),
  };
});

// The dialogs under test never open the image picker here, but `Upload` resolves a provider on import.
vi.mock("@/utils/imageUpload", async (importActual) => {
  const actual = await importActual<typeof import("@/utils/imageUpload")>();
  return { ...actual, resolveImageUploadProvider: () => ({ provider: { upload: async () => ({ url: "x" }) } }) };
});

const handbook = () =>
  resource({ id: "r1", title: "Handbook", url: "https://example.com/handbook", image: "https://img.example/h.png" });
const guide = () => resource({ id: "r2", title: "Parks Guide", url: "https://example.org/parks" });

const EDITORS: MembershipStatus[] = ["admin", "owner"];
const NON_EDITORS: MembershipStatus[] = ["moderator", "facilitator", "member", "attendee", "nonmember"];

function setup(options: CommunityRenderOptions & { list?: CommunityResource[] } = {}) {
  const { list = [handbook(), guide()], ...rest } = options;
  return renderInCommunity(<ResourcesPage />, {
    status: "admin",
    ...rest,
    api: { resources: { list: async () => list }, ...rest.api } as CommunityRenderOptions["api"],
  });
}

/** A server that keeps its own list, so the refetch after a change reflects it. */
function resourceServer(initial: CommunityResource[] = [handbook(), guide()]) {
  let list = initial;
  return {
    list: async () => list,
    remove: async (_communityId: string, resourceId: string) => {
      list = list.filter((r) => r.id !== resourceId);
    },
    update: async (_communityId: string, resourceId: string, patch: Partial<CommunityResource>) => {
      list = list.map((r) => (r.id === resourceId ? { ...r, ...patch } : r));
      return list.find((r) => r.id === resourceId)!;
    },
    create: async (_communityId: string, input: { title: string; url: string; image?: string }) => {
      const created = resource({ id: "r3", ...input });
      list = [...list, created];
      return created;
    },
    preview: async () => ({ title: "Fresh Link", image: "https://img.example/fresh.png" }),
  };
}

describe("ResourcesPage", () => {
  describe("loading states", () => {
    it("shows a spinner while the resources load", async () => {
      setup({ api: { resources: { list: () => new Promise(() => {}) } } });
      await screen.findByRole("button", { name: "Add a resource" });
      expect(screen.getByRole("progressbar")).toBeInTheDocument();
    });

    it("shows an error message when the resources cannot be loaded", async () => {
      setup({
        api: {
          resources: {
            list: async () => {
              throw new Error("boom");
            },
          },
        },
      });
      expect(await screen.findByRole("alert")).toHaveTextContent("Something went wrong loading resources.");
    });

    it("shows an empty state for an editor, with a way to add the first resource", async () => {
      const user = userEvent.setup();
      setup({ list: [] });
      expect(await screen.findByRole("heading", { name: "No resources" })).toBeInTheDocument();

      await user.click(screen.getByRole("button", { name: "Create a resource" }));
      expect(await screen.findByRole("textbox", { name: "Resource URL" })).toBeInTheDocument();
    });

    it("shows the empty state without a button to people who cannot edit the community", async () => {
      setup({ list: [], status: "member" });
      expect(await screen.findByRole("heading", { name: "No resources" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Create a resource" })).not.toBeInTheDocument();
    });
  });

  describe("the list", () => {
    it("shows each resource as a link that opens its URL in a new tab", async () => {
      setup({ status: "member" });
      const first = await screen.findByRole("link", { name: "Handbook" });
      expect(first).toHaveAttribute("href", "https://example.com/handbook");
      expect(first).toHaveAttribute("target", "_blank");
      expect(first).toHaveAttribute("rel", "noopener noreferrer");
      expect(screen.getByRole("link", { name: "Parks Guide" })).toHaveAttribute("href", "https://example.org/parks");
    });

    it("shows a resource's picture when it has one", async () => {
      setup({ status: "member" });
      const first = await screen.findByRole("link", { name: "Handbook" });
      expect(within(first).getByRole("presentation")).toHaveAttribute("src", "https://img.example/h.png");
      // The other resource has no picture, so only a blank placeholder is drawn.
      expect(within(screen.getByRole("link", { name: "Parks Guide" })).queryByRole("presentation")).not.toBeInTheDocument();
    });

    it("keeps the server's order", async () => {
      setup({ status: "member" });
      await screen.findByRole("link", { name: "Handbook" });
      expect(screen.getAllByRole("link").map((l) => l.textContent)).toEqual(["Handbook", "Parks Guide"]);
    });

    it("renders on a phone", async () => {
      setup({ mobile: true });
      expect(await screen.findByRole("link", { name: "Handbook" })).toBeInTheDocument();
      expect(screen.getByRole("link", { name: "Parks Guide" })).toBeInTheDocument();
    });
  });

  describe("permissions", () => {
    it.each(EDITORS)("lets a %s add, edit and delete resources", async (status) => {
      setup({ status });
      expect(await screen.findByRole("button", { name: "Edit Handbook" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Add a resource" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Delete Handbook" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Edit Parks Guide" })).toBeInTheDocument();
      expect(screen.getByRole("button", { name: "Delete Parks Guide" })).toBeInTheDocument();
    });

    it.each(NON_EDITORS)("shows a %s the resources read-only", async (status) => {
      setup({ status });
      expect(await screen.findByRole("link", { name: "Handbook" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: "Add a resource" })).not.toBeInTheDocument();
      expect(screen.queryByRole("button", { name: /^Edit / })).not.toBeInTheDocument();
      expect(screen.queryByRole("button", { name: /^Delete / })).not.toBeInTheDocument();
    });
  });

  describe("adding", () => {
    it("opens an empty dialog from the add button", async () => {
      const user = userEvent.setup();
      setup();
      await user.click(await screen.findByRole("button", { name: "Add a resource" }));

      expect(await screen.findByRole("textbox", { name: "Resource URL" })).toHaveValue("");
      expect(screen.getByRole("button", { name: "Post" })).toBeDisabled();
    });

    it("adds a new resource and shows it in the list after the dialog closes", async () => {
      const user = userEvent.setup();
      const server = resourceServer();
      const { api } = setup({ api: { resources: server } });
      await user.click(await screen.findByRole("button", { name: "Add a resource" }));
      await user.type(await screen.findByRole("textbox", { name: "Resource URL" }), "https://example.net/fresh");
      await user.click(screen.getByRole("button", { name: "Load link" }));
      await screen.findByText("Fresh Link");
      await user.click(screen.getByRole("button", { name: "Post" }));

      expect(await screen.findByText("Resource added")).toBeInTheDocument();
      expect(api.resources.create).toHaveBeenCalledWith("c1", {
        url: "https://example.net/fresh",
        title: "Fresh Link",
        image: "https://img.example/fresh.png",
      });
      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Resource URL" })).not.toBeInTheDocument());
      expect(await screen.findByRole("link", { name: "Fresh Link" })).toHaveAttribute("href", "https://example.net/fresh");
      expect(screen.getAllByRole("link")).toHaveLength(3);
    });

    it("replaces the empty state once the first resource is added", async () => {
      const user = userEvent.setup();
      setup({ api: { resources: resourceServer([]) } });
      await user.click(await screen.findByRole("button", { name: "Create a resource" }));
      await user.type(await screen.findByRole("textbox", { name: "Resource URL" }), "https://example.net/fresh");
      await user.click(screen.getByRole("button", { name: "Load link" }));
      await screen.findByText("Fresh Link");
      await user.click(screen.getByRole("button", { name: "Post" }));

      expect(await screen.findByRole("link", { name: "Fresh Link" })).toBeInTheDocument();
      expect(screen.queryByRole("heading", { name: "No resources" })).not.toBeInTheDocument();
    });

    it("closes the dialog without adding anything when it is dismissed", async () => {
      const user = userEvent.setup();
      const { api } = setup();
      await user.click(await screen.findByRole("button", { name: "Add a resource" }));
      await screen.findByRole("textbox", { name: "Resource URL" });
      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Resource URL" })).not.toBeInTheDocument());
      expect(api.resources.create).not.toHaveBeenCalled();
      expect(screen.getAllByRole("link")).toHaveLength(2);
    });
  });

  describe("editing", () => {
    it("opens the dialog prefilled with the resource that was chosen", async () => {
      const user = userEvent.setup();
      setup();
      await user.click(await screen.findByRole("button", { name: "Edit Parks Guide" }));

      expect(await screen.findByRole("textbox", { name: "Resource URL" })).toHaveValue("https://example.org/parks");
      // The title is shown twice on the page now: in the list behind the dialog and in the dialog.
      expect(within(screen.getByRole("dialog")).getByText("Parks Guide")).toBeInTheDocument();
      expect(within(screen.getByRole("dialog")).queryByText("Handbook")).not.toBeInTheDocument();
    });

    it("saves the change and shows the new title in the list", async () => {
      const user = userEvent.setup();
      const { api } = setup({ api: { resources: resourceServer() } });
      await user.click(await screen.findByRole("button", { name: "Edit Handbook" }));
      await screen.findByRole("textbox", { name: "Resource URL" });
      await user.click(screen.getByRole("button", { name: "Edit title" }));
      const title = screen.getByRole("textbox", { name: "Resource title" });
      await user.clear(title);
      await user.type(title, "Community Handbook");
      await user.click(screen.getByRole("button", { name: "Save title" }));
      await user.click(screen.getByRole("button", { name: "Post" }));

      expect(await screen.findByText("Resource updated")).toBeInTheDocument();
      expect(api.resources.update).toHaveBeenCalledWith("c1", "r1", {
        url: "https://example.com/handbook",
        title: "Community Handbook",
        image: "https://img.example/h.png",
      });
      expect(await screen.findByRole("link", { name: "Community Handbook" })).toBeInTheDocument();
      expect(screen.queryByRole("link", { name: "Handbook" })).not.toBeInTheDocument();
      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Resource URL" })).not.toBeInTheDocument());
    });

    it("leaves the list alone when the edit dialog is dismissed", async () => {
      const user = userEvent.setup();
      const { api } = setup();
      await user.click(await screen.findByRole("button", { name: "Edit Handbook" }));
      await screen.findByRole("textbox", { name: "Resource URL" });
      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() => expect(screen.queryByRole("textbox", { name: "Resource URL" })).not.toBeInTheDocument());
      expect(api.resources.update).not.toHaveBeenCalled();
      expect(screen.getByRole("link", { name: "Handbook" })).toBeInTheDocument();
    });
  });

  describe("deleting", () => {
    const openConfirm = async (user: ReturnType<typeof userEvent.setup>, title = "Handbook") => {
      await user.click(await screen.findByRole("button", { name: `Delete ${title}` }));
      return screen.findByText("Are you sure you want to delete this resource?");
    };

    it("asks for confirmation first and deletes nothing yet", async () => {
      const user = userEvent.setup();
      const { api } = setup();
      await openConfirm(user);
      expect(api.resources.remove).not.toHaveBeenCalled();
      // The page behind the confirmation is hidden from assistive technology but still there.
      expect(screen.getByRole("link", { name: "Handbook", hidden: true })).toBeInTheDocument();
    });

    it("removes the resource once confirmed, and it disappears from the list", async () => {
      const user = userEvent.setup();
      const { api } = setup({ api: { resources: resourceServer() } });
      await openConfirm(user);
      await user.click(screen.getByRole("button", { name: "Yes" }));

      await waitFor(() => expect(api.resources.remove).toHaveBeenCalledWith("c1", "r1"));
      await waitFor(() => expect(screen.queryByRole("link", { name: "Handbook" })).not.toBeInTheDocument());
      expect(screen.getByRole("link", { name: "Parks Guide" })).toBeInTheDocument();
      await waitFor(() =>
        expect(screen.queryByText("Are you sure you want to delete this resource?")).not.toBeInTheDocument(),
      );
    });

    it("deletes only the resource whose button was pressed", async () => {
      const user = userEvent.setup();
      const { api } = setup({ api: { resources: resourceServer() } });
      await openConfirm(user, "Parks Guide");
      await user.click(screen.getByRole("button", { name: "Yes" }));

      await waitFor(() => expect(api.resources.remove).toHaveBeenCalledWith("c1", "r2"));
      expect(api.resources.remove).toHaveBeenCalledTimes(1);
      await waitFor(() => expect(screen.queryByRole("link", { name: "Parks Guide" })).not.toBeInTheDocument());
      expect(screen.getByRole("link", { name: "Handbook" })).toBeInTheDocument();
    });

    it("keeps the resource when the confirmation is dismissed", async () => {
      const user = userEvent.setup();
      const { api } = setup({ api: { resources: resourceServer() } });
      await openConfirm(user);
      await user.click(screen.getByRole("button", { name: "Close" }));

      await waitFor(() =>
        expect(screen.queryByText("Are you sure you want to delete this resource?")).not.toBeInTheDocument(),
      );
      expect(api.resources.remove).not.toHaveBeenCalled();
      expect(screen.getByRole("link", { name: "Handbook" })).toBeInTheDocument();
    });

    it("tells the user when the delete fails and keeps the resource", async () => {
      const user = userEvent.setup();
      setup({
        api: {
          resources: {
            ...resourceServer(),
            remove: async () => {
              throw new Error("denied");
            },
          },
        },
      });
      await openConfirm(user);
      await user.click(screen.getByRole("button", { name: "Yes" }));

      expect(await screen.findByText("Something went wrong. Please try again.")).toBeInTheDocument();
      expect(screen.getByRole("link", { name: "Handbook" })).toBeInTheDocument();
    });
  });
});

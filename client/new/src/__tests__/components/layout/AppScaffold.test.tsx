// @vitest-environment jsdom
import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useTheme } from "@mui/material/styles";
import { describe, expect, it, vi } from "vitest";
import { me } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { createAppTheme } from "@/theme/theme";
import { AppScaffold, ScaffoldFab } from "@/components/layout/AppScaffold";

const api = {
  me: { get: async () => me() },
  communities: { listMine: async () => [] },
};

function PrimaryColor() {
  return <p data-testid="primary">{useTheme().palette.primary.main}</p>;
}

describe("AppScaffold", () => {
  it("renders the nav bar, the page content and the bottom nav", () => {
    renderWithProviders(
      <AppScaffold bottomNav={<nav aria-label="Bottom bar">bottom</nav>}>
        <main>Page content</main>
      </AppScaffold>,
      { api },
    );
    expect(screen.getByRole("link", { name: "Frankly home" })).toBeInTheDocument();
    expect(screen.getByRole("main")).toHaveTextContent("Page content");
    expect(screen.getByRole("navigation", { name: "Bottom bar" })).toBeInTheDocument();
  });

  it("opens the sidebar drawer from the nav bar and closes it again", async () => {
    const user = userEvent.setup();
    renderWithProviders(<AppScaffold>content</AppScaffold>, { api });
    expect(screen.queryByText("Frankly Home")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Show sidebar" }));
    expect(await screen.findByText("Frankly Home")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Close" }));
    await waitFor(() => expect(screen.queryByText("Frankly Home")).not.toBeInTheDocument());
  });

  it("closes the sidebar when a link in it navigates away", async () => {
    const user = userEvent.setup();
    renderWithProviders(<AppScaffold>content</AppScaffold>, { api });
    await user.click(screen.getByRole("button", { name: "Show sidebar" }));
    await user.click(await screen.findByRole("button", { name: "Frankly Home" }));
    await waitFor(() => expect(screen.queryByText("Help Center")).not.toBeInTheDocument());
  });

  it("applies the child theme to the page content, not to what is outside the scaffold", () => {
    const childTheme = createAppTheme({ primary: "#123456", secondary: "#abcdef" });
    renderWithProviders(
      <>
        <PrimaryColor />
        <AppScaffold childTheme={childTheme}>
          <PrimaryColor />
        </AppScaffold>
      </>,
      { api },
    );
    const [outside, inside] = screen.getAllByTestId("primary");
    expect(inside).toHaveTextContent("#123456");
    expect(outside).not.toHaveTextContent("#123456");
  });
});

describe("ScaffoldFab", () => {
  it("renders nothing outside a scaffold", () => {
    renderWithProviders(<ScaffoldFab text="Create an event" onClick={() => {}} />);
    expect(screen.queryByRole("button", { name: "Create an event" })).not.toBeInTheDocument();
  });

  it("shows a labeled button on wide screens and reports clicks", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    renderWithProviders(
      <AppScaffold>
        <ScaffoldFab text="Create an event" onClick={onClick} />
      </AppScaffold>,
      { api },
    );
    const fab = await screen.findByRole("button", { name: "Create an event" });
    expect(fab).toHaveTextContent("Create an event");
    await user.click(fab);
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("shows only the icon on phone-width screens", async () => {
    renderWithProviders(
      <AppScaffold>
        <ScaffoldFab text="Create an event" onClick={() => {}} />
      </AppScaffold>,
      { api, mobile: true },
    );
    const fab = await screen.findByRole("button", { name: "Create an event" });
    expect(fab.textContent).toBe("");
  });
});

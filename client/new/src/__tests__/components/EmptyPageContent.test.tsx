// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { EmptyPageContent, type EmptyPageType } from "@/components/EmptyPageContent";

describe("EmptyPageContent", () => {
  it.each<[EmptyPageType, string]>([
    ["posts", "Create a post"],
    ["events", "Create an event"],
    ["resources", "Create a resource"],
  ])("shows the default %s message and the matching action", async (type, buttonText) => {
    const user = userEvent.setup();
    const onButtonPress = vi.fn();
    renderWithProviders(<EmptyPageContent type={type} onButtonPress={onButtonPress} />);

    expect(screen.getByRole("heading", { level: 3, name: `No ${type}` })).toBeInTheDocument();
    expect(screen.getByText(`When new ${type} are added, you'll see them here.`)).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: buttonText }));

    expect(onButtonPress).toHaveBeenCalledTimes(1);
  });

  it("has no button unless the user can act (no onButtonPress)", () => {
    renderWithProviders(<EmptyPageContent type="events" />);

    expect(screen.getByRole("heading", { name: "No events" })).toBeInTheDocument();
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("lets callers override the title, subtitle and button text", () => {
    renderWithProviders(
      <EmptyPageContent
        type="posts"
        titleText="Nothing yet"
        subtitleText="Be the first to share."
        buttonText="Write something"
        onButtonPress={vi.fn()}
      />,
    );

    expect(screen.getByRole("heading", { name: "Nothing yet" })).toBeInTheDocument();
    expect(screen.getByText("Be the first to share.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Write something" })).toBeInTheDocument();
    expect(screen.queryByText("No posts")).not.toBeInTheDocument();
  });

  it("hides the decorative emoji from assistive tech", () => {
    renderWithProviders(<EmptyPageContent type="posts" />);

    expect(screen.getByText("💬")).toHaveAttribute("aria-hidden", "true");
  });
});

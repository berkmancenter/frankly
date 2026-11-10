// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { CommunityCircleIcon } from "@/components/CommunityCircleIcon";

describe("CommunityCircleIcon", () => {
  it("shows the community picture when it has one", () => {
    const { container } = renderWithProviders(
      <CommunityCircleIcon community={{ name: "Civic Lab", profileImageUrl: "https://img.test/c.png" }} />,
    );

    expect(container.querySelector("img")).toHaveAttribute("src", "https://img.test/c.png");
    expect(screen.queryByText("C")).not.toBeInTheDocument();
  });

  it("falls back to the first letter of the name without a picture", () => {
    const { container } = renderWithProviders(<CommunityCircleIcon community={{ name: "civic lab" }} />);

    expect(screen.getByText("C")).toBeInTheDocument();
    expect(container.querySelector("img")).not.toBeInTheDocument();
  });

  it("names itself with the community name in a tooltip", async () => {
    const user = userEvent.setup();
    renderWithProviders(<CommunityCircleIcon community={{ name: "Civic Lab" }} />);

    const icon = screen.getByLabelText("Civic Lab");
    await user.hover(icon);

    expect(await screen.findByRole("tooltip")).toHaveTextContent("Civic Lab");
  });

  it("honors size and bordered", () => {
    renderWithProviders(
      <>
        <CommunityCircleIcon community={{ name: "Plain" }} size={60} />
        <CommunityCircleIcon community={{ name: "Ringed" }} bordered />
      </>,
    );

    expect(screen.getByLabelText("Plain")).toHaveStyle({ width: "60px", height: "60px", borderStyle: "none" });
    expect(screen.getByLabelText("Ringed")).toHaveStyle({ width: "42px", borderStyle: "solid" });
  });
});

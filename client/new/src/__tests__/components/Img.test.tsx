// @vitest-environment jsdom
import { fireEvent, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { Img } from "@/components/Img";

describe("Img", () => {
  it("renders the image with its src and alt", () => {
    renderWithProviders(<Img src="https://img.test/a.png" alt="A cat" />);

    expect(screen.getByAltText("A cat")).toHaveAttribute("src", "https://img.test/a.png");
    expect(screen.queryByTestId("BrokenImageIcon")).not.toBeInTheDocument();
  });

  it("renders just the empty placeholder when there is no src", () => {
    const { container } = renderWithProviders(<Img src={null} width={80} height={60} />);

    expect(container.querySelector("img")).not.toBeInTheDocument();
    expect(screen.queryByTestId("BrokenImageIcon")).not.toBeInTheDocument();
    expect(container.firstElementChild).toHaveStyle({ width: "80px", height: "60px" });
  });

  it("swaps in a broken-image icon when the image fails to load", () => {
    renderWithProviders(<Img src="https://img.test/missing.png" alt="Gone" />);

    fireEvent.error(screen.getByAltText("Gone"));

    expect(screen.queryByAltText("Gone")).not.toBeInTheDocument();
    expect(screen.getByTestId("BrokenImageIcon")).toBeInTheDocument();
  });

  it("applies fit, radius and size to the frame", () => {
    renderWithProviders(<Img src="https://img.test/a.png" alt="Pic" fit="contain" radius="50%" width={40} height={40} />);

    expect(screen.getByAltText("Pic")).toHaveStyle({ objectFit: "contain" });
    expect(screen.getByAltText("Pic").parentElement).toHaveStyle({ width: "40px", height: "40px", borderRadius: "50%" });
  });

  it("recovers when src changes after an error", async () => {
    const user = userEvent.setup();
    function Swappable() {
      const [src, setSrc] = useState("https://img.test/missing.png");
      return (
        <>
          <Img src={src} alt="Pic" />
          <button onClick={() => setSrc("https://img.test/fixed.png")}>Fix</button>
        </>
      );
    }
    renderWithProviders(<Swappable />);
    fireEvent.error(screen.getByAltText("Pic"));
    expect(screen.getByTestId("BrokenImageIcon")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Fix" }));

    expect(screen.getByAltText("Pic")).toHaveAttribute("src", "https://img.test/fixed.png");
  });
});

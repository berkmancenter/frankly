// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { ErrorState, LoadingState } from "@/components/States";

describe("LoadingState", () => {
  it("shows a spinner, and a message when given one", () => {
    renderWithProviders(<LoadingState message="Fetching events" />);

    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.getByText("Fetching events")).toBeInTheDocument();
  });

  it("shows only the spinner by default and reserves the requested height", () => {
    const { container } = renderWithProviders(<LoadingState height={120} />);

    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(container.firstElementChild).toHaveTextContent("");
    expect(container.firstElementChild).toHaveStyle({ height: "120px" });
  });
});

describe("ErrorState", () => {
  it("announces the default message as an alert", () => {
    renderWithProviders(<ErrorState />);

    expect(screen.getByRole("alert")).toHaveTextContent("Something went wrong. Please refresh.");
  });

  it("shows a custom message and an action", () => {
    renderWithProviders(<ErrorState message="Could not load posts." action={<button>Retry</button>} />);

    expect(screen.getByRole("alert")).toHaveTextContent("Could not load posts.");
    expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
    expect(screen.queryByText("Something went wrong. Please refresh.")).not.toBeInTheDocument();
  });
});

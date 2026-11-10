// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { VerticalTimeAndDateIndicator } from "@/components/events/TimeIndicator";

// Local time, so the expectations hold in any time zone. 2030-01-01 is a Tuesday.
const start = new Date(2030, 0, 1, 18, 0);

describe("VerticalTimeAndDateIndicator", () => {
  it("shows the month, day, weekday and the start-to-end time range", () => {
    renderWithProviders(<VerticalTimeAndDateIndicator time={start} durationMinutes={90} />);
    expect(screen.getByText("JAN")).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 2, name: "1" })).toBeInTheDocument();
    expect(screen.getByText("Tue")).toBeInTheDocument();
    expect(screen.getByText("6:00p - 7:30p")).toBeInTheDocument();
  });

  it("shows only the start time without a duration", () => {
    renderWithProviders(<VerticalTimeAndDateIndicator time={start} />);
    expect(screen.getByText("6:00p")).toBeInTheDocument();
    expect(screen.queryByText(/ - /)).not.toBeInTheDocument();
  });

  it("treats a zero duration like no duration", () => {
    renderWithProviders(<VerticalTimeAndDateIndicator time={start} durationMinutes={0} />);
    expect(screen.getByText("6:00p")).toBeInTheDocument();
  });

  it("shows an end time on the next day correctly for events that cross midnight", () => {
    renderWithProviders(<VerticalTimeAndDateIndicator time={new Date(2030, 0, 1, 23, 30)} durationMinutes={60} />);
    expect(screen.getByText("11:30p - 12:30a")).toBeInTheDocument();
  });
});

// @vitest-environment jsdom
import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it, vi } from "vitest";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { combineDateAndTime, MonthCalendar, TimeInput, type TimeValue } from "@/components/pickers";

// All dates are built from local components, so the tests do not depend on the machine's time zone.
const day = (y: number, m: number, d: number) => new Date(y, m - 1, d);

describe("MonthCalendar", () => {
  const today = day(2030, 1, 15);

  const renderCalendar = (props: Partial<React.ComponentProps<typeof MonthCalendar>> = {}) => {
    const onChange = vi.fn();
    const view = renderWithProviders(
      <MonthCalendar value={null} onChange={onChange} minDate={today} today={today} {...props} />,
    );
    return { ...view, onChange };
  };

  it("opens on the month of the selected value, falling back to today's month", () => {
    const { unmount } = renderCalendar({ value: day(2030, 3, 9) });
    expect(screen.getByText("March 2030")).toBeInTheDocument();
    unmount();

    renderCalendar();
    expect(screen.getByText("January 2030")).toBeInTheDocument();
  });

  it("lays out every day of the month as a button", () => {
    renderCalendar({ value: day(2030, 2, 10), minDate: day(2030, 1, 1) });

    // February 2030 has 28 days; the grid also has seven weekday headers that are not buttons.
    const days = screen.getAllByRole("button").filter((b) => /^\w{3} \w{3} \d{2} 2030$/.test(b.getAttribute("aria-label") ?? ""));
    expect(days).toHaveLength(28);
    expect(screen.getByRole("button", { name: day(2030, 2, 28).toDateString() })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: day(2030, 3, 1).toDateString() })).not.toBeInTheDocument();
  });

  it("reports the clicked day", async () => {
    const user = userEvent.setup();
    const { onChange } = renderCalendar();

    await user.click(screen.getByRole("button", { name: day(2030, 1, 20).toDateString() }));

    expect(onChange).toHaveBeenCalledTimes(1);
    expect(onChange.mock.calls[0]![0]).toEqual(day(2030, 1, 20));
  });

  it("marks the selected day as pressed", () => {
    renderCalendar({ value: day(2030, 1, 20) });

    expect(screen.getByRole("button", { name: day(2030, 1, 20).toDateString() })).toHaveAttribute("aria-pressed", "true");
    expect(screen.getByRole("button", { name: day(2030, 1, 21).toDateString() })).toHaveAttribute("aria-pressed", "false");
  });

  it("disables days before minDate and does not report clicks on them", async () => {
    const user = userEvent.setup({ pointerEventsCheck: 0 });
    const { onChange } = renderCalendar();

    const before = screen.getByRole("button", { name: day(2030, 1, 14).toDateString() });
    expect(before).toBeDisabled();
    expect(screen.getByRole("button", { name: day(2030, 1, 15).toDateString() })).toBeEnabled();
    await user.click(before);

    expect(onChange).not.toHaveBeenCalled();
  });

  it("pages forward freely but cannot page back past the month of minDate", async () => {
    const user = userEvent.setup();
    renderCalendar();
    const back = screen.getByRole("button", { name: "Previous month" });
    expect(back).toBeDisabled();

    await user.click(screen.getByRole("button", { name: "Next month" }));
    expect(screen.getByText("February 2030")).toBeInTheDocument();
    expect(back).toBeEnabled();

    await user.click(back);
    expect(screen.getByText("January 2030")).toBeInTheDocument();
    expect(back).toBeDisabled();
  });

  it("rolls over the year boundary when paging", async () => {
    const user = userEvent.setup();
    renderCalendar({ value: day(2030, 12, 5) });
    expect(screen.getByText("December 2030")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Next month" }));

    expect(screen.getByText("January 2031")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: day(2031, 1, 31).toDateString() })).toBeEnabled();
  });
});

describe("TimeInput", () => {
  const nine: TimeValue = { hour: 9, minute: 5, pm: false };

  /** Keeps the value in state, like the real form does, and spies on what it reports. */
  function renderTime(initial: TimeValue = nine) {
    const onChange = vi.fn();
    function Controlled() {
      const [value, setValue] = useState(initial);
      return (
        <TimeInput
          value={value}
          onChange={(next) => {
            setValue(next);
            onChange(next);
          }}
        />
      );
    }
    return { ...renderWithProviders(<Controlled />), onChange };
  }
  const hourField = () => screen.getByRole("textbox", { name: "Hour" });
  const minuteField = () => screen.getByRole("textbox", { name: "Minute" });

  it("shows zero-padded hour and minute and the AM/PM selection", () => {
    renderTime();

    expect(hourField()).toHaveValue("09");
    expect(minuteField()).toHaveValue("05");
    const group = screen.getByRole("group", { name: "AM or PM" });
    expect(within(group).getByRole("button", { name: "AM" })).toHaveAttribute("aria-pressed", "true");
    expect(within(group).getByRole("button", { name: "PM" })).toHaveAttribute("aria-pressed", "false");
  });

  it("toggles AM/PM", async () => {
    const user = userEvent.setup();
    const { onChange } = renderTime();

    await user.click(screen.getByRole("button", { name: "PM" }));
    expect(onChange).toHaveBeenLastCalledWith({ hour: 9, minute: 5, pm: true });
    expect(screen.getByRole("button", { name: "PM" })).toHaveAttribute("aria-pressed", "true");

    await user.click(screen.getByRole("button", { name: "AM" }));
    expect(onChange).toHaveBeenLastCalledWith({ hour: 9, minute: 5, pm: false });
  });

  it("selects a field's contents on focus, so typing a digit replaces it", async () => {
    const user = userEvent.setup();
    const { onChange } = renderTime();

    await user.click(hourField());
    await user.keyboard("7");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 7, minute: 5, pm: false });
    // While focused the field shows what was typed; it is zero-padded again on blur.
    expect(hourField()).toHaveValue("7");

    await user.click(minuteField());
    expect(hourField()).toHaveValue("07");
    await user.keyboard("3");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 7, minute: 3, pm: false });
    expect(minuteField()).toHaveValue("3");

    await user.tab();
    expect(minuteField()).toHaveValue("03");
  });

  it("clamps hours to 1-12 and minutes to 0-59", async () => {
    const user = userEvent.setup();
    const { onChange } = renderTime();

    // Alternating fields re-focuses each one, which selects its text so the paste replaces it.
    await user.click(hourField());
    await user.paste("99");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 12, minute: 5, pm: false });
    expect(hourField()).toHaveValue("12");

    await user.click(minuteField());
    await user.paste("99");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 12, minute: 59, pm: false });
    expect(minuteField()).toHaveValue("59");

    // A lone "0" is kept while the user may still type "05"; the committed hour is already 1.
    await user.click(hourField());
    await user.paste("0");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 1, minute: 59, pm: false });
    expect(hourField()).toHaveValue("0");

    await user.click(minuteField());
    expect(hourField()).toHaveValue("01");
    await user.paste("0");
    await user.tab();
    expect(minuteField()).toHaveValue("00");
    expect(onChange).toHaveBeenLastCalledWith({ hour: 1, minute: 0, pm: false });
  });

  it("drops non-digit characters", async () => {
    const user = userEvent.setup();
    const { onChange } = renderTime();

    await user.click(hourField());
    await user.paste("1a");

    expect(onChange).toHaveBeenLastCalledWith({ hour: 1, minute: 5, pm: false });
    expect(hourField()).toHaveValue("1");

    await user.tab();
    expect(hourField()).toHaveValue("01");
  });

  it("lets a field be emptied while editing, then restores the previous value on blur", async () => {
    const user = userEvent.setup();
    const { onChange } = renderTime();

    await user.click(hourField());
    await user.keyboard("{Backspace}");
    expect(hourField()).toHaveValue("");
    await user.click(minuteField());
    await user.paste("x");
    expect(minuteField()).toHaveValue("");

    expect(onChange).not.toHaveBeenCalled();
    expect(hourField()).toHaveValue("09");
    await user.tab();
    expect(minuteField()).toHaveValue("05");
  });

  it("lets the user type a two-digit hour digit by digit", async () => {
    const user = userEvent.setup();
    renderTime({ hour: 9, minute: 0, pm: false });

    await user.click(hourField());
    await user.keyboard("12");

    expect(hourField()).toHaveValue("12");
  });
});

describe("combineDateAndTime", () => {
  it.each([
    [12, 0, false, 0], // 12:00 AM is midnight
    [12, 30, false, 0],
    [1, 0, false, 1],
    [11, 59, false, 11],
    [12, 0, true, 12], // 12:00 PM is noon
    [1, 15, true, 13],
    [11, 59, true, 23],
  ])("%i:%i pm=%s is hour %i of the day", (hour, minute, pm, expectedHour) => {
    const result = combineDateAndTime(day(2030, 6, 20), { hour, minute, pm });

    expect(result).toEqual(new Date(2030, 5, 20, expectedHour, minute, 0, 0));
  });

  it("keeps the calendar day and zeroes seconds and milliseconds", () => {
    const withClock = new Date(2030, 6, 4, 22, 41, 59, 999);

    const result = combineDateAndTime(withClock, { hour: 3, minute: 7, pm: true });

    expect(result.getFullYear()).toBe(2030);
    expect(result.getMonth()).toBe(6);
    expect(result.getDate()).toBe(4);
    expect(result.getSeconds()).toBe(0);
    expect(result.getMilliseconds()).toBe(0);
  });

  it("does not mutate the day it is given", () => {
    const base = day(2030, 6, 20);
    const copy = new Date(base);

    combineDateAndTime(base, { hour: 5, minute: 5, pm: true });

    expect(base).toEqual(copy);
  });
});

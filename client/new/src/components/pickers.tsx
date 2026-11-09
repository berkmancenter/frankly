import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useState } from "react";
import { isSameCalendarDay, startOfDay } from "@/utils/format";
import { colors, fontSizes } from "@/theme/tokens";

const WEEKDAYS = ["S", "M", "T", "W", "T", "F", "S"];
const monthName = new Intl.DateTimeFormat("en-US", {
  month: "long",
  year: "numeric",
});

/**
 * Month-grid calendar in the Material 3 date-picker style (the Flutter app embeds the
 * Material `CalendarDatePicker`). Days before `minDate` are disabled.
 */
export function MonthCalendar({
  value,
  onChange,
  minDate,
  today,
}: {
  value: Date | null;
  onChange: (date: Date) => void;
  minDate: Date;
  /** Authoritative "today" (from the clock), used for the today ring. */
  today: Date;
}) {
  const [cursor, setCursor] = useState(
    () =>
      new Date((value ?? today).getFullYear(), (value ?? today).getMonth(), 1),
  );
  const first = new Date(cursor.getFullYear(), cursor.getMonth(), 1);
  const daysInMonth = new Date(
    cursor.getFullYear(),
    cursor.getMonth() + 1,
    0,
  ).getDate();
  const cells: (Date | null)[] = [
    ...Array.from({ length: first.getDay() }, () => null),
    ...Array.from(
      { length: daysInMonth },
      (_, i) => new Date(cursor.getFullYear(), cursor.getMonth(), i + 1),
    ),
  ];
  const min = startOfDay(minDate);
  const canGoBack = new Date(cursor.getFullYear(), cursor.getMonth(), 0) >= min;

  return (
    <Box sx={{ width: "100%", maxWidth: 380, mx: "auto" }}>
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          mb: "8px",
        }}
      >
        <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500 }}>{monthName.format(cursor)}</Typography>
        <Box>
          <IconButton
            aria-label="Previous month"
            disabled={!canGoBack}
            onClick={() =>
              setCursor(
                new Date(cursor.getFullYear(), cursor.getMonth() - 1, 1),
              )
            }
          >
            <ChevronLeftIcon />
          </IconButton>
          <IconButton
            aria-label="Next month"
            onClick={() =>
              setCursor(
                new Date(cursor.getFullYear(), cursor.getMonth() + 1, 1),
              )
            }
          >
            <ChevronRightIcon />
          </IconButton>
        </Box>
      </Box>
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(7, 1fr)",
          rowGap: "4px",
          justifyItems: "center",
        }}
      >
        {WEEKDAYS.map((d, i) => (
          <Typography
            key={i}
            sx={{ fontSize: fontSizes.xs, color: colors.onSurface, height: 40, lineHeight: "40px" }}
          >
            {d}
          </Typography>
        ))}
        {cells.map((day, i) => {
          if (!day) return <Box key={`blank-${i}`} />;
          const disabled = day < min;
          const selected = !!value && isSameCalendarDay(day, value);
          const isToday = isSameCalendarDay(day, today);
          return (
            <ButtonBase
              key={day.toISOString()}
              disabled={disabled}
              onClick={() => onChange(day)}
              aria-label={day.toDateString()}
              aria-pressed={selected}
              sx={{
                width: 40,
                height: 40,
                borderRadius: "50%",
                fontSize: 14,
                bgcolor: selected ? "primary.main" : "transparent",
                color: selected
                  ? "primary.contrastText"
                  : disabled
                    ? "rgba(28,27,27,0.38)"
                    : colors.onSurface,
                border: isToday && !selected ? "1px solid" : "none",
                borderColor: colors.outline,
                "&:hover": {
                  bgcolor: selected ? "primary.main" : "action.hover",
                },
              }}
            >
              {day.getDate()}
            </ButtonBase>
          );
        })}
      </Box>
    </Box>
  );
}

export interface TimeValue {
  /** 1-12 */
  hour: number;
  /** 0-59 */
  minute: number;
  pm: boolean;
}

const clamp = (n: number, lo: number, hi: number) =>
  Math.min(hi, Math.max(lo, n));

/** Material 3 time picker, "input" mode: big hour/minute fields and an AM/PM toggle. */
export function TimeInput({
  value,
  onChange,
}: {
  value: TimeValue;
  onChange: (v: TimeValue) => void;
}) {
  const field = (
    label: string,
    v: string,
    set: (raw: string) => void,
    ariaLabel: string,
  ) => (
    <Box>
      <Box
        component="input"
        inputMode="numeric"
        aria-label={ariaLabel}
        value={v}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
          set(e.target.value.replace(/\D/g, "").slice(0, 2))
        }
        onFocus={(e: React.FocusEvent<HTMLInputElement>) => e.target.select()}
        sx={{
          width: 96,
          height: 72,
          textAlign: "center",
          fontSize: 45,
          fontFamily: "inherit",
          color: colors.onSurface,
          bgcolor: colors.surfaceContainerHighest,
          border: "2px solid transparent",
          borderRadius: "8px",
          outline: "none",
          "&:focus": { borderColor: "primary.main" },
        }}
      />
      <Typography sx={{ fontSize: fontSizes.xs, display: "block", mt: "4px" }}>
        {label}
      </Typography>
    </Box>
  );

  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "flex-start",
        justifyContent: "center",
        gap: "8px",
      }}
    >
      {field(
        "Hour",
        String(value.hour).padStart(2, "0"),
        (raw) => raw && onChange({ ...value, hour: clamp(Number(raw), 1, 12) }),
        "Hour",
      )}
      <Typography sx={{ fontSize: 45, lineHeight: "72px" }}>:</Typography>
      {field(
        "Minute",
        String(value.minute).padStart(2, "0"),
        (raw) =>
          raw !== "" &&
          onChange({ ...value, minute: clamp(Number(raw), 0, 59) }),
        "Minute",
      )}
      <Box
        role="group"
        aria-label="AM or PM"
        sx={{
          ml: "12px",
          border: "1px solid",
          borderColor: colors.outline,
          borderRadius: "8px",
          overflow: "hidden",
          height: 72,
        }}
      >
        {(["AM", "PM"] as const).map((label) => {
          const selected = (label === "PM") === value.pm;
          return (
            <ButtonBase
              key={label}
              onClick={() => onChange({ ...value, pm: label === "PM" })}
              aria-pressed={selected}
              sx={{
                display: "flex",
                width: 52,
                height: 36,
                fontSize: 16,
                fontWeight: 500,
                bgcolor: selected ? colors.secondaryContainer : "transparent",
                color: selected
                  ? colors.onSecondaryContainer
                  : colors.onSurfaceVariant,
                borderTop: label === "PM" ? "1px solid" : "none",
                borderColor: colors.outline,
              }}
            >
              {label}
            </ButtonBase>
          );
        })}
      </Box>
    </Box>
  );
}

/** Combine a calendar day and a 12-hour time value into a local `Date`. */
export function combineDateAndTime(day: Date, t: TimeValue): Date {
  const hours = (t.hour % 12) + (t.pm ? 12 : 0);
  return new Date(
    day.getFullYear(),
    day.getMonth(),
    day.getDate(),
    hours,
    t.minute,
    0,
    0,
  );
}

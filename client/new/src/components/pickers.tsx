import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
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
            aria-label={t({ id: "monthCalendar.previousMonth", message: "Previous month" })}
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
            aria-label={t({ id: "monthCalendar.nextMonth", message: "Next month" })}
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

/**
 * One numeric field. While focused it shows what the user has typed so far ("1" on the way to
 * "12"); the zero-padded committed value ("01") is shown again on blur. Re-padding on every
 * keystroke would turn "1" into "01" and make a two-digit value impossible to type.
 */
function TimeField({
  label,
  value,
  min,
  max,
  onCommit,
}: {
  label: string;
  value: number;
  min: number;
  max: number;
  onCommit: (n: number) => void;
}) {
  const [draft, setDraft] = useState<string | null>(null);
  return (
    <Box>
      <Box
        component="input"
        inputMode="numeric"
        aria-label={label}
        value={draft ?? String(value).padStart(2, "0")}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
          const raw = e.target.value.replace(/\D/g, "").slice(0, 2);
          if (raw === "") return setDraft(raw);
          const n = clamp(Number(raw), min, max);
          onCommit(n);
          // A one-digit "0" (hour) may still become "05"; a complete out-of-range entry ("99")
          // snaps to the clamped value right away.
          setDraft(n === Number(raw) || raw.length < 2 ? raw : null);
        }}
        onFocus={(e: React.FocusEvent<HTMLInputElement>) => e.target.select()}
        onBlur={() => setDraft(null)}
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
}

/** Material 3 time picker, "input" mode: big hour/minute fields and an AM/PM toggle. */
export function TimeInput({
  value,
  onChange,
}: {
  value: TimeValue;
  onChange: (v: TimeValue) => void;
}) {
  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "flex-start",
        justifyContent: "center",
        gap: "8px",
      }}
    >
      <TimeField
        label={t({ id: "timeInput.hour", message: "Hour" })}
        value={value.hour}
        min={1}
        max={12}
        onCommit={(hour) => onChange({ ...value, hour })}
      />
      <Typography sx={{ fontSize: 45, lineHeight: "72px" }}>:</Typography>
      <TimeField
        label={t({ id: "timeInput.minute", message: "Minute" })}
        value={value.minute}
        min={0}
        max={59}
        onCommit={(minute) => onChange({ ...value, minute })}
      />
      <Box
        role="group"
        aria-label={t({ id: "timeInput.amOrPm", message: "AM or PM" })}
        sx={{
          ml: "12px",
          border: "1px solid",
          borderColor: colors.outline,
          borderRadius: "8px",
          overflow: "hidden",
          height: 72,
        }}
      >
        {(["AM", "PM"] as const).map((periodKey) => {
          const selected = (periodKey === "PM") === value.pm;
          const periodLabel =
            periodKey === "PM"
              ? t({ id: "timeInput.pm", message: "PM" })
              : t({ id: "timeInput.am", message: "AM" });
          return (
            <ButtonBase
              key={periodKey}
              onClick={() => onChange({ ...value, pm: periodKey === "PM" })}
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
                borderTop: periodKey === "PM" ? "1px solid" : "none",
                borderColor: colors.outline,
              }}
            >
              {periodLabel}
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

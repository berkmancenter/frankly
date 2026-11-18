import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { DateCalendar } from "@mui/x-date-pickers/DateCalendar";
import { AdapterDateFns } from "@mui/x-date-pickers/AdapterDateFns";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { enUS as pickersEnUS, esES, zhCN as pickersZhCN, zhTW } from "@mui/x-date-pickers/locales";
import { enUS, es, zhCN, zhTW as dateFnsZhTW } from "date-fns/locale";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { colors } from "@/theme/tokens";
import { startOfDay } from "@/utils/format";

// The calendar speaks the app's language: month names come from date-fns, button labels from the pickers.
function calendarLocale(locale: string) {
  if (locale.startsWith("es")) return { adapter: es, text: esES };
  if (locale === "zh-Hant-TW" || locale === "zh_Hant_TW") return { adapter: dateFnsZhTW, text: zhTW };
  if (locale.startsWith("zh")) return { adapter: zhCN, text: pickersZhCN };
  return { adapter: enUS, text: pickersEnUS };
}

// Month-grid calendar. Days before `minDate` are disabled.
export function MonthCalendar({
  value,
  onChange,
  minDate,
  today,
}: {
  value: Date | null;
  onChange: (date: Date) => void;
  minDate: Date;
  /** Authoritative "today" (from the clock): the month shown when nothing is selected. */
  today: Date;
}) {
  const { i18n } = useLingui();
  const { adapter, text } = calendarLocale(i18n.locale);
  return (
    <LocalizationProvider
      dateAdapter={AdapterDateFns}
      adapterLocale={adapter}
      localeText={text.components.MuiLocalizationProvider.defaultProps.localeText}
    >
      <DateCalendar
        value={value}
        // Callers care about the day, not the time of day the picker carries over.
        onChange={(next) => next && onChange(startOfDay(next))}
        minDate={minDate}
        referenceDate={today}
        sx={{ width: "100%", maxWidth: 380, mx: "auto" }}
      />
    </LocalizationProvider>
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
      <Typography variant="body2" sx={{ display: "block", mt: "4px" }}>
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
  const { t } = useLingui();
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

import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import {
  formatMonthShortUpper,
  formatTimeShort,
  formatWeekdayShort,
} from "@/utils/format";
import { colors, fontSizes } from "@/theme/tokens";

/** `VerticalTimeAndDateIndicator`: MON / day number / weekday / `6:00p - 7:00p`. */
export function VerticalTimeAndDateIndicator({
  time,
  durationMinutes,
  disabled = false,
  padding = "8px 16px",
}: {
  time: Date;
  durationMinutes?: number;
  disabled?: boolean;
  padding?: string | number;
}) {
  const end = durationMinutes
    ? new Date(time.getTime() + durationMinutes * 60_000)
    : undefined;
  const color = disabled ? "rgba(28,27,27,0.75)" : colors.onSurface;
  const timeString = end
    ? `${formatTimeShort(time)} - ${formatTimeShort(end)}`
    : formatTimeShort(time);
  return (
    <Box
      sx={{
        p: padding,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        color,
        flexShrink: 0,
      }}
    >
      <Typography sx={{ fontSize: fontSizes.xs, color: "inherit" }}>
        {formatMonthShortUpper(time)}
      </Typography>
      <Typography component="h2" sx={{ fontSize: fontSizes["3xl"], color: "inherit" }}>
        {time.getDate()}
      </Typography>
      <Typography sx={{ color: "inherit" }}>
        {formatWeekdayShort(time)}
      </Typography>
      <Typography
        sx={{ color: "inherit", fontSize: 14, whiteSpace: "nowrap" }}
      >
        {timeString}
      </Typography>
    </Box>
  );
}

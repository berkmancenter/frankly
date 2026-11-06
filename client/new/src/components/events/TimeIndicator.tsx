import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import {
  formatMonthShortUpper,
  formatTimeShort,
  formatWeekdayShort,
} from '@/lib/format';

/** `VerticalTimeAndDateIndicator`: MON / day number / weekday / `6:00p - 7:00p`. */
export function VerticalTimeAndDateIndicator({
  time,
  durationMinutes,
  disabled = false,
  padding = '8px 16px',
}: {
  time: Date;
  durationMinutes?: number;
  disabled?: boolean;
  padding?: string | number;
}) {
  const end = durationMinutes ? new Date(time.getTime() + durationMinutes * 60_000) : undefined;
  const color = disabled ? 'rgba(28,27,27,0.75)' : 'm3.onSurface';
  const timeString = end ? `${formatTimeShort(time)} - ${formatTimeShort(end)}` : formatTimeShort(time);
  return (
    <Box sx={{ p: padding, display: 'flex', flexDirection: 'column', alignItems: 'center', color, flexShrink: 0 }}>
      <Typography variant="bodySmall" sx={{ color: 'inherit' }}>
        {formatMonthShortUpper(time)}
      </Typography>
      <Typography variant="headlineMedium" sx={{ color: 'inherit' }}>
        {time.getDate()}
      </Typography>
      <Typography variant="bodyMedium" sx={{ color: 'inherit' }}>
        {formatWeekdayShort(time)}
      </Typography>
      <Typography variant="bodyMedium" sx={{ color: 'inherit', fontSize: 14, whiteSpace: 'nowrap' }}>
        {timeString}
      </Typography>
    </Box>
  );
}

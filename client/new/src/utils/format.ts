const LOCALE = 'en-US';

const fmt = (options: Intl.DateTimeFormatOptions) => new Intl.DateTimeFormat(LOCALE, options);

const timeParts = fmt({ hour: 'numeric', minute: '2-digit', hour12: true });
const weekdayShort = fmt({ weekday: 'short' });
const monthShort = fmt({ month: 'short' });
const monthDayYearTime = fmt({
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour: 'numeric',
  minute: '2-digit',
  hour12: true,
});

/** `h:mma` lower-cased with the trailing "m" dropped: `3:00p`, `11:30a` (Flutter `formatTimeShort`). */
export function formatTimeShort(date: Date): string {
  return timeParts.format(date).replace(/\s/g, '').toLowerCase().replace(/m$/, '');
}

export const formatMonthShortUpper = (d: Date) => monthShort.format(d).toUpperCase();
export const formatWeekdayShort = (d: Date) => weekdayShort.format(d);

/** Community announcement stamp: `Nov 4, 2026, 6:15 PM`. */
export function formatLongStamp(date: Date): string {
  return monthDayYearTime.format(date);
}

/** Whole calendar days from `from` to `to` (local time); negative if `to` is earlier. */
function calendarDayDiff(to: Date, from: Date): number {
  const a = Date.UTC(to.getFullYear(), to.getMonth(), to.getDate());
  const b = Date.UTC(from.getFullYear(), from.getMonth(), from.getDate());
  return Math.round((a - b) / 86_400_000);
}

export function isSameCalendarDay(a: Date, b: Date): boolean {
  return calendarDayDiff(a, b) === 0;
}

export function addDays(date: Date, days: number): Date {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  return d;
}

export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function compactNumber(n: number): string {
  return new Intl.NumberFormat(LOCALE, { notation: 'compact' }).format(n);
}

export function timeZoneAbbreviation(date: Date): string {
  const part = new Intl.DateTimeFormat(LOCALE, { timeZoneName: 'short' })
    .formatToParts(date)
    .find((p) => p.type === 'timeZoneName');
  return part?.value ?? '';
}

export function initials(name: string | undefined | null): string {
  const trimmed = (name ?? '').trim();
  return trimmed ? trimmed[0]!.toUpperCase() : '?';
}

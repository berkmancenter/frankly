// Timezone utilities using native Intl API (Node.js 12+)
// No external dependency needed for timezone conversion.

export interface TimezoneLocation {
  name: string;
}

export class TimezoneUtils {
  private static _instance?: TimezoneUtils;

  static getInstance(): TimezoneUtils {
    return (this._instance ??= new TimezoneUtils());
  }

  getLocation(name: string): { name: string; abbr: string } {
    // Return a simple object with name and abbreviation
    // In production, use a proper timezone library like luxon
    const now = new Date();
    try {
      const abbr = new Intl.DateTimeFormat('en-US', {
        timeZone: name,
        timeZoneName: 'short',
      })
        .formatToParts(now)
        .find((p) => p.type === 'timeZoneName')?.value ?? name;
      return { name, abbr };
    } catch {
      return { name, abbr: name };
    }
  }

  formatInTimezone(date: Date, timezone: string, format: string): string {
    // Using Intl.DateTimeFormat for timezone conversion
    return new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      year: 'numeric',
      month: 'short',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    }).format(date);
  }

  getDatePartsInTimezone(
    date: Date,
    timezone: string
  ): { year: number; month: number; day: number; hour: number; minute: number } {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      year: 'numeric',
      month: 'numeric',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      hour12: false,
    }).formatToParts(date);

    const get = (type: string) =>
      parseInt(parts.find((p) => p.type === type)?.value ?? '0');

    return {
      year: get('year'),
      month: get('month'),
      day: get('day'),
      hour: get('hour'),
      minute: get('minute'),
    };
  }
}

export const timezoneUtils = TimezoneUtils.getInstance();

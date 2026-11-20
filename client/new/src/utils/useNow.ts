import { useEffect, useState } from "react";
import { useClock } from "./clock";

// The current time from the app clock, refreshed every `periodMs`: for countdowns and "is it open yet".
export function useNow(periodMs = 1000): Date {
  const clock = useClock();
  const [now, setNow] = useState(() => clock.now());
  useEffect(() => {
    const id = setInterval(() => setNow(clock.now()), periodMs);
    return () => clearInterval(id);
  }, [clock, periodMs]);
  return now;
}

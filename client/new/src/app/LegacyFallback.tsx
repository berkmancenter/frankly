import { useEffect, useMemo } from 'react';
import { useLocation } from 'react-router';
import { LoadingState } from '@/components/States';
import { NotFoundPage } from '@/features/NotFoundPage';

const STORAGE_KEY = 'frankly:legacy-handoff';
/** A second hand-off of the same URL inside this window means the edge sent it straight back. */
const LOOP_WINDOW_MS = 5000;

/**
 * Whether to hand `target` to the legacy (Flutter) app. Refuses when we already handed this exact
 * URL off a moment ago: that means the edge routed it back here (rules out of sync, or no Flutter
 * behind this server), and reloading again would loop forever.
 */
export function shouldHandOff(target: string, previous: string | null, now: number): boolean {
  if (!previous) return true;
  try {
    const { target: t, at } = JSON.parse(previous) as { target: string; at: number };
    return !(t === target && now - at < LOOP_WINDOW_MS);
  } catch {
    return true;
  }
}

function read(): string | null {
  try {
    return sessionStorage.getItem(STORAGE_KEY);
  } catch {
    return null;
  }
}

function write(target: string) {
  try {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ target, at: Date.now() }));
  } catch {
    /* storage unavailable: the guard just can't remember */
  }
}

/**
 * Catch-all for URLs this app does not own. Navigating inside the React app to a page that has
 * not been migrated (a link, `navigate()`, back/forward) lands here; we replace the entry with a
 * full page load, and the proxy / hosting rewrites serve it from Flutter.
 */
export function LegacyFallback() {
  const { pathname, search, hash } = useLocation();
  const target = `${pathname}${search}${hash}`;
  const handOff = useMemo(() => shouldHandOff(target, read(), Date.now()), [target]);

  useEffect(() => {
    if (!handOff) return;
    write(target);
    // React Router has already pushed `target`, so `location.replace(target)` would be a
    // same-URL navigation, which Chrome performs as a *reload* of this history entry. Back then
    // "traverses" into the previous React entry without loading anything and you see Flutter's
    // page under React's URL. Give the entry a different URL first so the replace is a real
    // cross-document navigation and Back reloads the React page properly.
    window.history.replaceState(window.history.state, '', `${pathname}?__handoff=1`);
    window.location.replace(target);
  }, [handOff, target, pathname]);

  return handOff ? <LoadingState height="100dvh" /> : <NotFoundPage />;
}

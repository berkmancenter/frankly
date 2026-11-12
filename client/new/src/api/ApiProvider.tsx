import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import type { Api } from './api';
import type { AuthService } from './auth';
import type { Backend } from './backend';
import { createFirebaseBackend } from './firebaseBackend';

export type { Backend } from './backend';

const BackendContext = createContext<Backend | null>(null);

/**
 * Dependency injection for the data layer. This is *not* state: it hands every query hook the
 * same `Api`. Tests can provide an isolated backend through the `backend` prop.
 */
export function BackendProvider({
  backend,
  children,
}: {
  backend?: Backend;
  children: ReactNode;
}) {
  const [value] = useState<Backend>(() => backend ?? createFirebaseBackend());
  useEffect(() => {
    if (import.meta.env.DEV) (window as unknown as { __frankly?: unknown }).__frankly = value;
  }, [value]);
  return <BackendContext.Provider value={value}>{children}</BackendContext.Provider>;
}

function useBackend(): Backend {
  const backend = useContext(BackendContext);
  if (!backend) throw new Error('BackendProvider is missing from the tree');
  return backend;
}

export const useApi = (): Api => useBackend().api;

export const useAuthService = (): AuthService => useBackend().auth;

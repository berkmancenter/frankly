import type { Api } from './api';

/**
 * The server-facing client services. The realtime transport (`RealtimeTransport` in
 * `./realtime`) joins this when the live meeting migrates.
 */
export interface Backend {
  api: Api;
}

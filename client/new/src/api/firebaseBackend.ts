import type { Backend } from './backend';
import { createFirebaseApi } from './firebaseApi';
import { createFirebaseAuthService } from './firebaseAuthService';
import { getFirebaseClient, useFirebaseEmulators } from './firebase';

export function createFirebaseBackend(): Backend {
	const client = getFirebaseClient();
	return {
		api: createFirebaseApi(client),
		// Against the emulator Flutter keeps the session in sessionStorage; match it.
		auth: createFirebaseAuthService(client, { sessionPersistence: useFirebaseEmulators() }),
	};
}

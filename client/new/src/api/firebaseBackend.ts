import type { Backend } from './backend';
import { createFirebaseApi } from './firebaseApi';
import { getFirebaseClient } from './firebase';

export function createFirebaseBackend(): Backend {
	const client = getFirebaseClient();
	return {
		api: createFirebaseApi(client),
	};
}

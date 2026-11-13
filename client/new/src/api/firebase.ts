import { getApps, initializeApp, type FirebaseApp, type FirebaseOptions } from 'firebase/app';
import { connectAuthEmulator, getAuth, type Auth } from 'firebase/auth';
import {
	connectFirestoreEmulator,
	getFirestore,
	type Firestore,
} from 'firebase/firestore';
import { CloudFunctions } from './cloudFunctions';

export interface FirebaseClient {
	app: FirebaseApp;
	auth: Auth;
	firestore: Firestore;
	functions: CloudFunctions;
}

let client: FirebaseClient | undefined;
const authEmulatorConnections = new WeakSet<Auth>();
const firestoreEmulatorConnections = new WeakSet<Firestore>();

export function useFirebaseEmulators(): boolean {
	const setting = import.meta.env.VITE_FIREBASE_USE_EMULATORS;
	return setting === 'true' || (setting !== 'false' && import.meta.env.DEV);
}

function firebaseOptions(useEmulators: boolean): FirebaseOptions {
	const options: FirebaseOptions = {
		apiKey: import.meta.env.VITE_FIREBASE_API_KEY || (useEmulators ? 'any' : undefined),
		appId: import.meta.env.VITE_FIREBASE_APP_ID || (useEmulators ? 'any' : undefined),
		authDomain:
			import.meta.env.VITE_FIREBASE_AUTH_DOMAIN ||
			(useEmulators ? 'localhost' : undefined),
		projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || (useEmulators ? 'dev' : undefined),
		messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
		storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
		databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL,
	};
	// eslint-disable-next-line lingui/no-unlocalized-strings -- Firebase config key names
	const required = ['apiKey', 'appId', 'authDomain', 'projectId'] as const;
	const missing = required.filter((key) => !options[key]);
	if (missing.length > 0) {
		throw new Error(
			`Missing Firebase configuration: ${missing
				.map((key) => `VITE_FIREBASE_${key.replace(/[A-Z]/g, (letter) => `_${letter}`).toUpperCase()}`)
				.join(', ')}`,
		);
	}
	return options;
}

export function getFirebaseClient(): FirebaseClient {
	if (client) return client;

	const useEmulators = useFirebaseEmulators();
	const options = firebaseOptions(useEmulators);
	const app = getApps().find((candidate) => candidate.name === '[DEFAULT]')
		?? initializeApp(options);
	const auth = getAuth(app);
	const firestore = getFirestore(app);
	// Must be `localhost`, like Flutter's `useAuthEmulator('localhost', 9099)`. Google sign-in goes through
	// an iframe served by the Auth emulator, and Chrome partitions its storage unless the emulator is the
	// same site as the app (`localhost` vs `127.0.0.1` is not), so the redirect result never arrives and
	// the visitor stays anonymous.
	const emulatorHost = import.meta.env.VITE_FIREBASE_EMULATOR_HOST || 'localhost';

	if (useEmulators) {
		if (!authEmulatorConnections.has(auth)) {
			connectAuthEmulator(
				auth,
				`http://${emulatorHost}:${Number(import.meta.env.VITE_FIREBASE_AUTH_EMULATOR_PORT) || 9099}`,
				{ disableWarnings: true },
			);
			authEmulatorConnections.add(auth);
		}
		if (!firestoreEmulatorConnections.has(firestore)) {
			connectFirestoreEmulator(
				firestore,
				emulatorHost,
				Number(import.meta.env.VITE_FIREBASE_FIRESTORE_EMULATOR_PORT) || 8080,
			);
			firestoreEmulatorConnections.add(firestore);
		}
	}

	client = {
		app,
		auth,
		firestore,
		functions: new CloudFunctions(
			{
				region: import.meta.env.VITE_FIREBASE_FUNCTIONS_REGION || 'us-central1',
				sameOrigin: true,
				...(useEmulators
					? {
							emulator: {
								host: emulatorHost,
								port:
									Number(import.meta.env.VITE_FIREBASE_FUNCTIONS_EMULATOR_PORT) ||
									5001,
							},
						}
					: {}),
			},
			app,
			auth,
		),
	};
	return client;
}

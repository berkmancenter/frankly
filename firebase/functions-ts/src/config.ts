// Centralized `firebase-functions/params` definitions, replacing the old
// `functions.config()` calls (one per name only - Firebase errors if the
// same param name is defined twice in a codebase, so every file that needs
// one of these imports it from here rather than re-declaring it).
import { defineString, defineSecret } from 'firebase-functions/params';

export const agoraAppId = defineString('AGORA_APP_ID');
export const agoraStorageBucketName = defineString('AGORA_STORAGE_BUCKET_NAME');
export const agoraRestKey = defineSecret('AGORA_REST_KEY');
export const agoraRestSecret = defineSecret('AGORA_REST_SECRET');
export const agoraWebhookSecret = defineSecret('AGORA_WEBHOOK_SECRET');

export const appGoogleId = defineString('APP_GOOGLE_ID');
export const appVersion = defineString('APP_VERSION', { default: 'dev' });

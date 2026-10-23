import * as admin from 'firebase-admin';

admin.initializeApp();

export { imageProxy } from './image_proxy';
export { ServeIndex } from './serve_index';
export { agoraRecordingWebhook } from './agora_recording_webhook';
export { downloadRecording } from './download_recordings';
export { downloadTranscripts } from './download_transcripts';
export { getSessionDownloadUrl } from './get_session_download_url';
export { repairSessionArtifacts } from './repair_session_artifacts';
export { produceSessions } from './produce_sessions';

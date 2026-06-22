const dartFunctions = require('./build/node/main.dart.js')

Object.assign(exports, dartFunctions)

exports.downloadRecording = require('./js/download-recordings.js')
exports.getSessionDownloadUrl = require('./js/get-session-download-url.js')
exports.produceSessions = require('./js/produce-sessions.js')
exports.agoraRecordingWebhook = require('./js/agora-recording-webhook.js')
exports.imageProxy = require('./js/image-proxy.js')

'use strict'

// Content-Security-Policy for the HTML served by ServeIndex.
//
// Cloudinary hosts are allowed unless the deployment sets
// `app.cloudinary_enabled` to "false". Deployments that must keep media and
// visitor traffic away from Cloudinary (for example EU-only deployments) turn
// it off here, and use MEDIA_UPLOAD_PROVIDER=firebase (or leave
// CLOUDINARY_CLOUD_NAME unset) in the client build.

const cloudinaryHosts = ' https://res.cloudinary.com https://api.cloudinary.com'
const cloudinaryMediaHost = ' https://res.cloudinary.com'
const cloudinaryWidgetHost = ' https://upload-widget.cloudinary.com'

// Download URLs for media uploaded with MEDIA_UPLOAD_PROVIDER=firebase.
// Uploads themselves are covered by https://*.googleapis.com in connect-src.
// Only allowed when app.media_upload_provider is "firebase", so the default
// policy stays as it was.
const firebaseStorageHost = ' https://firebasestorage.googleapis.com'

function cloudinaryEnabled(appConfig = {}) {
    const value = appConfig.cloudinary_enabled
    if (typeof value === 'boolean') return value
    if (typeof value !== 'string') return true
    return value.trim().toLowerCase() !== 'false'
}

function firebaseStorageMediaEnabled(appConfig = {}) {
    const value = appConfig.media_upload_provider
    return typeof value === 'string' && value.trim().toLowerCase() === 'firebase'
}

function buildCsp(nonce, { cloudinary = true, firebaseStorage = false } = {}) {
    const storageHost = firebaseStorage ? firebaseStorageHost : ''
    const directives = [
        `default-src 'self'`,
        `script-src 'strict-dynamic' 'nonce-${nonce}' 'wasm-unsafe-eval'`,
        `style-src 'self' 'unsafe-inline' https://vjs.zencdn.net`,
        `font-src 'self' data: https://fonts.gstatic.com`,
        // connect-src covers all fetch/XHR/WebSocket calls the Flutter app makes.
        // Add entries here if new backend services are integrated.
        `connect-src 'self'` +
            ` https://*.firebaseio.com wss://*.firebaseio.com` +
            ` https://*.googleapis.com https://*.cloudfunctions.net` +
            ` https://api.agora.io https://*.agora.io wss://*.agora.io:*` +
            ` https://*.sd-rtn.com wss://*.sd-rtn.com:*` +
            ` https://*.twiliocdn.com https://*.twilio.com` +
            ` https://api.mux.com https://stream.mux.com` +
            (cloudinary ? cloudinaryHosts : '') +
            ` https://player.vimeo.com https://api.segment.io` +
            ` https://api.linkpreview.net https://*.stripe.com` +
            ` https://stats.berkman.harvard.edu` +
            ` https://frankly.org https://fonts.gstatic.com https://www.gstatic.com`,
        `img-src 'self' data: blob:` +
            (cloudinary ? cloudinaryMediaHost : '') +
            ` https://*.googleusercontent.com` +
            storageHost +
            ` https://picsum.photos https://fastly.picsum.photos`,
        `media-src 'self' blob:` +
            (cloudinary ? cloudinaryMediaHost : '') +
            storageHost +
            ` https://*.mux.com`,
        `frame-src 'self'` +
            ` https://player.vimeo.com https://*.stripe.com https://*.firebaseapp.com` +
            ` https://*.firebaseio.com` +
            (cloudinary ? cloudinaryWidgetHost : ''),
        `worker-src 'self' blob:`,
        `object-src 'none'`,
        `base-uri 'self'`,
        `frame-ancestors 'self'`,
    ]
    return directives.join('; ')
}

module.exports = { buildCsp, cloudinaryEnabled, firebaseStorageMediaEnabled }

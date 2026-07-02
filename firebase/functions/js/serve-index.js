'use strict'

// ServeIndex - serves index.html with a per-request CSP nonce injected.
//
// This function is the entry point for all HTML page loads. Firebase Hosting
// rewrites all non-asset requests to this function (see firebase.json). The
// function reads a bundled copy of index.html, substitutes the __SCRIPT_NONCE__
// placeholder with a cryptographically random value, and sets a matching
// Content-Security-Policy response header.
//
// TEMPLATE SYNC: firebase/functions/web/index.html must be kept in sync with
// client/web/index.html. When client/web/index.html changes, copy it here.
// A CI/CD step will automate this for production deploys (see deploy workflow).

const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const functions = require('firebase-functions')

// Read the template once at module load. If the file is missing the function
// will fail to start, which surfaces the error at deploy time rather than
// silently at request time.
// __dirname is build/js/ at runtime; web/ sits two levels up at the package root.
const TEMPLATE_PATH = path.join(__dirname, '../../web/index.html')
const rawTemplate = fs.readFileSync(TEMPLATE_PATH, 'utf8')

// Substitute stable (non-per-request) placeholders once at startup.
const appConfig = functions.config().app || {}
const GOOGLE_ID = appConfig.google_id || ''
const VERSION = appConfig.version || 'dev'

const stableTemplate = rawTemplate
    .replace(/__GOOGLE_ID__/g, GOOGLE_ID)
    .replace(/__VERSION__/g, VERSION)

function buildCsp(nonce) {
    const directives = [
        `script-src 'strict-dynamic' 'nonce-${nonce}' 'wasm-unsafe-eval'`,
        `style-src 'self' 'unsafe-inline' https://vjs.zencdn.net`,
        `font-src 'self' data: https://fonts.gstatic.com`,
        // connect-src covers all fetch/XHR/WebSocket calls the Flutter app makes.
        // Add entries here if new backend services are integrated.
        `connect-src 'self'` +
            ` https://*.firebaseio.com wss://*.firebaseio.com` +
            ` https://*.googleapis.com https://*.cloudfunctions.net` +
            ` https://api.agora.io https://*.agora.io` +
            ` https://*.twiliocdn.com https://*.twilio.com` +
            ` https://api.mux.com https://stream.mux.com` +
            ` https://res.cloudinary.com https://api.cloudinary.com` +
            ` https://player.vimeo.com https://api.segment.io` +
            ` https://api.linkpreview.net https://*.stripe.com` +
            ` https://frankly.org https://fonts.gstatic.com https://www.gstatic.com`,
        `img-src 'self' data: blob:` +
            ` https://res.cloudinary.com https://*.googleusercontent.com`,
        `media-src 'self' blob: https://res.cloudinary.com https://*.mux.com`,
        `frame-src 'self'` +
            ` https://player.vimeo.com https://*.stripe.com https://*.firebaseapp.com`,
        `worker-src 'self' blob:`,
        `object-src 'none'`,
        `base-uri 'self'`,
        `frame-ancestors 'self'`,
    ]
    return directives.join('; ')
}

const ServeIndex = functions.https.onRequest((req, res) => {
    if (req.method !== 'GET' && req.method !== 'HEAD') {
        res.status(405).send('Method Not Allowed')
        return
    }

    const nonce = crypto.randomUUID()
    const html = stableTemplate.replace(/__SCRIPT_NONCE__/g, nonce)
    const csp = buildCsp(nonce)

    // no-store: the nonce is unique per response and must never be served from cache.
    res.set('Cache-Control', 'no-store')
    res.set('Content-Security-Policy', csp)
    // Report-Only duplicate: logs violations to the browser console without
    // blocking anything. Useful during staging validation to catch missing
    // domains. Remove once the enforcing policy is stable in production.
    res.set('Content-Security-Policy-Report-Only', csp)
    res.set('Content-Type', 'text/html; charset=utf-8')
    res.send(html)
})

module.exports = ServeIndex

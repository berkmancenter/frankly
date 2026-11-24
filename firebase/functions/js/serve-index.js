'use strict'

// ServeIndex - serves index.html with a per-request CSP nonce injected.
//
// This function is the entry point for all HTML page loads. Firebase Hosting
// rewrites all non-asset requests to this function (see firebase.json). The
// function reads a bundled copy of index.html, substitutes the __SCRIPT_NONCE__
// placeholder with a cryptographically random value, and sets a matching
// Content-Security-Policy response header.
//
// TEMPLATE SYNC: firebase/functions/web/index.html is a copy of
// client/web/index.html. The CI/CD workflows, build-all.sh, and run-dev.sh
// copy client/web/index.html here automatically before building functions.

const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const functions = require('firebase-functions')
const { regionalFunctions } = require('./function-region')
const {
    buildCsp,
    cloudinaryEnabled,
    firebaseStorageMediaEnabled,
} = require('./content-security-policy')

// Read the template once at module load. If the file is missing the function
// will fail to start, which surfaces the error at deploy time rather than
// silently at request time.
// __dirname is build/js/ when loaded by the compiled Dart entrypoint, and js/
// when the module is required directly (tests, tooling). web/ sits at the
// package root in both cases.
const TEMPLATE_CANDIDATES = [
    path.join(__dirname, '../../web/index.html'),
    path.join(__dirname, '../web/index.html'),
]
const TEMPLATE_PATH =
    TEMPLATE_CANDIDATES.find((candidate) => fs.existsSync(candidate)) ??
    TEMPLATE_CANDIDATES[0]
const rawTemplate = fs.readFileSync(TEMPLATE_PATH, 'utf8')

// Substitute stable (non-per-request) placeholders once at startup.
// Firebase Hosting does not serve the built client/build/web/index.html
// (firebase.json ignores it so every HTML request gets a nonce), so the deploy
// workflows fill __VERSION__ and __GOOGLE_ID__ into web/index.html when they
// sync the template. Anything still left as a placeholder falls back to the
// app.version / app.google_id runtime config.
const appConfig = functions.config().app || {}
const GOOGLE_ID = appConfig.google_id || ''
const VERSION = appConfig.version || 'dev'
const CLOUDINARY_ENABLED = cloudinaryEnabled(appConfig)
const FIREBASE_STORAGE_MEDIA = firebaseStorageMediaEnabled(appConfig)

const stableTemplate = rawTemplate
    .replace(/__GOOGLE_ID__/g, GOOGLE_ID)
    .replace(/__VERSION__/g, VERSION)

const ServeIndex = regionalFunctions()
    .runWith({ minInstances: 1 })
    .https.onRequest((req, res) => {
        if (req.method !== 'GET' && req.method !== 'HEAD') {
            res.status(405).send('Method Not Allowed')
            return
        }

        const nonce = crypto.randomBytes(16).toString('base64')
        const html = stableTemplate.replace(/__SCRIPT_NONCE__/g, nonce)
        const csp = buildCsp(nonce, {
            cloudinary: CLOUDINARY_ENABLED,
            firebaseStorage: FIREBASE_STORAGE_MEDIA,
        })

        // no-store: the nonce is unique per response and must never be served from cache.
        res.set('Cache-Control', 'no-store')
        res.set('Content-Security-Policy', csp)
        res.set('Content-Type', 'text/html; charset=utf-8')
        res.send(html)
    })

module.exports = ServeIndex

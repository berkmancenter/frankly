const assert = require('node:assert/strict')
const { test } = require('node:test')

const {
    buildCsp,
    cloudinaryEnabled,
    firebaseStorageMediaEnabled,
} = require('../js/content-security-policy')

// The policy ServeIndex sent before the Cloudinary and Firebase Storage
// switches existed. With the defaults the header must not change.
const previousDefaultPolicy = [
    `default-src 'self'`,
    `script-src 'strict-dynamic' 'nonce-abc' 'wasm-unsafe-eval'`,
    `style-src 'self' 'unsafe-inline' https://vjs.zencdn.net`,
    `font-src 'self' data: https://fonts.gstatic.com`,
    `connect-src 'self'` +
        ` https://*.firebaseio.com wss://*.firebaseio.com` +
        ` https://*.googleapis.com https://*.cloudfunctions.net` +
        ` https://api.agora.io https://*.agora.io wss://*.agora.io:*` +
        ` https://*.sd-rtn.com wss://*.sd-rtn.com:*` +
        ` https://*.twiliocdn.com https://*.twilio.com` +
        ` https://api.mux.com https://stream.mux.com` +
        ` https://res.cloudinary.com https://api.cloudinary.com` +
        ` https://player.vimeo.com https://api.segment.io` +
        ` https://api.linkpreview.net https://*.stripe.com` +
        ` https://stats.berkman.harvard.edu` +
        ` https://frankly.org https://fonts.gstatic.com https://www.gstatic.com`,
    `img-src 'self' data: blob:` +
        ` https://res.cloudinary.com https://*.googleusercontent.com` +
        ` https://picsum.photos https://fastly.picsum.photos`,
    `media-src 'self' blob: https://res.cloudinary.com https://*.mux.com`,
    `frame-src 'self'` +
        ` https://player.vimeo.com https://*.stripe.com https://*.firebaseapp.com` +
        ` https://*.firebaseio.com https://upload-widget.cloudinary.com`,
    `worker-src 'self' blob:`,
    `object-src 'none'`,
    `base-uri 'self'`,
    `frame-ancestors 'self'`,
].join('; ')

test('keeps the previous policy by default', () => {
    assert.equal(buildCsp('abc'), previousDefaultPolicy)
    assert.equal(
        buildCsp('abc', { cloudinary: true, firebaseStorage: false }),
        previousDefaultPolicy,
    )
})

test('omits every Cloudinary host when disabled', () => {
    const csp = buildCsp('abc', { cloudinary: false })
    assert.doesNotMatch(csp, /cloudinary/)
    assert.match(csp, /media-src 'self' blob: https:\/\/\*\.mux\.com/)
    assert.match(csp, /'nonce-abc'/)
})

test('allows Firebase Storage media only when it is the upload provider', () => {
    assert.doesNotMatch(buildCsp('abc'), /firebasestorage/)
    for (const cloudinary of [true, false]) {
        const csp = buildCsp('abc', { cloudinary, firebaseStorage: true })
        assert.match(csp, /img-src[^;]*https:\/\/firebasestorage\.googleapis\.com/)
        assert.match(csp, /media-src[^;]*https:\/\/firebasestorage\.googleapis\.com/)
    }
})

test('reads app.cloudinary_enabled from runtime config', () => {
    assert.equal(cloudinaryEnabled(), true)
    assert.equal(cloudinaryEnabled({}), true)
    assert.equal(cloudinaryEnabled({ cloudinary_enabled: 'true' }), true)
    assert.equal(cloudinaryEnabled({ cloudinary_enabled: ' FALSE ' }), false)
    assert.equal(cloudinaryEnabled({ cloudinary_enabled: false }), false)
})

test('reads app.media_upload_provider from runtime config', () => {
    assert.equal(firebaseStorageMediaEnabled(), false)
    assert.equal(firebaseStorageMediaEnabled({}), false)
    assert.equal(firebaseStorageMediaEnabled({ media_upload_provider: 'cloudinary' }), false)
    assert.equal(firebaseStorageMediaEnabled({ media_upload_provider: ' Firebase ' }), true)
})

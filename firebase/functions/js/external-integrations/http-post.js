// Minimal JSON POST for webhook deliveries.
//
// Uses Node's own http(s) client instead of fetch so that the connection can
// be pinned to the addresses checked by `safeLookup`. Redirects are never
// followed, the whole request has a time limit, and only a short snippet of
// an error response body is read.

const http = require('http')
const https = require('https')

const { safeLookup } = require('./url-validation')

const DEFAULT_MAX_ERROR_BYTES = 1024

/**
 * POSTs `body` to `url`.
 *
 * - `lookup`: DNS lookup used for the connection (default `safeLookup`).
 * - `allowHttp`: allow plain http URLs. Only for local receivers in the
 *   emulator and for tests.
 *
 * Resolves `{ status, bodySnippet }`. `bodySnippet` is `''` for 2xx
 * responses, otherwise at most `maxErrorBytes` of the response body. Rejects
 * on network errors and timeouts; errors from `lookup` are passed through
 * unchanged, so a blocked address keeps its `retryable: false` mark.
 */
function postJson(
    url,
    {
        headers = {},
        body = '',
        timeoutMs = 10000,
        lookup = safeLookup,
        maxErrorBytes = DEFAULT_MAX_ERROR_BYTES,
        allowHttp = false,
    } = {}
) {
    return new Promise((resolve, reject) => {
        let target
        try {
            target = new URL(url)
        } catch (err) {
            reject(err)
            return
        }
        let client
        if (target.protocol === 'https:') client = https
        else if (target.protocol === 'http:' && allowHttp) client = http
        else {
            const err = new Error(`Unsupported protocol ${target.protocol}`)
            err.retryable = false
            reject(err)
            return
        }

        let settled = false
        const finish = (fn, value) => {
            if (settled) return
            settled = true
            clearTimeout(timer)
            fn(value)
        }

        const payload = Buffer.from(body)
        const req = client.request(target, {
            method: 'POST',
            headers: { ...headers, 'Content-Length': payload.length },
            lookup,
            // No connection reuse: every delivery resolves and checks again.
            agent: false,
        })

        const timer = setTimeout(() => {
            req.destroy(new Error(`Request timed out after ${timeoutMs} ms`))
        }, timeoutMs)

        req.on('error', (err) => finish(reject, err))
        req.on('response', (res) => {
            const status = res.statusCode
            if (status >= 200 && status < 300) {
                // The body of a success response is ignored. Close the socket
                // instead of draining it, so a receiver that trickles the body
                // cannot keep the connection open. Errors raised by closing it
                // early do not matter any more.
                finish(resolve, { status, bodySnippet: '' })
                res.on('error', () => {})
                res.destroy()
                return
            }
            const chunks = []
            let size = 0
            const done = () => {
                res.destroy()
                finish(resolve, {
                    status,
                    bodySnippet: Buffer.concat(chunks).subarray(0, maxErrorBytes).toString('utf8'),
                })
            }
            res.on('data', (chunk) => {
                chunks.push(chunk)
                size += chunk.length
                if (size >= maxErrorBytes) done()
            })
            res.on('end', done)
            // A body cut short by the receiver still leaves a usable status.
            res.on('error', done)
            res.on('aborted', done)
        })
        req.end(payload)
    })
}

module.exports = { postJson, DEFAULT_MAX_ERROR_BYTES }

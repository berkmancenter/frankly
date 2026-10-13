// Deployment-level settings for external integrations, read from
// `functions.config().external_integrations`. All keys are optional:
//
//   allowed_domains        Comma separated list of domains webhook URLs may
//                          point to (subdomains included). Empty allows any
//                          public https host.
//   signed_url_ttl_minutes Lifetime of artifact download URLs in payloads.
//                          Default 60, min 5, max 10080 (7 days).
//   request_timeout_ms     Timeout for one webhook request. Default 10000.

const { parseAllowedDomains } = require('./url-validation')

const DEFAULT_SIGNED_URL_TTL_MINUTES = 60
const MIN_SIGNED_URL_TTL_MINUTES = 5
const MAX_SIGNED_URL_TTL_MINUTES = 7 * 24 * 60
const DEFAULT_REQUEST_TIMEOUT_MS = 10000

function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value))
}

function parseExternalIntegrationsConfig(raw) {
    const cfg = raw || {}
    const ttl = Number(cfg.signed_url_ttl_minutes)
    const timeout = Number(cfg.request_timeout_ms)
    return {
        allowedDomains: parseAllowedDomains(cfg.allowed_domains),
        signedUrlTtlSeconds:
            clamp(
                Number.isFinite(ttl) && ttl > 0 ? ttl : DEFAULT_SIGNED_URL_TTL_MINUTES,
                MIN_SIGNED_URL_TTL_MINUTES,
                MAX_SIGNED_URL_TTL_MINUTES
            ) * 60,
        requestTimeoutMs: clamp(
            Number.isFinite(timeout) && timeout > 0 ? timeout : DEFAULT_REQUEST_TIMEOUT_MS,
            1000,
            60000
        ),
    }
}

function readExternalIntegrationsConfig(functions) {
    let raw
    try {
        raw = functions.config().external_integrations
    } catch (_) {
        raw = undefined
    }
    return parseExternalIntegrationsConfig(raw)
}

module.exports = {
    parseExternalIntegrationsConfig,
    readExternalIntegrationsConfig,
}

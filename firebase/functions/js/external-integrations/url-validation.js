// Webhook URL validation for external integrations.
//
// Webhook URLs are entered by community admins, so the server must not be
// tricked into calling internal services (SSRF). We require https, refuse
// internal host names and private/link-local/loopback IP ranges, and check
// again at send time against what the host name resolves to.

const dns = require('dns')
const net = require('net')

const MAX_URL_LENGTH = 2048

const BLOCKED_HOSTNAMES = new Set(['localhost', 'metadata', 'metadata.google.internal'])
const BLOCKED_HOSTNAME_SUFFIXES = [
    '.localhost',
    '.local',
    '.internal',
    '.localdomain',
    '.home.arpa',
]

// [network, prefixLength]
const BLOCKED_IPV4_RANGES = [
    ['0.0.0.0', 8], // "this" network
    ['10.0.0.0', 8], // private
    ['100.64.0.0', 10], // carrier-grade NAT
    ['127.0.0.0', 8], // loopback
    ['169.254.0.0', 16], // link-local, includes cloud metadata 169.254.169.254
    ['172.16.0.0', 12], // private
    ['192.0.0.0', 24], // IETF protocol assignments
    ['192.0.2.0', 24], // documentation
    ['192.168.0.0', 16], // private
    ['198.18.0.0', 15], // benchmarking
    ['198.51.100.0', 24], // documentation
    ['203.0.113.0', 24], // documentation
    ['224.0.0.0', 4], // multicast
    ['240.0.0.0', 4], // reserved, includes broadcast
]

function ipv4ToInt(ip) {
    return ip.split('.').reduce((acc, part) => (acc << 8) + Number(part), 0) >>> 0
}

function isBlockedIpv4(ip) {
    const value = ipv4ToInt(ip)
    return BLOCKED_IPV4_RANGES.some(([network, prefix]) => {
        const mask = prefix === 0 ? 0 : (~0 << (32 - prefix)) >>> 0
        return (value & mask) === (ipv4ToInt(network) & mask)
    })
}

// Expands an IPv6 address into 8 16-bit groups. Returns null if invalid.
function ipv6Groups(ip) {
    let address = ip.toLowerCase()
    const zoneIndex = address.indexOf('%')
    if (zoneIndex >= 0) address = address.slice(0, zoneIndex)

    // Embedded IPv4 at the end, e.g. ::ffff:127.0.0.1 -> ::ffff:7f00:1
    const lastColon = address.lastIndexOf(':')
    const maybeV4 = address.slice(lastColon + 1)
    if (net.isIPv4(maybeV4)) {
        const v = ipv4ToInt(maybeV4)
        const high = ((v >>> 16) & 0xffff).toString(16)
        const low = (v & 0xffff).toString(16)
        address = `${address.slice(0, lastColon + 1)}${high}:${low}`
    }

    const halves = address.split('::')
    if (halves.length > 2) return null
    const parse = (s) => (s === '' ? [] : s.split(':').map((g) => parseInt(g, 16)))
    const head = parse(halves[0])
    const rest = halves.length === 2 ? parse(halves[1]) : []
    const known = head.length + rest.length
    if (halves.length === 1 && known !== 8) return null
    if (known > 8) return null
    const zeros = halves.length === 2 ? new Array(8 - known).fill(0) : []
    const groups = [...head, ...zeros, ...rest]
    if (groups.length !== 8 || groups.some((g) => Number.isNaN(g) || g < 0 || g > 0xffff)) {
        return null
    }
    return groups
}

function isBlockedIpv6(ip) {
    const groups = ipv6Groups(ip)
    if (!groups) return true // refuse anything we cannot parse
    const allZeroBefore = (n) => groups.slice(0, n).every((g) => g === 0)

    if (groups.every((g) => g === 0)) return true // ::
    if (allZeroBefore(7) && groups[7] === 1) return true // ::1 loopback
    // IPv4-mapped (::ffff:a.b.c.d) and IPv4-compatible (::a.b.c.d)
    if (allZeroBefore(5) && (groups[5] === 0xffff || groups[5] === 0)) {
        const v4 = `${groups[6] >> 8}.${groups[6] & 0xff}.${groups[7] >> 8}.${groups[7] & 0xff}`
        return isBlockedIpv4(v4)
    }
    if ((groups[0] & 0xfe00) === 0xfc00) return true // fc00::/7 unique local
    if ((groups[0] & 0xffc0) === 0xfe80) return true // fe80::/10 link-local
    if ((groups[0] & 0xffc0) === 0xfec0) return true // fec0::/10 site-local (deprecated)
    if ((groups[0] & 0xff00) === 0xff00) return true // ff00::/8 multicast
    if (groups[0] === 0x2001 && groups[1] === 0x0db8) return true // documentation
    if (groups[0] === 0x0064 && groups[1] === 0xff9b) {
        // NAT64 well-known prefix maps to IPv4 in the last 32 bits
        const v4 = `${groups[6] >> 8}.${groups[6] & 0xff}.${groups[7] >> 8}.${groups[7] & 0xff}`
        return isBlockedIpv4(v4)
    }
    return false
}

/** Returns true if the IP address must never be called. */
function isBlockedAddress(ip) {
    if (net.isIPv4(ip)) return isBlockedIpv4(ip)
    if (net.isIPv6(ip)) return isBlockedIpv6(ip)
    return true
}

function isBlockedHostname(hostname) {
    const host = hostname.toLowerCase().replace(/\.$/, '')
    if (BLOCKED_HOSTNAMES.has(host)) return true
    if (BLOCKED_HOSTNAME_SUFFIXES.some((suffix) => host.endsWith(suffix))) return true
    // Single-label names (no dot) only resolve on internal networks.
    if (!host.includes('.') && !net.isIPv6(host)) return true
    return false
}

/** Parses the deployment-level allowlist (comma or whitespace separated). */
function parseAllowedDomains(value) {
    if (!value) return []
    const list = Array.isArray(value) ? value : String(value).split(/[\s,]+/)
    return list
        .map((d) => d.trim().toLowerCase().replace(/^\*\./, '').replace(/\.$/, ''))
        .filter(Boolean)
}

function isAllowedByDomainList(hostname, allowedDomains) {
    if (!allowedDomains || allowedDomains.length === 0) return true
    const host = hostname.toLowerCase().replace(/\.$/, '')
    return allowedDomains.some((domain) => host === domain || host.endsWith(`.${domain}`))
}

/**
 * Checks a webhook URL without network access.
 *
 * Returns `{ ok: true, url }` with the normalized URL string, or
 * `{ ok: false, reason }`.
 */
const LOCAL_TARGET_HOSTS = new Set(['localhost', '127.0.0.1', '::1'])

function validateWebhookUrl(rawUrl, { allowedDomains = [], allowLocalTargets = false } = {}) {
    if (typeof rawUrl !== 'string' || rawUrl.trim() === '') {
        return { ok: false, reason: 'Webhook URL is required' }
    }
    const trimmed = rawUrl.trim()
    if (trimmed.length > MAX_URL_LENGTH) {
        return { ok: false, reason: 'Webhook URL is too long' }
    }

    let url
    try {
        url = new URL(trimmed)
    } catch (_) {
        return { ok: false, reason: 'Webhook URL is not a valid URL' }
    }

    if (url.username || url.password) {
        return { ok: false, reason: 'Webhook URL must not contain credentials' }
    }

    // URL keeps IPv6 hosts in brackets.
    const hostname = url.hostname.replace(/^\[(.*)\]$/, '$1')

    // Local receivers, http included, are only allowed in the Functions
    // emulator when explicitly enabled (see config.js).
    if (
        allowLocalTargets &&
        LOCAL_TARGET_HOSTS.has(hostname) &&
        (url.protocol === 'http:' || url.protocol === 'https:')
    ) {
        return { ok: true, url: url.toString(), hostname, local: true }
    }

    if (url.protocol !== 'https:') {
        return { ok: false, reason: 'Webhook URL must use https' }
    }
    if (!hostname) {
        return { ok: false, reason: 'Webhook URL must have a host' }
    }

    if (net.isIP(hostname)) {
        if (isBlockedAddress(hostname)) {
            return { ok: false, reason: 'Webhook URL points to a private or internal address' }
        }
    } else if (isBlockedHostname(hostname)) {
        return { ok: false, reason: 'Webhook URL points to an internal host name' }
    }

    if (!isAllowedByDomainList(hostname, allowedDomains)) {
        return { ok: false, reason: 'Webhook URL host is not in the allowed domain list' }
    }

    return { ok: true, url: url.toString(), hostname }
}

function defaultLookup(hostname) {
    return new Promise((resolve, reject) => {
        dns.lookup(hostname, { all: true, verbatim: true }, (err, addresses) => {
            if (err) reject(err)
            else resolve(addresses)
        })
    })
}

/**
 * Resolves the host name and refuses it if any address is internal. Guards
 * against public names that point at private addresses.
 */
// Errors carry `retryable` so callers can tell a DNS hiccup from a URL that
// will never be allowed.
function urlError(message, retryable) {
    const err = new Error(message)
    err.retryable = retryable
    return err
}

async function assertResolvesToPublicAddress(hostname, { lookup = defaultLookup } = {}) {
    if (net.isIP(hostname)) {
        if (isBlockedAddress(hostname)) {
            throw urlError('Webhook host is a private or internal address', false)
        }
        return [hostname]
    }
    let addresses
    try {
        addresses = await lookup(hostname)
    } catch (err) {
        throw urlError(`Webhook host could not be resolved: ${hostname}`, true)
    }
    const ips = (addresses || []).map((a) => (typeof a === 'string' ? a : a.address))
    if (ips.length === 0) {
        throw urlError(`Webhook host could not be resolved: ${hostname}`, true)
    }
    if (ips.some((ip) => isBlockedAddress(ip))) {
        throw urlError('Webhook host resolves to a private or internal address', false)
    }
    return ips
}

/**
 * Builds a `lookup` function for `http(s).request` that refuses to connect
 * when the host name resolves to any blocked address. The early check in
 * `validateWebhookUrlForSend` runs its own DNS query, so without this a host
 * could answer that check with a public address and the connection with a
 * private one (DNS rebinding).
 *
 * Supports both callback forms Node uses: `options.all === true` (array of
 * `{ address, family }`, used by `autoSelectFamily`) and the single-address
 * form.
 */
function createSafeLookup(resolve = dns.lookup) {
    return function safeLookup(hostname, options, callback) {
        if (typeof options === 'function') {
            callback = options
            options = {}
        } else if (typeof options === 'number') {
            options = { family: options }
        }
        const wantAll = Boolean(options && options.all)
        resolve(hostname, { ...options, all: true }, (err, addresses) => {
            if (err) {
                callback(err)
                return
            }
            const list = (addresses || []).map((a) =>
                typeof a === 'string' ? { address: a, family: net.isIP(a) } : a
            )
            if (list.length === 0) {
                const notFound = new Error(`Webhook host could not be resolved: ${hostname}`)
                notFound.code = 'ENOTFOUND'
                callback(notFound)
                return
            }
            if (list.some((a) => isBlockedAddress(a.address))) {
                const blocked = urlError(
                    'Webhook host resolves to a private or internal address',
                    false
                )
                blocked.code = 'EBLOCKEDADDRESS'
                callback(blocked)
                return
            }
            if (wantAll) callback(null, list)
            else callback(null, list[0].address, list[0].family)
        })
    }
}

const safeLookup = createSafeLookup()

/** Full check used before every request: static rules plus DNS. */
async function validateWebhookUrlForSend(
    rawUrl,
    { allowedDomains = [], allowLocalTargets = false, lookup } = {}
) {
    const result = validateWebhookUrl(rawUrl, { allowedDomains, allowLocalTargets })
    if (!result.ok) throw urlError(result.reason, false)
    if (result.local) return result.url
    await assertResolvesToPublicAddress(result.hostname, { lookup })
    return result.url
}

/** Logo URLs are shown in the client, so only https images are accepted. */
function validateLogoUrl(rawUrl) {
    if (rawUrl == null || rawUrl === '') return { ok: true, url: null }
    if (typeof rawUrl !== 'string' || rawUrl.length > MAX_URL_LENGTH) {
        return { ok: false, reason: 'Logo URL is not valid' }
    }
    try {
        const url = new URL(rawUrl.trim())
        if (url.protocol !== 'https:') {
            return { ok: false, reason: 'Logo URL must use https' }
        }
        return { ok: true, url: url.toString() }
    } catch (_) {
        return { ok: false, reason: 'Logo URL is not valid' }
    }
}

module.exports = {
    isBlockedAddress,
    isBlockedHostname,
    parseAllowedDomains,
    isAllowedByDomainList,
    validateWebhookUrl,
    assertResolvesToPublicAddress,
    validateWebhookUrlForSend,
    validateLogoUrl,
    createSafeLookup,
    safeLookup,
}

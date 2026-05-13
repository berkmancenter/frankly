import * as functions from 'firebase-functions'

export interface UnsubscribeData {
    userId: string
}

const ENCRYPTION_KEY = () => (functions.config().app?.encryption_key as string) ?? 'default_key'

export function getUnsubscribeUrl(opts: { userId: string }): string {
    const linkPrefix = functions.config().app?.full_url as string
    const data: UnsubscribeData = { userId: opts.userId }
    const encrypted = encryptUnsubscribeData(data)
    return `${linkPrefix}/unsubscribe?data=${encodeURIComponent(encrypted)}`
}

export function encryptUnsubscribeData(data: UnsubscribeData): string {
    return Buffer.from(JSON.stringify(data)).toString('base64')
}

export function decryptUnsubscribeData(encrypted: string): UnsubscribeData {
    try {
        return JSON.parse(Buffer.from(encrypted, 'base64').toString('utf8')) as UnsubscribeData
    } catch {
        // Fallback: try as plain JSON
        return JSON.parse(encrypted) as UnsubscribeData
    }
}

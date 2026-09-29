// Merges per-session transcript CSV fragments into one file per session.
// Filename: <eventId>-<breakoutSessionId>_<roomId>_<sessionId>_YYYYMMDDHHmmSSsss.csv
// Locale variant: <eventId>-<locale>_<breakoutSessionId>_<roomId>_<sessionId>_...
// Timestamps are absolute GMT, so duplicates are matched by date math, not string prefix.

const TIMESTAMP_REGEX = /(\d{17})(?:\.[^./]*)?$/

function basename(filePath) {
    const idx = filePath.lastIndexOf('/')
    return idx === -1 ? filePath : filePath.slice(idx + 1)
}

// Parses the trailing YYYYMMDDHHmmSSsss timestamp into ms since epoch (UTC), or null.
function parseFragmentTimestampMs(filePath) {
    const match = TIMESTAMP_REGEX.exec(basename(filePath))
    if (!match) return null

    const digits = match[1]
    const year = Number(digits.slice(0, 4))
    const month = Number(digits.slice(4, 6))
    const day = Number(digits.slice(6, 8))
    const hour = Number(digits.slice(8, 10))
    const minute = Number(digits.slice(10, 12))
    const second = Number(digits.slice(12, 14))
    const millisecond = Number(digits.slice(14, 17))

    const ms = Date.UTC(year, month - 1, day, hour, minute, second, millisecond)
    return Number.isNaN(ms) ? null : ms
}

// Locale-tagged if there's an underscore within 10 chars after the first hyphen.
function isLocaleTaggedFilename(filePath) {
    const name = basename(filePath)
    const hyphenIdx = name.indexOf('-')
    if (hyphenIdx === -1) return false

    const window = name.slice(hyphenIdx + 1, hyphenIdx + 1 + 10)
    return window.includes('_')
}

function splitLocaleAndDefault(entries) {
    const localeEntries = []
    const defaultEntries = []
    for (const entry of entries) {
        if (isLocaleTaggedFilename(entry.path)) {
            localeEntries.push(entry)
        } else {
            defaultEntries.push(entry)
        }
    }
    return { localeEntries, defaultEntries }
}

// Candidate duplicates: closest default-set entry within windowMs. Caller still
// confirms via content hash/size before dropping either fragment.
function findDuplicateCandidates(localeEntries, defaultEntries, windowMs = 10000) {
    const candidates = []
    for (const localeEntry of localeEntries) {
        const localeMs = parseFragmentTimestampMs(localeEntry.path)
        if (localeMs == null) continue

        let closest = null
        let closestDelta = Infinity
        for (const defaultEntry of defaultEntries) {
            const defaultMs = parseFragmentTimestampMs(defaultEntry.path)
            if (defaultMs == null) continue

            const delta = Math.abs(defaultMs - localeMs)
            if (delta <= windowMs && delta < closestDelta) {
                closest = defaultEntry
                closestDelta = delta
            }
        }

        if (closest) {
            candidates.push({ localeEntry, defaultEntry: closest, deltaMs: closestDelta })
        }
    }
    return candidates
}

function isContentDuplicate(hashA, sizeA, hashB, sizeB) {
    return sizeA === sizeB && hashA === hashB
}

// Sorts entries by fragment timestamp, dropping keysToDrop. Entries with no
// parseable timestamp sort last (stable order).
function buildMergeOrder(entries, keysToDrop = new Set()) {
    const remaining = entries.filter((e) => !keysToDrop.has(e.key))
    return remaining
        .map((entry, index) => ({ entry, index, ms: parseFragmentTimestampMs(entry.path) }))
        .sort((a, b) => {
            if (a.ms == null && b.ms == null) return a.index - b.index
            if (a.ms == null) return 1
            if (b.ms == null) return -1
            if (a.ms !== b.ms) return a.ms - b.ms
            return a.index - b.index
        })
        .map((wrapped) => wrapped.entry)
}

// Concatenates CSV text in order, dropping the header line of every file after the first.
function mergeCsvContents(csvTexts) {
    const nonEmpty = csvTexts.filter((text) => text != null && text.length > 0)
    if (nonEmpty.length === 0) return ''

    const parts = nonEmpty.map((text, i) => {
        const normalized = text.replace(/\r\n/g, '\n')
        if (i === 0) return normalized.replace(/\n+$/, '')

        const firstNewline = normalized.indexOf('\n')
        const withoutHeader = firstNewline === -1 ? '' : normalized.slice(firstNewline + 1)
        return withoutHeader.replace(/\n+$/, '')
    })

    return parts.filter((p) => p.length > 0).join('\n') + '\n'
}

function parseVtt(vttText) {
    const lines = vttText.split('\n')
    const cues = []
    let i = 0

    while (i < lines.length && !lines[i].includes('-->')) i++

    while (i < lines.length) {
        const line = lines[i].trim()
        if (line.includes('-->')) {
            const [startStr, endStr] = line.split('-->')
            const start = startStr.trim()
            const end = endStr.trim()
            i++
            let text = ''
            while (i < lines.length && lines[i].trim() !== '') {
                if (text) text += ' '
                text += lines[i].trim()
                i++
            }
            if (text) {
                cues.push({ start, end, text })
            }
        } else {
            i++
        }
    }
    return cues
}

function cuesToCsv(cues, uidMap) {
    const header = 'Start,End,Speaker,Speaker ID,Text'
    const rows = cues.map((cue) => {
        let speaker = ''
        let speakerId = ''
        let text = cue.text
        const match = text.match(/^<v\s+(\d+)>(.*)$/)
        if (match) {
            const uid = match[1]
            speaker = uidMap[uid] || `Speaker ${uid}`
            speakerId = uid
            text = match[2]
        }
        const escaped = text.replace(/"/g, '""')
        const speakerEscaped = speaker.replace(/"/g, '""')
        return `${cue.start},${cue.end},"${speakerEscaped}","${speakerId}","${escaped}"`
    })
    return [header, ...rows].join('\n')
}

function cuesToPlainText(cues, uidMap) {
    return cues
        .map((cue) => {
            let speaker = ''
            let text = cue.text
            const match = text.match(/^<v\s+(\d+)>(.*)$/)
            if (match) {
                const uid = match[1]
                speaker = uidMap[uid] || `Speaker ${uid}`
                text = match[2]
            }
            return speaker ? `[${cue.start}] ${speaker}: ${text}` : `[${cue.start}] ${text}`
        })
        .join('\n')
}

module.exports = {
    parseFragmentTimestampMs,
    isLocaleTaggedFilename,
    splitLocaleAndDefault,
    findDuplicateCandidates,
    isContentDuplicate,
    buildMergeOrder,
    mergeCsvContents,
    parseVtt,
    cuesToCsv,
    cuesToPlainText,
}

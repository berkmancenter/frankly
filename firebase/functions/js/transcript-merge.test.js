const test = require('node:test')
const assert = require('node:assert/strict')

const {
    parseFragmentTimestampMs,
    isLocaleTaggedFilename,
    splitLocaleAndDefault,
    findDuplicateCandidates,
    isContentDuplicate,
    buildMergeOrder,
    mergeCsvContents,
} = require('./transcript-merge')

test('parseFragmentTimestampMs parses trailing timestamp as UTC', () => {
    const ms = parseFragmentTimestampMs('evt-bsid_room_sess_20260315235959123.csv')
    assert.equal(new Date(ms).toISOString(), '2026-03-15T23:59:59.123Z')
})

test('parseFragmentTimestampMs returns null when no timestamp present', () => {
    assert.equal(parseFragmentTimestampMs('evt-bsid_room_sess.csv'), null)
})

const bsid = 'aBreakoutSessionId20' // 20 chars, like a Firestore auto-id

test('isLocaleTaggedFilename detects locale segment after first hyphen', () => {
    assert.equal(isLocaleTaggedFilename(`evt-en-US_${bsid}_room_sess_1.csv`), true)
    assert.equal(isLocaleTaggedFilename(`evt-${bsid}_room_sess_1.csv`), false)
})

test('splitLocaleAndDefault separates entries by filename', () => {
    const entries = [
        { key: 'a', path: `evt-${bsid}_room_sess_20260101000000000.csv` },
        { key: 'b', path: `evt-en-US_${bsid}_room_sess_20260101000000000.csv` },
    ]
    const { localeEntries, defaultEntries } = splitLocaleAndDefault(entries)
    assert.equal(localeEntries.length, 1)
    assert.equal(defaultEntries.length, 1)
    assert.equal(localeEntries[0].key, 'b')
})

test('findDuplicateCandidates matches within time window across a minute boundary', () => {
    const localeEntries = [
        { key: 'locale', path: `evt-en-US_${bsid}_room_sess_20260101005959998.csv` },
    ]
    const defaultEntries = [{ key: 'default', path: `evt-${bsid}_room_sess_20260101010000002.csv` }]
    const candidates = findDuplicateCandidates(localeEntries, defaultEntries)
    assert.equal(candidates.length, 1)
    assert.equal(candidates[0].defaultEntry.key, 'default')
})

test('findDuplicateCandidates finds no match outside the window', () => {
    const localeEntries = [
        { key: 'locale', path: `evt-en-US_${bsid}_room_sess_20260101000000000.csv` },
    ]
    const defaultEntries = [{ key: 'default', path: `evt-${bsid}_room_sess_20260101001000000.csv` }]
    assert.equal(findDuplicateCandidates(localeEntries, defaultEntries).length, 0)
})

test('isContentDuplicate compares size and hash', () => {
    assert.equal(isContentDuplicate('h1', 10, 'h1', 10), true)
    assert.equal(isContentDuplicate('h1', 10, 'h2', 10), false)
    assert.equal(isContentDuplicate('h1', 10, 'h1', 11), false)
})

test('buildMergeOrder sorts by timestamp and drops given keys', () => {
    const entries = [
        { key: 'b', path: `evt-${bsid}_room_sess_20260101000100000.csv` },
        { key: 'a', path: `evt-${bsid}_room_sess_20260101000000000.csv` },
        { key: 'c', path: `evt-${bsid}_room_sess_20260101000200000.csv` },
    ]
    const order = buildMergeOrder(entries, new Set(['c']))
    assert.deepEqual(
        order.map((e) => e.key),
        ['a', 'b']
    )
})

test('buildMergeOrder places entries with no timestamp last, in original order', () => {
    const entries = [
        { key: 'no-ts', path: `evt-${bsid}_room_sess.csv` },
        { key: 'ts', path: `evt-${bsid}_room_sess_20260101000000000.csv` },
    ]
    const order = buildMergeOrder(entries)
    assert.deepEqual(
        order.map((e) => e.key),
        ['ts', 'no-ts']
    )
})

test('mergeCsvContents drops header from every file after the first', () => {
    const merged = mergeCsvContents([
        'Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi',
        'Start,End,Speaker,Speaker ID,Text\n00:02,00:03,B,2,there',
    ])
    assert.equal(
        merged,
        'Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi\n00:02,00:03,B,2,there\n'
    )
})

test('mergeCsvContents handles a single fragment', () => {
    const merged = mergeCsvContents(['Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi'])
    assert.equal(merged, 'Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi\n')
})

test('mergeCsvContents skips empty fragments', () => {
    const merged = mergeCsvContents(['', 'Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi'])
    assert.equal(merged, 'Start,End,Speaker,Speaker ID,Text\n00:00,00:01,A,1,hi\n')
})

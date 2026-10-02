// Reconcile stopped recording sessions against GCS. Dry run unless --apply.
// Usage: GOOGLE_APPLICATION_CREDENTIALS=key.json node scripts/backfill-session-artifacts.js \
//   --project <id> --bucket <name> [--community <id>] [--event <id>] [--apply]

const admin = require('firebase-admin')
const { reconcileArtifacts } = require('../js/session-artifacts')

function parseArgs(argv) {
    const args = { apply: false }
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i]
        if (a === '--apply') args.apply = true
        else if (a.startsWith('--')) args[a.slice(2)] = argv[++i]
    }
    return args
}

// Read-only wrappers for dry runs.
const dryRef = (ref, log) => ({ get: () => ref.get(), update: async (u) => log.push(u) })
const dryBucket = (bucket) => ({
    getFiles: (opts) => bucket.getFiles(opts),
    file: (path) => ({ download: () => bucket.file(path).download(), save: async () => {} }),
})

async function main() {
    const args = parseArgs(process.argv.slice(2))
    if (!args.project || !args.bucket) {
        console.error('--project and --bucket are required')
        process.exit(1)
    }

    admin.initializeApp({ projectId: args.project })
    const firestore = admin.firestore()
    const bucket = admin.storage().bucket(args.bucket)

    let query = firestore.collection('recording-sessions').where('status', '==', 'stopped')
    if (args.community) query = query.where('communityId', '==', args.community)
    if (args.event) query = query.where('eventId', '==', args.event)
    const snap = await query.get()

    console.log(
        `${args.apply ? 'APPLY' : 'DRY RUN'}: ${snap.size} stopped session(s) in ${args.project}`
    )
    let repaired = 0
    for (const doc of snap.docs) {
        const session = doc.data()
        if (!session.gcsPrefix) continue
        const log = []
        try {
            const result = await reconcileArtifacts({
                bucket: args.apply ? bucket : dryBucket(bucket),
                firestore,
                ref: args.apply ? doc.ref : dryRef(doc.ref, log),
                session,
                deleteField: admin.firestore.FieldValue.delete(),
            })
            if (result.repaired) {
                repaired++
                console.log(`${doc.id}: ${JSON.stringify(result)}`)
                if (!args.apply)
                    log.forEach((u) => console.log(`  would update: ${JSON.stringify(u)}`))
            }
        } catch (err) {
            console.error(`${doc.id}: ${err.message}`)
        }
    }
    console.log(`${repaired} session(s) ${args.apply ? 'repaired' : 'would be repaired'}`)
}

main().catch((err) => {
    console.error(err)
    process.exit(1)
})

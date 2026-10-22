// Minimal in-memory stand-ins for Firestore and Cloud Storage, used by the
// external integration unit tests. Only the calls those modules make are
// supported.

const clone = (value) => (value === undefined ? undefined : structuredClone(value))

class FakeSnapshot {
    constructor(ref, data) {
        this.ref = ref
        this.id = ref.id
        this.exists = data !== undefined
        this._data = data
    }

    data() {
        return clone(this._data)
    }
}

class FakeDocRef {
    constructor(db, path) {
        this._db = db
        this.path = path
        this.id = path.split('/').pop()
    }

    async get() {
        return new FakeSnapshot(this, clone(this._db.store.get(this.path)))
    }

    async set(data, options = {}) {
        const existing = this._db.store.get(this.path)
        this._db.store.set(
            this.path,
            options.merge && existing ? { ...existing, ...clone(data) } : clone(data)
        )
    }

    async create(data) {
        if (this._db.store.has(this.path)) {
            const err = new Error('ALREADY_EXISTS')
            err.code = 6
            throw err
        }
        this._db.store.set(this.path, clone(data))
    }

    async update(data) {
        const existing = this._db.store.get(this.path)
        if (!existing) {
            const err = new Error('NOT_FOUND')
            err.code = 5
            throw err
        }
        this._db.store.set(this.path, { ...existing, ...clone(data) })
    }

    async delete() {
        this._db.store.delete(this.path)
    }
}

class FakeQuery {
    constructor(db, { collectionPath = null, groupId = null, filters = [] }) {
        this._db = db
        this._collectionPath = collectionPath
        this._groupId = groupId
        this._filters = filters
    }

    doc(id) {
        return new FakeDocRef(this._db, `${this._collectionPath}/${id}`)
    }

    where(field, op, value) {
        if (op !== '==') throw new Error(`Unsupported operator ${op}`)
        return new FakeQuery(this._db, {
            collectionPath: this._collectionPath,
            groupId: this._groupId,
            filters: [...this._filters, [field, value]],
        })
    }

    async get() {
        const docs = []
        for (const [path, data] of this._db.store.entries()) {
            const parts = path.split('/')
            const parent = parts.slice(0, -1).join('/')
            if (this._collectionPath != null && parent !== this._collectionPath) continue
            if (this._groupId != null && parts[parts.length - 2] !== this._groupId) continue
            if (!this._filters.every(([field, value]) => data[field] === value)) continue
            docs.push(new FakeSnapshot(new FakeDocRef(this._db, path), clone(data)))
        }
        return { docs, size: docs.length, empty: docs.length === 0 }
    }
}

class FakeFirestore {
    constructor(initial = {}) {
        this.store = new Map(Object.entries(initial).map(([k, v]) => [k, clone(v)]))
    }

    doc(path) {
        return new FakeDocRef(this, path)
    }

    collection(path) {
        return new FakeQuery(this, { collectionPath: path })
    }

    collectionGroup(id) {
        return new FakeQuery(this, { groupId: id })
    }

    batch() {
        const ops = []
        return {
            set: (ref, data, options) => ops.push(() => ref.set(data, options)),
            update: (ref, data) => ops.push(() => ref.update(data)),
            delete: (ref) => ops.push(() => ref.delete()),
            commit: async () => {
                for (const op of ops) await op()
            },
        }
    }

    // Transactions run one at a time, which gives the same result as
    // Firestore retrying a transaction whose reads changed underneath it.
    async runTransaction(fn) {
        const previous = this._transactionLock || Promise.resolve()
        let release
        this._transactionLock = new Promise((resolve) => (release = resolve))
        await previous
        try {
            const writes = []
            const tx = {
                get: (ref) => ref.get(),
                update: (ref, data) => writes.push(() => ref.update(data)),
                set: (ref, data, options) => writes.push(() => ref.set(data, options)),
            }
            const result = await fn(tx)
            for (const write of writes) await write()
            return result
        } finally {
            release()
        }
    }

    get(path) {
        return clone(this.store.get(path))
    }
}

class FakeBucket {
    constructor(files = {}) {
        this.files = files // path -> { size, contentType }
        this.signedUrlRequests = []
    }

    file(path) {
        return {
            name: path,
            exists: async () => [Object.prototype.hasOwnProperty.call(this.files, path)],
            getMetadata: async () => [
                { size: String(this.files[path].size), contentType: this.files[path].contentType },
            ],
            getSignedUrl: async (options) => {
                this.signedUrlRequests.push({ path, ...options })
                return [
                    `https://storage.example.test/${encodeURIComponent(path)}?expires=${
                        options.expires
                    }`,
                ]
            },
        }
    }
}

module.exports = { FakeFirestore, FakeBucket }

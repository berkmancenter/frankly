const test = require('node:test')
const assert = require('node:assert/strict')
const dns = require('dns')
const http = require('http')

const { postJson } = require('./http-post')

async function withServer(handler, fn) {
    const requests = []
    const server = http.createServer((req, res) => {
        let body = ''
        req.on('data', (chunk) => (body += chunk))
        req.on('end', () => {
            requests.push({ method: req.method, url: req.url, headers: req.headers, body })
            handler(req, res)
        })
    })
    await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve))
    const base = `http://127.0.0.1:${server.address().port}`
    try {
        return await fn(base, requests)
    } finally {
        server.closeAllConnections()
        await new Promise((resolve) => server.close(resolve))
    }
}

// Local test servers are on loopback, which safeLookup refuses on purpose.
const local = { lookup: dns.lookup, allowHttp: true, timeoutMs: 2000 }

test('posts the body and headers and returns the status', async () => {
    await withServer(
        (req, res) => res.writeHead(204).end(),
        async (base, requests) => {
            const result = await postJson(`${base}/hook`, {
                ...local,
                headers: { 'Content-Type': 'application/json', 'X-Test': '1' },
                body: '{"a":1}',
            })
            assert.deepEqual(result, { status: 204, bodySnippet: '' })
            assert.equal(requests.length, 1)
            assert.equal(requests[0].method, 'POST')
            assert.equal(requests[0].url, '/hook')
            assert.equal(requests[0].headers['x-test'], '1')
            assert.equal(requests[0].headers['content-length'], '7')
            assert.equal(requests[0].body, '{"a":1}')
        }
    )
})

test('reads at most maxErrorBytes of an error body', async () => {
    await withServer(
        (req, res) => {
            res.writeHead(500, { 'Content-Type': 'text/plain' })
            res.end('x'.repeat(1024 * 1024))
        },
        async (base) => {
            const result = await postJson(base, { ...local, maxErrorBytes: 100 })
            assert.equal(result.status, 500)
            assert.equal(result.bodySnippet, 'x'.repeat(100))

            const defaults = await postJson(base, local)
            assert.equal(defaults.bodySnippet.length, 1024)
        }
    )
})

test('does not follow redirects', async () => {
    await withServer(
        (req, res) => {
            if (req.url === '/hook') {
                res.writeHead(302, { Location: '/elsewhere' }).end()
            } else {
                res.writeHead(200).end()
            }
        },
        async (base, requests) => {
            const result = await postJson(`${base}/hook`, local)
            assert.equal(result.status, 302)
            assert.deepEqual(
                requests.map((r) => r.url),
                ['/hook']
            )
        }
    )
})

test('times out a receiver that never answers', async () => {
    await withServer(
        () => {},
        async (base) => {
            await assert.rejects(postJson(base, { ...local, timeoutMs: 100 }), /timed out/)
        }
    )
})

test('refuses http unless allowed', async () => {
    await assert.rejects(postJson('http://hooks.example.com/'), (err) => {
        assert.equal(err.retryable, false)
        return true
    })
})

test('lookup errors reach the caller unchanged', async () => {
    const blocked = new Error('blocked')
    blocked.retryable = false
    const lookup = (hostname, options, callback) => callback(blocked)
    await assert.rejects(
        postJson('https://hooks.example.com/', { lookup, timeoutMs: 2000 }),
        (err) => {
            assert.equal(err.message, 'blocked')
            assert.equal(err.retryable, false)
            return true
        }
    )
})

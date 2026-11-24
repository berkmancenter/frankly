// Schedules an HTTP function call through Cloud Tasks. This is the JS
// counterpart of lib/utils/infra/scheduled_functions.dart and uses the same
// queue, location and `app.functions_url_prefix` config, so both runtimes
// share one queue. Keep the two in sync.

const QUEUE_LOCATION = 'us-east4'
const QUEUE_NAME = 'scheduled-functions'

const isEmulator = () => process.env.FUNCTIONS_EMULATOR === 'true'

// In the emulator the configured prefix may name another project; point it at
// the project the emulator runs as (same as the Dart helper).
function emulatorUrlPrefix(urlPrefix) {
    const projectId = process.env.GCLOUD_PROJECT
    if (!projectId) return urlPrefix
    try {
        const url = new URL(urlPrefix)
        const segments = url.pathname.split('/').filter(Boolean)
        if (segments.length < 2 || segments[0] === projectId) return urlPrefix
        return `${url.origin}/${[projectId, ...segments.slice(1)].join('/')}`
    } catch (_) {
        return urlPrefix
    }
}

function createTaskScheduler({ functions, tasksClientFactory, fetchImpl = globalThis.fetch }) {
    let client
    const getClient = () => {
        if (!client) {
            if (tasksClientFactory) {
                client = tasksClientFactory()
            } else {
                const { CloudTasksClient } = require('@google-cloud/tasks')
                client = new CloudTasksClient()
            }
        }
        return client
    }

    return async function enqueueFunctionCall({ functionName, payload, scheduleTime }) {
        const config = functions.config().app || {}
        const urlPrefix = config.functions_url_prefix
        if (!urlPrefix) {
            throw new Error('app.functions_url_prefix must be set in the functions config')
        }
        const body = JSON.stringify(payload)

        if (isEmulator()) {
            // Cloud Tasks cannot reach a local emulator; call directly after
            // the delay instead.
            const delay = Math.max(0, scheduleTime.getTime() - Date.now())
            const target = `${emulatorUrlPrefix(urlPrefix)}/${functionName}`
            setTimeout(() => {
                fetchImpl(target, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body,
                }).catch((err) => console.error(`Emulator call to ${functionName} failed:`, err))
            }, delay)
            return
        }

        const projectId = config.project_id
        if (!projectId) {
            throw new Error('app.project_id must be set in the functions config')
        }
        const tasks = getClient()
        await tasks.createTask({
            parent: tasks.queuePath(projectId, QUEUE_LOCATION, QUEUE_NAME),
            task: {
                httpRequest: {
                    url: `${urlPrefix}/${functionName}`,
                    httpMethod: 'POST',
                    body: Buffer.from(body).toString('base64'),
                    headers: { 'Content-Type': 'application/json' },
                },
                scheduleTime: { seconds: Math.round(scheduleTime.getTime() / 1000) },
            },
        })
    }
}

module.exports = {
    QUEUE_LOCATION,
    QUEUE_NAME,
    emulatorUrlPrefix,
    createTaskScheduler,
}

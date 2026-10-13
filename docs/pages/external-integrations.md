# External Integrations (Webhooks)

Frankly can send an event's recordings and transcripts to another tool as soon as they are ready. A community admin adds an **integration** (a webhook receiver), and event hosts switch it on per event. Frankly then sends a signed HTTPS `POST` to the receiver for every recording and transcript of that event.

Frankly never sends file contents. Each request carries metadata and a short-lived signed download URL. The receiver downloads the file itself.

This page describes the contract so anyone can build a receiver.

---

## How it works

1. A community owner or admin adds an integration in **Admin → Settings → Integrations**: name, logo URL, short description, webhook URL (https only), which events to send, and whether it is on for new events by default.
2. Frankly generates a signing secret and shows it **once**. Store it in your receiver. It can be rotated later; the old secret stops working right away.
3. Event hosts see the integration (logo and name) in the event settings and can switch it on or off for their event. They can also enter an optional reference (for example a project ID in your tool). Frankly passes it to you untouched as `externalReference`.
4. Participants are told in the recording notice that recordings from this event are sent to the integration.
5. When a recording or transcript of the event is ready, Frankly sends one webhook per file. Delivery status is shown to admins in the event's data dialog, with a **Resend** button.

Nothing is sent, and no extra UI is shown, unless a community has an active integration that is switched on for the event. Integrations only receive something when the event is recorded (and transcribed, for transcripts).

---

## Events

| Type | Sent when | Artifact |
| --- | --- | --- |
| `recording.ready` | An MP4 recording of a room is stored. One per file; long recordings can have several. | `artifact.kind = "recording"`, `video/mp4` |
| `transcript.ready` | The merged transcript of a room is stored. | `artifact.kind = "transcript"`, `text/csv` |

Breakout rooms are recorded separately, so one event can produce several deliveries of each type. Use `recordingSession` to tell them apart.

---

## Request

```
POST <your webhook URL>
Content-Type: application/json
User-Agent: Frankly-Webhooks/1
X-Frankly-Event: recording.ready
X-Frankly-Delivery: dlv_2be4b8f159ba9d6a51ab5b40917c6b3a46d79fb2
X-Frankly-Attempt: 1
X-Frankly-Timestamp: 1767261900
X-Frankly-Signature: v1=5257a869e7ecebeda32affa62cdca3fa51cad7e77a0e56ff536d0ce8e108d8bd
```

| Header | Meaning |
| --- | --- |
| `X-Frankly-Event` | Event type, same as `type` in the body. |
| `X-Frankly-Delivery` | Delivery id, same as `deliveryId` in the body. Stable across retries and resends. |
| `X-Frankly-Attempt` | Attempt number for this delivery, starting at 1. Counts all retries and resends. |
| `X-Frankly-Timestamp` | Unix time (seconds) when the request was signed. |
| `X-Frankly-Signature` | `v1=` followed by the hex HMAC-SHA256 signature (see below). |

Redirects are not followed. Answer with any `2xx` status to confirm receipt.

### Body (schema version 1)

```json
{
  "schemaVersion": 1,
  "deliveryId": "dlv_2be4b8f159ba9d6a51ab5b40917c6b3a46d79fb2",
  "type": "recording.ready",
  "createdAt": "2026-01-01T10:05:00.000Z",
  "sentAt": "2026-01-01T10:05:00.120Z",
  "attempt": 1,
  "integration": { "id": "9af6fdc70e45050f4148" },
  "community": { "id": "my-community" },
  "event": {
    "id": "e1",
    "templateId": "t1",
    "title": "Town hall",
    "scheduledTime": "2026-01-01T09:00:00.000Z"
  },
  "recordingSession": {
    "id": "sess1",
    "roomType": "main",
    "roomId": "room1",
    "breakoutSessionId": null,
    "startedAt": "2026-01-01T09:00:00.000Z",
    "stoppedAt": "2026-01-01T09:58:00.000Z"
  },
  "externalReference": "project-42",
  "artifact": {
    "key": "complete_mp4_0",
    "kind": "recording",
    "fileName": "rec_0.mp4",
    "contentType": "video/mp4",
    "sizeBytes": 104857600,
    "downloadUrl": "https://storage.googleapis.com/...",
    "downloadUrlExpiresAt": "2026-01-01T11:05:00.120Z"
  }
}
```

| Field | Type | Notes |
| --- | --- | --- |
| `schemaVersion` | integer | `1`. New optional fields may be added without a version change; breaking changes bump it. |
| `deliveryId` | string | Stable id for this (integration, event type, file). Use it to deduplicate. |
| `type` | string | `recording.ready` or `transcript.ready`. |
| `createdAt` | ISO 8601 | When the delivery was first created. |
| `sentAt` | ISO 8601 | When this attempt was sent. |
| `attempt` | integer | Same as `X-Frankly-Attempt`. |
| `integration.id` | string | Your integration's id in Frankly. |
| `community.id` | string | Frankly community id. |
| `event.id`, `event.templateId` | string | Frankly event and template ids. |
| `event.title` | string or null | Event title. |
| `event.scheduledTime` | ISO 8601 or null | Scheduled start. |
| `recordingSession.*` | | The recorded room. `roomType` is `main` or `breakout`. |
| `externalReference` | string or null | The host's per-event value, passed through untouched. |
| `artifact.key` | string | Frankly's artifact key on the session. |
| `artifact.kind` | string | `recording` or `transcript`. |
| `artifact.fileName` | string | File name without path. |
| `artifact.contentType` | string | MIME type. |
| `artifact.sizeBytes` | integer or null | File size. |
| `artifact.downloadUrl` | string | Signed `GET` URL. Download promptly. |
| `artifact.downloadUrlExpiresAt` | ISO 8601 | When the URL stops working (default 60 minutes after `sentAt`). |

A JSON Schema of the body:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["schemaVersion", "deliveryId", "type", "createdAt", "sentAt", "attempt",
               "integration", "community", "event", "recordingSession", "externalReference", "artifact"],
  "properties": {
    "schemaVersion": { "const": 1 },
    "deliveryId": { "type": "string", "pattern": "^dlv_[a-f0-9]{40}$" },
    "type": { "enum": ["recording.ready", "transcript.ready"] },
    "createdAt": { "type": "string", "format": "date-time" },
    "sentAt": { "type": "string", "format": "date-time" },
    "attempt": { "type": "integer", "minimum": 1 },
    "integration": { "type": "object", "required": ["id"], "properties": { "id": { "type": "string" } } },
    "community": { "type": "object", "required": ["id"], "properties": { "id": { "type": "string" } } },
    "event": {
      "type": "object",
      "required": ["id"],
      "properties": {
        "id": { "type": "string" },
        "templateId": { "type": ["string", "null"] },
        "title": { "type": ["string", "null"] },
        "scheduledTime": { "type": ["string", "null"], "format": "date-time" }
      }
    },
    "recordingSession": {
      "type": "object",
      "required": ["id"],
      "properties": {
        "id": { "type": "string" },
        "roomType": { "enum": ["main", "breakout", null] },
        "roomId": { "type": ["string", "null"] },
        "breakoutSessionId": { "type": ["string", "null"] },
        "startedAt": { "type": ["string", "null"], "format": "date-time" },
        "stoppedAt": { "type": ["string", "null"], "format": "date-time" }
      }
    },
    "externalReference": { "type": ["string", "null"] },
    "artifact": {
      "type": "object",
      "required": ["key", "kind", "fileName", "contentType", "downloadUrl", "downloadUrlExpiresAt"],
      "properties": {
        "key": { "type": "string" },
        "kind": { "enum": ["recording", "transcript", "file"] },
        "fileName": { "type": "string" },
        "contentType": { "type": "string" },
        "sizeBytes": { "type": ["integer", "null"] },
        "downloadUrl": { "type": "string", "format": "uri" },
        "downloadUrlExpiresAt": { "type": "string", "format": "date-time" }
      }
    }
  }
}
```

---

## Verifying the signature

The signature is the hex HMAC-SHA256, keyed with your secret, of:

```
<X-Frankly-Timestamp> + "." + <raw request body>
```

Use the raw body bytes exactly as received (before any JSON parsing). Compare in constant time, and reject requests whose timestamp is more than 5 minutes away from your clock to stop replays.

=== "Node.js"

    ```js
    const crypto = require('crypto')

    function verifyFranklyWebhook({ secret, rawBody, headers, toleranceSeconds = 300 }) {
        const timestamp = headers['x-frankly-timestamp']
        const signature = String(headers['x-frankly-signature'] || '')
        if (!timestamp || !signature.startsWith('v1=')) return false
        if (Math.abs(Date.now() / 1000 - Number(timestamp)) > toleranceSeconds) return false

        const expected = crypto
            .createHmac('sha256', secret)
            .update(`${timestamp}.${rawBody}`)
            .digest('hex')
        const given = signature.slice(3)
        return (
            given.length === expected.length &&
            crypto.timingSafeEqual(Buffer.from(given), Buffer.from(expected))
        )
    }
    ```

=== "Python"

    ```python
    import hashlib, hmac, time

    def verify_frankly_webhook(secret: str, raw_body: bytes, headers, tolerance=300) -> bool:
        timestamp = headers.get("X-Frankly-Timestamp", "")
        signature = headers.get("X-Frankly-Signature", "")
        if not timestamp or not signature.startswith("v1="):
            return False
        if abs(time.time() - int(timestamp)) > tolerance:
            return False
        signed = timestamp.encode() + b"." + raw_body
        expected = hmac.new(secret.encode(), signed, hashlib.sha256).hexdigest()
        return hmac.compare_digest(signature[3:], expected)
    ```

The secret looks like `whsec_...`; use the whole string, prefix included, as the key.

---

## Retries, resends and idempotency

- The first attempt is made as soon as the file is ready. Each attempt has a 10 second timeout.
- Network errors, timeouts, `5xx`, `408`, `425` and `429` are retried after 1 minute, 5 minutes, 30 minutes, 2 hours and 6 hours (6 attempts in total, about 8.5 hours).
- Other responses (`3xx`, `4xx`) are not retried; the delivery is marked failed.
- Deliveries are also marked failed, without a request, if the integration was turned off or removed, the host switched it off for the event, or the file no longer exists.
- Admins and the event host can **Resend** any delivery. A resend starts a new set of retries and signs a fresh download URL.
- Retries and resends keep the same `deliveryId`, so **deduplicate on `deliveryId`**. You may receive the same delivery more than once (for example if your `2xx` response was lost); handle that by doing nothing the second time.
- Deliveries are independent and can arrive in any order.

---

## Security notes

- Webhook URLs must use `https`. URLs with credentials, internal host names (`localhost`, `*.internal`, `*.local`, single-label names) and private, loopback, link-local and metadata IP addresses are refused when the integration is saved, and the host name is resolved and checked again before every request.
- Deployments can restrict webhook hosts with an allowlist (see below).
- Signing secrets are generated by Frankly, stored in a Firestore collection that no client can read (`external-integration-secrets`), and only returned once when created or rotated.
- The webhook URL is only visible to community admins. The integration's name, logo and description are visible to signed-in users, because participants are told where recordings go.
- The per-event `externalReference` is stored on the event and is readable by signed-in users who can read the event. Do not put secrets in it.

---

## Deployment settings

All settings are optional and live in the functions config under `external_integrations`:

```bash
firebase functions:config:set \
  external_integrations.allowed_domains="partner.example,hooks.other.example" \
  external_integrations.signed_url_ttl_minutes="60" \
  external_integrations.request_timeout_ms="10000"
```

| Key | Default | Meaning |
| --- | --- | --- |
| `allowed_domains` | empty (any public https host) | Comma separated domains webhook URLs may use. Subdomains are included. |
| `signed_url_ttl_minutes` | `60` | Lifetime of download URLs (5 to 10080). |
| `request_timeout_ms` | `10000` | Timeout of one request (1000 to 60000). |
| `allow_local_targets_in_emulator` | `false` | `"true"` allows `http://localhost` receivers. Only honoured in the Functions emulator, for local testing. |

Retries use the same Cloud Tasks queue (`scheduled-functions` in `us-east4`) and `app.functions_url_prefix` as Frankly's other scheduled functions.

To show the admin settings section, build the client with `ENABLE_EXTERNAL_INTEGRATIONS=true`.

### Functions

| Function | Type | Purpose |
| --- | --- | --- |
| `upsertExternalIntegration` | callable | Create or update an integration (community owners/admins). Returns the secret on creation. |
| `rotateExternalIntegrationSecret` | callable | Replace the signing secret and return the new one. |
| `deleteExternalIntegration` | callable | Remove an integration, its URL and its secret. Delivery history is kept. |
| `resendExternalIntegrationDelivery` | callable | Send a delivery again (event host or community moderators/admins). |
| `externalIntegrationDeliveryTask` | HTTP | Cloud Tasks target for retries. Ignores requests that do not match a pending delivery's current run. |

Deliveries are created by `produceSessions` (and `repairSessionArtifacts` for late files) after the recording and transcript are registered. Delivery problems never affect recording or transcript processing.

### Firestore data

| Path | Who can read | Contents |
| --- | --- | --- |
| `community/{communityId}/external-integrations/{integrationId}` | signed-in users | Name, logo, description, events, defaults, active flag. |
| `community/{communityId}/external-integration-endpoints/{integrationId}` | community admins | Webhook URL. |
| `external-integration-secrets/{integrationId}` | nobody (server only) | Signing secret. |
| `community/{c}/templates/{t}/events/{e}/external-integration-settings/{integrationId}` | signed-in users; written by the host or moderators | `enabled`, `externalReference`. |
| `external-integration-deliveries/{deliveryId}` | community moderators | Status (`pending`, `delivered`, `failed`), attempts, last error, timestamps. |

# Deploying Your Own Instance of Frankly

This guide explains how to host your own production-ready instance of **Frankly**, a Flutter web app backed by Firebase and Google Cloud.

Frankly uses:

- A **Flutter** client application (web)
- **Firebase Hosting**
- **Firebase Authentication**
- **Cloud Firestore**
- **Realtime Database**
- **Firebase Functions**
- Third-party integrations (some optional), including **Agora**, **Mux**, **Cloudinary**, and **SendGrid**

---

## Prerequisites

Before you begin, make sure you have:

- A Google account with access to create Firebase and Google Cloud projects
- Firebase CLI installed (`npm install -g firebase-tools`)
- Node.js and npm installed (recommend via `nvm`)
- Flutter `3.22.2` installed
- Access to any third-party services you plan to enable

Recommended tools:

- Google Cloud SDK (`gcloud`)
- Chrome
- VS Code

---

## 1. Create Firebase Projects

Create separate Firebase projects for each environment you want to support, for example:

- **staging**
- **production**

For each project:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add a **Web App** (under Project Settings → Your Apps)
4. Note the Firebase web configuration values — you will use them in `client/.env` later

---

## 2. Update `.firebaserc`

Update `.firebaserc` at the repo root to point at your Firebase project IDs.

Example structure:

```json
{
  "projects": {
    "default": "your-staging-project-id",
    "staging": "your-staging-project-id",
    "prod": "your-production-project-id"
  }
}
```

---

## 3. Initialize Core Firebase Services

For each Firebase project/environment, set up the following in the Firebase Console.

### Firestore

1. Create a Firestore database (single-region configuration required)
2. Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules
```

### Realtime Database

1. Create a Realtime Database
2. Deploy Realtime Database rules:

```bash
firebase deploy --only database
```

### Firebase Authentication

Enable the required auth providers in the Firebase Console under **Authentication → Sign-in method**:

- **Anonymous** — Required. New visitors are signed in anonymously.
- **Email/Password**
- **Google**

For **Google sign-in**, you will also need to set the Google OAuth Client ID via the `app.google_id` runtime config value (see section 8). The `ServeIndex` function substitutes this into the HTML at request time.

---

## 4. Configure Firebase Hosting

Frankly is hosted via Firebase Hosting. The built Flutter web app is served from `client/build/web`.

All HTML page requests are routed through the `ServeIndex` Cloud Function, which injects a per-request Content Security Policy (CSP) nonce. A nonce is a random, single-use token generated fresh for each page load. The server includes the same nonce value in both the CSP header and on each trusted `<script>` tag. The browser only executes scripts whose nonce attribute matches the one in the CSP header. Because an attacker cannot predict the nonce for a given request, injected scripts will not have the correct nonce and will be blocked. Static assets (JS, CSS, images, fonts) are served directly by Firebase Hosting without going through the function.

This is configured by the catch-all rewrite in `firebase.json`:

```json
{
  "source": "**",
  "function": "ServeIndex"
}
```

### Content Security Policy (CSP)

The CSP is set as an HTTP response header by `ServeIndex` (in `firebase/functions/js/serve-index.js`). It uses `'strict-dynamic'` with a per-request nonce, which means:

- Every `<script>` tag in `index.html` must have `nonce="__SCRIPT_NONCE__"`. The function replaces this placeholder with a cryptographic random value on each request.
- Scripts dynamically created by trusted (nonced) parent scripts are automatically trusted via `strict-dynamic` propagation. This covers Firebase SDK internals, Cloudinary widget internals, etc.
- `connect-src` restricts which domains the app can make fetch/XHR/WebSocket calls to. If you add a new backend service integration, add its domain to the `connect-src` list in `serve-index.js`.
- `frame-ancestors 'self'` prevents the app from being embedded in iframes on other sites (clickjacking protection). This directive only works as an HTTP header, not a meta tag.

### Adding a new third-party script

1. Add the `<script>` tag to `client/web/index.html` with `nonce="__SCRIPT_NONCE__"`.
2. Run `build-all.sh` or `run-dev.sh` (or let CI handle it) so `client/web/index.html` is copied to `firebase/functions/web/index.html` before building/deploying functions.
3. If the script makes network requests to new domains, add those domains to `connect-src` in `serve-index.js`.
4. If the script loads images or media from new domains, update `img-src` or `media-src` accordingly.
5. If the script loads stylesheets or fonts from new domains, update `style-src` or `font-src` accordingly.

### Template sync

`firebase/functions/web/index.html` is a copy of `client/web/index.html` used by the ServeIndex function. The CI/CD workflows, `build-all.sh`, and `run-dev.sh` all copy `client/web/index.html` to `firebase/functions/web/index.html` automatically before building functions. You should not need to sync these files manually.

If you are using multiple hosting targets (e.g. staging and production sites), configure them with:

```bash
firebase target:apply hosting staging your-staging-site-name
firebase target:apply hosting prod your-production-site-name
```

Also configure your custom domains in Firebase Hosting for each target as needed.

For more information, see [Firebase Hosting deploy targets](https://firebase.google.com/docs/cli/targets#set-up-deploy-target-hosting).

---

## 5. Configure Firebase Functions

Frankly uses Firebase Functions. Before deploying, verify that the default service account for the Firebase project is enabled:

- Firebase Console → Project Settings → Service Accounts
- Click **Manage service accounts** in Google Cloud Console
- Confirm the required service account is enabled

### Install dependencies and build functions

From `firebase/functions`:

```bash
npm install
dart pub get
dart run build_runner build --output=build
```

### Deploy functions

```bash
firebase deploy --only functions
```

### Inspect current runtime config

```bash
firebase functions:config:get
```

---

## 6. Create Required Cloud Tasks Queue

Frankly uses Google Cloud Tasks for scheduled function work.

```bash
gcloud config set project YOUR-FIREBASE-PROJECT-ID
gcloud tasks queues create scheduled-functions
```

Repeat for each environment as needed.

---

## 7. Deploy Rules and Indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only database
firebase deploy --only firestore:indexes
```

---

## 8. Set Functions Runtime Configuration

Frankly uses `firebase functions:config` for server-side configuration. These values are read by Firebase Functions at runtime — they are **not** the same as the client `.env` variables covered in the next section.

A sample configuration file is at `firebase/functions/.runtimeconfig.json.example`. Copy it to `firebase/functions/.runtimeconfig.json` for local development.

For production, set values using the Firebase CLI:

```bash
firebase functions:config:set \
  app.domain="<YOUR_VALUE_HERE>" \
  app.legal_entity_name="<YOUR_VALUE_HERE>" \
  app.alt_email_domain="<YOUR_VALUE_HERE>" \
  app.no_reply_email="<YOUR_VALUE_HERE>" \
  app.unsubscribe_encryption_key="<YOUR_VALUE_HERE>" \
  app.name="<YOUR_VALUE_HERE>" \
  app.full_url="<YOUR_VALUE_HERE>" \
  app.privacy_policy_url="<YOUR_VALUE_HERE>" \
  app.mailing_address="<YOUR_VALUE_HERE>" \
  app.banner_image_url="<YOUR_VALUE_HERE>" \
  app.functions_url_prefix="<YOUR_VALUE_HERE>" \
  app.project_id="<YOUR_VALUE_HERE>" \
  app.copyright="<YOUR_VALUE_HERE>" \
  app.google_id="<YOUR_VALUE_HERE>" \
  app.version="<YOUR_VALUE_HERE>" \
  ics.prod_id="<YOUR_VALUE_HERE>" \
  xmlns.url="<YOUR_VALUE_HERE>" \
  xmlns.media_url="<YOUR_VALUE_HERE>" \
  functions.on_firestore.min_instances="<YOUR_VALUE_HERE>" \
  functions.update_live_stream_participant_count.min_instances="<YOUR_VALUE_HERE>"
```

### What these values are for

**Application settings**

- `app.domain` — App domain without protocol, e.g. `www.example.com`
- `app.legal_entity_name` — Legal owner/operator of the app (may contain HTML)
- `app.alt_email_domain` — Domain used for SendGrid mail sending
- `app.no_reply_email` — No-reply sender email address
- `app.name` — Public-facing application name
- `app.full_url` — Full app URL including protocol, e.g. `https://www.example.com`
- `app.privacy_policy_url` — Full privacy policy URL
- `app.mailing_address` — Physical mailing address for outgoing email content
- `app.banner_image_url` — Home page banner image URL
- `app.functions_url_prefix` — Base URL for deployed Firebase Functions
- `app.project_id` — Firebase project ID
- `app.copyright` — Copyright statement for outgoing emails
- `app.unsubscribe_encryption_key` — Random string used for unsubscribe link signing
- `app.google_id` — Google OAuth Client ID for Google Sign-In (substituted into the HTML by ServeIndex)
- `app.version` — Application version string (substituted into the HTML by ServeIndex; typically set by CI/CD)

**Calendar / XML namespace values**

- `ics.prod_id` — Product identifier string for ICS calendar generation
- `xmlns.url` — App URL plus `/xmlns`
- `xmlns.media_url` — Media RSS namespace URL (typically `http://search.yahoo.com/mrss/`)

**Function scaling controls**

- `functions.on_firestore.min_instances` — Minimum warm instances for the main Firestore function
- `functions.update_live_stream_participant_count.min_instances` — Minimum warm instances for the participant count function

These values may differ between staging and production.

---

## 9. Configure the Flutter Client

All client configuration is done via a `.env` file. The Flutter build reads this file using `--dart-define-from-file`. No source files need to be edited for configuration except the Google Sign-In client ID placeholder in `client/web/index.html` (see below).

Copy `client/.env.hosted.example` to `client/.env` and fill in all required values:

```bash
cp client/.env.hosted.example client/.env
```

### Required values in `client/.env`

**Firebase connection** — obtain from Firebase Console → Project Settings → Your Apps → Web App:

```bash
FIREBASE_API_KEY=<value>
FIREBASE_APP_ID=<value>
FIREBASE_MESSAGING_SENDER_ID=<value>
FIREBASE_PROJECT_ID=<value>
FIREBASE_AUTH_DOMAIN=<value>
FIREBASE_DATABASE_URL=<value>
FIREBASE_STORAGE_BUCKET=<value>
FIREBASE_MEASUREMENT_ID=<value>
```

**App connections:**

```bash
FUNCTIONS_URL_PREFIX=<value>   # Base URL for your Google Cloud Run Functions
SHARE_LINK_URL=<value>         # URL prefix for share links, e.g. https://<app-url>/share
```

**Cloudinary** (for media uploads):

```bash
CLOUDINARY_IMAGE_PRESET=<value>
CLOUDINARY_VIDEO_PRESET=<value>
CLOUDINARY_DEFAULT_PRESET=<value>
CLOUDINARY_CLOUD_NAME=<value>
```

**Optional / branding** — defaults are set in the example file and can be overridden:

```bash
APP_NAME=
APP_URL=
LOGO_URL=
SIDEBAR_FOOTER=
COPYRIGHT_STATEMENT=
TERMS_URL=
PRIVACY_POLICY_URL=
# ... (see .env.hosted.example for full list)
```

**Optional monitoring:**

```bash
SENTRY_DSN=<value>
SENTRY_ENVIRONMENT=<value>
SENTRY_RELEASE=<value>
MATOMO_URL=<value>
MATOMO_SITE_ID=<value>
```

### Google Sign-In Client ID

The file `client/web/index.html` contains the placeholder `__GOOGLE_ID__` in a `<meta name="google-signin-client_id">` tag. Replace this with your Google OAuth client ID before building.

---

## 10. Optional Third-Party Integrations

You only need to configure the services your instance will use.

### Agora

Agora powers video functionality. Set these values via `firebase functions:config:set`:

```bash
agora.app_id="<YOUR_VALUE_HERE>"
agora.app_certificate="<YOUR_VALUE_HERE>"
agora.rest_key="<YOUR_VALUE_HERE>"
agora.rest_secret="<YOUR_VALUE_HERE>"
agora.storage_bucket_name="<YOUR_VALUE_HERE>"
agora.storage_access_key="<YOUR_VALUE_HERE>"
agora.storage_secret_key="<YOUR_VALUE_HERE>"
agora.webhook_secret="<YOUR_VALUE_HERE>"
```

Setup summary:

- Create a project in the [Agora console](https://console.agora.io/v2/) using **Secure Mode: App ID + Token**
- `app_id` / `app_certificate`: from the project page in the Agora console
- `rest_key` / `rest_secret`: from **Developer Toolkit → Restful API → Add a Secret**
- `storage_bucket_name` / `storage_access_key` / `storage_secret_key`: create a Google Cloud Storage bucket for recordings and generate interoperability access keys under **Storage → Settings → Interoperability**
- `webhook_secret`: a secret string you choose when configuring Agora **Notifications** to point at your deployed `AgoraRecordingWebhook` function URL

### Mux

Mux supports livestream workflows. Set via `firebase functions:config:set`:

```bash
mux.token_id="<YOUR_VALUE_HERE>"
mux.secret="<YOUR_VALUE_HERE>"
```

Also configure Mux webhooks in the Mux dashboard to POST to your deployed `MuxWebhooks` function URL.

### Cloudinary

Cloudinary is used for media uploads. Configuration is done entirely via `client/.env` (see step 9). No source files need to be edited.

### Stripe

Stripe is currently disabled by default. If you enable it, set via `firebase functions:config:set`:

```bash
stripe.connected_account_webhook_key="<YOUR_VALUE_HERE>"
stripe.pub_key="<YOUR_VALUE_HERE>"
stripe.secret_key="<YOUR_VALUE_HERE>"
stripe.webhook_key="<YOUR_VALUE_HERE>"
```

Also create products and pricing with a `plan_type` metadata field (`individual`, `club`, or `pro`) and configure prices for each.

### SendGrid

SendGrid email delivery is handled through a Firestore extension. Configure the Firebase extension `firebase/firestore-send-email@0.1.9` with your SendGrid credentials. Email definitions are written to the `sendgridmail` Firestore collection.

### Email Authentication DNS Records

To prevent spoofing of your sender domain, configure these DNS records:

**SPF** - Add a TXT record on your apex domain:

```
v=spf1 mx ip4:<your-mail-server-ip-range> include:sendgrid.net -all
```

**DKIM** - In SendGrid, go to Settings -> Sender Authentication -> Authenticate Your Domain. SendGrid will give you CNAME records to add in your DNS provider. Verify they resolve:

```bash
dig +short CNAME <selector>._domainkey.yourdomain.com
```

**DMARC** - Add a TXT record at `_dmarc.yourdomain.com`:

```
v=DMARC1; p=quarantine; rua=mailto:<your-reporting-address>
```

Start with `p=quarantine` to catch misaligned senders before moving to `p=reject`.

### DNSSEC

DNSSEC adds cryptographic signatures to DNS responses, preventing attackers from forging or tampering with DNS answers (cache poisoning). Without it, an attacker who can poison a resolver cache could redirect your users to a different server.

If your domain uses Gandi nameservers (ns-\*.gandi.net), Gandi handles key generation and DS record publication automatically:

1. Log in to Gandi -> go to your domain -> DNS Records tab
2. Click "DNSSEC" in the sidebar
3. Enable DNSSEC - Gandi will generate the signing keys and publish the DS record to the parent zone

Verify it is active after propagation:

```bash
dig +short DS yourdomain.com
```

If you see one or more DS records, DNSSEC is live. You can also check with:

```bash
dig +dnssec yourdomain.com
```

Look for the `ad` (authenticated data) flag in the response header.

---

## 11. Build and Deploy

### Step 1: Select the target project

```bash
firebase use staging
# or
firebase use prod
```

### Step 2: Deploy rules and indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only database
firebase deploy --only firestore:indexes
```

### Step 3: Build and deploy functions

From `firebase/functions`:

```bash
npm install
dart run build_runner build --output=build
firebase deploy --only functions
```

### Step 4: Build the Flutter client

From `client/`:

```bash
flutter pub get
flutter build web --release --source-maps --web-renderer html -t lib/main.dart --dart-define-from-file=.env
```

The built output goes to `client/build/web`, which is what Firebase Hosting serves (as configured in `firebase.json`).

### Step 5: Deploy hosting

From the repo root:

```bash
firebase deploy --only hosting
```

---

## 12. Post-Deployment Verification Checklist

### Core platform

- [ ] Firebase Hosting site loads successfully
- [ ] Anonymous auth works for new visitors
- [ ] Email/password auth works
- [ ] Google auth works
- [ ] Firestore reads/writes succeed
- [ ] Realtime Database connectivity works
- [ ] Firebase Functions deploy with no runtime config errors

### Video / events

- [ ] Users can create or join events
- [ ] Breakout room assignment works
- [ ] Audio/video works in browser
- [ ] Recording works if Agora recording is configured

### Livestreaming

- [ ] Mux webhook is reachable
- [ ] Live stream playback appears correctly

### Media and messaging

- [ ] Cloudinary uploads succeed
- [ ] SendGrid emails are delivered
- [ ] Banner images and public assets load

### Infrastructure

- [ ] Cloud Tasks queue exists
- [ ] Firestore indexes are built
- [ ] Rules are deployed to the correct environment

---

## 13. Recommended Environment Rollout Process

1. Set up **staging** first
2. Configure all secrets and Firebase services
3. Deploy rules, indexes, functions, and hosting
4. Verify authentication, event flow, and integrations
5. Repeat for **production**
6. Keep a separate config checklist for each environment

---

## 14. Common Pitfalls

### Functions deploy but fail at runtime

Usually caused by missing `firebase functions:config` values. Check with:

```bash
firebase functions:config:get
```

### Wrong Firebase project deployed

Confirm your active project before running deploy commands:

```bash
firebase use
```

### Hosting works but client points at wrong backend

Double-check your `client/.env` values — specifically `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_DATABASE_URL`, and `FUNCTIONS_URL_PREFIX`.

### Google sign-in does not work

Ensure `__GOOGLE_ID__` in `client/web/index.html` was replaced with your actual Google OAuth client ID before building.

### Video or integrations do not work

Usually caused by:

- Missing third-party credentials in `firebase functions:config`
- Wrong webhook URLs
- Missing storage bucket setup
- Missing Cloudinary presets in `client/.env`
- Missing SendGrid extension configuration

### Scheduled functions do not run

Check whether the Cloud Tasks queue exists:

```bash
gcloud tasks queues list
```

---

## 15. Minimal Deployment Checklist

- [ ] Create Firebase projects (staging and/or production)
- [ ] Add a Web App in each Firebase project and note the config values
- [ ] Update `.firebaserc` with your project IDs
- [ ] Enable Anonymous, Email/Password, and Google auth providers
- [ ] Create Firestore and Realtime Database
- [ ] Deploy Firestore rules, Realtime Database rules, and Firestore indexes
- [ ] Set required `firebase functions:config` values
- [ ] Build and deploy Firebase Functions
- [ ] Create `scheduled-functions` Cloud Tasks queue
- [ ] Copy `client/.env.hosted.example` to `client/.env` and fill in all values
- [ ] Replace `__GOOGLE_ID__` in `client/web/index.html` with your Google OAuth client ID
- [ ] Build Flutter client with `--dart-define-from-file=.env`
- [ ] Deploy Firebase Hosting
- [ ] Verify sign-in, events, and integrations

---

## 16. Useful Commands Reference

```bash
# Select active Firebase project
firebase use staging
firebase use prod

# Deploy rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only database
firebase deploy --only firestore:indexes

# Build and deploy functions (from firebase/functions)
npm install
dart pub get
dart run build_runner build --output=build
firebase deploy --only functions

# Inspect / set runtime config
firebase functions:config:get
firebase functions:config:set app.name="Your App Name"

# Create Cloud Tasks queue
gcloud config set project YOUR-FIREBASE-PROJECT-ID
gcloud tasks queues create scheduled-functions

# Build the Flutter client (from client/)
flutter build web --release --source-maps --web-renderer html -t lib/main.dart --dart-define-from-file=.env

# Deploy hosting
firebase deploy --only hosting
```

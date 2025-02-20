# Introduction

Welcome to the Frankly repo!

Frankly is an online deliberations platform that allows anyone to host video-enabled conversations about any topic. Key functionalities include:

- Matching participants into breakout rooms based on survey questions
- Creating structured event templates with different activities to take participants through

Frankly is a **Flutter** app with a **Firebase** backend.

<!-- See instructions [here](dev.md) for development. -->

# Overview

🪧 This README includes the following sections:

- **Overview**: An overview of the contents of the README and a description of the contents of major directories in the repo.
- **Running Frankly Locally for Development**: Instructions for setting up and running the app locally.
- **Testing**
- **Hosting Your Own Instance of Frankly**: Instructions for setting up a full production-ready instance of the app.
- **Troubleshooting and FAQ**

## Repo contents

This subsection provides a description of the contents of major directories in the repo.  
**💡 Important note:** For the rest of this README, most terminal commands should be executed from within the `client` directory (or subdirectories of it when specified).

- `client`
  The main Flutter app.

- `data_models`
  These are the data models used by both the client and Firestore.

- `firebase/functions`
  These are the Firebase Functions which are deployed on Google Cloud and called by the Flutter app. Firebase functions are built on top of Cloud Functions.

- `firestore/firestore.rules`
  This is a Firestore security rules file which defines which Firestore documents are readable by which users.

- `matching`
  Contains `lib/matching.dart`, which is the logic for matching participants into breakout rooms. See the README in this directory for links to helpful documentation on matching.

1.  Download and install Google Chrome [here](https://www.google.com/chrome/) if it’s not already pre-installed. This is used for live debugging on web.
2.  Download and install XCode from the Mac App Store. This is used for developing iOS apps and running on macOS as a desktop app.
3.  Install VSCode [here](https://code.visualstudio.com/download).
4.  Optional, but recommended: Install Homebrew [here](https://brew.sh/).
5.  Follow the instructions [here](https://docs.flutter.dev/get-started/install) to install Flutter on your machine. You can choose iOS as your target platform.

    1. This includes a link to install CocoaPods. However, you may run into issues with installing CocoaPods due to a Ruby version issue (the pre-installed Ruby on MacOS is too old). You can install ruby via homebrew instead by running `brew install cocoapods`, which should alleviate those errors.
    2. **Recommended**: Install the [Flutter VSCode extension](https://docs.flutter.dev/get-started/editor#install-the-vs-code-flutter-extension) and use the extension to [install Flutter via VSCode](https://docs.flutter.dev/get-started/install/macos/mobile-ios#use-vs-code-to-install-flutter).
    3. **Recommended**: Install the Flutter SDK in your home folder under a directory called `dev` (or something similar).

6.  Add Flutter to your PATH. For Mac with Zsh (you can also copy this command from [here](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download#add-flutter-to-your-path)), create or open ~/.zshenv and add this line:
    `export PATH=$HOME/development/flutter/bin:$PATH`
    Restart terminal sessions to see the changes.
7.  Install Node.js and npm [here](https://nodejs.org/en).
8.  Install Firebase CLI Tools using the command `npm install -g firebase-tools` ([documentation](https://www.npmjs.com/package/firebase-tools)).

    1. You will likely run into permissions issues when installing this due to being a non-root user. To remedy this, reassign ownership of the relevant folders to yourself by running the following 2 commands before running `npm install` :
       `sudo chown -R $USER /usr/local/bin/`
       `sudo chown -R $USER /usr/local/lib/node_modules`

    For more information, you can read this Stack Overflow [post](https://stackoverflow.com/questions/48910876/error-eacces-permission-denied-access-usr-local-lib-node-modules).

9.  Activate the Firebase CLI for Flutter by following the steps [here](https://firebase.google.com/docs/flutter/setup?platform=ios). Skip steps 3 and 4 in the “Initialize Firebase in your app” section. This project uses a separate file (app.dart) for the imports.

> Please check **❓Troubleshooting / FAQ** at the end of the README for suggested resolutions to common Flutter installation errors.

## Environment Setup

These are the steps for getting started with developing Frankly:

1. 📦 Build the data models
2. 🔥 Setting up and connecting to the Firebase emulators
3. 🔌 Connecting to third-party services
4. 🐦 Running the frontend Flutter app

The following section will cover these steps for running the app for the first time.

## 📦 Data Models

The first step in running the app is to build the data_models package. Some code in this package is auto-generated by [Freezed](https://pub.dev/packages/freezed). Run the following steps in the `data_models` directory to generate code and make the package available to the client and Firebase functions:

1. To install all Dart dependencies run `flutter pub get`.
2. Run `dart run build_runner build --delete-conflicting-outputs`

## 🔥 Firebase

### Firebase CLI

Most of the operations for development and deployment take place via the Firebase CLI. You can find documentation for the Firebase CLI [here](https://firebaseopensource.com/projects/firebase/firebase-tools/).

Run the following steps once:

- Install Firebase CLI using `npm install -g firebase-tools`
- You should be able to use the CLI for local development without signing in

### Firebase Functions Installation

Firebase Functions are built on top of Cloud Functions (GCP's serverless functions product), which is why there are references to Cloud Functions tooling below. Functions are written in `dart` and are compiled to `javascript` with `dart2js`.

For the following sub-section, switch to the `firebase/functions` directory to run all commands.

- To install all Javascript dependencies, run `npm install`.
- To install all Dart dependencies run `flutter pub get`.

You don't need to run `npm install` again unless you've added new dependencies or made updates to existing ones. Same applies to `flutter pub get`, but for changes to any function dependencies.

### Emulators

Firebase has a full suite of emulators called Firebase Local Emulator Suite. You can find the full description of the Firebase Local Emulator Suite and its capabilities [here](https://firebase.google.com/docs/emulator-suite).

You should emulate services locally for development purposes, and set up the client to use these emulators instead of connecting to a live Firebase project. By default, the emulators will run against the default project "dev," specified in the `.firebaserc` file.

**Using config in emulators**

You do not need to run `functions:config:set.` as the emulators are configured by a file.

- To configure the emulators, create the file `firebase/functions/.runtimeconfig.json`.
  - A sample file containing the config properties described above can be found in `firebase/functions/.runtimeconfig.json.local.example`.

**Running the emulators**

:point_right: **Important**: you must do this before running the [client](?id=%f0%9f%90%a6-running-and-building-the-frontend-web-client).

To run the emulators locally, run the following _while_ in the `firebase/functions` directory:

```
dart run build_runner build --output=build
firebase emulators:start --only firestore,functions,auth,pubsub,database
```

We recommend using the emulators [import and export](https://firebase.google.com/docs/emulator-suite/connect_firestore#import_and_export_data) functionality to make development easier.

> Please refer to the Cloud Functions Emulator section under **❓Troubleshooting / FAQ** for common issues and resolutions!

## 🔌 Third Party Services

The Firebase Functions and/or Flutter client app connect to the following third party services, which must be set up and configured for local development.

### Agora

Sign up for Agora and open the [Agora console](https://console.agora.io/v2/). The following instructions are geared towards using V2 of the Agora console.

The following instructions will guide you through retrieving the values to fill in the following command for setting Agora-related values in your Functions configuration:

```
agora.app_id="<YOUR_VALUE_HERE>"
agora.app_certificate="<YOUR_VALUE_HERE>"
agora.rest_key="<YOUR_VALUE_HERE>"
agora.rest_secret="<YOUR_VALUE_HERE>"
agora.storage_bucket_name="<YOUR_VALUE_HERE>"
agora.storage_access_key="<YOUR_VALUE_HERE>"
agora.storage_secret_key="<YOUR_VALUE_HERE>"
```

#### **🔧 Setting up the integration**

- **Agora**
  Create a new project in the Agora console. For Authentication Mode, select **Secure Mode: App ID + Token**.

  - `app_id`: Copy the App ID from the Projects list in the console home.
  - `app_certificate`: Select **Configure** on your project. Copy the value under **Security > Primary Certificate**.
  - `rest_key`: In the left navigation panel, select **Restful API** under either **Developer Toolkit** or **Developer Resources**, depending on your screen size. Click **Add a Secret**. Download the Customer Secret, and input the value for **Key**.
  - `rest_secret`: From the Customer Secret file, input the value for **Secret**.

- **Google Cloud Storage**
  Create a Google Cloud Storage bucket to store event recordings. Navigate to [Google Cloud Storage](https://console.cloud.google.com/storage/) and select **Create a Bucket**. Provide a bucket name. Then, configure the bucket with your desired settings for the remaining options.
  - `storage_bucket_name`: Enter the bucket name you selected.
  - `storage_access_key`: Select **Settings** under the Cloud Storage left-side settings panel. Click on the **Interopability** tab. You may choose to either create an access key for a service account, or create a key for your user account. For whichever method you have opted to use, select **Create a Key**. Then, paste the generated **Access key** here.
  - `storage_secret_key`: From the generated key, paste the **Secret**.
- **In the codebase**
  In `client/lib/app/community/admin/conversations_tab.dart`, change the URIs in the `_buildRecordingSection` method (replacing the ASML values appearing ahead of `/us-central1/downloadRecording`) to reflect your staging and prod Firebase project IDs.

#### 👾 Testing the integration

Once you have the keys set up, you can follow the below checklist to test that key behaviors that depend on Agora are working successfully.

- [ ] **Basic video functionality**: Create a community, start an event, and join the event from two different browser windows with two different users. Verify that when video and audio are enabled, both parties can see and hear each other.
  - [ ] **Mobile size**: Verify that video still works on mobile size.
  - [ ] **Adjusting AV settings:** In the bottom navigation bar, adjust your microphone and video input. Verify that the change occurs successfully.
- [ ] **Breakout rooms**: Start breakout rooms. Verify that users are assigned to breakout rooms and video still works.
- [ ] **Recording**: Record the meeting by going into Settings and toggling the "Recording" option on before joining the event. After joining the meeting, verify that the top right corner says "Recording".
  - [ ] Go to your Settings view, select Conversations, and select 'Download'. Verify that a .zip file should be downloaded with several different files, including audio and video.
- [ ] **Bottom navigation**: Interact with everything on the bottom navigation bar, including chat and emoji reactions. Verify that behavior works as expected.
- [ ] **Show participant info**: In the right side bar, click on a participant to show their user info. Verify that user details show as expected.
- [ ] **Kicking a user**: In a hosted meeting, kick a user. Verify that the host sees the user disappear, and the user should see that they are banned if they try to navigate back to the event.

### Mux

Mux streaming is used when a customer wants to stream video from a third party streaming service, such as Zoom, to Frankly. Essentially the customer will record video from the third party platform, the data is sent to Mux, which will then notify Frankly's MuxWebhook Firebase function that a stream has started. Once the stream has started, the Frankly event page will display the streaming video.

1. Using [Mux's instructions](https://docs.mux.com/guides/start-live-streaming#1-get-an-api-access-token), get a new access token. Use the environment of your choice and set the permission level to "Mux Video".
2. Set up Mux secrets for your local development environment by replacing values in the following command. As the names suggest, the mux.token_id corresponds to your Mux token ID and mux.secret corresponds to your Mux token secret.

```
firebase functions:config:set mux.secret="<YOUR_VALUE_HERE>" mux.token_id="<YOUR_VALUE_HERE>"
```

3. To connect Mux to the [MuxWebhooks cloud function](https://github.com/berkmancenter/frankly/blob/73687b331ffa7bebcc488bb2eac64eecd4c52c0f/client/functions/lib/functions/on_request/mux_webhooks.dart#L4), the function first needs to be deployed to your Google Cloud Project. Get the URL of the deployed function provided by Google Cloud, which should resemble this format: https://us-central1-myproject.cloudfunctions.net/MuxWebhooks.
4. Login to Mux and go to Settings > Webhooks. Select the environment for which you want to use the webhook, then click “Create new webhook.”For the URL to Notify field, provide the URL for your deployed MuxWebhooks function. Then click "Create webhook."

#### 👾 Testing your setup

You can verify the integration is working by manually triggering a new call directly from Mux.

1. Visit your Google Cloud Platform Logging page so you can scan for any errors and expected logs during the live stream test.
2. In the Mux dashboard, go to Video > Live Streams. Click "Create your first live stream."
3. Run the default request.

The following should be true if your Mux setup works as expected:
The logs displayed on the Logging page should indicate that the MuxWebhook Firebase function was called. You can filter the logs by function name in the Google Cloud Console to find logs associated to this function. When viewing the logs, you will likely observe the following error message: `"Error: Unexpected number of documents matching livestream ID"`. This is due to the liveStreamId not matching an id associated to an existing LiveStreamInfo.kFieldMuxId value in the database. This is an expected error. For more thorough testing, we recommend the steps below.

(Recommended) You can also use the following steps to set up a live stream in Zoom and test your Mux integration end-to-end:

1. Create a new event in Frankly and configure it for livestreaming using steps 1-2 in [these instructions](https://www.notion.so/Livestreams-4332e73273954776a46c86b091dbe708?pvs=21).
2. Open Zoom and verify you have livestreaming enabled using [these](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064210#h_4b4ded3d-3f6b-4965-baaa-3692f947e36c) steps. Then follow [these](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064210#h_62b792dc-3cf9-4b62-848d-93ee9e412a7c) steps to setup your livestreaming event on Zoom. Use the following values:
   - For Stream URL, use the Stream URL provided on the Frankly event page.
   - For Stream Key, use the Stream Key provided on the Frankly event page.
   - For “Live streaming page URL,” use the page URL of the event setup page where you got the Streaming values above. The URL should look like this: https://gen-hls-bkc-7627.web.app/space/<ids>/discuss/<more ids>?status=joined
3. Visit your Google Cloud Platform Logging page so you can scan for any errors during the live stream test.
4. When you are ready, start the live stream on Zoom using [these](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064210#h_0cd3b33b-0172-4199-bd19-88ba6b57f173) steps

The following should be true if your Mux setup works as expected:

- The live streaming page on Frankly is now showing your streaming video from Zoom
- The logs displayed on the Logging page should not display any errors related to the MuxWebhook function. Be sure to query logs from the past 1 hour or longer. You can also use [this](https://cloudlogging.app.goo.gl/J22AmCfDfEB1F82P9) query to include only Errors.

### Cloudinary

- Sign up for cloudinary
- Create two upload presets, one for images and one for videos.
  - Image Preset configuration:
    - Use filename:true
    - Unique filename:true
    - Type:upload
    - Access mode:public
    - Transformation:c_crop,g_custom (note: this is achieved by going to Upload Manipulations->Incoming Transformations and setting Mode to Crop and Gravity to custom. These settings are required so that users are able to crop images. They also ensure that all images, cropped or not, are compressed before storage).
  - Video Preset configuration:
    - Use filename:true
    - Unique filename:true
    - Type:upload
    - Access mode:public
    - Folder:videos/uploads (this value doesn't matter, just somewhere unique to store your videos)
- Replace `defaultMediaPreset` (video), `uploadPreset` (image), and `cloudName` at `client/lib/services/media_helper_service.dart`.

### SendGrid

- Uses a Firestore extension. Emails definitions are written to the firestore collection sendgridemail.
- Configure the firestore extension "Trigger Email" firebase/firestore-send-email@0.1.9 with your sendgrid info

### Stripe

Stripe is currently disabled for the platform. The following instructions will apply if you choose to enable Stripe:

- Set your Stripe secret key in functions config by replacing placeholder values in the following command:

```
firebase functions:config:set stripe.connected_account_webhook_key="<YOUR_CONNECTED_ACCOUNT_WEBHOOK_SECRET_KEY>" stripe.pub_key="<YOUR_STRIPE_PUBLISHABLE_KEY>" stripe.secret_key="<YOUR_STRIPE_SECRET_KEY>" stripe.webhook_key="<YOUR_WEBHOOK_SECRET_KEY>"
```

- Set up products for each type with a metadata field "plan_type" of individual, club, pro and prices for each one

## 🐦 Running and building the Client

:grey_question: But first, have you setup and run the [emulators](?id=emulators)?

**Recommended instructions (debug configs)**

In general, you can use the configs defined in .vscode/launch.json to run **debug mode**. We have defined 2 environments for you:

1. Client
2. Client Dev (Emulators) - this connects to functions, firestore, database, and auth emulators

**💡 Tip:** The default debug platform is Web (Chrome), so please ensure it is selected as the target platform when running. We do not currently officially support any other platform.

### .env File

You will need to create a .env file for client configuration. Copy `client/.env.example.local` file to `client/.env` and update the missing secrets marked with `<value>` accordingly. The VSCode profiles assume the .env file lives in the `client` directory.

You can also add an `EMULATORS` environment variable to override the default Emulators profile behavior of running `'firestore, auth, functions, database'` Set the value to any desired combination of emulators.

**Manual instructions**
If you want to use emulators, ensure you start the emulators first. Then run the following commands in the `/client` directory.

To run the app with backend pointing at staging.
`flutter run -d chrome --release --web-renderer html -t lib/main.dart --dart-define-from-file=.env`

To run the app with locally running functions, firestore, and auth emulators
`flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart --dart-define-from-file=.env`

### Supported browsers

The client app only runs on the Flutter web platform. Flutter uses Chrome for debugging web apps, but it does support all major browsers in production [Web FAQ | Flutter](https://docs.flutter.dev/platform-integration/web/faq#which-web-browsers-are-supported-by-flutter) -- Chrome, Firefox, Safari, and Edge.

# Testing

### End-to-End Tests

See instructions [here](e2e.md) for developing and running end-to-end Playwright tests.

### Flutter Unit Tests

The `client/test` directory holds Flutter unit and widget tests.

To run existing tests, you can run the following command from the `client/test` directory:

```
flutter pub run build_runner build
cd ../
flutter test --platform chrome
```

To run newly added tests:

```
flutter test <optional path to test files>
```

To run unit tests with locally generated HTML coverage report:

```
flutter test --coverage && format_coverage --in=coverage && genhtml coverage/lcov.info -o coverage/html
```

### Firebase Functions Tests

Firebase functions tests, located in the `firebase/functions/test` directory, execute functions directly using an emulated Firestore database.

To run these tests, execute the following command from the `firebase/functions` directory:

```
CLOUD_RUNTIME_CONFIG=./test/test_config.json firebase emulators:exec --only firestore --project fake-project-id 'npm run test'
```

### Firestore Rules Tests

Firestore rules tests verify that our firestore rules are enforcing the correct access limits on firestore documents. The tests are located in the `firebase/firestore/test` directory.

Rules tests are written in TypeScript. If you make any changes to the tests, you must compile tests so they are translated to JavaScript prior to execution.

**Compiling Tests**
Run `tsc` from the `firebase/firestore` directory.

If you'd like to compile-on-air, use `tsc --watch`. For example:
In `../functions` run `tsc --watch firestore.spec.ts`.  
Once you change the logic - `firestore.spec.js` will be recompiled.

**Running Tests**

To run tests for rules, go to `firebase/firestore` and run:

```
npm install
firebase emulators:exec --only firestore "npm run test".
```

# 🌏 Hosting Your Own Instance

## Setting up new Firebase projects

- Create Firebase projects for staging and prod environments
- Get Firebase config values at https://console.firebase.google.com/ > Project Settings > Your app > Web
- Update values in `.firebaserc` to use your own project IDs for staging and prod.
- Update Firebase configuration values at `client/lib/firebase_options.dart` and `client/lib/dev_main.dart`
- Update values at `client/web/index.html`

## Configure Firebase

:pause_button: You do not need to configure Firebase if just running the emulators.

The functions are currenty 1st Gen Firebase Functions. Their config properties are set by running `firebase functions:config:set` from the CLI.

You will need to set config properties that are specific to your application, such as domains and brand names.

<details>

<summary>List of properties</summary>

| Key                                                          | Description                                                                                                                                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| app.legal_entity_name                                        | The name of the company, organization, or person that owns and maintains your implementation of the app. An HTML string can be provided in this field as shown in the example. |
| app.alt_email_domain                                         | The domain used for sending emails to users via SendGrid. This domain may or may not be the same as the production domain. The string value does not include the protocol.     |
| app.no_reply_email                                           | The email address shown on emails that recipients can't reply to                                                                                                               |
| app.name                                                     | The formal, public-facing name for your application                                                                                                                            |
| app.full_url                                                 | The full url for your app, including the protocol (i.e. "https://www.example.com")                                                                                             |
| app.privacy_policy_url                                       | The full url of your privacy policy page, including the protocol                                                                                                               |
| app.mailing_address                                          | The physical mailing address of the legal entity that owns or maintains the app. This is displayed in emails sent to users.                                                    |
| app.banner_image_url                                         | The full url of the banner image displayed on the home page                                                                                                                    |
| app.functions_url_prefix                                     | Your Firebase functions' base URL (i.e. "//us-central1-myapp.cloudfuncs.net")                                                                                                  |
| app.project_id                                               | The Firebase project id for your project                                                                                                                                       |
| ics.prod_id                                                  | The ID of the entity that generates ICS calendar data for events. Can be set to anything. Product name is generally recommended.                                               |
| xmlns.url                                                    | Your app URL appended by "/xmlns"                                                                                                                                              |
| xmlns.media_url                                              | The Media RSS namespace. We recommend using http://search.yahoo.com/mrss/, as the specification is currently maintained by Yahoo.                                              |
| app.unsubscribe_encryption_key                               | Any randomly generated string                                                                                                                                                  |
| functions.on_firestore.min_instances                         | The minInstances for all functions that deal with firestore updates                                                                                                            |
| functions.update_live_stream_participant_count.min_instances | The minInstances for the function that updates event participation count                                                                                                       |

(NOTE: All other functions have minInstances set to 0 in the codebase. These are functions we identified as needing different configuation in staging and production environments).

</details>

### Deploy rules

- Create Firestore database in Firebase console. Initialize Firestore in your CLI by running `firebase init firestore`. Then, deploy Firestore security rules via CLI using the command `firebase deploy --only firestore:rules`. These rules will be deployed from `client/firestore/firestore.rules`.
- Create Realtime Database in Firebase console. Initialize the Realtime DB in your CLI by running `firebase init database`. Then, deploy Realtime Database rules using the command `firebase deploy --only database`. These rules will be deployed from `firebase/database.rules.json`.

  - For more information on deploying rules, see the Firebase docs page on this topic [here](https://firebase.google.com/docs/rules/manage-deploy#cloud-firestore).

- Initialize Firebase Auth providers in Firebase console:
  - Anonymous
    - This is required for the app to run. Each new visitor to the app is logged in as an anonymous user.
  - Email/password
  - Google
    - This is handled by Firebase and should mostly work out of the box. You will need to toggle it on in the Authentication section of the Firebase console.

#### One-off deployments and builds

We have included a checklist here for components of the application that need to deployed. Many of these do not necessarily need to be deployed unless changed.

- [ ] **Firebase Hosting**
      You can find the docs on setting deploy targets for Firebase Hosting via the CLI [here](https://firebase.google.com/docs/cli/targets#set-up-deploy-target-hosting).

  - Configure domain name in firebase hosting for target "prod" and "staging", where "prod" and "staging" are aliases that you have set up. The existing settings for deploy targets are in the `.firebaserc` file.
  - For example, for the Frankly dev project, run `firebase target:apply hosting staging [projectname]`.

- [ ] **Firebase Functions**
  - For initial deployment, you'll first need to make sure your default service account is still enabled in the GCP Console (Firebase > Project settings > Service accounts > Click on "Manage service account permissions").
- Verify that you have the correct Firebase Runtime Configurations, even if you did not need to change them: `firebase functions:config:get`

  - Run the following in the firebase/functions directory:
    `npm install`

    `dart run build_runner build --output=build`

    `firebase deploy --only functions`

  - Note: Environment configurations set via the CLI (via `firebase functions:config`) will also be automatically deployed when Functions are deployed.

- [ ] **Google Cloud Tasks**

  - To switch projects: `gcloud config set project [FIREBASE-PROJECT-ID]`
  - Create tasks queue for function scheduling: `gcloud tasks queues create scheduled-functions`

- [ ] **Rules and indexes**
  - Deploy Firestore security rules via CLI using the command `firebase deploy --only firestore:rules`.
  - Deploy Realtime Database rules using the command `firebase deploy --only database`.
  - Deploy Firestore indexes using the command `firestore deploy --only firestore:indexes`.

This project uses `firebase functions:config` to manage secrets used in Firebase Functions. There are several subcommands which we'll explain below.

> **Note:** Repeat these processes for each environment you want to support. For example, if you have a staging and production environment, you will complete setup processes twice -- once for each environment.

### Setting multiple secrets

You can set the secrets for all third party services **except for Stripe** using the following command:

```
firebase functions:config:set \
  agora.storage_access_key="<YOUR_VALUE_HERE>" \
  agora.rest_secret="<YOUR_VALUE_HERE>" \
  agora.storage_secret_key="<YOUR_VALUE_HERE>" \
  agora.rest_key="<YOUR_VALUE_HERE>" \
  agora.app_certificate="<YOUR_VALUE_HERE>" \
  agora.app_id="<YOUR_VALUE_HERE>" \
  mux.secret="<YOUR_VALUE_HERE>" \
  mux.token_id="<YOUR_VALUE_HERE>" \
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
  ics.prod_id="<YOUR_VALUE_HERE>" \
  xmlns.url="<YOUR_VALUE_HERE>"
  xmlns.media_url="<YOUR_VALUE_HERE>" \
  functions.on_firestore.min_instances="<YOUR_VALUE_HERE>" \
  functions.update_live_stream_participant_count.min_instances="<YOUR_VALUE_HERE>"
```

### Setting individual secrets

If you'd prefer to set secrets individually, such as for testing certain subsystems in isolation, you can run the commands above individually for each service. For example, you can run `firebase functions:config:set agora.storage_access_key="<YOUR_VALUE_HERE>"` to set only the Agora storage access key.

**Configure the Flutter client**

You will need to connect the Flutter client to your hosted instance by modifying the values in the .env file. See the example file `client/.env.hosted.example` for a the names and descriptions of environment variables used in a hosted environment. Most of them are the same as those used in local development, with the addition of properties used to connect to your Firebase and Google Cloud Functions, as well as some optional connection properties for connecting to Sentry and Matomo for reporting and analytics.

# ❓ Troubleshooting and FAQ

## Flutter installation

- If you install Android and you see this output when running `flutter doctor`:
  ```
  [!] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
  ✗ cmdline-tools component is missing
  Run path/to/sdkmanager --install "cmdline-tools;latest
  ```
  Run the following steps:
  1. Open **Android Studio**
  2. Select **More Actions** > **SDK Manager**
  3. Under the **SDK Tools** tab, select **Android SDK Command-line Tools (latest)** (see screenshot below)**.**
  4. Click **Apply** to proceed with installation.
- When activating the FlutterFire CLI (step 1.3 in the Flutter doc: `dart pub global activate flutterfire_cli`), you may see a prompt to update your path:
  ```
  Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
  ```
  You can fix that by adding this to your shell's config file (.zshrc, .bashrc, .bash_profile, etc.):
  ```
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  ```
  After adding the recommended export to your **~/.zshrc** file, restart all terminal windows.

## Cloud Functions Emulator

- **Functions fail to emulate**: If you run `firebase emulators:start --only ...` and you get a message saying that function emulation failed to start, you may need to run `firebase init functions` on first launch. Use the following selections after running:

```
? What language would you like to use to write Cloud Functions? JavaScript
? Do you want to use ESLint to catch probable bugs and enforce style? Yes
? File functions/package.json already exists. Overwrite? No
i  Skipping write of functions/package.json
✔  Wrote functions/.eslintrc.js
✔  Wrote functions/index.js
? File functions/.gitignore already exists. Overwrite? No
i  Skipping write of functions/.gitignore
? Do you want to install dependencies with npm now? Yes
```

If you see an error message indicating ports are taken such as the one below, run `sudo lsof -i tcp:<PORT_ID>` to get the PID, then run `kill -9 <PID>` to stop the running emulator.

```
i  emulators: Starting emulators: auth, functions, firestore, database, pubsub
⚠  pubsub: Port 8085 is not open on 0.0.0.0, could not start Pub/Sub Emulator.
⚠  pubsub: To select a different host/port, specify that host/port in a firebase.json config file:
      {
        // ...
        "emulators": {
          "pubsub": {
            "host": "HOST",
            "port": "PORT"
          }
        }
      }
i  emulators: Shutting down emulators.

Error: Could not start Pub/Sub Emulator, port taken.
```

- **Integrations not working:** Third-party services will not work the Functions Emulator unless you have created the file `firebase/functions/.runtimeconfig.json`. Please refer to the sub-section **🔑 Using Config in Emulators** for further detail.

# ⚙️ Running Local Development Version

Most components of Frankly can be run on your local machine. This section describes how to setup and run the Flutter client app and the Firebase emulators (which can be setup in place of a Firebase/GCP project). The app still connects to several third-party services, which are also described below.

## Tools and Flutter Setup


!!! warning "Important"
    Frankly runs on Flutter `3.22.2.` **Please use this version of Flutter in order to avoid any unexpected errors.**

This section covers setting up a new computer for Flutter development.

### Part 1: Platform-specific

=== "macOS"
    1. Download and install Google Chrome [here](https://www.google.com/chrome/) if it’s not already pre-installed. This is used for live debugging on web.
    2. Download and install XCode from the Mac App Store. This is used for developing iOS apps and running on macOS as a desktop app.
    3. Optional, but recommended: Install Homebrew [here](https://brew.sh/).
    4. Xcode should've installed git automatically, but if not for some reason, you can install it via Homebrew:
      ```
      brew install git
      ```
    5. Clone the Frankly repo in a directory where you prefer your projects to live:
      ```
      git clone https://github.com/berkmancenter/frankly && cd frankly
      ```
    6. Follow the instructions [here](https://docs.flutter.dev/get-started/install) to install Flutter on your machine. You can choose iOS as your target platform.
        - This includes a link to install CocoaPods. However, you may run into issues with installing CocoaPods due to a Ruby version issue (the pre-installed Ruby on MacOS is too old). You can install ruby via Homebrew instead by running `brew install cocoapods`, which should alleviate those errors.
        - **Recommended**: Install the Flutter SDK in your home folder under a directory called `dev` (or something similar).
    7.  Install VSCode [here](https://code.visualstudio.com/download).
        - **Recommended**: Install the [Flutter VSCode extension](https://docs.flutter.dev/get-started/editor#install-the-vs-code-flutter-extension) and use the extension to [install Flutter via VSCode](https://docs.flutter.dev/get-started/install/macos/mobile-ios#use-vs-code-to-install-flutter).
    8.  Add Flutter to your PATH. For Mac with Zsh (you can also copy this command from [here](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download#add-flutter-to-your-path)), create or open ~/.zshenv and add this line:
        ```
        export PATH=$HOME/dev/flutter/bin:$PATH
        ```
        Restart terminal sessions to see the changes.
=== "Linux"
    1.  Download and install chromium and git if they're not already installed. Chromium is used for live debugging on web.
      ```
      sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y chromium git
      ```
    2. Clone the Frankly repo in a directory where you prefer your projects to live:
      ```
      git clone https://github.com/berkmancenter/frankly && cd frankly
      ```
    3. Follow the instructions [here](https://docs.flutter.dev/get-started/install) to install Flutter dependencies on your machine. You can choose web as your target platform.
    4. Install VSCode [here](https://code.visualstudio.com/docs/setup/linux).

        !!! info ""
            You may need to download the binary for your specific architecture [here](https://code.visualstudio.com/Download)
            
        - **Recommended**: Install the [Flutter VSCode extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) and use the extension to [install Flutter via VSCode](https://docs.flutter.dev/get-started/install/linux/web#install-the-flutter-sdk).
        - **Recommended**: Install the Flutter SDK in your home folder under a directory called `dev` (or something similar).
    5. You will probably need to add both flutter and dart to your PATH. Run:
        ```
        export PATH="$PATH:$HOME/[path to flutter]/flutter/bin"
        ```
            
### Part 2

1.  Install Node.js and npm. We strongly recommend that you do this via `nvm` (steps [here](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating)) since it is the easiest end cleanest way to do so.
2. Once nvm is installed and sourced to your CLI profile, run:
  ```
  nvm install --lts
  ```
3. Install the [Firebase CLI Tools](https://www.npmjs.com/package/firebase-tools):
  ```
  npm install -g firebase-tools
  ```
    - You may run into permissions issues when installing this due to being a non-root user. To remedy this, reassign ownership of the relevant folders to yourself by running the following 2 commands before running `npm install` :
       ```
        sudo chown -R $USER /usr/local/bin/ && sudo chown -R $USER /usr/local/lib/node_modules
       ```

        !!! info ""
            For more information, you can read this Stack Overflow [post](https://stackoverflow.com/questions/48910876/error-eacces-permission-denied-access-usr-local-lib-node-modules).

9.  Activate the Firebase CLI for Flutter by following the steps [here](https://firebase.google.com/docs/flutter/setup?platform=ios). Skip steps 3 and 4 in the “Initialize Firebase in your app” section. This project uses a separate file (app.dart) for the imports.

    !!! info ""
        If step 2 complains about not finding a project, make sure that you're running from within `client`.

    !!! question ""
        Please check [**❓Troubleshooting / FAQ**](/faq) for suggested resolutions to common Flutter installation errors.

## Environment Setup

These are the steps for getting started with developing Frankly:

1. 📦 Build the data models
2. 🔥 Setting up and connecting to the Firebase emulators
3. 🔌 Connecting to third-party services
4. 🐦 Running the frontend Flutter app

The following section will cover these steps for running the app for the first time.

### 📦 Data Models

The first step in running the app is to build the data_models package. Some code in this package is auto-generated by [Freezed](https://pub.dev/packages/freezed). Run the following steps in the `data_models` directory to generate code and make the package available to the client and Firebase functions:

1. To install all Dart dependencies run `flutter pub get`.
2. Run: ```dart run build_runner build --delete-conflicting-outputs```

You can also just run `./build.sh`.

### 🔥 Firebase

#### Firebase CLI

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

!!! info "Important"
    Do this before running the [client](#running-and-building-the-frontend-web-client).

To run the emulators locally, run the following _while_ in the `firebase/functions` directory:

```
dart run build_runner build --output=build
firebase emulators:start --only firestore,functions,auth,pubsub,database
```

We recommend using the emulators [import and export](https://firebase.google.com/docs/emulator-suite/connect_firestore#import_and_export_data) functionality to make development easier.


!!! question ""
    Please refer to the Cloud Functions Emulator [section](/faq/#cloud-functions-emulator) at [**❓Troubleshooting / FAQ**](/faq) for common issues and resolutions!

### Optional: Setup Firebase Cloud Project

In order to allow the capability to run the app locally without needing to create/modify a live Firebase project, emulators for all Google Cloud services that are needed (Functions, Auth, Realtime Database, etc.) suffice for most development task.

If you plan on using [Mux](#optional-mux) within your local app, however, the emulator version of the functions host is inadequate, since that service needs an actual deployed URL to send [webhooks :octicons-link-external-24:](https://en.wikipedia.org/wiki/Webhook) to. You will need a Firebase project of your own. 

1. Create a new Firebase project [here :octicons-link-external-24:](https://console.firebase.google.com/).
2. Make a note of the unique ID that is created for your project. It will be in the format of `my-dev-project-d2f8c`.
3. You may need to create a default [realtime database](https://firebase.google.com/docs/database/web/start). 
4. From your command line within the `firebase/functions` directory, run:
    ```
    firebase login
    ```

    !!! warning "Logging In"
        When the login window appears, ensure you are logging in as the same user that created your project.

4. Now run:
  ```
  firebase use <project_id>
  ```
  You should see a message like `Now using project my-dev-project-d2f8c`

You can follow the official [documentation :octicons-link-external-24:](https://firebase.google.com/docs/functions/get-started?gen=1st#initialize-your-project_1) to find out how to deploy, but you might use a command like this: `firebase deploy --only functions`.

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

### Optional: Mux

#### **🔧 Setting up the integration**

Mux streaming is used when a customer wants to stream video from a third party streaming service, such as Zoom, to Frankly. Essentially the customer will record video from the third party platform, the data is sent to Mux, which will then notify Frankly's MuxWebhook Firebase function that a stream has started. Once the stream has started, the Frankly event page will display the streaming video.

1.  Using [Mux's instructions](https://docs.mux.com/guides/start-live-streaming#1-get-an-api-access-token), get a new access token. Use the environment of your choice and set the permission level to "Mux Video".

2.  Set up Mux secrets for your local development environment, either by running the firebase command line or copying and pasting the information.

    === "Command Line"
        As the names suggest, the mux.token_id corresponds to your Mux token ID and mux.secret corresponds to your Mux token secret.
        ```
        firebase functions:config:set mux.secret="<YOUR_VALUE_HERE>" mux.token_id="<YOUR_VALUE_HERE>"
        ```
    === "Copy/Paste"
        Or, paste your token and secret into the `.runtimeconfig.json` file where the `mux` field is.
        ```
          "mux": {
            "secret": "...",
            "token_id": "..."
          },
        ```

3.  To connect Mux to the [MuxWebhooks cloud function](https://github.com/berkmancenter/frankly/blob/staging/firebase/functions/lib/events/live_meetings/mux_webhooks.dart), the function first needs to be deployed to your Google Cloud Project. Get the URL of the deployed function provided by Google Cloud, which should resemble this format: https://us-central1-myproject.cloudfunctions.net/MuxWebhooks.
4.  Login to Mux and go to Settings > Webhooks. Select the environment for which you want to use the webhook, then click “Create new webhook.” For the _URL to Notify_ field, provide the URL for your deployed MuxWebhooks function. Then click "Create webhook."

#### 👾 Testing your setup

You can verify the integration is working by manually triggering a new call directly from Mux.

- [ ] Visit your Google Cloud Platform Logging page so you can scan for any errors and expected logs during the live stream test.
- [ ] In the Mux dashboard, go to Video > Live Streams. Click "Create your first live stream."
- [ ] Run the default request.

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

1. [Sign up](https://cloudinary.com/users/register_free) for Cloudinary.
2. Create two upload presets [here](https://console.cloudinary.com/settings/upload/presets), one for images and one for videos.

    !!! info ""
        You can learn about upload presets [here](https://cloudinary.com/documentation/upload_presets#use_cases).

    1. On the _General_ panel, use this configuration for images:
        ```
        - Name: "frankly-image-default" (or whatever you'd like)
        - Signing mode: Unsigned
        - Disallow public ID: ✔️
        - Asset folder: empty
        - Generated public ID: Auto-generate
        - Generated display name: Use the last segment of the public ID
        ```
        1.  Now, on the _Transform_ panel, under "Incoming transformation", enter `c_crop,g_custom` and click Save. 
     
        !!! note "" 
            These settings are required so that users are able to crop images. They also ensure that all images, cropped or not, are compressed before storage).

    2. On the _General_ panel, use this configuration for videos:
        ```
        - Name: "frankly-video-default" (or whatever you'd like)
        - Signing mode: Unsigned
        - Disallow public ID: ✔️
        - Asset folder: "videos/uploads" (this value doesn't matter, just somewhere unique to store your videos)
        - Generated public ID: Auto-generate
        - Generated display name: Use the last segment of the public ID
        ```
        1. Click Save.
         
3. Now update the following in `client/.env`:
    
    !!! note "" 
        Your `CLOUDINARY_CLOUD_NAME` is found [here](https://console.cloudinary.com/settings/account) under "Product environment cloud name".

  ```
  CLOUDINARY_IMAGE_PRESET=frankly-image-default (or name you used)
  CLOUDINARY_VIDEO_PRESET=frankly-video-default
  CLOUDINARY_DEFAULT_PRESET=frankly-video-default
  CLOUDINARY_CLOUD_NAME=<value>
  ```


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

❔ But first, if using, have you setup and run the [emulators](#emulators)?

**Recommended instructions (debug configs)**

In general, you can use the configs defined in `.vscode/launch.json` to run **debug mode**. We have defined 2 environments for you:

1. Client
2. 🌟 Client Dev (Emulators) - this connects to functions, firestore, database, and auth emulators 

!!! note
    The default debug platform is Web (Chrome), so please ensure it is selected as the target platform when running. We do not currently officially support any other platform.

### .env File

You will need to create a **.env** file for client configuration. Copy `client/.env.example.local` to `client/.env` and update the missing secrets marked with `<value>` accordingly. The VSCode profiles assume the .env file lives in the `client` directory.

You can also add an `EMULATORS` environment variable to override the default Emulators profile behavior of running `firestore, auth, functions, database`. Set the value to any desired combination of emulators.

#### Manual instructions
If you want to use emulators, ensure you start the emulators first. Then run the following commands in the `/client` directory.

To run the app with backend pointing at staging.
```
flutter run -d chrome --release --web-renderer html -t lib/main.dart --dart-define-from-file=.env
```

To run the app with locally running functions, firestore, and auth emulators
```
flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart --dart-define-from-file=.env
```

### Supported browsers

The client app runs only on the Flutter web platform. Flutter uses Chrome for debugging web apps, but it does support all major browsers in production [Web FAQ | Flutter](https://docs.flutter.dev/platform-integration/web/faq#which-web-browsers-are-supported-by-flutter); Chrome, Firefox, Safari, Edge.

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
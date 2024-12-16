# Frankly 💬

Welcome to the Frankly repo!

[WIP] Frankly is an online deliberations platform that allows anyone to host video-enabled conversations about any topic. Key functionalities include:

- Matching participants into breakout rooms based on survey questions
- Creating structured event templates with different activities to take participants through

Frankly is a **Flutter** app with a **Firebase** backend.

# Overview

🪧 This README includes the following sections:

- **Overview**: An overview of the contents of the README and a description of the contents of major directories in the repo.
- **Flutter setup**: Instructions for setting up a Flutter dev environment.
- **Frankly setup**: Instructions for changing platform configurations and running the app for the first time.
- **Development**: Information relevant to ongoing development.
- **Deployment**: Information relevant to deploying the app.
- **Testing**
- **Troubleshooting and FAQ**

### Repo contents

This subsection provides a description of the contents of major directories in the repo.  
**💡 Important note:** For the rest of this README, most terminal commands should be executed from within the `client` directory (or subdirectories of it when specified).

- `client`
  The main Flutter app.

  - `client/functions`
    These are the Firebase Functions which are deployed on Google Cloud and called by the Flutter app. Firebase functions are built on top of Cloud Functions.

  - `client/shared/lib/cloud_functions`
    This is a list of JSON formats for making calls to the functions in `client/functions`. It is used by both client and backend functions for the encoding and decoding of requests.

  - `client/shared/lib/firestore`
    These are the models defined in Firestore. Firestore is the database benind this app.

  - `client/firestore/firestore.rules`
    This is a Firestore security rules file which defines which Firestore documents are readable by which users.

- `matching`
  Contains `lib/matching.dart`, which is the logic for matching participants into breakout rooms. See the README in this directory for links to helpful documentation on matching.
- `extra`
  This folder holds code that was used during Kazm development for things like creating custom reports for a client or running 1-off tests. The code is included here in case useful but is not necessary for the core Kazm video experience.
  - **Note**: There are several READMEs within the `extra` directory that give further detail on the code here. They have not been included in the main README as the code in `extra` is not part of the platform.

# Flutter setup

This section covers setting up a new computer for Flutter development.

1.  Download and install Google Chrome [here](https://www.google.com/chrome/) if it’s not already pre-installed. This is used for live debugging on web.
2.  Download and install XCode from the Mac App Store. This is used for developing iOS apps and running on macOS as a desktop app.
3.  Install VSCode [here](https://code.visualstudio.com/download).
4.  Optional but recommended: Install Homebrew [here](https://brew.sh/).
5.  Follow the instructions [here](https://docs.flutter.dev/get-started/install) to install Flutter on your machine. You can choose iOS as your target platform.

        1. This includes a link to install CocoaPods. However, you may run into issues with installing CocoaPods due to a Ruby version issue (the pre-installed Ruby on MacOS is too old). You can install ruby via homebrew instead by running `brew install cocoapods`, which should alleviate those errors.
        2. Recommended: Install the [Flutter VSCode extension](https://docs.flutter.dev/get-started/editor#install-the-vs-code-flutter-extension) and use the extension to [install Flutter via VSCode](https://docs.flutter.dev/get-started/install/macos/mobile-ios#use-vs-code-to-install-flutter).
        3. Recommended: Install the Flutter SDK in your home folder under a directory called `dev` (or something similar).

        > ⚠️ (Optional) If you install Android and you see this output when running `flutter doctor`:
        >
        > `[!] Android toolchain - develop for Android devices (Android SDK version 35.0.0)

    ✗ cmdline-tools component is missing
    Run path/to/sdkmanager --install "cmdline-tools;latest"
    See https://developer.android.com/studio/command-line for more details.` > > Run the following steps: > > 1. Open **Android Studio** > 2. Select **More Actions** > **SDK Manager** > 3. Under the **SDK Tools** tab, select **Android SDK Command-line Tools (latest)** (see screenshot below)**.** > 4. Click **Apply** to proceed with installation.

6.  Add Flutter to your PATH. For Mac with Zsh (you can also copy this command from [here](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download#add-flutter-to-your-path)), create or open ~/.zshenv and add this line:
    `export PATH=$HOME/development/flutter/bin:$PATH`
    Restart terminal sessions to see the changes.
7.  Install Node.js and npm [here](https://nodejs.org/en).
8.  Install Firebase CLI Tools using the command `npm install -g firebase-tools` ([documentation](https://www.npmjs.com/package/firebase-tools)).

    1. You will likely run into permissions issues when installing this due to being a non-root user. To remedy this, reassign ownership of the relevant folders to yourself by running the following 2 commands before running `npm install` :
       `sudo chown -R $USER /usr/local/bin/`
       `sudo chown -R $USER /usr/local/lib/node_modules`

    For more information, you can read this Stack Overflow [post](https://stackoverflow.com/questions/48910876/error-eacces-permission-denied-access-usr-local-lib-node-modules).

9.  Activate the Firebase CLI for Flutter by following the steps [here](https://firebase.google.com/docs/flutter/setup?platform=ios). Skip steps 3 and 4 in the “Initialize Firebase in your app” section. This project uses a separate file (junto_app.dart) for the imports.

        > ⚠️ When running Step 1.3 in the Flutter doc (`dart pub global activate flutterfire_cli`), you may see a prompt to update the path:
        >
        > `Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.

    You can fix that by adding this to your shell's config file (.zshrc, .bashrc, .bash_profile, etc.):` >

    > `export PATH="$PATH":"$HOME/.pub-cache/bin"` >
    > `Activated flutterfire_cli 1.0.0.` > > Add the recommended export to your **~/.zshrc** file. Then restart all terminal windows.

# Frankly setup

These are the steps for getting started with developing Frankly:

1. 🔥 Setting up and connecting to your own Firebase projects
2. 🔌 Connecting third-party services to your own instances
3. 🐦 Running the frontend Flutter app

The following section will cover these steps for running the app for the first time. Please check **Troubleshooting/FAQ** at the end of the README for additonal guidance.

## 🔥 Firebase

**Setting up new Firebase projects**

> Deliberations team note: We've already set up Firebase projects for this project, and it only needs to be done once per project. Skip this section and proceed with the **Firebase CLI** steps.

- Create Firebase projects for staging and prod environments
- Get Firebase config values at https://console.firebase.google.com/ > Project Settings > Your app > Web
- Update values in `client/.firebaserc` to use your own project IDs for staging and prod.
- Update Firebase configuration values at `client/lib/firebase_options.dart` and `client/lib/dev_main.dart`
- Update values at `client/web/index-prod.html` and `client/web/index.html`

**Deploy rules**
- Create Firestore database in Firebase console. Initialize Firestore in your CLI by running `firebase init firestore`. Then, deploy Firestore security rules via CLI using the command `firebase deploy --only firestore:rules`. These rules will be deployed from `client/firestore/firestore.rules`.
- Create Realtime Database in Firebase console. Initialize the Realtime DB in your CLI by running `firebase init database`. Then, deploy Realtime Database rules using the command `firebase deploy --only database`. These rules will be deployed from `client/database.rules.json`. 
  - For more information on deploying rules, see the Firebase docs page on this topic [here](https://firebase.google.com/docs/rules/manage-deploy#cloud-firestore).

- Initialize Firebase Auth providers in Firebase console:
  - Anonymous
    - This is required for the app to run. Each new visitor to the app is logged in as an anonymous user. 
  - Email/password
  - Google
    - This is handled by Firebase and should mostly work out of the box. You will need to toggle it on in the Authentication section of the Firebase console.

**Firebase CLI**
Most of the operations for development and deployment take place via the Firebase CLI. You can find documentation for the Firebase CLI [here](https://firebaseopensource.com/projects/firebase/firebase-tools/).

Run the following steps once:

- Install Firebase CLI using `npm install -g firebase-tools`
- Login to Google account via CLI
- `firebase use --add` to set up aliases for Firebase project (staging and prod)
- `firebase use <alias you setup after --add>` to switch between projects.

**Firebase indexes**

- To export indexes from Firestore, run `firebase firestore:indexes > firestore.indexes.json`
- Indexes can deployed via CLI to your Firestore instance by running `firestore deploy --only firestore:indexes`

### Firebase Functions

Firebase Functions are built on top of Cloud Functions, which is why there are references to Cloud Functions tooling below. Functions are written in `dart` and are compiled to `javascript` with `dart2js`. However, everything else, like `firestore-rules` are written in `typescript`. See the **Development** section for more information on the usage of Typescript in this project.

For the following sub-section, switch to the `client/functions` directory to run all commands.

Initial Setup:

1. To install all Javascript dependencies, run `npm install`.
2. To install all Dart dependencies related to the Flutter app, including Firebase Functions written in Dart, run `flutter pub get` in the `client` directory.

You don't need to run `npm install` again unless you've added new dependencies or made updates to existing ones. Same applies to `flutter pub get`, but for changes to any function dependencies.

Developer workflow:
After you've made any changes to the functions code in dart, run `dart run build_runner build --output=build`.
This will also compile the dart functions into javascript for you. For more background on how this works, see [this Dart readme](https://github.com/dart-lang/build/tree/master/build_web_compilers#configuration).

**Emulators**
Firebase has a full suite of emulators called Firebase Local Emulator Suite. You can find the full description of the Firebase Local Emulator Suite and its capabilities [here](https://firebase.google.com/docs/emulator-suite).

Cloud Functions Emulator is one of the products in the Firebase Local Emulator Suite that specifically emulates the Cloud Functions Service.

You can emulate some services locally for development purposes, and set up the client to use these functions instead of the deployed versions. Overall, we recommend using emulators for development and testing purposes for both efficiency and keeping cloud billing costs low.

To run the functions, auth, and firestore emulators locally, run the following in `functions`:

```
dart run build_runner build --output=build
firebase emulators:start --only firestore,functions,auth,pubsub --import emulators_exports_asml_8-5-24/main
```

Note that due to the `--only firestore,functions,auth` flag, **only Functions, Auth, and Firestore** are emulated, not any other Firebase service. This works for triggering Firebase functions. If you'd like to set up more emulators for your project, run `firebase init emulators`.

If you'd like to import different a different folder other than `emulators_exports_asml_8-5-24/main` to use with the Firestore emulator, follow [this](https://medium.com/firebase-developers/how-to-import-production-data-from-cloud-firestore-to-the-local-emulator-e82ae1c6ed8) tutorial.

> Please refer to the Cloud Functions Emulator section under **❓Troubleshooting / FAQ** for common issues and resolutions!

## 🔌 Third Party Services

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
  app.prod_domain="<YOUR_VALUE_HERE>" \
  app.dev_domain="<YOUR_VALUE_HERE>" \
  app.legal_entity_name="<YOUR_VALUE_HERE>" \
  app.alt_email_domain="<YOUR_VALUE_HERE>" \
  app.no_reply_email="<YOUR_VALUE_HERE>" \
  app.unsubscribe_encryption_key="<YOUR_VALUE_HERE>" \
  app.name="<YOUR_VALUE_HERE>" \
  app.prod_full_url="<YOUR_VALUE_HERE>" \
  app.dev_full_url="<YOUR_VALUE_HERE>" \
  app.privacy_policy_url="<YOUR_VALUE_HERE>" \
  app.mailing_address="<YOUR_VALUE_HERE>" \
  app.banner_image_url="<YOUR_VALUE_HERE>" \
  app.dev_functions_url_prefix="<YOUR_VALUE_HERE>" \
  app.prod_functions_url_prefix="<YOUR_VALUE_HERE>" \
  app.dev_project_id="<YOUR_VALUE_HERE>" \
  ics.prod_id="<YOUR_VALUE_HERE>" \
  xmlns.url="<YOUR_VALUE_HERE>"
  xmlns.media_url="<YOUR_VALUE_HERE>"
```

### Setting individual secrets

If you'd prefer to set secrets individually, such as for testing certain subsystems in isolation, you can run the commands below for each service.

#### Agora

Sign up for Agora and open the [Agora console](https://console.agora.io/v2/). The following instructions are geared towards using V2 of the Agora console.

The following instructions will guide you through retrieving the values to fill in the following command for setting Agora-related values in your Functions configuration:

```
firebase functions:config:set \
agora.app_id="<YOUR_VALUE_HERE>" \
agora.app_certificate="<YOUR_VALUE_HERE>" \
agora.rest_key="<YOUR_VALUE_HERE>" \
agora.rest_secret="<YOUR_VALUE_HERE>" \
agora.storage_bucket_name="<YOUR_VALUE_HERE>" \
agora.storage_access_key="<YOUR_VALUE_HERE>" \
agora.storage_secret_key="<YOUR_VALUE_HERE>"
```

**🔧 Setting up the integration**

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
  In `client/lib/app/junto/admin/conversations_tab.dart`, change the URIs in the `_buildRecordingSection` method (replacing the ASML values appearing ahead of `/us-central1/downloadRecording`) to reflect your staging and prod Firebase project IDs.

**👾 Testing the integration**
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

**📝 A note on Agora configuration**
Agora uses a Javascript file as part of its Flutter SDK as mentioned in the Web section of the package docs on [pub.dev](https://pub.dev/packages/agora_rtc_engine). However, this Web implementation does not completely cover all features provided in the Agora Flutter SDK. Therefore, Junto had to augment Agora's Javascript file via this [open source fork](https://github.com/JuntoChat/iris_web). The changes that were made in this fork are:

1. Fixing the publishing and unpublishing feature ([commit](https://github.com/JuntoChat/iris_web/commit/d3f6dbc976128e96ded51af315719efac6359ad2))
2. Implemented getting microphone device information ([commit](https://github.com/JuntoChat/iris_web/commit/7008218fad0163b4409d9d92e5401cf54107b10c))

The [README of the custom fork](https://github.com/JuntoChat/iris_web/blob/main/README.md) describes how to build the project, which results in a JS file located at `client/web/agora/iris-web-rtc.js`. This replaces the iris web artifact that is mentioned in the Agora Flutter package setup instructions [here](https://pub.dev/packages/agora_rtc_engine).

Once Agora implements microphone device information and irons out the publishing/unplublishing issues, this fork can be abandoned. You can find the bug report on the Agora Flutter repo [here](https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK/issues/1652).

#### Stripe

Stripe is currently disabled for the platform. The following instructions will apply if you choose to enable Stripe:

- Set your Stripe secret key in functions config by replacing placeholder values in the following command:

```
firebase functions:config:set stripe.connected_account_webhook_key="<YOUR_CONNECTED_ACCOUNT_WEBHOOK_SECRET_KEY>" stripe.pub_key="<YOUR_STRIPE_PUBLISHABLE_KEY>" stripe.secret_key="<YOUR_STRIPE_SECRET_KEY>" stripe.webhook_key="<YOUR_WEBHOOK_SECRET_KEY>"
```

- Set up products for each type with a metadata field "plan_type" of individual, club, pro and prices for each one

#### Mux
Mux streaming is used when a customer wants to stream video from a third party streaming service, such as Zoom, to Frankly. Essentially the customer will record video from the third party platform, the data is sent to Mux, which will then notify Frankly's MuxWebhook Firebase function that a stream has started. Once the stream has started, the Frankly event page will display the streaming video.

1. Using [Mux's instructions](https://docs.mux.com/guides/start-live-streaming#1-get-an-api-access-token), get a new access token. Use the environment of your choice and set the permission level to "Mux Video".
2. Set up Mux secrets for your local development environment by replacing values in the following command. As the names suggest, the mux.token_id corresponds to your Mux token ID and mux.secret corresponds to your Mux token secret.
```
firebase functions:config:set mux.secret="<YOUR_VALUE_HERE>" mux.token_id="<YOUR_VALUE_HERE>"
```

3. To connect Mux to the [MuxWebhooks cloud function](https://github.com/berkmancenter/frankly/blob/73687b331ffa7bebcc488bb2eac64eecd4c52c0f/client/functions/lib/functions/on_request/mux_webhooks.dart#L4), the function first needs to be deployed to your Google Cloud Project. Get the URL of the deployed function provided by Google Cloud, which should resemble this format: https://us-central1-myproject.cloudfunctions.net/MuxWebhooks.
4. Login to Mux and go to Settings > Webhooks. Select the environment for which you want to use the webhook, then click “Create new webhook.”For the URL to Notify field, provide the URL for your deployed MuxWebhooks function. Then click "Create webhook."

**Testing your Mux setup**

(Optional) You can verify the integration is working by manually triggering a new call directly from Mux.
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

#### Cloudinary

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

#### SendGrid

- Uses a Firestore extension. Emails definitions are written to the firestore collection sendgridemail.
- Configure the firestore extension "Trigger Email" firebase/firestore-send-email@0.1.9 with your sendgrid info

#### Stripe

Stripe is currently disabled for the platform. The following instructions will apply if you choose to enable Stripe:

- Set your Stripe secret key in functions config by replacing placeholder values in the following command:

```
firebase functions:config:set stripe.connected_account_webhook_key="<YOUR_CONNECTED_ACCOUNT_WEBHOOK_SECRET_KEY>" stripe.pub_key="<YOUR_STRIPE_PUBLISHABLE_KEY>" stripe.secret_key="<YOUR_STRIPE_SECRET_KEY>" stripe.webhook_key="<YOUR_WEBHOOK_SECRET_KEY>"
```

- Set up products for each type with a metadata field "plan_type" of individual, club, pro and prices for each one

#### General app secrets

You will need to set secrets that are specific to your application, such as domains and brand names. Below is a list of secrets you will need to set and what each are for:

- app.prod_domain: The domain for your production app without the protocol (i.e. "www.example.com")
- app.dev_domain: The domain for your development or staging app without the protocol (i.e. "www.stagingexample.com")
- app.legal_entity_name: The name of the company, organization, or person that owns and maintains your implementation of the app
- app.alt_email_domain: The domain used for sending emails to users via SendGrid. This domain may or may not be the same as the production domain. The string value does not include the protocol.
- app.no_reply_email: The email address shown on emails that recipients can't reply to
- app.name: The formal, public-facing name for your application
- app.prod_full_url: The full url for your production app, including the protocol (i.e. "https://www.example.com")
- app.dev_full_url: The full url for your development or staging app, including the protocol (i.e. "https://www.stagingexample.com")
- app.privacy_policy_url: The full url of your privacy policy page, including the protocol
- app.mailing_address: The physical mailing address of the legal entity that owns or maintains the app. This is displayed in emails sent to users.
- app.banner_image_url: The full url of the banner image displayed on the home page
- app.dev_functions_url_prefix : Your Firebase functions' base URL when deployed to the developer or staging project (i.e. "//us-central1-myapp.cloudfuncs.net")
- app.prod_functions_url_prefix : Your Firebase functions' base URL when deployed to production
- app.dev_project_id : The Firebase project id for your development/staging project
- ics.prod_id: TBD
- xmlns.url: Your app URL appended by "/xmlns"
- xmlns.media_url: TBD
- app.unsubscribe_encryption_key: Any randomly generated string 

#### 🔑 Using Secrets in Functions Emulator

After you have set up all of your secrets according to the instructions in 🔌 **Third Party Services**, you will need to run an extra command for secrets to work locally. Ensure the following is run from the `/functions` directory:

`firebase functions:config:get > .runtimeconfig.json`

## 🐦 Running and building the frontend web client

**Recommended instructions (debug configs)**

In general, you can use the configs defined in .vscode/launch.json to run **debug mode**. We have defined 4 environments for you:

1. Prod
2. Staging
3. Dev (Functions Emulator)
4. Dev (Emulators) - this connects to functions, firestore, and auth emulators 

**💡 Tip:** The default debug platform is Web (Chrome), so please ensure it is selected as the target platform when running. We do not currently officially support any other platform.

**Manual instructions**
If you want to use emulators, ensure you start the emulators first. Then run the following commands in the `/client` directory.

To run the app with backend pointing at staging.
`flutter run -d chrome --release --web-renderer html -t lib/dev_main.dart`

To run the app with locally running functions, firestore, and auth emulators
`flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart`

To run the app with only specific emulators, you can provide one or more of the following options
`flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart --dart-define=EMULATORS=functions (or functions,firestore,auth)`

### Additional platforms

**Supported browsers**
Flutter uses Chrome for debugging web apps, but it does support all major browsers in production [Web FAQ | Flutter](https://docs.flutter.dev/platform-integration/web/faq#which-web-browsers-are-supported-by-flutter) -- Chrome, Firefox, Safari, and Edge.

**Building for desktop (MacOS)**

This project was tested only on `macos` by the prior owners. As of June 2024, this app does not build on MacOS. The following information was provided to us by the previous team:

> Desktop build only builds `development`because we don't expect it to be `production` ready.
>
> 1. Ensure you have `macos` enabled in Flutter.
>
> ```
> flutter config --enable-macos-desktop
> ```
>
> 2. Run via configuration  
>    ![image](https://user-images.githubusercontent.com/12739071/129923053-b45442dd-dde6-41f8-b738-f0b2d4c23a9f.png)  
>    Or `flutter run -d macos -t lib/dev_main.dart`

### Additional build modes

For information on Flutter build modes, see the Flutter docs [here](https://docs.flutter.dev/testing/build-modes).

The instructions for building this project in release mode are:
**Staging release mode:** `flutter build web --release  --web-renderer html  -t lib/dev_main.dart`

**Prod release mode build command (for deployment)**: `flutter build web --release  --web-renderer html `

# Development

The following section covers information that's important to know when doing regular development on the platform.

### Development Quickstart

After you've completed the one-time setup steps in [Flutter setup](#flutter-setup) and [Frankly setup](#frankly-setup), you can follow these steps to get the app running after making updates:

1. Open a new terminal window (we'll call this "Window 1") and navigate to the functions directory.
2. Run the`firebase functions:config:set...` to set multiple secrets needed for the codebase according to the instructions in [Setting multiple secrets](#setting-multiple-secrets)
3. Run `firebase functions:config:get > .runtimeconfig.json`
5. (Optional, no need to run unless package dependencies changed) In Window 1, run `npm install` in the functions directory to install any dependencies
6. (Optional, no need to run unless function dependencies changed) In Window 1, run the following in the client directory: `cd ..` and get any flutter dependencies: `flutter pub get`
7. In Window 1, build the app by running this in the functions directory: `dart run build_runner build --output=build`. Then run `firebase emulators:start --only functions,firestore,auth,pubsub --import emulators_exports_asml_8-5-24/main` to start the emulators with test Firestore data
8. Open a second terminal window (Window 2). In Window 2, change to the client directory. Then run the app: `flutter run -d chrome --release --web-renderer html -t lib/dev_emulators_main.dart`

Proceed with developing and testing your changes.

### 🎨 Theme and style

We are currently have everything style-related stored in `lib/styles/app_styles.dart`.

**Updating styles**

If you find new values, simply add them to respective classes within `app_styles.dart`;

**Using styles**

1. Find element reference in Figma
   ![image](https://user-images.githubusercontent.com/12739071/126578569-4659100b-24e9-416f-81e7-cb67ad538447.png)
2. Only look into `Ag` (name of the style) and `Color` (name)
3. In your `Text` or any widget that has to take `TextStyle`, reference correct style and override color  
   with the color from the Figma.

```
Text(
   'Navigation',
   style: AppTextStyle.headline1.copyWith(color: AppColor.brightGreen),
)
```

### ❄️ CodeGen and Freezed

This project makes use of the Freezed plugin (https://pub.dev/packages/freezed)

Regenerate model code by running from this (shared/) directory.

`dart run build_runner build`

Use delete-conflicting-outputs to overwrite existing generated files:
`dart run build_runner build --delete-conflicting-outputs `

### 📕 Resources/Naming

Resources definitions in our app can be found at client/shared/firestore. Below is a summary of the primary ones making up the core discussion experience.

There is a heirarchy that is as follows

Junto - This is the top level organization/group.
Topic - Within a Junto, they create topics which are like templates for conversation
Discussion - Users can create instances of a template to talk to a group of people, these are discussions. This also includes the agenda information
DiscussionParticipant - When a user registers for a meeting a discussion participant entry is made to indicate they will be attending

Within a Discussion when users are live in the event things are coordinated via some other documents:

- Live Meeting: Events and information about things like who is pinned, the current breakout session, what events have occurred (Start, agenda item completed, etc)
- ParticipantAgendaItemDetails: A document for every agenda item (from the Discussion) that users can use to take actions during the event. Every user listens to everyone else's agenda item details for the current agenda item (computed based on the live meeting events above). So if users upload suggestions or submit word cloud responses, etc, they go in the participant agenda item details.
- Breakout Rooms: If the host initializes breakout rooms it is noted in the live meeting document which indicates to clients to move to their respective breakout room assignments. Each breakout room has its own "agenda", "live meeting" and "participant agenda item details".

### ⛅️ Firebase Functions

Most of the Firebase Functions are written in `dart`. This section covers the exceptions to that rule that occur in this directory.

#### TypeScript code

- Ensure you have `TypeScript` installed by running `npm install -g typescript`.
- **Code formatting**: For code formatting we are using prettier. To install `prettier`, run `npm install --save-dev --save-exact prettier`. Then:

  - Go to your IDE's `Preferences -> Language & Frameworks -> JavaScript`
  - Prettier - find your `prettier` path
  - Select `On code reformat`.
    ![image](https://user-images.githubusercontent.com/12739071/124049889-99a01000-da43-11eb-8871-33321e96efb1.png)

  You're all set. Now you can reformat your code with shortcut, and it will use `prettier`. Official `prettier` [guide](https://prettier.io/docs/en/install.html) can be found here.

- **Style/Rules**: These are defined in `.prettierrc.json`. Feel free to give suggestions to improve readability/code quality.

# Deployment

#### One-off deployments and builds
We have included a checklist here for components of the application that need to deployed. Many of these do not necessarily need to be deployed unless changed. 

- [ ] **Firebase Hosting**
You can find the docs on setting deploy targets for Firebase Hosting via the CLI [here](https://firebase.google.com/docs/cli/targets#set-up-deploy-target-hosting).
  - Configure domain name in firebase hosting for target "prod" and "staging", where "prod" and "staging" are aliases that you have set up. The existing settings for deploy targets are in the `.firebaserc` file.
  - For example, for the Frankly dev project, run `firebase target:apply hosting staging gen-hls-bkc-7627`.

- [ ] **Firebase Functions**
  - For initial deployment, you'll first need to make sure your default service account is still enabled in the GCP Console (Firebase > Project settings > Service accounts > Click on "Manage service account permissions").
- Verify that you have the correct Firebase Runtime Configurations, even if you did not need to change them: `firebase functions:config:get`
  - Run the following in the client/functions directory:
    `npm install`

    `dart run build_runner build --output=build`

    `firebase deploy --only functions`

  - Note: Environment configurations set via the CLI (via `firebase functions:config`) will also be automatically deployed when Functions are deployed. 

- [ ] **Google Cloud Tasks**
  - To switch projects: `gcloud config set project [FIREBASE-PROJECT-ID]`
  - Create tasks queue for discussion notifications: `gcloud tasks queues create discussion-notifications`

- [ ] **Rules and indexes** 
  - Deploy Firestore security rules via CLI using the command `firebase deploy --only firestore:rules`.
  - Deploy Realtime Database rules using the command `firebase deploy --only database`. 
  - Deploy Firestore indexes using the command `firestore deploy --only firestore:indexes`.

#### Legacy deployment steps

Here are the steps that the Junto team used for deploying the app.

1. **Choose an environment**
   Setup firebase command line tool
   `firebase use default`
   or
   `firebase use staging`
2. **Build generated code output**
   Build shared
   `cd shared`
   `dart run build_runner build`

3. **Deploy Firebase Functions**
   `npm install`
   `dart run build_runner build --output=build`
   `firebase deploy --only functions`

4. **Deploy to Firebase Hosting**
   Increment version number in html files at client/web/index-prod.html and client/web/index.html
   This prevents the JS from being cached

   ```
    <script type="application/javascript">
      // Keep this in sync with the main.dart.js version below
      window.platformVersion = 329; <----------- Here
    </script>
    <script
      src="main.dart.js?version=329" <---------- Here
      type="application/javascript"
    ></script>
   ```

   `flutter build web --release  --web-renderer html`
   or
   `flutter build web --release  --web-renderer html  -t lib/dev_main.dart`

   `firebase deploy --only hosting:prod`
   or
   `firebase deploy --only hosting:staging`

# Testing

### End-to-End Tests

See instructions [here](client/e2e/README.md) for developing and running end-to-end Playwright tests.

### Flutter Unit Tests

The `test` directory holds Flutter unit and widget tests.

To run existing tests, you can run the following command from the `test` directory:

```
flutter pub run build_runner build
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

### firestore-rules

Firestore rules tests verify that our firestore rules are enforcing the correct access limits on firestore documents. The tests are located in the `../functions/test/firestore-rules` directory.

Tests are written in TypeScript. To compile tests so they are translated to JavaScript, run `tsc` from the `../functions` directory.  
If you'd like to compile-on-air, use `tsc --watch`. For example:
In `../functions` run `tsc --watch firestore.spec.ts`.  
Once you change the logic - `firestore.spec.js` will be recompiled.

To run tests for rules, go to root (`../functions`) and run `firebase emulators:exec --only firestore "npm run test-firestore-rules"`.

# ❓ Troubleshooting and FAQ

### Cloud Functions Emulator

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

- **Integrations not working:** Third-party services will not work the Functions Emulator unless the setup command for developer secrets, `firebase functions:config:get > .runtimeconfig.json`, is run. Please refer to the sub-section **🔑 Using Secrets in Functions Emulator** under 🔌 **Third Party Services** for further detail.

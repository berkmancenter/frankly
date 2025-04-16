

# ❓ Troubleshooting and FAQ

### Flutter installation
* If you install Android and you see this output when running `flutter doctor`:
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
* When activating the FlutterFire CLI (step 1.3 in the Flutter doc: `dart pub global activate flutterfire_cli`), you may see a prompt to update your path:
  ```
  Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
  ```
  You can fix that by adding this to your shell's config file (.zshrc, .bashrc, .bash_profile, etc.):
  ```
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  ```
  After adding the recommended export to your **~/.zshrc** file, restart all terminal windows.
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

- **Integrations not working:** Third-party services will not work the Functions Emulator unless you have created the file `firebase/functions/.runtimeconfig.json`. Please refer to the sub-section **🔑 Using Config in Emulators** for further detail.



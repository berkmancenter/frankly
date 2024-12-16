# End-to-End Testing with Playwright

This directory contains [Playwright](https://playwright.dev/) tests for some of the product [test scenarios](https://www.notion.so/rebootingsocialmedia/Kazm-Test-Scenarios-13896de35e1748578285ad8a80f8331d).

## Configuring Playwright

The [Playwright configuration](https://playwright.dev/docs/test-configuration) file `playwright.config.ts` specifies, among other things, the base URL for the instance to be tested and the devices on which to test. The file is currently configured to run tests on http://localhost:60959, using Chromium, Firefox, and Webkit. Playwright also emulates mobile browsers and has a [long list of devices](https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json) that can be added to simulate various phone types.

## Running Tests Locally

Follow these steps to set up your environment for running Playwright:

1. Create a .env file in the e2e directory. At a minimum, this file should contain the base URL and the credentials for two accounts that can sign in to the instance you are testing using an email account. The global setup script discussed below creates a test community called ASML Testing that many of the tests use. The "Owner" account will be the owner of this acccount and the "Member" account will be a member (for role-based testing). Future roles can be configured in a similar manner as tests are added.

⚠️ Note: The global setup script (currently `global.setup.ts`) will need to be modified to create these accounts on a clean deployment when we introduce CD. For now, it is assumed that these users are already registered.

Also, it is recommended to set FORCE_LOGIN=true if you are running against local emulators. The shortcut mechanism described below of loading authentication state into the browser's local storage doesn't always work well with local emulators. Setting FORCE_LOGIN to true will ensure the tests log in every time through the UI.

#### _`.env`_

```
BASE_URL=http://localhost:60959
TEST_OWNER_USER_NAME=someone@gmail.com
TEST_OWNER_PASSWORD=heresapassword
TEST_MEMBER_USER_NAME=someonelse@gmail.com
TEST_MEMBER_PASSWORD=anotherpassword
FORCE_LOGIN=true
```

2. Run `npm install` from the e2e directory to install Playwright and its dependencies.

3. Run `npx playwright install` to install Playwright's default browsers.

4. Run firestore and functions emulator if testing locally. Log in to the app once as TEST_OWNER to create a record in the publicUser database. Due to gated beta, you then have to manually set appRole to "owner" in the firestore emulator console before running the tests.

⚠️ It is recommended that you NOT run the auth emulator. Some of the tests fail because authentication state is not always maintained during page navigation via URL (currently unsure of the cause).

### Playwright Global Setup

Playwright allows you to specify global setup and teardown scripts that run once before and after an entire test suite. Our Playwright configuration file introduces a dependency on the "Setup" project, which is currently configured to match any file ending in .setup.ts. Right now, this matches `tests/global.setup.ts` This script has two important functions:

1. It signs in to the browser using the 'Owner' credentials, then writes the browser authentication data from local storage (and IndexedDB on Chrome) to the file `e2e/.auth/user.json` (if it does not already exist). Playwright's [authentication mechanism](https://playwright.dev/docs/auth) reads from this file (path configured in `playwright.config.ts`) to automatically authenticate tests by repopulating test browsers with the stored state. This allows us to run tests without having to log in through the app every time. Setting the environment variable EMULATORS to true will bypass this mechanism.
2. It creates the community `ASML Testing`, which many of the tests use, and sets environment variables for test interaction. The community will not be created if the following variables are set to point to an existing community in `.env`. These values can be set to any existing community. The system allows duplicate community names. However, **each developer should use a unique community URL**. The setup script will print the URL of the test community it creates if these values aren't set. This URL can then be added to your .env file to avoid creating more communities in the future.

#### _`.env`_

```
TEST_COMMUNITY_NAME='ASML Testing'
TEST_COMMUNITY_TAGLINE='Doing all the testing'
TEST_COMMUNITY_URL='http://localhost:60959/space/1qOsSScDzRy51tvwmjKS'
```

### Running Tests from VSCode

The Playwright extension for VSCode adds a handy testing panel that allows you to select the devices/browsers to use for text execution, as well as whether to show the browser during text execution, which is good for debugging and fun for demos. Note that the above-mentioned Global setup script will only run if the "setup" box under Projects is checked. If you have run once to generate a `.auth/user.json` file and you have the test community environment variables set to some community you want to use, you should not need to run setup.

From the Test Explorer or regular Explorer, you can then select one or more tests to run. Results are displayed in the "Test Results" window.

⚠️ Note: The default configuration assumes you are running the Dev (Functions and Firestore Emulator) profile locally prior to launching a test. The `.vscode/launch.json` file is configured to start the Flutter client on port 5000. To change the baseURL to point to another instance, simply edit the BASE_URL property in your env file.

<img width="433" alt="Screenshot 2024-07-23 at 12 32 12 PM" src="https://github.com/user-attachments/assets/d56ed90d-1a53-45f9-a8f9-11a93f562853">

### Running Tests from Command Line

You can run the entire test suite or a single test [from the command line](https://playwright.dev/docs/test-cli) as well.

⚠️ Note: The global setup files will run once for each command line execution, but the current code is written to eliminate overhead by checking for the presence of `.auth/user.json` and TEST_COMMUNITY environment variables in `.env`

**Run all tests:**

```console
foo@e2e:~$ npx playwright test
```

**Run a single test file:**

```console
foo@e2e:~$ npx playwright test tests/event/rsvp-event.spec.ts
```

**Run a single test within a file:**
The -g command line option matches individual tests within a file by regular expression

```console
foo@e2e:~$ npx playwright test tests/event/rsvp-event.spec.ts -g "RSVP to a public event"
```

### Viewing Test Results

A test report will be generated at the end of test execution and displayed in a browser. _Only the most recent test results are stored in the `test-results` folder_ and can be accessed by running:

```console
foo@e2e:~$ npx playwright show-report e2e/playwright-report
```

Test results are also displayed in the "Test Results" window when running in VSCode.

### Parallel Execution

Playwright supports [parallel execution](https://playwright.dev/docs/test-parallel), and the tests currently should be able to run with multiple parallel workers (individual tests should not be relying on any sort of shared state that could be modified). The workers property can be configured in `playwright.config.ts` or passed as a parameter when running from command line:

```console
foo@e2e:~$ npx playwright test --workers 4
```

## Developing Playwright Tests

It is beyond the scope of this README to provide details on how to write tests with Playwright generally. However, there are currently several things to keep in mind when creating or modifying Playwright tests specifically for our application:

1. It is currently not possible for Playwright to identify any individual web elements in our Flutter app without enabling Flutter semantics, which creates a default Semantics tree in the DOM that allows Playwright [Locators](https://playwright.dev/docs/locators) to find many of the elements they need to interact with. Until we properly address Semantics in the app, the test code needs to press the hidden "Enable accessibility" button on every page of our app. We use a [test fixture](https://playwright.dev/docs/test-fixtures) defined in `custom-test-fixture.ts` to achieve this on every page load. **All tests must use this fixture.** Also note that this fixture contains some code for copying Playwright authentication data into IndexedDB on Chrome, as Playwright does not currently do this (see [here](https://github.com/microsoft/playwright/issues/11164) for more information).

To use the fixture, simply make sure you are importing 'test' from the correct location. Example:
<img width="638" alt="Screenshot 2024-07-24 at 9 07 31 AM" src="https://github.com/user-attachments/assets/32d6e08e-5ab7-4a85-adbd-ca4a280fdd47">

Additionally, test creation can be simplified by using the Record capabilities in VSCode. However, accessibility must be enabled on the web pages for this to work as well. The easiest way to make this work is to temporarily modify the code to start with a default Semantics tree. Edit `client/lib/junto_app.dart` as follows:

#### _`.junto_app.dart`_

<img width="477" alt="Screenshot 2024-07-25 at 10 25 54 AM" src="https://github.com/user-attachments/assets/a967eaf5-a308-42c6-9902-5c53ab666016">

You can also trigger the hidden Enable Accessibility button by opening console in Chrome DevTools and executing `document.querySelector('flt-semantics-placeholder').click()`

2.  We have adopted Playwright's recommended [Page Object Model](https://playwright.dev/docs/pom) to encapsulate the details of locating individual UI elements. Tests should not be using Playwright [Locators](https://playwright.dev/docs/locators) directly. Rather, each page or dialog of the app should be modeled as a page in the `pages` folder, and tests should interact directly with that model.

3.  **There is currently no way to specify a date or time when creating an event.** As a result, new events are created with today's date, and the next hour as the start time. The current event pages are coded to handle this, but _results may be inconsistent if there is more than one event with the same template and date._

4.  As of now, tests must tear down anything they create. We may decide later to create more default objects like events and templates in the global setup (to reduce test execution time), but _care must be taken to avoid issues when running tests with parallel workers._ Playwright has [some recommendations](https://playwright.dev/docs/test-parallel) for dealing with a shared state system during parallel execution.

5.  Some UI elements are still not identifiable by the default Semantics tree. You may need to modify the code you are testing to add semantic labels. Many Flutter widgets have a semanticsLabel property, but if not, you can modify build methods to wrap widgets in a Semantics object as in the following example:

```
    child: Semantics(label:'Submit Chat Button',button: true,
              child: ActionButton(
                minWidth: 20,
                color: AppColor.darkBlue,
                controller: _sendController,
                onPressed: canSubmit ? _sendMessage : null,
                disabledColor: AppColor.white.withOpacity(0.3),
                height: isMobile ? 50 : 55,
                child: Icon(
                  Icons.send,
                  color: canSubmit ? AppColor.brightGreen : AppColor.gray2,
                ),
                ),
              ),
```

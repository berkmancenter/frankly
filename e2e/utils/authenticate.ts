import { Page } from '@playwright/test';
import { HomeMenuBar } from '../pages/home-menu-bar';
import { SignInPage } from '../pages/auth/sign-in-page';
import { HomePage } from '../pages/home-page';
import path from 'path';

/**
 * Populates the brower's IndexedDB (on Chrome) with authentication information.
 * This entire method is necessary because Playwright config does not deal with IndexedDB,
   See https://github.com/microsoft/playwright/issues/11164
   Otherwise we could authenticate through the normal playwright config file, which
   works if storing auth info in localStorage or cookies: https://playwright.dev/docs/auth
   We do NOT do this on localhost due to an issue with auth emulators that caused us to clear
   the indexedDB on page load in index.html
 * @param page 
 */
export const authenticate = async (page: Page) => {
    // Start from the index page

    await new HomePage(page).goto();

    if (
        process.env.FORCE_LOGIN ||
        process.env.BASE_URL?.includes('localhost') ||
        process.env.BASE_URL?.includes('127.0.0.1')
    ) {
        await signInAsTestOwner(page);
    } else {
        // Get the authentication data from the `.auth/user.json` file (using readFileSync)
        const auth = JSON.parse(
            require('fs').readFileSync(path.resolve(__dirname, '../', '.auth/user.json'), 'utf8')
        );

        // Set the authentication data in the indexedDB of the page to authenticate the user
        await page.evaluate((auth) => {
            // Open the IndexedDB database
            const indexedDB = window.indexedDB;
            const request = indexedDB.open('firebaseLocalStorageDb');

            request.onupgradeneeded = (event: any) => {
                const db = event.target.result;

                db.onerror = (event) => {
                    console.log('Error updated IndexedDB' + event);
                };

                // Create an objectStore for this database
                const objectStore = db.createObjectStore('firebaseLocalStorage', {
                    keyPath: 'fbase_key',
                });
                const localStorage = auth.origins[0].localStorage;

                for (const element of localStorage) {
                    // Might be a better way to avoid adding other local storage entries to the IndexedDB?
                    // They don't match fbase_key, which causes an error
                    if (element.name.toString().startsWith('firebase:authUser')) {
                        const value = element.value;
                        objectStore.put(JSON.parse(value));
                    }
                }
            };

            request.onsuccess = function (event: any) {
                const db = event.target.result;
                // Start a transaction to access the object store (firebaseLocalStorage)
                const transaction = db.transaction(['firebaseLocalStorage'], 'readwrite');
                const objectStore = transaction.objectStore('firebaseLocalStorage', {
                    keyPath: 'fbase_key',
                });

                // Loop through the localStorage data inside the `user.json` and add it to the object store
                const localStorage = auth.origins[0].localStorage;

                for (const element of localStorage) {
                    // Might be a better way to avoid adding other local storage entries to the IndexedDB?
                    // They don't match fbase_key, which causes an error
                    if (element.name.toString().startsWith('firebase:authUser')) {
                        const value = element.value;
                        objectStore.put(JSON.parse(value));
                    }
                }
            };
        }, auth);
    }
};

/**
 * Sign in using the credentials for the Owner role of the test community, obtained from
 * TEST_OWNER_USER_NAME and TEST_OWNER_PASSWORD environment variables
 * @param page
 */
export const signInAsTestOwner = async (page: Page) => {
    await signIn(page, process.env.TEST_OWNER_USER_NAME!, process.env.TEST_OWNER_PASSWORD!);
};

/**
 * Sign in using the credentials for the Member role of the test community, obtained from
 * TEST_MEMBER_USER_NAME and TEST_MEMBER_PASSWORD environment variables
 * @param page
 */
export const signInAsMember = async (page: Page) => {
    await signIn(page, process.env.TEST_MEMBER_USER_NAME!, process.env.TEST_MEMBER_PASSWORD!);
};

/**
 * Sign in using an email address through the UI
 * @param page
 * @param uname the username (email address)
 * @param pwd  password
 */
export const signIn = async (page: Page, uname: string, pwd: string) => {
    const homeMenu = new HomeMenuBar(page);
    await homeMenu.clickLogin();

    const signInPage = new SignInPage(page);
    await signInPage.clickSignInWithEmail();
    await signInPage.enterEmail(uname);
    await signInPage.enterPassword(pwd);
    await signInPage.clickSignIn();

    // verify a profile button has appeared, meaning we are now signed in
    await homeMenu.waitForProfileButton();
};

/**
 * Retrieves the display name of the test community's member, used during events
 * @returns The display name
 */
export const getMemberDisplayName = () => {
    return process.env.TEST_MEMBER_NAME!.substring(
        0,
        process.env.TEST_MEMBER_NAME!.indexOf(' ') + 2
    );
};

/**
 * Sign out through the UI
 * @param page
 */
export const signOut = async (page: Page) => {
    const homeMenu = new HomeMenuBar(page);
    await homeMenu.clickSignOut();
};

export const isLoggedIn = async (page: Page) => {
    const homeMenu = new HomeMenuBar(page);
    return await homeMenu.profileButtonVisible();
};

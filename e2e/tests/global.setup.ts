import { test as setup } from '@playwright/test';
import { enableAccessibility } from '../utils/accessibility';
import { isLoggedIn, signInAsTestOwner } from '../utils/authenticate';
import { HomePage } from '../pages/home-page';
import { StartCommunityPage } from '../pages/community/start-community-page';
import { CommunitySpacePage } from '../pages/community/community-space-page';
import path from 'path';
import fs from 'fs';

const authFile = path.resolve(__dirname, '../', '.auth/user.json');
/**
 * This setup is run once before the entire test suite when tests are run from command line
 * If running tests from VSCode, run this script by checking the 'setup' project on the Testing panel
 * Precondition: This will sign into the app using the owner credentials specified in the .env file, so that
 * account needs to exist. Can modify this script in the future to create the user account for CI/CD.
 */
setup('global setup', async ({ page }) => {
    // While we can create spaces with multiple names, tests run into issues locating them uniquely
    const TEST_COMMUNITY_NAME = 'ASML Testing ' + Math.floor(Math.random() * 1000);
    const TEST_COMMUNITY_TAGLINE = 'Doing all the testing';
    const TEST_COMMUNITY_ABOUT = 'A place for automated tests to do their thing';
    console.log('Running global setup');
    await enableAccessibility(page);
    // Create the user.json file from a freshly logged in user, if needed
    if (!fs.existsSync(authFile)) {
        console.log('Writing authentication file from browser state');
        await new HomePage(page).goto();
        await signInAsTestOwner(page);

        // Copy authentication data from indexDB and localstorage to the specified authFile.
        // Playwright config reads this file to automatically authenticate all tests, so no need
        // to run this repeatedly.
        await page.evaluate(() => {
            // Open the IndexedDB database
            const indexedDB = window.indexedDB;
            const request = indexedDB.open('firebaseLocalStorageDb');

            request.onsuccess = function (event: any) {
                const db = event.target.result;

                // Open a transaction to access the firebaseLocalStorage object store
                const transaction = db.transaction(['firebaseLocalStorage'], 'readonly');
                const objectStore = transaction.objectStore('firebaseLocalStorage');

                // Get all keys and values from the object store
                const getAllKeysRequest = objectStore.getAllKeys();
                const getAllValuesRequest = objectStore.getAll();

                getAllKeysRequest.onsuccess = function (event: any) {
                    const keys = event.target.result;

                    getAllValuesRequest.onsuccess = function (event: any) {
                        const values = event.target.result;

                        // Copy keys and values to localStorage
                        for (let i = 0; i < keys.length; i++) {
                            const key = keys[i];
                            const value = values[i];
                            localStorage.setItem(key, JSON.stringify(value));
                        }
                    };
                };
            };

            request.onerror = function (event: any) {
                console.error('Error opening IndexedDB database:', event.target.error);
            };
        });
        await page.context().storageState({ path: authFile });
    }

    // Create the test community used by tests in this suite and set environment variables for tests to access
    // Note if running single tests manually, you will need to add these env variables to your own .env
    if (!process.env.TEST_COMMUNITY_NAME) {
        console.log('Creating test community');
        const homePage = new HomePage(page);
        await homePage.goto();
        const loggedIn = await isLoggedIn(page);
        if (!loggedIn) {
            console.log('Signing in');
            await signInAsTestOwner(page);
        }
        await homePage.clickStartCommunity();
        const startCommPage = new StartCommunityPage(page);
        await startCommPage.clickAgreeAndContinue();
        await startCommPage.enterCommunityName(TEST_COMMUNITY_NAME);
        await startCommPage.enterTagline(TEST_COMMUNITY_TAGLINE);
        await startCommPage.enterAbout(TEST_COMMUNITY_ABOUT);
        await startCommPage.clickNext();
        await startCommPage.clickFinish();
        const commPage = new CommunitySpacePage(page, TEST_COMMUNITY_NAME, TEST_COMMUNITY_TAGLINE);
        await commPage.assertVisible();

        // Set environment variables for the tests
        process.env.TEST_COMMUNITY_NAME = TEST_COMMUNITY_NAME;
        process.env.TEST_COMMUNITY_TAGLINE = TEST_COMMUNITY_TAGLINE;
        process.env.TEST_COMMUNITY_ABOUT = TEST_COMMUNITY_ABOUT;
        console.log('The test community URL: ' + page.url());
        process.env.TEST_COMMUNITY_URL = page.url();
    }
});

import { test } from '../../../custom-test-fixture';
import { HomeMenuBar } from '../../../pages/home-menu-bar';
import { MyProfilePage } from '../../../pages/auth/my-profile-page';
import { checkAccessibility } from '../../../utils/accessibility';

test('test profile events page is accessible', async ({ page }, testInfo) => {
    await new HomeMenuBar(page).clickMyProfile();
    const myProfilePage = new MyProfilePage(page);
    await myProfilePage.clickMyEvents();
    await myProfilePage.waitForMyEvents();
    // TODO this would be a better test with events in the list
    await checkAccessibility(page, testInfo);
});

test('test profile page is accessible', async ({ page }, testInfo) => {
    await new HomeMenuBar(page).clickMyProfile();
    const myProfilePage = new MyProfilePage(page);
    await myProfilePage.clickProfile();
    await myProfilePage.waitForProfile();
    await checkAccessibility(page, testInfo);
});

test('test notifications page is accessible', async ({ page }, testInfo) => {
    await new HomeMenuBar(page).clickMyProfile();
    const myProfilePage = new MyProfilePage(page);
    await myProfilePage.clickNotifications();
    // TODO wait for notifications instead (contents of page different if no communities)
    await page.waitForTimeout(2000);
    await checkAccessibility(page, testInfo);
});

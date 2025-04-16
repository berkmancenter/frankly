import { HomeMenuBar } from '../../pages/home-menu-bar';
import { MyProfilePage } from '../../pages/auth/my-profile-page';
import { test } from '../../custom-test-fixture';

/**
 * ACC-003 User can edit their profile
 */

test('test user can edit their profile image', async ({ page }) => {
    await new HomeMenuBar(page).clickMyProfile();
    const myProfilePage = new MyProfilePage(page);
    await myProfilePage.clickProfile();

    await myProfilePage.selectProfileImage(
        'https://upload.wikimedia.org/wikipedia/commons/2/2a/Soccerball.jpg'
    );
    // need to edit other profile fields to test
    await myProfilePage.clickUpdateProfile();
});

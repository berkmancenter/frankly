import { test } from '../../../custom-test-fixture';
import { HomeMenuBar } from '../../../pages/home-menu-bar';
import { checkAccessibility } from '../../../utils/accessibility';
import { signOut } from '../../../utils/authenticate';
import { SignInPage } from '../../../pages/auth/sign-in-page';

test('test sign in page is accessible', async ({ page }, testInfo) => {
    signOut(page);
    const homeMenu = new HomeMenuBar(page);
    await homeMenu.clickLogin();

    const signInPage = new SignInPage(page);
    await signInPage.waitFor();
    await checkAccessibility(page, testInfo);
    await signInPage.clickSignInWithEmail();
    await signInPage.waitForEmailSignIn();
    await checkAccessibility(page, testInfo);
});

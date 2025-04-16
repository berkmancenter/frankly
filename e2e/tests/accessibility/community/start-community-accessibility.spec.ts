import { StartCommunityPage } from '../../../pages/community/start-community-page';
import { HomePage } from '../../../pages/home-page';
import { test } from '../../../custom-test-fixture';
import { checkAccessibility } from '../../../utils/accessibility';

test('test start community is accessible', async ({ page }, testInfo) => {
    new HomePage(page).clickStartCommunity();
    const startCommPage = new StartCommunityPage(page);
    await startCommPage.waitFor();
    await checkAccessibility(page, testInfo);
    await startCommPage.clickAgreeAndContinue();
    await startCommPage.waitForInputFields();
    await checkAccessibility(page, testInfo);
    await startCommPage.enterCommunityName('Cat Lovers Unite');
    await startCommPage.enterTagline('Felines Rule!');
    await startCommPage.enterAbout('All the conversations about cats');
    await startCommPage.enterContactEmail('catlover@gmail.com');
    await startCommPage.clickNext();
    await startCommPage.waitForBranding();
    await checkAccessibility(page, testInfo);
});

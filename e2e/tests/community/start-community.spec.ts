import { StartCommunityPage } from '../../pages/community/start-community-page';
import { CommunitySpacePage } from '../../pages/community/community-space-page';
import { HomePage } from '../../pages/home-page';
import { test } from '../../custom-test-fixture';

/**
 * COM-001, Participant can start a community
 */

/**
 * Test that a user who has been manually given permission to start communities is able to do so
 * (Note this test assumes that the user defined as OWNER has this permission)
 */
test('test owner can start a public community', async ({ page }) => {
    new HomePage(page).clickStartCommunity();
    const startCommPage = new StartCommunityPage(page);
    await startCommPage.clickAgreeAndContinue();
    await startCommPage.enterCommunityName('Cat Lovers Unite');
    await startCommPage.enterTagline('Felines Rule!');
    await startCommPage.enterAbout('All the conversations about cats');
    await startCommPage.selectBackground(
        'https://asml.cyber.harvard.edu/wp-content/uploads/sites/18/2023/10/Group-48096892-1.png'
    );
    await startCommPage.selectLogo(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Harvard_University_coat_of_arms.svg/300px-Harvard_University_coat_of_arms.svg.png'
    );
    await startCommPage.enterContactEmail('catlover@gmail.com');
    await startCommPage.clickNext();
    await startCommPage.clickFinish();
    const commPage = new CommunitySpacePage(page, 'Cat Lovers Unite', 'Felines Rule!');
    await commPage.assertVisible();
    //Need to delete the community through UI once that ability is added
});

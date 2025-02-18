import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../utils/test-community';
import { test } from '../../custom-test-fixture';
import { TemplatePage } from '../../pages/template/template-page';

/**
 * TEM-002, Moderator can edit a template
 */

let templatePage: TemplatePage;
const templateName = 'Favorite 90s Sitcom';
const description = 'Seinfeld who?';
const imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/9/92/RAndom.jpg';

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, description, imageUrl);
    await templatePage.assertVisible();
});

test.afterEach(async ({ page }) => {
    if (templatePage) await removeTemplate(page, templateName);
});

test('test moderator can edit a template by selecting a new image', async ({ page }) => {
    const imageUrl =
        'https://extension.harvard.edu/wp-content/uploads/sites/8/2020/12/aerial-harvard.jpg';

    await templatePage.clickEditTemplate();
    await templatePage.selectImageFromEditMenu(imageUrl);
    // should also test editing title, description, and visible on home page
    await templatePage.clickSaveTemplate();
});

test('test moderator can edit a template image inline', async ({ page }) => {
    const imageUrl =
        'https://extension.harvard.edu/wp-content/uploads/sites/8/2020/12/aerial-harvard.jpg';

    await templatePage.selectEditableImage(imageUrl);
});

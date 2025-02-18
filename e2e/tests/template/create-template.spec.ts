import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../utils/test-community';
import { test } from '../../custom-test-fixture';
import { TemplatePage } from '../../pages/template/template-page';

/**
 * TEM-001, Moderator can create a template
 */

let templatePage: TemplatePage;
const templateName = 'Best Vegan Food';

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
});

test.afterEach(async ({ page }) => {
    if (templatePage) await removeTemplate(page, templateName);
});

test('test moderator can create a template', async ({ page }) => {
    const description = "Who's Hungry?";
    const imageUrl =
        'https://extension.harvard.edu/wp-content/uploads/sites/8/2020/12/aerial-harvard.jpg';

    templatePage = await createTemplate(page, templateName, description, imageUrl);
    await templatePage.assertVisible();
});

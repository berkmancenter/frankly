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

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
});

test.afterEach(async ({}) => {
    if (templatePage) await removeTemplate(templatePage);
});

test('test moderator can create a template', async ({ page }) => {
    const templateName = 'Best Vegan Food';
    const description = "Who's Hungry?";
    const imageUrl =
        'https://extension.harvard.edu/wp-content/uploads/sites/8/2020/12/aerial-harvard.jpg';

    templatePage = await createTemplate(page, templateName, description, imageUrl);
    await templatePage.assertVisible();
});

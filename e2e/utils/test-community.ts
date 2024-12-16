import { Page } from '@playwright/test';
import { CommunitySpacePage } from '../pages/community/community-space-page';
import { TemplatesPage } from '../pages/template/templates-page';
import { CreateTemplatePage } from '../pages/template/create-template-page';
import { EventsPage } from '../pages/event/events-page';
import { TemplatePage } from '../pages/template/template-page';
import { PostsPage } from '../pages/discussion-board/posts-page';

/**
 * Navigate to the home page of the Test Community (as specified by environment variables)
 * @param page
 * @returns The CommunitySpacePage representing the current page
 */
export const gotoTestCommunitySpace = async (page: Page) => {
    const commSpace = new CommunitySpacePage(
        page,
        process.env.TEST_COMMUNITY_NAME!,
        process.env.TEST_COMMUNITY_TAGLINE!
    );
    await commSpace.goto();
    return commSpace;
};

/**
 * Navigate to the home page of the Test Community (as specified by environment variables)
 * @param page
 * @returns The CommunitySpacePage representing the current page
 */
export const gotoTestCommunitySpaceAnonymously = async (page: Page) => {
    const commSpace = new CommunitySpacePage(
        page,
        process.env.TEST_COMMUNITY_NAME!,
        process.env.TEST_COMMUNITY_TAGLINE!
    );
    await page.goto(process.env.TEST_COMMUNITY_URL!);
    return commSpace;
};

/**
 * Navigate to the templates page of the Test Community (as specified by environment variables)
 * @param page
 * @returns The TemplatesPage representing the current page
 */
export const gotoTestCommunityTemplatesPage = async (page: Page) => {
    await gotoTestCommunitySpace(page);
    const templatesPage = new TemplatesPage(page);
    await templatesPage.goto();
    await templatesPage.waitFor();
    return templatesPage;
};

/**
 * Navigate to the events page of the Test Community (as specified by environment variables)
 * @param page
 * @returns The EventsPage representing the current page
 */
export const gotoTestCommunityEventsPage = async (page: Page) => {
    await gotoTestCommunitySpace(page);
    const eventsPage = new EventsPage(page);
    await eventsPage.goto();
    return eventsPage;
};

/**
 * Navigate to the posts page of the Test Community (as specified by environment variables)
 * @param page
 * @returns The PostsPage representing the current page
 */
export const gotoTestCommunityDiscussionBoard = async (page: Page) => {
    await gotoTestCommunitySpace(page);
    const postsPage = new PostsPage(page);
    await postsPage.goto();
    return postsPage;
};

/**
 * Verifies the browser is currently showing the home page of the Test Community
 * @param page
 */
export const assertTestCommunitySpaceVisible = async (page: Page) => {
    const commSpace = new CommunitySpacePage(
        page,
        process.env.TEST_COMMUNITY_NAME!,
        process.env.TEST_COMMUNITY_TAGLINE!
    );
    await commSpace.assertVisible();
};

/**
 * Creates a Template in the Test Community. Assumes you are on the community templates page
 * @param page
 * @param templateName
 * @param description
 * @param imageUrl
 * @param tags
 */
export const createTemplate = async (
    page: Page,
    templateName: string,
    description: string,
    imageUrl?: string,
    tags?: string[]
) => {
    await new TemplatesPage(page).clickCreateOrAddNew();

    const createPage = new CreateTemplatePage(page);

    await createPage.enterName(templateName);
    await createPage.enterDescription(description);
    if (imageUrl) {
        await createPage.selectImage(imageUrl);
    }
    // Need to add tags when bug is fixed
    await createPage.clickCreate();
    const templatePage = new TemplatePage(page, templateName);
    templatePage.setDescription(description);
    return templatePage;
};

/**
 * Removes the specified template.
 */
export const removeTemplate = async (page: Page, templateName: string) => {
    const templatesPage = await gotoTestCommunityTemplatesPage(page);
    await templatesPage.clickTemplate(templateName);
    const templatePage = new TemplatePage(page, templateName);
    await templatePage.clickEditTemplate();
    await templatePage.clickRemoveTemplate();
};

import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../../utils/test-community';
import { TemplatePage } from '../../../pages/template/template-page';
import { createEvent, removeEvent } from '../../../utils/event';
import { EventPage } from '../../../pages/event/event-page';
import { test } from '../../../custom-test-fixture';

/**
 * EVT-001 Verify moderator can create a hosted event from template
 */
const templateName = 'Best Craft Beers';
const templateDescription = 'A forum to discuss all the beer';
const eventTime = '5:00p';
const longDate = '07/31/2027';
let templatePage: TemplatePage;
let eventPage: EventPage;

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
});

test.afterEach(async ({ page }) => {
    if (eventPage) await removeEvent(eventPage);
    await removeTemplate(page, templateName);
});

test('test moderator can create a public hosted event from template', async ({ page }) => {
    eventPage = await createEvent(page, templateName, longDate, eventTime, true);
    await eventPage.assertVisible();
});

test('test moderator can create a private hosted event from template', async ({ page }) => {
    eventPage = await createEvent(page, templateName, longDate, eventTime, false);
    await eventPage.assertVisible();
});

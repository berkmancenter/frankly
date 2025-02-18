import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../../utils/test-community';
import { TemplatePage } from '../../../pages/template/template-page';
import { createEvent, removeEvent } from '../../../utils/event';
import { EventPage } from '../../../pages/event/event-page';
import { test } from '../../../custom-test-fixture';
import { EditEventPage } from '../../../pages/event/edit-event-page';

/**
 * EVT-012 Verify moderator can edit an event
 */
const templateName = 'Best Vacation Spots';
const templateDescription = 'Time to get away';
const eventTime = '5:00p';
const eventDate = '07/31/2027';
let templatePage: TemplatePage;
let eventPage: EventPage;

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
    eventPage = await createEvent(page, templateName, eventDate, eventTime, true);
});
test.afterEach(async ({ page }) => {
    if (eventPage) await removeEvent(eventPage);
    if (templatePage) {
        await removeTemplate(page, templateName);
    }
});

test('test moderator can edit an event', async ({ page }) => {
    await eventPage.clickEditEvent();
    const editEventPage = new EditEventPage(page);
    await editEventPage.selectImage(
        'https://upload.wikimedia.org/wikipedia/commons/1/15/Tour_Saint-Jacques_au_cr%C3%A9puscule.jpg'
    );
    // need to edit other fields and verify edit successful
    await editEventPage.clickSaveEvent();
});

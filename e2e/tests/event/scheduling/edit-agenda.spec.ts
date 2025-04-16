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
 * EVT-013 Verify moderator can edit event agenda
 */
const templateName = 'Pineapple on pizza?';
const templateDescription = 'The controversy is real';
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

test('test moderator can add an image agenda item to event agenda', async ({ page }) => {
    const agendaTab = await eventPage.clickAgenda();
    await agendaTab.clickAddItem();
    await agendaTab.selectItemType('Image');
    await agendaTab.enterItemTitle('Does this look good to you?');
    await agendaTab.selectAndCropItemImage(
        'https://upload.wikimedia.org/wikipedia/commons/e/ea/Pizza_with_pineapple.jpg'
    );
    await agendaTab.clickSaveItem();
});

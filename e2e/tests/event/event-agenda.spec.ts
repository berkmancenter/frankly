import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    gotoTestCommunitySpace,
    removeTemplate,
} from '../../utils/test-community';
import { signInAsMember, signInAsTestOwner, signOut } from '../../utils/authenticate';
import { EventPage } from '../../pages/event/event-page';
import { LiveMeetingPage } from '../../pages/event/live-meeting-page';
import {
    contextPerms,
    createEvent,
    removeEvent,
    enterEventInNewContext,
    gotoEvent,
} from '../../utils/event';
import { TemplatePage } from '../../pages/template/template-page';
import { test } from '../../custom-test-fixture';

/**
 * Tests of agenda-related functionality in hosted events
 * EVT-004, EVT-008, EVT-009, HTD-001, HTD-002
 * These are combined due to overhead of launching an event
 */

let eventPage: EventPage;
let templatePage: TemplatePage;
const eventDate = '07/31/2024';
const eventTime = '5:00pm';
const templateName = 'Household Plants';
const templateDescription = 'All things plants';
const agendaItem1 = 'Introductions';
const agendaItem2 = 'Do succulents suck?';

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
    eventPage = await createEvent(page, templateName, eventDate, eventTime, true);
    await signOut(page);
    await signInAsMember(page);
});

test.afterEach(async ({ page }) => {
    await new LiveMeetingPage(page).leaveEvent();
    // will be signed out after leaving event
    await signInAsTestOwner(page);
    await gotoEvent(page, templateName, eventDate);
    await removeEvent(eventPage);
    await removeTemplate(page, templateName);
});

test('test participant and host can view and modify agenda in a hosted event', async ({
    context,
    browser,
    page,
}) => {
    test.setTimeout(120000);
    context.grantPermissions(contextPerms);
    const ownerPage = await enterEventInNewContext(
        browser,
        templateName,
        eventPage.getShortEventDate()
    );

    // Now participant can enter, Non-member is starting at event page
    await eventPage.enterEvent();

    const ownerConvo = new LiveMeetingPage(ownerPage);
    const memberConvo = new LiveMeetingPage(page);

    await memberConvo.clickAgenda();
    await memberConvo.assertAgendaItemVisible(agendaItem1);
    await memberConvo.clickAgenda();

    await ownerConvo.clickStartEvent();
    await ownerConvo.assertAgendaItemCardVisible(agendaItem1);
    await memberConvo.assertAgendaItemCardVisible(agendaItem1);

    await ownerConvo.clickAgenda();
    await ownerConvo.clickAddItem();
    await ownerConvo.enterItemTitle(agendaItem2);
    await ownerConvo.enterItemContent('Should we keep injurious plants in our home?');
    await ownerConvo.clickSaveItem();
    await ownerConvo.clickAgenda();

    // Give time for agenda to update async before clicking next, otherwise will end the agenda
    await page.waitForTimeout(10000);
    await ownerConvo.clickNext();
    await memberConvo.assertAgendaItemCardVisible(agendaItem2);

    await memberConvo.clickAgenda();
    await memberConvo.assertAgendaItemVisible(agendaItem2);
    await memberConvo.clickAgenda();

    //close the other browser context
    ownerPage.context().close();
});

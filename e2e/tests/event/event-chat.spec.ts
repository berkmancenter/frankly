import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    gotoTestCommunitySpace,
    removeTemplate,
} from '../../utils/test-community';
import { signInAsMember, signInAsTestOwner, signOut } from '../../utils/authenticate';
import { EventPage } from '../../pages/event/event-page';
import { LiveMeetingPage } from '../../pages/event/live-meeting-page';
import { TemplatePage } from '../../pages/template/template-page';
import {
    contextPerms,
    createEvent,
    enterEventInNewContext,
    gotoEvent,
    removeEvent,
} from '../../utils/event';
import { test } from '../../custom-test-fixture';

/**
 * Tests of agenda-related functionality in hosted events
 * EVT-004, EVT-008, EVT-009, HTD-001
 * These are combined due to overhead of launching an event
 *
 */
let eventPage: EventPage;
let templatePage: TemplatePage;
const eventDate = '07/31/2024';
const eventTime = '5:00pm';
const templateName = 'Happy Hour';
const templateDescription = "Who's thirsty?";

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
    eventPage = await createEvent(page, templateName, eventDate, eventTime, true);
    await signOut(page);
    await signInAsMember(page);
});

test.afterEach(async ({ page }) => {
    await new LiveMeetingPage(page).leaveEvent();
    await signInAsTestOwner(page);
    await gotoEvent(page, templateName, eventDate);
    await removeEvent(eventPage);
    await removeTemplate(page, templateName);
});

test('test participants can chat in an event', async ({ context, browser, page }) => {
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

    await ownerConvo.enterMessageMainScreen('Hey how are you?');
    await memberConvo.clickChat();

    // reenable when Playwright can read chat messages
    //await memberConvo.assertChatMessageVisible('Hey how are you?');

    await memberConvo.enterMessageChatWindow('All good!');
    await ownerConvo.clickChat();

    // reenable when Playwright can read chat messages
    //ownerConvo.assertChatMessageVisible('All good!');

    //close the other browser context
    ownerPage.context().close();
});

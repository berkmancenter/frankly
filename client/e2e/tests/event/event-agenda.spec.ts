import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    gotoTestCommunitySpace,
    removeTemplate,
} from '../../utils/test-community';
import { signInAsMember, signInAsTestOwner, signOut } from '../../utils/authenticate';
import { EventPage } from '../../pages/event/event-page';
import { ConversationPage } from '../../pages/event/conversation-page';
import { contextPerms, createEvent, removeEvent, enterEventInNewContext } from '../../utils/event';
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
const agendaTopic1 = 'Introductions';
const agendaTopic2 = 'Do succulents suck?';

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
    eventPage = await createEvent(page, templateName, eventDate, eventTime, true);
    await signOut(page);
    await signInAsMember(page);
});

test.afterEach(async ({ page }) => {
    await new ConversationPage(page).leaveConversation();
    await signOut(page);
    await signInAsTestOwner(page);
    await eventPage.goto();
    await removeEvent(eventPage);
    await templatePage.goto();
    await removeTemplate(templatePage);
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

    const ownerConvo = new ConversationPage(ownerPage);
    const memberConvo = new ConversationPage(page);

    await memberConvo.clickAgenda();
    await memberConvo.assertAgendaTopicVisible(agendaTopic1);
    await memberConvo.clickAgenda();

    await ownerConvo.clickStartConversation();
    await ownerConvo.assertTopicCardVisible(agendaTopic1);
    await memberConvo.assertTopicCardVisible(agendaTopic1);

    await ownerConvo.clickAgenda();
    await ownerConvo.clickAddCard();
    await ownerConvo.enterCardTitle(agendaTopic2);
    await ownerConvo.enterCardContent('Should we keep injurious plants in our home?');
    await ownerConvo.clickSaveCard();
    await ownerConvo.clickAgenda();

    // Give time for agenda to update async before clicking next, otherwise will end the agenda
    await page.waitForTimeout(10000);
    await ownerConvo.clickNext();
    await memberConvo.assertTopicCardVisible(agendaTopic2);

    await memberConvo.clickAgenda();
    await memberConvo.assertAgendaTopicVisible(agendaTopic2);
    await memberConvo.clickAgenda();

    //close the other browser context
    ownerPage.context().close();
});

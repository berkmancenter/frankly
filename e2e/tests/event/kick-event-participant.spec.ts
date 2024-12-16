import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../utils/test-community';
import {
    authenticate,
    getMemberDisplayName,
    signInAsMember,
    signInAsTestOwner,
    signOut,
} from '../../utils/authenticate';
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
 * Tests that moderator can randomly assign participants to breakout rooms (currently an odd precondition of
 * kicking someone out) and then kick a participant out of the event
 * HTD-003, HTD-004, HTD-005
 * These are combined due to overhead of launching an event
 */

let eventPage: EventPage;
let templatePage: TemplatePage;
const eventDate = '07/31/2024';
const eventTime = '5:00pm';
const templateName = 'Favorite Trees';
const templateDescription = 'So many trees to choose. Which is your favorite?';

test.beforeEach(async ({ page }) => {
    await gotoTestCommunityTemplatesPage(page);
    templatePage = await createTemplate(page, templateName, templateDescription);
    eventPage = await createEvent(page, templateName, eventDate, eventTime, true);
    await signOut(page);
    await signInAsMember(page);
});

test.afterEach(async ({ page }) => {
    await signOut(page);
    await signInAsTestOwner(page);
    await gotoEvent(page, templateName, eventDate);
    await removeEvent(eventPage);
    await removeTemplate(page, templateName);
});

test('test moderator can kick a participant out of a hosted event', async ({
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

    // Now participant can enter
    await eventPage.enterEvent();

    const ownerConvo = new LiveMeetingPage(ownerPage);
    const memberConvo = new LiveMeetingPage(page);

    const participantName = getMemberDisplayName();
    await ownerConvo.assertParticipantPresent(participantName);
    await ownerConvo.clickAdmin();
    await ownerConvo.clickBreakouts();
    await ownerConvo.clickRandomlyAssign();

    await ownerConvo.assertInBreakoutRoom();
    // Verify in breakout room - agenda should show even though we didn't start the event
    await ownerConvo.assertAgendaItemCardVisible('Introductions');

    await ownerConvo.clickAdmin();
    await ownerConvo.clickBreakoutRoom('Room 1');

    // This only works because we have one participant, currently no way to distinguish
    // one participant's action menu from another
    await ownerConvo.showParticipantActionMenu();
    await ownerConvo.clickKick();
    await ownerConvo.clickRemoveParticipant();
    await ownerConvo.assertParticipantNotPresent(participantName);

    // Kicked out participant gets the finish convo dialog
    await memberConvo.clickFinish();

    // Make sure they can't re-enter the convo
    await signInAsMember(page);
    await gotoEvent(page, templateName, eventDate);
    await eventPage.assertBanned();

    //close the other browser context
    ownerPage.context().close();
});

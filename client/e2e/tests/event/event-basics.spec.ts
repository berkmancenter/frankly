import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    assertTestCommunitySpaceVisible,
    removeTemplate,
} from '../../utils/test-community';
import {
    getMemberDisplayName,
    signInAsMember,
    signInAsTestOwner,
    signOut,
} from '../../utils/authenticate';
import { EventPage } from '../../pages/event/event-page';
import { ConversationPage } from '../../pages/event/conversation-page';
import { contextPerms, createEvent, removeEvent, enterEventInNewContext } from '../../utils/event';
import { TemplatePage } from '../../pages/template/template-page';
import { test } from '../../custom-test-fixture';

/**
 * Tests of basic functionality in hosted events like video, sound, entering, and leaving
 * EVT-004-EVT-007, EVT-011
 * These are combined due to overhead of launching an event
 */

    let eventPage: EventPage;
    let templatePage: TemplatePage;
    const eventDate = '07/31/2024';
    const eventTime = '5:00pm';
    const templateName = 'The Weather';
    const templateDescription = 'Everyone has an opinion';

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
        await eventPage.goto();
        await removeEvent(eventPage);
        await templatePage.goto();
        await removeTemplate(templatePage);
    });

    test('test participant can participate in an event', async ({ context, browser, page }) => {
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

        const participantName = getMemberDisplayName();

        await memberConvo.clickStartVideo();
        await memberConvo.assertEventParticipantVideoOn(participantName);
        await ownerConvo.assertEventParticipantVideoOn(participantName);

        await memberConvo.clickStopVideo();
        await memberConvo.assertEventParticipantVideoOff(participantName);
        await ownerConvo.assertEventParticipantVideoOff(participantName);

        // Any way to verify this?
        await memberConvo.clickUnmute();
        await memberConvo.clickMute();

        await memberConvo.leaveConversation();

        // Host can no longer see participant in the event
        await ownerConvo.assertParticipantNotPresent(participantName);

        await ownerConvo.leaveConversation();
        // participant returned to community space
        await assertTestCommunitySpaceVisible(page);

        //close the other browser context
        ownerPage.context().close();
    });

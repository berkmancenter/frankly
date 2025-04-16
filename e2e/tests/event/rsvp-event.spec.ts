import {
    createTemplate,
    gotoTestCommunityTemplatesPage,
    removeTemplate,
} from '../../utils/test-community';
import { signInAsMember, signInAsTestOwner, signOut } from '../../utils/authenticate';
import { EventPage } from '../../pages/event/event-page';
import { TemplatePage } from '../../pages/template/template-page';
import { createEvent, gotoEvent, removeEvent } from '../../utils/event';
import { test } from '../../custom-test-fixture';

/**
 * EVT-002 Verify member can RSVP to an event
 */

let eventPage: EventPage;
let templatePage: TemplatePage;
const eventDate = '07/31/2024';
const eventTime = '5:00pm';
const templateName = 'Best Testing Frameworks';
const templateDescription = "Let's discuss the various testing frameworks. Which is best?";

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
    await removeEvent(eventPage);
    await removeTemplate(page, templateName);
});

test('test member can RSVP to a public event', async ({}) => {
    // can remove this when we are actually able to specify an event time
    test.skip(
        new Date().getMinutes() >= 45,
        'RSVP not enabled because event starts in less than 15 minutes'
    );
    //setup should end on page of newly created event
    await eventPage.clickRSVP();
    await eventPage.clickRSVPConfirm();
    await eventPage.assertRegistered();
});

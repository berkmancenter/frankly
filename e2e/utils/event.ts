import { Browser, Page, expect } from '@playwright/test';
import { CreateEventPage } from '../pages/event/create-event-page';
import { EventPage } from '../pages/event/event-page';
import { TemplatePage } from '../pages/template/template-page';
import { authenticate, signIn, signOut } from './authenticate';
import { gotoTestCommunityEventsPage, gotoTestCommunitySpace } from './test-community';
import { enableAccessibility } from './accessibility';

// This prevents the popup asking for mic permission, note there are flags
// we can use to simulate mic/video later if we want:
// https://stackoverflow.com/questions/71462024/how-to-handle-chromium-microphone-permission-pop-ups-in-playwright
export const contextPerms: string[] = new Array('microphone', 'camera');

/**
 * Creates a hosted event from a template. Assumes you are currently on the event's template page
 * @param page
 * @param templateName
 * @param eventDate not currently used
 * @param eventTime not currently used
 * @param eventPublic true if event is public, false if private
 * @returns The EventPage of the new event, which the browser should be currently displaying
 */
export const createEvent = async (
    page: Page,
    templateName: string,
    eventDate: string,
    eventTime: string,
    eventPublic: boolean
) => {
    const templatePage = new TemplatePage(page, templateName);
    await templatePage.selectHostedEvent();
    await templatePage.clickCreateEvent();
    const createEventPage = new CreateEventPage(page);
    if (eventPublic) {
        await createEventPage.selectPublic();
    } else {
        await createEventPage.selectPrivate();
    }
    await createEventPage.clickNext();
    await createEventPage.enterDate(eventDate);
    await createEventPage.clickNext();
    await createEventPage.enterTime(eventTime);
    await createEventPage.clickCreateEvent();

    if (eventPublic) {
        await createEventPage.clickConfirm();
    }

    return new EventPage(page, templateName, eventDate, eventPublic);
};

export const gotoEvent = async (page: Page, eventName: string, eventDate: string) => {
    const eventsPage = await gotoTestCommunityEventsPage(page);
    // assumes only one event of the same name and will be the on the first date
    await eventsPage.clickOnEvent(eventName);
};

/**
 * Cancels the specified event (essentially removing it). Assumes you are on the event page
 * @param eventPage The event to be removed

 */
export const removeEvent = async (eventPage: EventPage) => {
    await eventPage.clickCancelEvent();
    await eventPage.clickCancelConfirmation();
};

/**
 * Spawns a new context to allow simulation of multiple users in an event
 * @param browser
 * @param templateName The name of the template identifying the event
 * @param shortEventDate The date of the indentifying event
 * @param username Optional username, otherwise uses default playwright config
 * @param password Optional password, otherwise uses default playwright config
 * @returns The new Playwright page object for the event
 */
export const enterEventInNewContext = async (
    browser: Browser,
    templateName: string,
    shortEventDate: string,
    username?: string,
    password?: string
) => {
    const context = await browser.newContext();
    context.grantPermissions(contextPerms);
    const page = await context.newPage();
    // new page needs to enable semantics
    await enableAccessibility(page);
    // And login
    await authenticate(page);
    if (username && password) {
        await signOut(page);
        await signIn(page, username, password);
    }
    const commSpace = await gotoTestCommunitySpace(page);

    // This assumes only one event on this date with this template name
    await commSpace.clickUpcomingEvent(templateName, shortEventDate);
    const eventPage = new EventPage(page, templateName, shortEventDate, true);
    await eventPage.assertVisible();
    await eventPage.enterEvent();

    return page;
};

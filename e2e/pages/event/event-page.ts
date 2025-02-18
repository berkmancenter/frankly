import { Locator, Page, expect } from '@playwright/test';
import { MediaPicker } from '../media-picker';
import { AgendaTabPage } from './agenda-tab-page';

export class EventPage {
    private readonly page: Page;
    private eventName: string;
    private eventDate: Date;
    private isPublic: boolean;
    private readonly cancelEventButton: Locator;
    private readonly cancelConfirmationButton: Locator;
    private readonly editTemplateLink: Locator;
    private readonly editEventButton: Locator;
    private readonly rsvpButton: Locator;
    private readonly rsvpConfirmButton: Locator;
    private readonly addToCalendar: Locator;
    private readonly eventStartsInButton: Locator;
    private readonly agendaTab: Locator;

    constructor(page: Page, eventName: string, eventDate: string, isPublic: boolean) {
        this.page = page;
        this.eventName = eventName;
        // For now, we ignore the date passed in because it's not possible to select a date when
        //creating an event
        this.eventDate = new Date();
        this.isPublic = isPublic;
        this.cancelEventButton = page.getByRole('button', { name: 'Cancel event' });
        this.cancelConfirmationButton = page.getByRole('button', { name: 'Yes, cancel' });
        this.editTemplateLink = page.locator('flt-semantics:text-is("edit the template")');
        this.editEventButton = page.locator('flt-semantics:text-is("Edit event")');
        this.rsvpButton = page.getByRole('button', { name: 'RSVP' });
        this.rsvpConfirmButton = page.getByRole('button', { name: "I'll be there" });
        this.addToCalendar = page.locator('flt-semantics:text-matches(".*Add to calendar.*", "i")');
        this.eventStartsInButton = page.getByRole('button', { name: 'Starts in' });
        this.agendaTab = page.locator('flt-semantics:text-is("AGENDA AGENDA")');
    }

    setEventName(eventName: string) {
        this.eventName = eventName;
    }

    setEventDate(date: Date) {
        this.eventDate = date;
    }

    async clickCancelEvent() {
        await this.cancelEventButton.click();
    }

    async clickCancelConfirmation() {
        await this.cancelConfirmationButton.click();
    }

    async clickEditTemplate() {
        await this.editTemplateLink.click();
    }

    async clickEditEvent() {
        await this.editEventButton.click();
    }

    async clickRSVP() {
        await this.rsvpButton.click();
    }

    async clickRSVPConfirm() {
        await this.rsvpConfirmButton.click();
    }

    async clickAgenda() {
        await this.agendaTab.click();
        return new AgendaTabPage(this.page);
    }

    async clickEnterEvent() {
        try {
            await this.eventStartsInButton.click({ timeout: 5000 });
        } catch (e) {
            // two enter event buttons, grab either one
            await this.page.getByRole('button', { name: 'Enter Event' }).nth(0).click();
        }
    }

    async assertVisible() {
        var dateAry = this.getShortEventDate().split(/(\s+)/);
        const re = new RegExp(
            '.*'.concat(dateAry[0], '\\s+', dateAry[2], '[\\s\\S]*', this.eventName, '.*')
        );
        await expect(this.page.getByLabel(re)).toBeVisible();
    }

    async assertRegistered() {
        // Add to calendar button is visible only if user is registered for event
        await expect(this.addToCalendar).toBeVisible();
    }

    getShortEventDate() {
        const month = this.eventDate.toLocaleString('default', { month: 'short' });
        const day = this.eventDate.getDate();
        return month.toUpperCase().concat(' ', day.toString());
    }

    async enterEvent() {
        // At some point close to the event (15 mins?) you can no longer RSVP and must enter
        // since we can't set the date or time, have to try both
        try {
            await this.rsvpButton.click({ timeout: 5000 });
            await this.clickRSVPConfirm();
            await this.assertRegistered();
        } catch {
            // must be 15 mins or less before the event
        }
        await this.clickEnterEvent();
    }

    async assertBanned() {
        await expect(
            this.page.getByLabel(/[\s\S]*You were removed from this event and cannot rejoin./)
        ).toBeVisible();
        await expect(this.page.getByRole('button', { name: 'Enter Event' })).toHaveCount(0);
    }
}

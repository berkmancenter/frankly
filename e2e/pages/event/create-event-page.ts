import { Locator, Page } from '@playwright/test';
/**
 * Create Event dialog
 */
export class CreateEventPage {
    private readonly page: Page;
    private readonly publicEventRadioButton: Locator;
    private readonly privateEventRadioButton: Locator;
    private readonly nextButton: Locator;
    private readonly createEventButton: Locator;
    private readonly confirmationButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.publicEventRadioButton = page.locator(
            'flt-semantics:text-is("Allow the community to join")'
        );
        this.privateEventRadioButton = page.locator(
            'flt-semantics:text-is("I\'ll share this with a private group")'
        );
        this.nextButton = page.getByRole('button', { name: 'Next', exact: true });
        this.createEventButton = page.getByRole('button', { name: 'Create Event' });
        this.confirmationButton = page.getByRole('button', { name: "I'll be there" });
    }

    async clickNext() {
        await this.nextButton.click();
    }

    async selectPublic() {
        await this.publicEventRadioButton.click();
    }

    async selectPrivate() {
        await this.privateEventRadioButton.click();
    }

    async enterDate(date: string) {
        //currently not possible, manipulating sliders is tricky. need input field (see backlog)
    }

    async enterTime(time: string) {
        // currently not possible, manipulating sliders is tricky. need input field (see backlog)
    }

    async clickCreateEvent() {
        await this.createEventButton.click();
    }

    async clickConfirm() {
        await this.confirmationButton.click();
    }
}

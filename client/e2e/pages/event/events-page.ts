import { Page } from '@playwright/test';
/**
 * Events page
 */
export class EventsPage {
    private readonly page: Page;
    private readonly url: string;

    constructor(page: Page, url: string) {
        this.page = page;
        this.url = url;
    }

    async goto() {
        await this.page.goto(this.url);
    }

    async selectDate(date: string) {
        await this.page.locator('flt-semantics:text-is("'.concat(date, '")')).click();
    }
}

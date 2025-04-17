import { Page } from '@playwright/test';
import { CommunityMenuBar } from '../community/community-menu-bar';
/**
 * Events page
 */
export class EventsPage {
    private readonly page: Page;
    private readonly menuBar: CommunityMenuBar;

    constructor(page: Page) {
        this.page = page;
        this.menuBar = new CommunityMenuBar(page);
    }

    async goto() {
        await this.menuBar.clickEvents();
    }

    async clickOnEvent(name: string) {
        await this.page.locator('flt-semantics:text-matches("'.concat(name, '")')).click();
    }
}

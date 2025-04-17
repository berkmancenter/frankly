import { Locator, Page } from '@playwright/test';
/**
 * The navigation sidebar
 */
export class Sidebar {
    private readonly page: Page;
    private readonly unfollowButton: Locator;
    private readonly followButton: Locator;
    private readonly closeButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.unfollowButton = page.locator('flt-semantics:text-is("Unfollow")');
        // There could be a follow button on a page containing this sidebar too
        // technically this means we might click that instead of the one in the sidebar menu, would be better
        // to give sidebar Follow button a unique label
        this.followButton = this.page.getByRole('button', { name: 'Follow' }).nth(0);
        this.closeButton = this.page.getByRole('button', { name: 'Close' });
    }

    async clickUnfollow() {
        await this.unfollowButton.click();
        await this.page.getByRole('button', { name: 'Yes' }).click();
    }

    async clickFollow() {
        await this.followButton.click();
    }

    async clickClose() {
        await this.closeButton.click();
    }

    async waitFor() {
        await this.closeButton.waitFor();
    }

    async clickCommunity(name) {
        await this.page.locator('flt-semantics:text-is("'.concat(name, '")')).nth(0).click();
    }
}

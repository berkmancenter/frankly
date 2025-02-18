import { Locator, Page, expect } from '@playwright/test';
import { Sidebar } from '../sidebar';
import { HomeMenuBar } from '../home-menu-bar';
/**
 * Home page of a Community
 */
export class CommunitySpacePage {
    private readonly page: Page;
    private readonly tagline: Locator;
    private readonly communityNameLocator: Locator;
    private readonly followButton: Locator;
    private readonly menuBar: HomeMenuBar;
    private readonly communityName: String;

    constructor(page: Page, commName: string, tagline: string) {
        this.page = page;
        this.communityName = commName;
        this.communityNameLocator = page.locator(
            'flt-semantics:text-is('.concat("'", commName, "')")
        );
        this.tagline = page.locator('flt-semantics:text-is('.concat("'", tagline, "')"));
        // There are two follow buttons on a space page. For now, selecting randomly
        this.followButton = page.getByRole('button', { name: 'Follow' }).nth(0);
        this.menuBar = new HomeMenuBar(page);
    }

    async goto() {
        const sidebar = await this.menuBar.showSidebar();
        await sidebar.clickCommunity(this.communityName);
    }

    async assertVisible() {
        await expect(this.communityNameLocator).toBeVisible({ timeout: 30000 });
        await expect(this.tagline).toBeVisible();
        // Need to verify about text displayed once fixed - seems to be entirely missing from Semantics tree
        // See about_section.dart

        // Also need to verify tags once we can add them (see bug)
        // And verify background and logo images (using playwright screenshot?)
    }

    async waitFor() {
        await this.tagline.waitFor();
    }

    async clickFollow() {
        await this.followButton.click();
    }

    async clickUpcomingEvent(eventName: string, eventShortDate: string) {
        //Need to filter by time when we can set it
        await this.page.getByText(eventName).filter({ hasText: eventShortDate }).nth(0).click();
    }
}

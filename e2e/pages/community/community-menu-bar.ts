import { Locator, Page, expect } from '@playwright/test';
import { HomeMenuBar } from '../home-menu-bar';

/**
 * Top navigation bar on a Community home page
 */
export class CommunityMenuBar extends HomeMenuBar {
    private readonly events: Locator;
    private readonly posts: Locator;
    private readonly resources: Locator;
    private readonly templates: Locator;
    private readonly announcements: Locator;
    private readonly profileMenu: Locator;
    private readonly settings: Locator;
    private readonly announcementsButton: Locator;

    constructor(page: Page) {
        super(page);
        this.events = this.page.locator('flt-semantics:text-is("Events")');
        this.posts = this.page.locator('flt-semantics:text-is("Posts")');
        this.resources = this.page.locator('flt-semantics:text-is("Resources")');
        this.templates = this.page.locator('flt-semantics:text-is("Templates")');
        this.announcementsButton = this.page.getByRole('button', {
            name: 'Show Announcements Button',
        });
    }

    async clickEvents() {
        await this.events.click();
    }

    async clickTemplates() {
        this.templates.click();
    }

    async clickPosts() {
        this.posts.click();
    }

    async assertVisible() {
        await expect(this.events).toBeVisible({ timeout: 30000 });
    }

    async assertAnnouncementsVisible() {
        await expect(this.announcementsButton).toBeVisible();
    }
}

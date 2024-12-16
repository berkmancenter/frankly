import { Locator, Page, expect } from '@playwright/test';
import { Sidebar } from './sidebar';
/**
 * Top navigation bar on home screen
 */
export class HomeMenuBar {
    protected readonly page: Page;
    private readonly logIn: Locator;
    private readonly signUp: Locator;
    private readonly profileMenuButton: Locator;
    private readonly myProfileMenuItem: Locator;
    private readonly sidebarButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.logIn = page.locator('flt-semantics:text-is("Log In")');
        this.signUp = page.locator('flt-semantics:text-is("Sign Up")');
        this.profileMenuButton = page.getByRole('button', { name: 'Profile Button' });
        this.myProfileMenuItem = page.locator('flt-semantics:text-is("My Profile")');
        this.sidebarButton = page.getByRole('button', { name: 'Show Sidebar Button' });
    }

    async clickLogin() {
        await this.logIn.click();
    }

    async clickSignUp() {
        await this.signUp.click();
    }

    async clickSignOut() {
        await this.profileMenuButton.hover();
        await this.page.locator('flt-semantics:text-is("Sign Out")').click();
    }

    async clickMyProfile() {
        await this.profileMenuButton.click();
        await this.myProfileMenuItem.click();
    }

    async profileButtonVisible() {
        let vis = false;
        try {
            await this.profileMenuButton.waitFor({ state: 'visible', timeout: 10000 });
            vis = true;
        } catch (e) {}
        return vis;
    }

    async waitForProfileButton() {
        await this.profileMenuButton.waitFor();
    }

    async showSidebar() {
        await this.sidebarButton.click();
        return new Sidebar(this.page);
    }
}

import { Locator, Page, expect } from '@playwright/test';
import { CommunityMenuBar } from '../community/community-menu-bar';
/**
 * A post
 */
export class PostPage {
    private readonly page: Page;
    private readonly postTxt: string;
    private readonly showOptionsButton: Locator;
    private readonly deletePostButton: Locator;
    private readonly yesButton: Locator;

    constructor(page: Page, postTxt: string) {
        this.page = page;
        this.postTxt = postTxt;
        this.showOptionsButton = page.locator('flt-semantics:text-is("Show Options")');
        this.deletePostButton = page.getByRole('button', { name: 'Delete Post' });
        this.yesButton = page.getByRole('button', { name: 'Yes' });
    }

    async clickShowOptions() {
        await this.showOptionsButton.click({ force: true });
    }

    async clickDeletePost() {
        await this.deletePostButton.click();
    }

    async clickYes() {
        await this.yesButton.click();
    }
}

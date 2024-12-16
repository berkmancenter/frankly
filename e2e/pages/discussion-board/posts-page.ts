import { Locator, Page } from '@playwright/test';
import { CommunityMenuBar } from '../community/community-menu-bar';
/**
 * The Posts page
 */
export class PostsPage {
    private readonly page: Page;
    private readonly createPostButton: Locator;
    private readonly menuBar: CommunityMenuBar;

    constructor(page: Page) {
        this.page = page;
        this.createPostButton = page.getByRole('button', { name: 'Create a post' });
        this.menuBar = new CommunityMenuBar(page);
    }

    async goto() {
        await this.menuBar.clickPosts();
    }

    async clickCreatePost() {
        await this.createPostButton.click();
    }

    async selectPost(txt: string) {
        await this.page.getByLabel(txt).click();
    }
}

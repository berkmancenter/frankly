import { Locator, Page } from '@playwright/test';
/**
 * The Posts page
 */
export class PostsPage {
    private readonly page: Page;
    private readonly url: string;
    private readonly createPostButton: Locator;

    constructor(page: Page, url: string) {
        this.page = page;
        this.url = url;
        this.createPostButton = page.getByRole('button', { name: 'Create a post' });
    }

    async goto() {
        await this.page.goto(this.url);
    }

    async clickCreatePost() {
        await this.createPostButton.click();
    }

    async selectPost(txt: string) {
        await this.page.getByLabel(txt).click();
    }
}

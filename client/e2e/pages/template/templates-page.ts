import { Page } from '@playwright/test';
/**
 * The Templates page
 */
export class TemplatesPage {
    private readonly page: Page;
    private readonly url: string;

    constructor(page: Page, url: string) {
        this.page = page;
        this.url = url;
    }

    async goto() {
        await this.page.goto(this.url);
    }

    async clickCreateOrAddNew() {
        // Button changes based on whether there are already templates in the space
        try {
            await this.page
                .getByRole('button', { name: 'Create a template' })
                .click({ timeout: 5000 });
        } catch (e) {
            await this.page.getByRole('button', { name: 'Add New' }).click();
        }
    }
}

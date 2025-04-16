import { Page } from '@playwright/test';
import { CommunityMenuBar } from '../community/community-menu-bar';
/**
 * The Templates page
 */
export class TemplatesPage {
    private readonly page: Page;
    private readonly menuBar: CommunityMenuBar;

    constructor(page: Page) {
        this.page = page;
        this.menuBar = new CommunityMenuBar(page);
    }

    async goto() {
        await this.menuBar.clickTemplates();
    }

    async waitFor() {
        await this.page.getByLabel('Search templates').isVisible();
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

    async clickTemplate(name) {
        await this.page.locator('flt-semantics:text-is("'.concat(name, '")')).nth(0).click();
    }
}

import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * Create Template dialog
 */
export class CreateTemplatePage {
    private readonly page: Page;
    private readonly templateNameField: Locator;
    private readonly descriptionField: Locator;
    private readonly addTagButton: Locator;
    private readonly createButton: Locator;
    private readonly tagField: Locator;
    private readonly editImageButton: Locator;
    private readonly mediaPicker: MediaPicker;

    constructor(page: Page) {
        this.page = page;
        this.templateNameField = page.getByLabel('Template name');
        this.descriptionField = page.getByLabel('Description');
        this.addTagButton = page.getByRole('button', { name: 'Add tag' });
        this.createButton = page.getByRole('button', { name: 'Create' });
        this.tagField = page.getByRole('textbox', { name: 'Tag' });
        this.editImageButton = page.locator('flt-semantics:text-is("Edit Image")');
        this.mediaPicker = new MediaPicker(page);
    }

    async enterName(name: string) {
        await this.templateNameField.click();
        await this.templateNameField.fill(name);
    }

    async enterDescription(description: string) {
        await this.descriptionField.click();
        await this.descriptionField.fill(description);
    }

    /**
     * This method doesn't work right now. Could be same issue affecting adding tags
     * to a community space, though the behavior isn't similar when testing manually
     *
     */
    async addTags(tags: string[]) {
        await this.addTagButton.click();
        for (const tag of tags) {
            await this.tagField.click({ force: true });
            // Tried fill and pressSequentially, neither will actually put the value in
            await this.tagField.pressSequentially(tag);
            await this.page.getByRole('button', { name: 'Submit Tag' }).click();
        }
    }

    async clickCreate() {
        await this.createButton.click();
    }

    async selectImage(imageUrl: string) {
        await this.editImageButton.click();
        await this.mediaPicker.selectImage(imageUrl);
    }
}

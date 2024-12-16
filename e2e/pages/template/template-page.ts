import { Locator, Page, expect } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * The page displayed when you select a single Template
 */
export class TemplatePage {
    private readonly page: Page;
    private readonly nameText: Locator;
    private description: string;
    private readonly editTemplateButton: Locator;
    private readonly removeTemplateButton: Locator;
    private readonly createEventButton: Locator;
    private readonly hostedRadioButton: Locator;
    private readonly saveTemplateButton: Locator;
    private readonly mediaPicker: MediaPicker;

    constructor(page: Page, name: string) {
        this.page = page;
        this.nameText = page.getByLabel(name);
        this.editTemplateButton = page.locator('flt-semantics:text-is("Edit template")');
        this.removeTemplateButton = page.getByRole('button', { name: 'Remove template' });
        this.saveTemplateButton = page.getByRole('button', { name: 'Save template' });
        this.createEventButton = page.getByRole('button', { name: 'Create event' });
        this.hostedRadioButton = page.locator('flt-semantics:text-is("Hosted")');
        this.mediaPicker = new MediaPicker(page);
    }

    setDescription(description: string) {
        this.description = description;
    }

    async clickEditTemplate() {
        await this.editTemplateButton.click();
    }

    async clickRemoveTemplate() {
        await this.removeTemplateButton.click({ force: true });
    }

    async clickSaveTemplate() {
        await this.saveTemplateButton.click();
    }

    async clickCreateEvent() {
        await this.createEventButton.click();
    }

    async selectHostedEvent() {
        await this.hostedRadioButton.click();
    }

    async selectImageFromEditMenu(imageUrl: string) {
        await this.page.locator('flt-semantics:text-is("Image")').click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async selectEditableImage(imageUrl: string) {
        await this.page.locator('flt-semantics:text-is("Edit Image")').click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async assertVisible() {
        await expect(this.nameText).toBeVisible({ timeout: 30000 });
        if (this.description) {
            await expect(
                this.page.locator('flt-semantics:text-is("'.concat(this.description, '")'))
            ).toBeVisible();
        }
        // Need to do image and tag validation once tags can be set
    }
}

import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * The sidebar displayed when editing an event
 */
export class EditEventPage {
    private readonly page: Page;
    private readonly mediaPicker: MediaPicker;
    private readonly closeEditButton: Locator;
    private readonly saveButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.closeEditButton = page.locator('flt-semantics:text-is("Close Edit")');
        this.saveButton = page.getByRole('button', { name: 'Save', exact: true });
        this.mediaPicker = new MediaPicker(page);
    }

    async clickSaveEvent() {
        // do it this way b/c Playwright won't scroll down to the Save Event button
        await this.closeEditButton.click();
        await this.saveButton.click();
    }

    async selectImage(imageUrl: string) {
        await this.page.locator('flt-semantics:text-is("Image")').click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async enterTitle(title: string) {
        // this needs some work, doesn't always seem to replace previous text
        await this.page.getByLabel('Title').fill(title);
    }

    async enterDescription(description: string) {
        // this needs some work, doesn't always seem to replace previous text
        await this.page.getByLabel('Description').fill(description);
    }

    async enterDate(date: string) {
        // this needs some work, doesn't always display on click
        await this.page.getByLabel('Date').click();
        await this.page.getByRole('button', { name: 'Switch to input' }).click();
        await this.page.getByLabel('Enter Date').fill(date);
        await this.page.getByRole('button', { name: 'OK' }).click();
    }

    async enterMeetingLength(length: string) {
        await this.page.getByRole('button', { name: 'Length' }).click();
        await this.page.locator('flt-semantics:text-is("'.concat(length, '")')).click();
    }
}

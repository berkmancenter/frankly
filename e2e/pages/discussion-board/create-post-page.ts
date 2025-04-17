import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * The Create Post dialog
 */
export class CreatePostPage {
    private readonly page: Page;
    private readonly mediaPicker: MediaPicker;
    private readonly msgField: Locator;
    private readonly imageButton: Locator;
    private readonly postButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.mediaPicker = new MediaPicker(page);
        this.msgField = page.getByLabel('Type something');
        this.imageButton = page.locator('flt-semantics:text-is("Image")');
        this.postButton = page.getByRole('button', { name: 'Post' });
    }

    async enterText(msg: string) {
        await this.msgField.fill(msg);
    }

    async selectImage(imageUrl: string) {
        await this.imageButton.click();
        await this.mediaPicker.selectImage(imageUrl);
    }
    async clickPost() {
        await this.postButton.click();
    }
}

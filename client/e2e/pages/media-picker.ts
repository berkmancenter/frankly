import { FrameLocator, Page } from '@playwright/test';
/**
 * The frame used to select images and videos for upload
 */
export class MediaPicker {
    private readonly imgFrame: FrameLocator;

    constructor(page: Page) {
        this.imgFrame = page.frameLocator('[data-test="uw-iframe"]');
    }

    async selectImage(imageUrl: string) {
        await this.uploadImage(imageUrl, false);
    }

    async selectAndCropImage(imageUrl: string) {
        await this.uploadImage(imageUrl, true);
    }

    private async uploadImage(imageUrl: string, crop: boolean) {
        //The media frames are not unique in an easily locatable way
        // Appears to be no way to know how many iFrames were matched, never seen more than 3 on
        // a given screen
        for (var index = 0; index < 3; index++) {
            const frame = this.imgFrame.nth(index);
            try {
                await frame.locator('[data-test="url-btn"]').click({ timeout: 5000 });
                await frame.locator('[data-test="search-input-box"]').fill(imageUrl);
                await frame.locator('[data-test="upload-from-link-btn"]').click();
                if (crop) {
                    await frame.locator('[data-test="cropBtn"]').click();
                } else {
                    await frame.locator('[data-test="skip-button"]').click();
                }
                break;
            } catch (e) {}
        }
    }
}

import { Locator, Page, expect } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * Start a Community dialog
 */
export class StartCommunityPage {
    private readonly page: Page;
    private readonly agreeAndContinueButton: Locator;
    private readonly communityNameField: Locator;
    private readonly taglineField: Locator;
    private readonly aboutField: Locator;
    private readonly logoButton: Locator;
    private readonly backgroundButton: Locator;
    private readonly contactField: Locator;
    private readonly privateSpaceBox: Locator;
    private readonly nextButton: Locator;
    private readonly finishButton: Locator;
    private readonly mediaPicker: MediaPicker;
    private readonly addTagButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.agreeAndContinueButton = page.getByRole('button', { name: 'Agree and continue' });
        this.communityNameField = page.getByLabel('Name');
        this.taglineField = page.getByLabel('Tagline');
        this.aboutField = page.getByLabel('About');
        this.logoButton = page.getByRole('button', { name: 'Logo' });
        this.backgroundButton = page.getByRole('button', { name: 'Background' });
        this.contactField = page.getByLabel('Contact email');
        this.privateSpaceBox = page.getByLabel('Make this space private');
        this.nextButton = page.getByRole('button', { name: 'Next' });
        this.finishButton = page.getByRole('button', { name: 'Finish' });
        this.addTagButton = page.getByRole('button', { name: 'Add tag' });
        this.mediaPicker = new MediaPicker(page);
    }

    async clickAgreeAndContinue() {
        await this.agreeAndContinueButton.click();
    }

    async enterCommunityName(commName: string) {
        await this.communityNameField.click();
        await this.communityNameField.fill(commName);
    }

    async enterTagline(tagline: string) {
        await this.taglineField.click();
        await this.taglineField.fill(tagline);
    }

    async enterAbout(about: string) {
        await this.aboutField.click();
        await this.aboutField.fill(about);
    }

    async selectBackground(backgroundUrl: string) {
        await this.backgroundButton.click();
        await this.mediaPicker.selectImage(backgroundUrl);
    }

    async selectLogo(logoUrl: string) {
        await this.logoButton.click({ force: true });
        await this.mediaPicker.selectImage(logoUrl);
    }

    async enterContactEmail(email: string) {
        await this.contactField.click();
        await this.contactField.fill(email);
    }

    async checkPrivate() {
        await this.privateSpaceBox.click();
        expect(await this.privateSpaceBox.isChecked()).toBeTruthy();
    }

    async clickNext() {
        await this.nextButton.click();
    }

    async clickFinish() {
        await this.finishButton.click();
    }

    async waitFor() {
        await this.agreeAndContinueButton.waitFor();
    }

    async waitForInputFields() {
        await this.communityNameField.waitFor();
    }

    async waitForBranding() {
        await this.addTagButton.waitFor();
    }
}

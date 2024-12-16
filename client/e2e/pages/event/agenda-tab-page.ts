import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * The Agenda tab of an event page
 */
export class AgendaTabPage {
    private readonly page: Page;
    private readonly addCardButton: Locator;
    private readonly cardTypeButton: Locator;
    private readonly cardTitleField: Locator;
    private readonly uploadImageButton: Locator;
    private readonly saveCardButton: Locator;
    private readonly mediaPicker: MediaPicker;

    constructor(page: Page) {
        this.page = page;
        this.addCardButton = page.locator('flt-semantics:text-is("Add agenda item")');
        this.cardTypeButton = page.getByRole('button', { name: 'Text', exact: true });
        this.cardTitleField = page.getByLabel('Title');
        this.uploadImageButton = page.getByRole('button', { name: 'Upload Image' });
        this.saveCardButton = page.getByRole('button', { name: 'Save Agenda Item' });
        this.mediaPicker = new MediaPicker(page);
    }

    async clickAddCard() {
        await this.addCardButton.click();
    }

    async selectCardType(cardType: string) {
        await this.cardTypeButton.click();
        await this.page.locator('flt-semantics:text-is("'.concat(cardType, '")')).click();
    }

    async enterCardTitle(title: string) {
        await this.cardTitleField.click();
        await this.cardTitleField.fill(title);
    }

    async selectCardImage(imageUrl: string) {
        await this.uploadImageButton.click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async selectAndCropCardImage(imageUrl: string) {
        await this.uploadImageButton.click();
        await this.mediaPicker.selectAndCropImage(imageUrl);
    }

    async clickSaveCard() {
        await this.saveCardButton.click();
    }
}

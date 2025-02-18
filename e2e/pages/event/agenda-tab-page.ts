import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';
/**
 * The Agenda tab of an event page
 */
export class AgendaTabPage {
    private readonly page: Page;
    private readonly addItemButton: Locator;
    private readonly itemTypeButton: Locator;
    private readonly itemTitleField: Locator;
    private readonly uploadImageButton: Locator;
    private readonly saveItemButton: Locator;
    private readonly mediaPicker: MediaPicker;

    constructor(page: Page) {
        this.page = page;
        this.addItemButton = page.locator('flt-semantics:text-is("Add agenda item")');
        this.itemTypeButton = page.getByRole('button', { name: 'Text', exact: true });
        this.itemTitleField = page.getByLabel('Title');
        this.uploadImageButton = page.getByRole('button', { name: 'Upload Image' });
        this.saveItemButton = page.getByRole('button', { name: 'Save Agenda Item' });
        this.mediaPicker = new MediaPicker(page);
    }

    async clickAddItem() {
        await this.addItemButton.click();
    }

    async selectItemType(itemType: string) {
        await this.itemTypeButton.click();
        await this.page.locator('flt-semantics:text-is("'.concat(itemType, '")')).click();
    }

    async enterItemTitle(title: string) {
        await this.itemTitleField.click();
        await this.itemTitleField.fill(title);
    }

    async selectItemImage(imageUrl: string) {
        await this.uploadImageButton.click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async selectAndCropItemImage(imageUrl: string) {
        await this.uploadImageButton.click();
        await this.mediaPicker.selectAndCropImage(imageUrl);
    }

    async clickSaveItem() {
        await this.saveItemButton.click();
    }
}

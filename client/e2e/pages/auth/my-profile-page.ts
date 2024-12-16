import { Locator, Page } from '@playwright/test';
import { MediaPicker } from '../media-picker';

/**
 * My Profile page
 */
export class MyProfilePage {
    private readonly page: Page;
    private readonly mediaPicker: MediaPicker;
    private readonly profileTab: Locator;
    private readonly editImageButton: Locator;
    private readonly updateProfileButton: Locator;
    private readonly eventsTab: Locator;
    private readonly upcomingEvents: Locator;
    private readonly notificationsTab: Locator;

    constructor(page: Page) {
        this.page = page;
        this.mediaPicker = new MediaPicker(page);
        this.profileTab = page.locator('flt-semantics:text-is("PROFILE PROFILE")');
        this.editImageButton = page.locator('flt-semantics:text-is("Edit Image")');
        this.eventsTab = page.locator('flt-semantics:text-is("MY EVENTS MY EVENTS")');
        this.upcomingEvents = page.getByLabel('UPCOMING');
        this.updateProfileButton = page.getByRole('button', { name: 'Update Profile' });
        this.notificationsTab = page.locator(
            'flt-semantics:text-is("NOTIFICATIONS NOTIFICATIONS")'
        );
    }

    async clickProfile() {
        await this.profileTab.click();
    }

    async selectProfileImage(imageUrl: string) {
        await this.editImageButton.click();
        await this.mediaPicker.selectImage(imageUrl);
    }

    async clickUpdateProfile() {
        await this.updateProfileButton.click();
    }

    async clickMyEvents() {
        await this.eventsTab.click();
    }

    async clickNotifications() {
        await this.notificationsTab.click();
    }

    async waitForMyEvents() {
        await this.upcomingEvents.waitFor();
    }

    async waitForProfile() {
        await this.profileTab.waitFor();
    }
}

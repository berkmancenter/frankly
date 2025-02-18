import { Locator, Page } from '@playwright/test';

/**
 * SignIn Dialog Box
 */
export class SignInPage {
    private readonly page: Page;
    private readonly signInWithEmailButton: Locator;
    private readonly emailInput: Locator;
    private readonly passwordInput: Locator;
    private readonly signInButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.signInWithEmailButton = page.getByRole('button', { name: 'Sign in with Email' });
        this.emailInput = page.getByLabel('Email');
        this.passwordInput = page.getByLabel('Password');
        this.signInButton = page.getByRole('button', { name: 'Sign In' });
    }

    async enterEmail(user: string) {
        await this.emailInput.click();
        await this.emailInput.fill(user);
    }

    async enterPassword(pwd: string) {
        await this.passwordInput.click();
        await this.passwordInput.fill(pwd);
    }

    async clickSignInWithEmail() {
        await this.signInWithEmailButton.click();
    }

    async clickSignIn() {
        await this.signInButton.click();
    }

    async waitFor() {
        await this.signInWithEmailButton.waitFor();
    }

    async waitForEmailSignIn() {
        await this.emailInput.waitFor();
    }
}

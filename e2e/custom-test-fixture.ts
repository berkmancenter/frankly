import { enableAccessibility } from './utils/accessibility';
import { authenticate } from './utils/authenticate';
import { test as base } from '@playwright/test';
/**
 * The fixture that all Playwright tests should use. It
 * ensures that browser authentication is handled and
 * accessibility is enabled to allow tests to recognize individual elements
 */
export const test = base.extend({
    page: async ({ page }, use) => {
        await enableAccessibility(page);
        await authenticate(page);
        await use(page); //runs test here
        //could add logic after test
    },
});
export { expect } from '@playwright/test';

import AxeBuilder from '@axe-core/playwright';
import { expect, Page, TestInfo } from '@playwright/test';
/**
 * Adds a hook to click the hidden enable accessbility button on page, which must be done to build the
 * Semantics tree of that page. This is the only way that Playwright tests can find individual
 * elements on a page.
 * @param page
 */
export const enableAccessibility = async (page: Page) => {
    await page.addInitScript(() => {
        // Make sure body has loaded.
        window.addEventListener('DOMContentLoaded', () => {
            const observer = new MutationObserver(() => {
                const selector = document.querySelector('flt-semantics-placeholder');
                if (selector) {
                    (selector as HTMLElement).click();
                    observer.disconnect();
                }
            });
            observer.observe(document.body, {
                attributes: false,
                childList: true,
                characterData: false,
                subtree: true,
            });
        });
    });
};

export const checkAccessibility = async (page: Page, testInfo: TestInfo) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
        .disableRules(['meta-viewport'])
        .analyze();

    await testInfo.attach('accessibility-scan-results', {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: 'application/json',
    });

    expect(accessibilityScanResults.violations).toEqual([]);
};

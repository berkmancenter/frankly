import { expect, test } from '../../custom-test-fixture';
import { HomeMenuBar } from '../../pages/home-menu-bar';
import { Sidebar } from '../../pages/sidebar';
import { HomePage } from '../../pages/home-page';
import { checkAccessibility } from '../../utils/accessibility';

test('test home page is accessible', async ({ page }, testInfo) => {
    await new HomePage(page).waitFor();
    await checkAccessibility(page, testInfo);
});

test('test home page sidebar is accessible', async ({ page }, testInfo) => {
    await new HomeMenuBar(page).showSidebar();
    await new Sidebar(page).waitFor();
    await checkAccessibility(page, testInfo);
});

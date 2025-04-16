import { test } from '../../../custom-test-fixture';
import { checkAccessibility } from '../../../utils/accessibility';
import { gotoTestCommunitySpace } from '../../../utils/test-community';

test('test community page is accessible', async ({ page }, testInfo) => {
    const communityPage = await gotoTestCommunitySpace(page);
    await communityPage.waitFor();
    await checkAccessibility(page, testInfo);
});

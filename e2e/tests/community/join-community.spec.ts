import { signInAsMember, signOut } from '../../utils/authenticate';
import {
    gotoTestCommunitySpace,
    gotoTestCommunitySpaceAnonymously,
} from '../../utils/test-community';
import { CommunityMenuBar } from '../../pages/community/community-menu-bar';
import { test } from '../../custom-test-fixture';

/**
 * COM-002 Verify participant can follow/join a community
 */
test.beforeEach(async ({ page }) => {
    await signOut(page);
});

test.afterEach(async ({ page }) => {
    const sidebar = await new CommunityMenuBar(page).showSidebar();
    await sidebar.clickUnfollow();
});

test('test participant can join a community from page', async ({ page }) => {
    const communitySpacePage = await gotoTestCommunitySpaceAnonymously(page);
    await signInAsMember(page);
    await communitySpacePage.clickFollow();
    // Should be able to see announcements as a member/follower
    await new CommunityMenuBar(page).assertAnnouncementsVisible();
});

test('test participant can join a community from sidebar', async ({ page }) => {
    await gotoTestCommunitySpaceAnonymously(page);
    await signInAsMember(page);
    const sidebar = await new CommunityMenuBar(page).showSidebar();
    await sidebar.clickFollow();
    // close the sidebar so tear down will work
    await sidebar.clickClose();
    await new CommunityMenuBar(page).assertAnnouncementsVisible();
});

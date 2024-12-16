import { gotoTestCommunityDiscussionBoard } from '../../utils/test-community';
import { expect, test } from '../../custom-test-fixture';
import { PostsPage } from '../../pages/discussion-board/posts-page';
import { CreatePostPage } from '../../pages/discussion-board/create-post-page';
import { PostPage } from '../../pages/discussion-board/post-page';

/**
 * DIS-001, Member can post to discussion board
 */

let postsPage: PostsPage;
let postPage: PostPage;

test.beforeEach(async ({ page }) => {
    postsPage = await gotoTestCommunityDiscussionBoard(page);
});

test.afterEach(async ({}) => {
    if (postPage) {
        await postPage.clickShowOptions();
        await postPage.clickDeletePost();
        await postPage.clickYes();
    }
});

test('test owner can post to discussion board', async ({ page }) => {
    const postTxt = 'Hi there!';
    await postsPage.clickCreatePost();
    const createPostPage = new CreatePostPage(page);
    await createPostPage.enterText(postTxt);
    await createPostPage.selectImage(
        'https://upload.wikimedia.org/wikipedia/commons/f/f0/%22a_gscheits_Bier%22_in_Dillingen._-_panoramio.jpg'
    );
    await createPostPage.clickPost();
    // this will fail if post was not added
    await postsPage.selectPost(postTxt);
    postPage = new PostPage(page, postTxt);
});

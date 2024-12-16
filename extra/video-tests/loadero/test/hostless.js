/**
 * End-to-end test for the sample Vue3+Vite todo app located at
 * https://github.com/nightwatchjs-community/todo-vue
 */
describe("To-Do List End-to-End Test", function () {
  it("joins a hostless", async function () {
    await browser.navigateTo(
      "https://juntochat-dev.web.app/space/Ek6bMd7SN22CQONXTviT/discuss/63h1DF3vCvA1bPD24nnO/oBlTK0FTytorqmB66Em6?test=testEmail3@test.com"
    );

    await browser.pause(1000 * 60 * 10);
  });
});

module.exports = {
    'Demo test ecosia.org': function (client) {
        const signInXPath = getTextXPath('Sign In');
        const signInEmailXPath = getTextXPath('Sign In With Email');
        const registerXPath = getTextXPath('REGISTER');
        const joinXPath = getTextXPath('JOIN');
        const startsXPath = getTextXPath('STARTS');

        const random = `${Date.now()}-${getRandomInt(10000)}`;

        const page = client
            .resizeWindow(1280, 720)
            .useXpath()
            .url('https://myjunto.app/home/#/junto/unify-america-twilio/challenge?typeformLink=https%3A%2F%2Funifyamerica.typeform.com%2Fto%2FKGMEwdSu%3Fzmle%3Dc%26zid%3D4304818000009309001%26ps_id%3D4304818000009402250&meetingId=tearful-oil&userId=4&userDisplay=4')
            .pause(8000)
            .moveTo(null, -(1280 / 2), -(720 / 2))
            .moveTo(null, 340, 450)
            .mouseButtonClick()
            .pause(10000);
        ///x: 138.5
        //y: 465.078125

        /*waitAndClick(page, signInXPath).then(() =>
            waitAndClick(page, signInEmailXPath).then(() => {
                page
                    .pause(1500)
                    .keys(client.Keys.TAB)
                    .keys(client.Keys.TAB)
                    .keys(client.Keys.TAB)
                    .keys(`John Wayne (${random})`)
                    .keys(client.Keys.TAB)
                    .keys(`test-${random}@myjunto.app`)
                    .keys(client.Keys.TAB)
                    .keys('testing1');
                waitAndClick(page, registerXPath).then(() =>
                    waitAndClick(page, joinXPath).then(() => {
                        page
                            .pause(2000)
                            .keys(client.Keys.TAB)
                            .keys(client.Keys.SPACE)
                            .pause(3000);
                        waitAndClick(page, startsXPath).then(() => {
                            afterConnect(page);
                        })
                    }))
            }));*/

        /*
        
        
            await page.keyboard.press('Tab');
            await page.keyboard.press('Tab');
            await page.keyboard.press('Tab');
            await page.keyboard.type(`John Wayne (${random})`);
        
            await page.keyboard.press('Tab');
            await page.keyboard.type(`test-${random}@myjunto.app`);
        
            await page.keyboard.press('Tab');
            await page.keyboard.type(`testing1`);
        
            await waitAndClickElementWithText(page, 'REGISTER');
        
            await page.waitForTimeout(4000);
            await page.goto('https://juntochat-dev.web.app/home/#/junto/CTqYh6sW4Hueyxy2SK3d/discuss/sargfqL3ebwUWYhGB1uJ/z3F9maX7Q8c7tWCKKoR0');
        
            await waitAndClickElementWithText(page, 'JOIN');
        
            await page.waitForTimeout(2000);
            await page.keyboard.press('Tab');
            await page.keyboard.press('Space');
        
            await waitAndClickElementWithText(page, 'STARTS');
        
            */



    }
};

function afterConnect(client) {
    client.pause(3000)
    client.end();
}

let mouseX = 0;
let mouseY = 0;

async function waitAndClick(client, xpath) {
    client.pause(3000)
        .waitForElementVisible(xpath)
        .pause(1500);
    const elementLocation = await new Promise((resolve, reject) => client.getLocation('xpath', xpath, resolve));
    console.log(elementLocation);
    let offsetX = Math.round(elementLocation.value.x + 2 - mouseX);
    let offsetY = Math.round(elementLocation.value.y + 2 - mouseY);
    mouseX += offsetX;
    mouseY += offsetY;
    console.log(`Mouse at ${mouseX}, ${mouseY}`);
    console.log(offsetX);
    console.log(typeof offsetY);
    console.log(offsetY);

    client.moveTo(null, offsetX, offsetY)
        .mouseButtonClick();
}

function getTextXPath(text) {
    return `(//*[contains(text(), "${text}")])[1]`;
}

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}
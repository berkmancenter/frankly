const puppeteer = require('puppeteer');

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function getTextXPath(text) {
    return `//text()[contains(., "${text}")]`;
}

async function waitAndClickElementWithText(page, text) {
    const path = getTextXPath(text);
    await page.waitForXPath(path);
    await page.waitForTimeout(4000);
    const [button] = await page.$x(path);
    const bounds = await button.boundingBox();
    await page.mouse.click(bounds.x, bounds.y);
}

async function getBrowser(props) {

    let browser;
    if (props.isLocal) {
        browser = await puppeteer.launch({
            headless: false,
            args: [
                '--use-fake-device-for-media-stream',
                '--use-fake-ui-for-media-stream',
            ],
        });
    } else {

        const dedicatedApiKey = '9d715a63-53ab-4513-9cb1-63d43af2e31e';
        const onDemandApiKey = 'b767a236-c439-43ab-842a-6279c1b1d657';
        browser = await puppeteer.connect({
            browserWSEndpoint: `wss://chrome.browserless.io/?token=${onDemandApiKey}&--use-fake-device-for-media-stream&--use-fake-ui-for-media-stream`,
        });
    }
    return browser;
}

async function joinMeeting(page, i) {
    await page.goto('https://juntochat-dev.web.app/home/');

    console.log(`browser ${i} signing in`)
    await waitAndClickElementWithText(page, 'Sign In');
    await waitAndClickElementWithText(page, 'Sign In With Email');
    await page.waitForTimeout(2000);

    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    const random = `${i}-${Date.now()}`;
    await page.keyboard.type(`John ${random}`);

    await page.keyboard.press('Tab');
    await page.keyboard.type(`test-${random}@myjunto.app`);

    await page.keyboard.press('Tab');
    await page.keyboard.type(`testing1`);

    await waitAndClickElementWithText(page, 'REGISTER');

    await page.waitForTimeout(4000);
    console.log(`browser ${i} signed up`);
    await page.goto('https://juntochat-dev.web.app/share/junto/CTqYh6sW4Hueyxy2SK3d/discuss/cjMTqHda5ICPrKGFewV4/SLoLPFuEIDU6YM3CDKon');

    await waitAndClickElementWithText(page, 'REGISTER');

    await page.waitForTimeout(4000);
    console.log(`browser ${i} registered`);
    //await page.keyboard.press('Tab');
    //await page.keyboard.press('Space');

    console.log(`browser ${i} clicking start`);
    await waitAndClickElementWithText(page, 'STARTS');
    console.log(`browser ${i} done start`);
    //await page.waitForTimeout(4000);

    /*const shadowRoot = await page.evaluateHandle('document.querySelector("#root")');
    const xpath = getTextXPath('Join Now');
    const button = shadowRoot.evaluateHandle(xpath);

    const frames = await page.frames()
    await waitAndClickElementWithText(page, 'Join Now');*/


    console.log(`${i} starting my wait`);
    await page.waitForTimeout(45000);
    console.log(`${i} finished my wait`);

    await page.goBack();
    await page.waitForTimeout(3000);
    console.log(`${i} returning`);
}

async function joinInstantMeeting(page, i) {
    const meetingId = 'jNiOKwyryfkuF51gbD1n';
    const random = `${Date.now()}-${getRandomInt(10000)}`;
    await page.goto(`http:/juntochat-dev.web.app/home/#/junto/danny-test-twilio/challenge?meetingId=${meetingId}&userId=${random}&userDisplay=${random}&typeformLink=`,
        {
            // waitUntil: 'networkidle2',
        });

    await page.waitForTimeout(6000);
    const shadowRoot = await page.waitForFunction('document.querySelector("flt-platform-view")?.shadowRoot?.querySelector("#twilio-video-conference")');
    const content = await shadowRoot.contentFrame();


    console.log('join starting: ' + i);
    /*const mutePath = getTextXPath('Mute');
    await content.waitForXPath(mutePath);
    const [muteButton] = await content.$x(mutePath);
    const muteBounds = await muteButton.boundingBox();
    await page.mouse.click(muteBounds.x, muteBounds.y);*/

    const xpath = getTextXPath('Join Now');
    await content.waitForXPath(xpath);
    const [button] = await content.$x(xpath);
    const bounds = await button.boundingBox();
    await page.mouse.click(bounds.x, bounds.y);

    console.log('join completed: ' + i);

    await page.waitForTimeout(15000);
}


async function joinFlutterInstantMeeting(page, i, meetingId) {
    const random = `${Date.now()}-${getRandomInt(10000)}`;

    await page.goto(`http:/juntochat-dev.web.app/home/#/junto/danny-test/instant?meetingId=${meetingId}`,
        //await page.goto('https://juntochat-dev.web.app/home/#/junto/temp/instant?meetingId=test',
        {
            // waitUntil: 'networkidle2',
        });

    await page.waitForTimeout(6000);

    await page.waitForTimeout(180000);
}



async function joinFlutterInstantMeetingSmartMatching(page, i, juntoId, meetingId) {
    const random = `${Date.now()}-${getRandomInt(10000)}`;

    const numResponses = 7;
    var responses = Math.random() < 0.5 ? '-FHrJXcV0-qtgD__FJ8Ykw==' : 'mSotcoFythonvNCUEmNGcw==';

    await page.goto(`https://juntochat-dev.web.app/home/junto/${juntoId}/instant?skipCheck=true&name=Num_${i}&meetingId=${meetingId}&am=${responses}`,
        //await page.goto('https://juntochat-dev.web.app/home/#/junto/temp/instant?meetingId=test',
        {
            // waitUntil: 'networkidle2',
        });

    await page.waitForTimeout(6000);
    await page.screenshot({

        path: "./screenshot.png",

        fullPage: true

    });

    await page.waitForTimeout(60 * 1000 * 5);
}


async function joinDailyMeeting(page, i) {
    await page.goto(`http://juntochat-dev.web.app/home/#/junto/danny-test/challenge?sfu=0&meetingId=danny-test-1229-7&userId=comp-${i}&userDisplay=Danny-1&typeformLink=https%3A%2F%2Funifyamerica.typeform.com%2Fto%2FKGMEwdSu%3Fzmle%3Dc%26zid%3D4304818000009309001%26ps_id%3D4304818000009402250`);

    await page.waitForTimeout(20000);
}

async function startRecordingMeeting(page) {
    await page.goto(`https://junto-meet.daily.co/cVzh16dRCxWxN65HvDi3?t=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyIjoiY1Z6aDE2ZFJDeFd4TjY1SHZEaTMiLCJvIjp0cnVlLCJ2byI6dHJ1ZSwiYW8iOnRydWUsInNyIjp0cnVlLCJlciI6InJ0cC10cmFja3MiLCJkIjoiMGY2YmU2OGQtYzE1MC00YjI4LTk1ZjktNGUxNzIzMjA5NDU0IiwiaWF0IjoxNjA4MDg2MTgyfQ.CNhn6xjaRqTN9lr218XjJpFZN10cK_VZyeE9SYTPyJ8`);

    await waitAndClickElementWithText(page, 'Click to start recording');
    await waitAndClickElementWithText(page, 'Leave');
}

function later(delay) {
    return new Promise(function (resolve) {
        setTimeout(resolve, delay);
    });
}



(async () => {

    const promises = [];
    const browsers = [];
    const numBrowsers = 1;
    for (let i = 0; i < numBrowsers; i++) {

        async function run(j) {
            await later(j / numBrowsers * 45000);
            console.log(`got browser(${j}`);
            const browser = await getBrowser({ isLocal: false });
            browsers.push(browser);

            console.log(`creating new page (${j}`);
            const page = await browser.newPage();
            console.log(`creating new page (${j}`);

            await joinFlutterInstantMeetingSmartMatching(page, j, 'danny-test', 'bot-test-10-8');
            //await joinFlutterInstantMeeting(page, j, 'new-video-off-test-7');

            console.log(`finished test (${j}`);
        }

        promises.push(run(i).catch(e => console.log(e)));

        // promises.push(joinInstantMeeting(page, i));
        //promises.push(startRecordingMeeting(page));
    }

    await Promise.all(promises);

    console.log('finished');
    await Promise.all(browsers.map((b) => b.close()));

})();
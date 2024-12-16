/*

Run this to launch multiple bot sessions from a single puppeteer instance

Install dependencies:
  npm install uuid puppeteer axios

Usage:
  node scaletest.js [namePrefix] [numBots] [serviceProvider] [offset] [audioVideo]

Parameters:
  namePrefix: first part of identifier for bots, useful when launching multiple instances of this script to distinguish
  numBots: number of bots (chrome sessions) to launch
  serviceProvider: put 'browserless' to launch via browserless.io, otherwise launches locally
  offset: offset for created bot identifiers, needed when launching multiple simultaneous instances of this script
  audioVideo: put 'camera' to simulate camera/mic, else disabled

e.g.:
  node scaletest.js bot 20 local
  node scaletest.js bot 4 local 0 camera
  node scaletest.js bot 100 browserless

*/


const { v4: uuidv4 } = require('uuid');
const puppeteer = require('puppeteer');
process.setMaxListeners(0);

// docker run -p 4444:3000 -e "CONNECTION_TIMEOUT=600000" browserless/chrome

const NAME_PREFIX = process.argv[2];
const NUM_BOTS = parseInt(process.argv[3]);
const USE_BROWSERLESS = process.argv[4] === "browserless";
const OFFSET = process.argv[5] ? parseInt(process.argv[5]) : 0
const USE_CAMERA = process.argv[6] === "camera";

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

const ANSWERS = [
    '_CFcjEBVrrvUzGnEcfelmw==',
    '_NRib6lXgJjN2TAfzL2aMA==',
    '-FHrJXcV0-qtgD__FJ8Ykw=='
]

const numDuplicateMatchIds = Math.ceil(NUM_BOTS/4);
let matchIds = [];
for(let i = 0; i < numDuplicateMatchIds; ++i){
  let id = uuidv4();
  matchIds.push(id);
  matchIds.push(id);
}
for(let i = matchIds.length; i < NUM_BOTS; ++i){
  let id = uuidv4();
  matchIds.push(id);
}
shuffleArray(matchIds);

let matchLog = `using match ids:\n`;
matchIds.forEach((v) => matchLog += `${v}\n`);
console.log(matchLog);

const getAnswer = (num) => ANSWERS[Math.floor(Math.random()*3)];
const getMatchID = (num) => matchIds[num];
const getParticipantId = (num) => uuidv4();

let latest = {};

let makeClient = async (num, localIndex) => {
  let attempt = 0;
  let finished = false;
  let browser;
  let page;
  while(!finished) {
    let info = (msg) => {
      console.log(`${num}(${attempt}): ${msg}`);
      latest[num] = msg;
    }
    try {
      attempt++;
      if (page) {
        await page.close();
        page = null;
      }
      if (browser) {
        await browser.close();
        browser = null;
      }
      info('connect');
      let retryCount = 0;
      //browser = await puppeteer.connect({browserWSEndpoint: 'ws://localhost:4444/?--use-fake-device-for-media-stream&--use-fake-ui-for-media-stream'});
      while (true) {
        try {
          if (USE_BROWSERLESS) {
            browser = await puppeteer.connect({
              browserWSEndpoint: 'wss://chrome.browserless.io/?token=b767a236-c439-43ab-842a-6279c1b1d657&--use-fake-device-for-media-stream&&--use-fake-ui-for-media-stream'
            });
          } else {
            browser = await puppeteer.launch({
              headless: true,
              args: ['--use-fake-device-for-media-stream', '--use-fake-ui-for-media-stream', '--no-sandbox']
            });
          }
          const context = await browser.createIncognitoBrowserContext();

          info('newPage');
          page = await browser.newPage();
          page
            /*.on('console', message =>
              info(`${message.type().substr(0, 3).toUpperCase()} ${message.text()}`))*/
            .on('pageerror', ({ message }) => info(message))
            .on('error', ({ message }) => info(message))
            /*.on('response', response =>
              info(`${response.status()} ${response.url()}`))*/
            .on('requestfailed', request =>
              info(`${request.failure().errorText} ${request.url()}`))
            .on('response', async response => {
              if(response.status() > 399) {
                info(`${response.url()}: ${response.status()} \nrequest-body: ${response.request().postData()} \nresponse-body: ${await response.text()}`);
              }
            })
          info('setViewport');
          await page.setViewport({
            width: 820,
            height: 800
          });
          let matchParams = '';
          if (Math.random() < .8){
            matchParams += `&participant_id=${getParticipantId(localIndex)}`;
            matchParams += `&match_id=${getMatchID(localIndex)}`;
            if (Math.random() < .8) {
              matchParams += `&am=${getAnswer(localIndex)}`;
            }
          }
          const url = `https://juntochat-dev.web.app/home/junto/scale-testing/discuss/mX2jaeQni6O3LORs9bbb/YO4zuAkRMzTNbeegCbds?enableDriver${matchParams}`;
          info(`goto ${url}`);
          await page.goto(url, {timeout: 180000});
          try {
            info('waitForNavigation');
            await page.waitForNavigation({timeout: 10000, waitUntil: "networkidle2"});
          } catch {
            info('waitForNavigation timeout, continuing');
          }
          info('waitForTimeout');

          while (true){
            let result = await page.evaluate(() => $driver);
            if (result){
              break;
            }
            info('driver not yet available');
            await page.waitForTimeout(3000);
          }

          await page.waitForTimeout(10000);
          //info('waitFor');
          //await page.evaluate(() => $driver({"command": "waitFor", "timeout": "50000", "finderType": "ByText", "text": "Sign In"}));
          info('sign in');
          await page.evaluate(() => $driver({
            "command": "tap",
            "finderType": "ByText",
            "text": "Sign In",
            "timeout": "60000",
          }));

          break;
        } catch (e) {
          if (page) {
            await page.screenshot({path: `bad-${num}.png`});
          }
          info(e.toString());
          if (page) {
            await page.close();
            page = null;
          }
          if (browser) {
            await browser.close();
            browser = null;
          }
          retryCount++;
          info('retry connect and sign in (' + retryCount + ')');
        }
      }

      info('signIn with email');
      await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "Sign In With Email "}));
      await page.evaluate(() => $driver({
        "command": "tap",
        "finderType": "ByValueKey",
        "keyValueString": "input-name",
        "keyValueType": "String"
      }));
      await page.evaluate((n) => $driver({"command": "enter_text", "text": `User ${n}`}), num);
      await page.evaluate(() => $driver({
        "command": "tap",
        "finderType": "ByValueKey",
        "keyValueString": "input-email",
        "keyValueType": "String"
      }));
      await page.evaluate((n) => $driver({"command": "enter_text", "text": `email${n}@example.com`}), num);
      await page.evaluate(() => $driver({
        "command": "tap",
        "finderType": "ByValueKey",
        "keyValueString": "input-password",
        "keyValueType": "String"
      }));
      await page.evaluate(() => $driver({"command": "enter_text", "text": "password"}));
      info('register');
      await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "Register"}));
      try {
        await page.waitForTimeout(2000);
        await page.keyboard.press('Escape');
        await page.evaluate(() => $driver({
          "command": "tap",
          "timeout": "4000",
          "finderType": "ByText",
          "text": "Already a user? Sign In"
        }));
        await page.waitForTimeout(2000);
        await page.evaluate(() => $driver({
          "command": "tap",
          "finderType": "ByValueKey",
          "keyValueString": "input-password",
          "keyValueType": "String"
        }));
        await page.waitForTimeout(2000);
        await page.keyboard.press('Tab');
        await page.waitForTimeout(1000);
        info('log in');
        await page.keyboard.press('Enter');
      } catch {
        info('made new user');
      }
      try {
        await page.waitForTimeout(6000);
        info('reserve spot');
        await page.evaluate(() => $driver({
          "command": "tap",
          "finderType": "ByText",
          "text": "RESERVE A SPOT",
          "timeout": "2000"
        }));
        await page.waitForTimeout(6000);
        info('confirm');
        await page.evaluate(() => $driver({
          "command": "tap",
          "finderType": "ByText",
          "text": "I'll be there!",
          "timeout": "2000"
        }));
      } catch (e) {
        info('already joined convo');
      }

      await page.waitForTimeout(5000);
      //info('go to chat');
      //await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "CHAT"}));

      //info('focus input');
      //await page.evaluate(() => $driver({"command": "tap", "finderType": "ByValueKey", "keyValueString": "input-chat", "keyValueType": "String"}));
      //info('enter message');
      //await page.evaluate((n) => $driver({"command": "enter_text", "text": `Message from User ${n}`}), num);
      //info('send');
      //await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "Send"}));
      //await page.waitForTimeout(10000);

      let retryConvo = 0;
      info('enter convo');
      try {
        await page.evaluate(() => $driver({
          "command": "tap",
          "timeout": "60000",
          "finderType": "ByValueKey",
          "keyValueString": "enter-button",
          "keyValueType": "String"
        }));
      } catch {
        retryConvo++;
        info('retry enter convo (' + retryConvo + ')');
        await page.evaluate(() => $driver({
          "command": "tap",
          "timeout": "60000",
          "finderType": "ByValueKey",
          "keyValueString": "enter-button",
          "keyValueType": "String"
        }));
      }
      info('wait for breakouts');
      finished = true;
      await page.waitForTimeout(5000);
      if (USE_CAMERA) {
        await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "Yes"}));
        info('enabled camera');
      } else {
        await page.evaluate(() => $driver({"command": "tap", "finderType": "ByText", "text": "No"}));
        info('did not enable camera');
      }
      await page.waitForTimeout(50000000);
    } catch (e) {
      info(e);
    }
  }
};

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function makeName(i) {
  return (NAME_PREFIX) + "-" + (i + 1 + OFFSET);
}

(async () => {
  await sleep(Math.random()*20000);
  for (let i = 0; i < NUM_BOTS; ++i) {
    makeClient(makeName(i), i);
    for (let j = 0; j < NUM_BOTS; ++j) {
      let name = makeName(j);
      if(latest[name] !== undefined) {
        //console.log("*** latest for " + name + ": " + latest[name]);
      }
    }
    await sleep(40000);
  }
  while (true) {
    for (let j = 0; j < NUM_BOTS; ++j) {
      let name = makeName(j);
      if(latest[name] !== undefined) {
        //console.log("*** latest for " + name + ": " + latest[name]);
      }
    }
    await sleep(40000);
  }
})();

import { step, TestSettings, By } from '@flood/element'

function getRandomInt(max: number) {
	return Math.floor(Math.random() * Math.floor(max));
}

function getTextXPath(text: string) {
	return `//text()[contains(., "${text}")]`;
}

function getFilePath() {
	if (process.env['']) {
		return '/data/flood/files';
	}

	return '/Users/dannyfranklin/code/junto/video-tests/load-tests';
}
// google-chrome --use-fake-device-for-media-stream --use-file-for-fake-video-capture=/Users/dannyfranklin/code/junto/video-tests/load-tests/silent_cif.y4m

export const settings: TestSettings = {
	loopCount: 1,
	launchArgs: [
		'--use-fake-device-for-media-stream',
		'--use-fake-ui-for-media-stream',
		//`--use-file-for-fake-video-capture=${getFilePath()}/silent_cif.y4m`,
		//`--use-file-for-fake-audio-capture=${getFilePath()}/Silent.wav`,
	],
	//waitUntil: 'present',
	waitTimeout: 30,
}



export default () => {
	const meetingId = 'auto-1234';
	const random = `${Date.now()}-${getRandomInt(10000)}`;

	step('Start', async browser => {
		await browser.visit(`https://juntochat-dev.web.app/home/#/junto/test-junto/challenge?meetingId=${meetingId}&userId=${random}&userDisplay=${random}&typeformLink=`,
			{
				waitUntil: 'domcontentloaded',
			});
		await browser.wait(6000);
		await browser.takeScreenshot();
	});

	// browser keyword can be shorthanded as "b" or anything that is descriptive to you.
	step('Join Meeting', async browser => {
		const joinButtonFrame = await browser.findElement(By.js('document.querySelector("flt-platform-view")?.shadowRoot?.querySelector("#twilio-video-conference")'));

		//const frameId = await joinButtonFrame.getId();

		//console.log('frame id');
		//console.log(frameId);
		console.log(browser.frames.length);
		//await browser.switchTo().frame(frameId!);

		const content = await joinButtonFrame.element.contentFrame();


		const mutePath = getTextXPath('Mute');
		await content!.waitForXPath(mutePath);
		const [muteButton] = await content!.$x(mutePath);

		const muteBounds = await muteButton.boundingBox();
		await browser.mouse.click(muteBounds!.x, muteBounds!.y);

		const xpath = getTextXPath('Join Now');
		await content!.waitForXPath(xpath);
		const [button] = await content!.$x(xpath);

		const bounds = await button.boundingBox();
		await browser.mouse.click(bounds!.x, bounds!.y);

		await browser.wait(1000 * 60 * 15);
		await browser.takeScreenshot();
	})
}

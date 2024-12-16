#!/usr/bin/env node

const axios = require('axios');
const yargs = require("yargs");

const options = yargs
    .usage("Usage: -n <name>")
    .option("n", { alias: "num-users", describe: "How many users to create", type: "number", demandOption: true })
    .option("r", { alias: "ramp-up", describe: "How long to ramp these users up over in seconds", type: "number", demandOption: true })
    .argv;



function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

function getWaitDuration() {
    return Math.random() * options.rampUp * 1000;
}

let index = 0;

async function runTestForUser(i) {
    await sleep(getWaitDuration());

    let localIndex = index;
    index++;
    console.log(`Making call for ${localIndex}`);
    try {
        await axios.get('https://kazm-scale-testing-cgkrf7xhla-uc.a.run.app/hostless');
    } catch (e) {
        console.log(`Failed call ${localIndex} with ${e}`);
        return;
    }
    console.log(`Completed call for ${localIndex}`);
}

let allRuns = [];
for (let i = 0; i < options.numUsers; i++) {
    allRuns.push(runTestForUser(i));
}

async function main() {
    await Promise.all(allRuns);
}

main();
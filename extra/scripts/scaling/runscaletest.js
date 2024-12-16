/*

Run this to kick off multiple instances of scaletest.js, for use on GCP hardware

Install dependencies:
  npm install uuid puppeteer axios

Usage:
  node runscaletest.js [botsPerProcess] [processes] [namePrefix] [audioVideo]

Parameters:
  botsPerProcess: number of bots per puppeteer process
  processes: number of puppeteer processes to spawn
  namePrefix: first part of identifier for bots, or leave empty or put 'query' to use current gcp instance name
  audioVideo: put 'camera' to simulate camera/mic, else disabled

e.g.:
  node runscaletest.js 5 12
  node runscaletest.js 4 2 mymachine camera
  node runscaletest.js 4 2 query camera

*/

const { spawn } = require('child_process');
const axios = require('axios');

const PER_PROCESS = parseInt(process.argv[2]);
const NUM_PROCESSES = parseInt(process.argv[3]);
const HOST_NAME = process.argv[4];
const USE_CAMERA = process.argv[5];

(async () => {
    let vmname = HOST_NAME;
    if (vmname === null || vmname === "" || vmname === undefined || vmname === "query") {
        const response = await axios.get('http://metadata/computeMetadata/v1/instance/hostname', {
            headers: {
                'Metadata-Flavor': 'Google'
            }
        });
        vmname = response.data.split('.')[0];
    }

    for (let i = 0; i < NUM_PROCESSES; ++i){
        let p = spawn('node', ['scaletest.js', vmname, PER_PROCESS, 'no', i*PER_PROCESS, USE_CAMERA]);
        p.stdout.on('data', (data) => {
            console.log(`stdout: ${data.toString().trim()}`);
        });
        p.stderr.on('data', (data) => {
            console.error(`stderr: ${data.toString().trim()}`);
        });
    }
})();

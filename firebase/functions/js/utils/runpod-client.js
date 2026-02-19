/*
This is a limited purpose RunPod client. Attempting to make use of runpod-sdk in Frankly as one
would expect unfortunately fails on import with ERR_REQUIRE_ESM. The usual workarounds to allow
lazy ESM imports for backward compatibility don't seem to work for runpod-sdk either. In its place,
this is a specialized limited purpose client that supports what's necessary to make transcriptions
requests to the Whisper model invoked by transcribe-recordings.js, rather than a more general
purpose RunPod client.
*/

const functions = require('firebase-functions')
const axios = require('axios')

const apiKey = functions.config().runpod.api_key
const endpointId = functions.config().runpod.endpoint_id
const timeout = 10 * 60 * 1000 // Max timeout allowed by RunPod's API
const wait = 60 * 1000 // Wait period for a status checkin by Frankly

const baseUrl = 'https://api.runpod.ai/v2'
const baseEndpointUrl = `${baseUrl}/${endpointId}`
const baseRunUrl = `${baseEndpointUrl}/runsync`
const baseStatusUrl = `${baseEndpointUrl}/status-sync`

const requestConfig = {
    headers: {
        'Authorization': `Bearer ${apiKey}`,
        'content-type': 'application/json',
        'User-Agent': 'Frankly'
    }
}


const request = async (request) => {
    const startTime = Date.now()
    const remainingTime = () => timeout - (Date.now() - startTime)
    const waitPeriod = () => Math.max(1000, Math.min(wait, remainingTime()))

    console.log(`Initiating the request to RunPod.`)
    const requestUrl = `${baseRunUrl}?wait=${waitPeriod()}`
    let response = await _handleRequest(axios.post(requestUrl, request, requestConfig))

    while (response.running) {
        let secondsRemaining = Math.abs(remainingTime() / 1000)
        if (secondsRemaining <= 0) {
            console.log(`RunPod request ${response.id} timed out after ${secondsRemaining} seconds.`)
            return response
        }
        console.log(`RunPod request ${response.id} still in progress.`)
        console.log(`Seconds remaining before timeout: ${secondsRemaining}.`)

        const statusUrl = `${baseStatusUrl}/${response.id}?wait=${waitPeriod()}`
        response = await _handleRequest(axios.get(statusUrl, requestConfig))
    }

    return response
}

const _handleRequest = async (axiosRequest) => {
    const response = await axiosRequest
    return {
        ...response.data,
        succeeded: response.data.status === 'COMPLETED',
        running: response.data.status === 'IN_PROGRESS',
    }
}

module.exports = request

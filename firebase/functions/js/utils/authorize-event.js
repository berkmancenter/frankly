const admin = require('firebase-admin')
const { HttpsError } = require('firebase-functions/lib/providers/auth')

const firestore = admin.firestore()


const authorizeEvent = async (req, res) => {
    // Fetch the bearer token from the request
    const authToken = req.headers.authorization?.split('Bearer ')[1]
    if (!authToken) {
        throw new HttpsError('unauthorized', 'Unauthorized')
    }

    // Verify the bearer token is valid in Firebase Auth and get the UID
    const decodedToken = await admin.auth().verifyIdToken(authToken)
    const uid = decodedToken.uid

    // Extract the event path from the request body
    const eventPath = req.body['eventPath']
    if (!eventPath) {
        throw new HttpsError('failed-precondition', 'eventPath value not found')
    }
    console.log(`Authorizing user ${uid} for event data at ${eventPath}.`)

    // Fetch the event data
    const eventDoc = await firestore.doc(eventPath).get()
    if (!eventDoc.exists) {
        throw new HttpsError('failed-precondition', 'Event document not found')
    }
    const event = { id: eventDoc.id, ...eventDoc.data() }

    // Fetch the membership data
    const membershipPath = `memberships/${uid}/community-membership/${event.communityId}`
    const membershipDoc = await firestore.doc(membershipPath).get()
    if (!membershipDoc.exists) {
        throw new HttpsError('failed-precondition', 'Community membership document not found')
    }
    const membership = membershipDoc.data()

    // Confirm the user is an owner or admin of the community holding the requested event
    if (!['owner', 'admin'].includes(membership.status)) {
        throw new HttpsError('failed-precondition', 'Unauthorized')
    }

    return event
}

module.exports = authorizeEvent

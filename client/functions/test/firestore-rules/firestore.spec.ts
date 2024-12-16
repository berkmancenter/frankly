/**
 * Main file for testing firestore-rules.
 *
 * Reference taken from https://github.com/firebase/quickstart-testing/tree/master/unit-test-security-rules.
 */

import * as path from 'path'
import { firestore } from 'firebase-admin/lib/firestore'
import { JuntoRulesHelper, Membership } from './firestore-rules-helper'
import 'mocha'

const firebase = require('@firebase/rules-unit-testing')
const fs = require('fs')
const http = require('http')

/**
 * The emulator will accept any project ID for testing.
 */
const PROJECT_ID = 'firestore-emulator-example'

/**
 * The FIRESTORE_EMULATOR_HOST environment variable is set automatically
 * by "firebase emulators:exec"
 */

// Hard-coding path for now since we are running `npm run test`
// More about test report - https://firebase.google.com/docs/rules/emulator-reports
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080'
const COVERAGE_URL = `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}:ruleCoverage.html`

// Fields
const fieldCreatorId = 'creatorId'
const fieldMembershipStatusSnapshot = 'membershipStatusSnapshot'

// Data
const originalDataMap = { someField: 'someValue' }
const updateDataMap = { someField: 'someUpdatedValue' }

// Create a reference for DB Admin
let dbAdmin: firestore.Firestore

/**
 * Creates a new client FirebaseApp with authentication and returns the Firestore instance.
 */
function getAuthedFirestore(userId?: string) {
    return firebase
        .initializeTestApp({
            projectId: PROJECT_ID,
            auth: userId ? { uid: userId } : null,
        })
        .firestore()
}

afterEach(async () => {
    // Clear the database between tests
    await firebase.clearFirestoreData({
        projectId: PROJECT_ID,
    })
})

before(async () => {
    // Load the rules file before the tests begin
    const rules = fs.readFileSync(
        path.join(__dirname, '../', '../', '../', 'firestore', 'firestore.rules'),
        'utf8'
    )
    await firebase.loadFirestoreRules({
        projectId: PROJECT_ID,
        rules,
    })
})

after(async () => {
    // Delete all the FirebaseApp instances created during testing
    // Note: this does not affect or clear any data
    await Promise.all(firebase.apps().map((app) => app.delete()))
    // Write the coverage report to a file
    const coverageFile = 'firestore-coverage.html'
    const fstream = fs.createWriteStream(coverageFile)
    await new Promise((resolve, reject) => {
        http.get(COVERAGE_URL, (res) => {
            res.pipe(fstream, { end: true })

            res.on('end', resolve)
            res.on('error', reject)
        })
    })

    console.log(`View firestore rule coverage information at ${COVERAGE_URL} or ${coverageFile}\n`)
})

describe('Firestore security rules', async () => {
    // For some reason `before` executes semi-after describe, leaving `dbAdmin` not initialised.
    dbAdmin = await firebase.initializeAdminApp({ projectId: PROJECT_ID }).firestore()

    describe('/publicUser/{userId}', () => {
        const collection = 'publicUser'
        const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
            { collection: collection, document: 'alice' },
        ])

        it('not authorized', async () => {
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
            const user = getAuthedFirestore(undefined)
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertFails(userDocRef.get())
            await firebase.assertFails(userDocRef.set(originalDataMap))
            await firebase.assertFails(userDocRef.update(updateDataMap))
            await firebase.assertFails(userDocRef.delete())
        })

        it('authorized, same id', async () => {
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
            const user = getAuthedFirestore('alice')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertSucceeds(userDocRef.get())
            await firebase.assertSucceeds(userDocRef.set(originalDataMap))
            await firebase.assertSucceeds(userDocRef.update(originalDataMap))
            await firebase.assertSucceeds(userDocRef.delete())
        })

        it('authorized, different id', async () => {
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
            const user = getAuthedFirestore('bob')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertSucceeds(userDocRef.get())
            await firebase.assertFails(userDocRef.set(originalDataMap))
            await firebase.assertFails(userDocRef.update(originalDataMap))
            await firebase.assertFails(userDocRef.delete())
        })

        it('authorized, updating with same appRole', async () => {
            const adminRoleDataMap = { appRole: 'owner', otherField: 'otherValue' }
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap)

            const user = getAuthedFirestore('alice')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertSucceeds(userDocRef.get())
            await firebase.assertSucceeds(userDocRef.update(adminRoleDataMap))
            await firebase.assertSucceeds(userDocRef.delete())
        })

        it('authorized, updating with different appRole', async () => {
            const adminRoleDataMap = { appRole: 'user', otherField: 'otherValue' }
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap)

            const user = getAuthedFirestore('alice')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertSucceeds(userDocRef.get())
            await firebase.assertFails(
                userDocRef.update({ appRole: 'owner', otherField: 'otherValue' })
            )
            await firebase.assertSucceeds(userDocRef.delete())
        })
    })

    describe('/privateUserData/{userId}', () => {
        const colPrivateUserData = 'privateUserData'
        const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
            { collection: colPrivateUserData, document: 'alice' },
        ])

        beforeEach(async () => {
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
        })

        it('not authorized', async () => {
            const user = getAuthedFirestore(undefined)
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertFails(userDocRef.get())
            await firebase.assertFails(userDocRef.set(originalDataMap))
            await firebase.assertFails(userDocRef.update(updateDataMap))
            await firebase.assertFails(userDocRef.delete())
        })

        it('authorized, same id', async () => {
            const user = getAuthedFirestore('alice')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertSucceeds(userDocRef.get())
            await firebase.assertSucceeds(userDocRef.set(originalDataMap))
            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
            await firebase.assertSucceeds(userDocRef.delete())
        })

        it('authorized, different id', async () => {
            const user = getAuthedFirestore('bob')
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertFails(userDocRef.get())
            await firebase.assertFails(userDocRef.set(originalDataMap))
            await firebase.assertFails(userDocRef.update(updateDataMap))
            await firebase.assertFails(userDocRef.delete())
        })

        describe('/juntoUserSettings/{juntoId}', () => {
            const colJuntoUserSettings = 'juntoUserSettings'
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                {
                    collection: colPrivateUserData,
                    document: 'alice',
                },
                {
                    collection: colJuntoUserSettings,
                    document: 'alice2',
                },
            ])

            beforeEach(async () => {
                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
            })

            it('not authorized', async () => {
                const user = getAuthedFirestore(undefined)
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await firebase.assertFails(userColRef.add(originalDataMap))
                await firebase.assertFails(userDocRef.get())
                await firebase.assertFails(userDocRef.set(originalDataMap))
                await firebase.assertFails(userDocRef.update(updateDataMap))
                await firebase.assertFails(userDocRef.delete())
            })

            it('authorized, same id', async () => {
                const user = getAuthedFirestore('alice')
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await firebase.assertSucceeds(userColRef.add(originalDataMap))
                await firebase.assertSucceeds(userDocRef.get())
                await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                await firebase.assertSucceeds(userDocRef.delete())
            })

            it('authorized, different id', async () => {
                const user = getAuthedFirestore('bob')
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await firebase.assertFails(userColRef.add(originalDataMap))
                await firebase.assertFails(userDocRef.get())
                await firebase.assertFails(userDocRef.set(originalDataMap))
                await firebase.assertFails(userDocRef.update(updateDataMap))
                await firebase.assertFails(userDocRef.delete())
            })
        })
    })

    describe('/junto/{juntoId}', () => {
        const collectionJunto = 'junto'
        const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
            { collection: collectionJunto, document: 'juntoId' },
        ])

        beforeEach(async () => {
            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
        })

        it('not authorized', async () => {
            const user = getAuthedFirestore(undefined)
            const userColRef = juntoRulesHelper.getCollectionRef(user)
            const userDocRef = juntoRulesHelper.getDocumentRef(user)

            await firebase.assertFails(userColRef.add(originalDataMap))
            await firebase.assertFails(userDocRef.get())
            await firebase.assertFails(userDocRef.set(originalDataMap))
            await firebase.assertFails(userDocRef.update(updateDataMap))
            await firebase.assertFails(userDocRef.delete())
        })

        describe('authorized reader', async () => {
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                { collection: collectionJunto, document: 'juntoId' },
            ])

            it('create', async () => {
                const user = getAuthedFirestore('alice')
                const userColRef = juntoRulesHelper.getCollectionRef(user)

                // Trying to add a document without `creatorId` being the owner
                await firebase.assertFails(userColRef.add(originalDataMap))

                // Trying to add a document with `creatorId` being the owner
                await firebase.assertFails(userColRef.add({ [fieldCreatorId]: 'alice' }))
            })

            it('get', async () => {
                const user = getAuthedFirestore('alice')
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await firebase.assertSucceeds(userDocRef.get())
            })

            it('update', async () => {
                const user = getAuthedFirestore('alice')
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'value' })

                for (const membership of Object.keys(Membership)) {
                    await juntoRulesHelper.createMembership('alice', membership)
                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                        case Membership.facilitator:
                        case Membership.member:
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            break
                    }
                }
            })

            it('delete', async () => {
                const user = getAuthedFirestore('alice')
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'value' })

                await firebase.assertFails(userDocRef.delete())
            })
        })

        describe('/chats/{messageId=**}', () => {
            const collectionChats = 'chats'
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                { collection: collectionJunto, document: 'juntoId' },
                { collection: collectionChats, document: 'messageId' },
            ])

            describe('authorized', () => {
                const user = getAuthedFirestore('alice')
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                beforeEach(async () => {
                    await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                })

                it('isDocCreator', async () => {
                    await juntoRulesHelper.makeDocCreator('alice')

                    async function testDifferentMembership(membership: string) {
                        await juntoRulesHelper.createMembership('alice', membership)

                        // Currently there is no influence based on membership rule. But in the future there might be
                        // so leaving this switch for now more convenience.
                        switch (membership) {
                            case Membership.owner:
                            case Membership.admin:
                            case Membership.mod:
                            case Membership.facilitator:
                            case Membership.member:
                            case Membership.nonmember:
                            case Membership.attendee:
                                await firebase.assertSucceeds(
                                    userDocRef.set({
                                        [fieldCreatorId]: 'alice',
                                        someKey: 'someValue',
                                    })
                                )
                                // Merging to keep `creatorId` set.
                                await firebase.assertSucceeds(
                                    userDocRef.set(originalDataMap, { merge: true })
                                )
                                await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                        }
                    }

                    for (const membership of Object.keys(Membership)) {
                        await testDifferentMembership(membership)
                    }
                })

                it('not docCreator but mod', async () => {
                    await juntoRulesHelper.makeDocCreator('bob')

                    async function testDifferentMembership(membership: string) {
                        await juntoRulesHelper.createMembership('alice', membership)

                        switch (membership) {
                            case Membership.owner:
                            case Membership.admin:
                            case Membership.mod:
                                await firebase.assertSucceeds(
                                    userDocRef.set({
                                        [fieldCreatorId]: 'bob',
                                        someKey: 'someValue',
                                    })
                                )
                                // Merging to keep `creatorId` set.
                                await firebase.assertSucceeds(
                                    userDocRef.set(originalDataMap, { merge: true })
                                )
                                await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                            case Membership.facilitator:
                            case Membership.member:
                            case Membership.nonmember:
                            case Membership.attendee:
                                await firebase.assertFails(
                                    userDocRef.set({
                                        [fieldCreatorId]: 'bob',
                                        someKey: 'someValue',
                                    })
                                )
                                // Merging to keep `creatorId` set.
                                await firebase.assertFails(
                                    userDocRef.set(originalDataMap, { merge: true })
                                )
                                await firebase.assertFails(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                        }
                    }

                    for (const membership of Object.keys(Membership)) {
                        await testDifferentMembership(membership)
                    }
                })
            })

            it('not authorized', async () => {
                const user = getAuthedFirestore('bob')
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                await juntoRulesHelper.makeDocCreator('alice')

                async function testDifferentMembership(membership: string) {
                    await juntoRulesHelper.createMembership('alice', membership)

                    // Currently there is no influence based on membership rule. But in the future there might be
                    // so leaving this switch for now more convenience.
                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                        case Membership.facilitator:
                        case Membership.member:
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(
                                userDocRef.set({
                                    [fieldCreatorId]: 'alice',
                                    someKey: 'someValue',
                                })
                            )
                            // Merging to keep `creatorId` set.
                            await firebase.assertFails(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                    }
                }

                for (const membership of Object.keys(Membership)) {
                    await testDifferentMembership(membership)
                }
            })
        })

        describe('/featured/{featuredId=**}', () => {
            const collectionFeatured = 'featured'
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                { collection: collectionJunto, document: 'juntoId' },
                { collection: collectionFeatured, document: 'featuredId' },
            ])

            describe('authorized', () => {
                beforeEach(async () => {
                    await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                })

                it('isJuntoAdmin', async () => {
                    const user = getAuthedFirestore('alice')
                    const userColRef = juntoRulesHelper.getCollectionRef(user)
                    const userDocRef = juntoRulesHelper.getDocumentRef(user)

                    async function testDifferentMembership(membership: string) {
                        await juntoRulesHelper.createMembership('alice', membership)

                        switch (membership) {
                            case Membership.owner:
                            case Membership.admin:
                                await firebase.assertSucceeds(userColRef.add(originalDataMap))
                                await firebase.assertSucceeds(userDocRef.get())
                                await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                                await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                await firebase.assertSucceeds(userDocRef.delete())
                                break
                            case Membership.mod:
                            case Membership.facilitator:
                            case Membership.member:
                            case Membership.nonmember:
                            case Membership.attendee:
                                await firebase.assertFails(userColRef.add(originalDataMap))
                                await firebase.assertSucceeds(userDocRef.get())
                                await firebase.assertFails(userDocRef.set(originalDataMap))
                                await firebase.assertFails(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                        }
                    }

                    for (const membership of Object.keys(Membership)) {
                        await testDifferentMembership(membership)
                    }
                })
            })

            it('not authorized', async () => {
                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)

                const user = getAuthedFirestore('bob')
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                async function testDifferentMembership(membership: string) {
                    await juntoRulesHelper.createMembership('alice', membership)

                    // Currently there is no influence based on membership rule. But in the future there might be
                    // so leaving this switch for now more convenience.
                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                        case Membership.facilitator:
                        case Membership.member:
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(userDocRef.set(originalDataMap))
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                    }
                }

                for (const membership of Object.keys(Membership)) {
                    await testDifferentMembership(membership)
                }
            })
        })

        describe('/announcements/{announcementId}', () => {
            const collectionAnnouncements = 'announcements'
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                { collection: collectionJunto, document: 'juntoId' },
                { collection: collectionAnnouncements, document: 'announcementId' },
            ])

            describe('authorized', () => {
                beforeEach(async () => {
                    await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                })

                it('isJuntoAdmin', async () => {
                    const user = getAuthedFirestore('alice')
                    const userColRef = juntoRulesHelper.getCollectionRef(user)
                    const userDocRef = juntoRulesHelper.getDocumentRef(user)

                    async function testDifferentMembership(membership: string) {
                        await juntoRulesHelper.createMembership('alice', membership)

                        switch (membership) {
                            case Membership.owner:
                            case Membership.admin:
                                await firebase.assertFails(userColRef.add(originalDataMap))
                                await firebase.assertSucceeds(
                                    userColRef.add({
                                        [fieldCreatorId]: 'alice',
                                        someKey: 'someValue',
                                    })
                                )
                                await firebase.assertSucceeds(userDocRef.get())
                                await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                                await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                            case Membership.mod:
                            case Membership.facilitator:
                            case Membership.member:
                            case Membership.nonmember:
                            case Membership.attendee:
                                await firebase.assertFails(userColRef.add(originalDataMap))
                                await firebase.assertFails(
                                    userColRef.add({
                                        [fieldCreatorId]: 'alice',
                                        someKey: 'someValue',
                                    })
                                )
                                await firebase.assertSucceeds(userDocRef.get())
                                await firebase.assertFails(userDocRef.set(originalDataMap))
                                await firebase.assertFails(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                        }
                    }

                    for (const membership of Object.keys(Membership)) {
                        await testDifferentMembership(membership)
                    }
                })
            })

            it('not authorized', async () => {
                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)

                const user = getAuthedFirestore(undefined)
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                async function testDifferentMembership(membership: string) {
                    // Currently there is no influence based on membership rule. But in the future there might be
                    // so leaving this switch for now more convenience.
                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                        case Membership.facilitator:
                        case Membership.member:
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(
                                userColRef.add({
                                    [fieldCreatorId]: null,
                                    someKey: 'someValue',
                                })
                            )
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertFails(userDocRef.set(originalDataMap))
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                    }
                }

                for (const membership of Object.keys(Membership)) {
                    await testDifferentMembership(membership)
                }
            })
        })

        describe('/topics/{topicId}', () => {
            const collectionTopics = 'topics'
            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                { collection: collectionJunto, document: 'juntoId' },
                { collection: collectionTopics, document: 'topicId' },
            ])
            it('authorized', async () => {
                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)

                const user = getAuthedFirestore('alice')
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                async function testDifferentMembership(membership: string) {
                    await juntoRulesHelper.createMembership('alice', membership)

                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(
                                userColRef.add({
                                    [fieldCreatorId]: 'alice',
                                    someKey: 'someValue',
                                })
                            )
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                        case Membership.facilitator:
                        case Membership.member:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(
                                userColRef.add({
                                    [fieldCreatorId]: 'alice',
                                    someKey: 'someValue',
                                })
                            )
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(
                                userColRef.add({
                                    [fieldCreatorId]: 'alice',
                                    someKey: 'someValue',
                                })
                            )
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                    }
                }

                for (const membership of Object.keys(Membership)) {
                    await testDifferentMembership(membership)
                }
            })

            it('not authorized', async () => {
                await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)

                const user = getAuthedFirestore(undefined)
                const userColRef = juntoRulesHelper.getCollectionRef(user)
                const userDocRef = juntoRulesHelper.getDocumentRef(user)

                async function testDifferentMembership(membership: string) {
                    switch (membership) {
                        case Membership.owner:
                        case Membership.admin:
                        case Membership.mod:
                        case Membership.facilitator:
                        case Membership.member:
                        case Membership.nonmember:
                        case Membership.attendee:
                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(
                                userColRef.add({
                                    [fieldCreatorId]: null,
                                    someKey: 'someValue',
                                })
                            )
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                            break
                    }
                }

                for (const membership of Object.keys(Membership)) {
                    await testDifferentMembership(membership)
                }
            })

            describe('/discussions/{discussionId}', () => {
                const collectionDiscussions = 'discussions'
                const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                    { collection: collectionJunto, document: 'juntoId' },
                    { collection: collectionTopics, document: 'topicId' },
                    { collection: collectionDiscussions, document: 'discussionId' },
                ])

                beforeEach(async () => {
                    await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                })

                describe('authorized', () => {
                    it('isDocCreator', async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set({
                            [fieldCreatorId]: 'alice',
                            someKey: 'someValue',
                        })

                        const user = getAuthedFirestore('alice')
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        async function testDifferentMembership(membership: string) {
                            await juntoRulesHelper.createMembership('alice', membership)

                            switch (membership) {
                                case Membership.owner:
                                case Membership.admin:
                                case Membership.mod:
                                case Membership.facilitator:
                                case Membership.member:
                                case Membership.nonmember:
                                case Membership.attendee:
                                    await firebase.assertFails(userColRef.add(originalDataMap))
                                    await firebase.assertSucceeds(
                                        userColRef.add({
                                            [fieldCreatorId]: 'alice',
                                            someKey: 'someValue',
                                        })
                                    )
                                    await firebase.assertSucceeds(userDocRef.get())
                                    await firebase.assertSucceeds(
                                        userDocRef.set(originalDataMap, { merge: true })
                                    )
                                    await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                    await firebase.assertFails(userDocRef.delete())
                                    break
                            }
                        }

                        for (const membership of Object.keys(Membership)) {
                            await testDifferentMembership(membership)
                        }
                    })
                    it('!isDocCreator', async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set({
                            [fieldCreatorId]: 'alice',
                            someKey: 'someValue',
                        })

                        const user = getAuthedFirestore('bob')
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        async function testDifferentMembership(membership: string) {
                            await juntoRulesHelper.createMembership('bob', membership)

                            switch (membership) {
                                case Membership.owner:
                                case Membership.admin:
                                case Membership.mod:
                                    await firebase.assertFails(userColRef.add(originalDataMap))
                                    await firebase.assertSucceeds(
                                        userColRef.add({
                                            [fieldCreatorId]: 'bob',
                                            someKey: 'someValue',
                                        })
                                    )
                                    await firebase.assertSucceeds(userDocRef.get())
                                    await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                    await firebase.assertSucceeds(
                                        userDocRef.set(originalDataMap, { merge: true })
                                    )
                                    await firebase.assertFails(userDocRef.delete())
                                    break
                                case Membership.facilitator:
                                case Membership.member:
                                case Membership.nonmember:
                                case Membership.attendee:
                                    await firebase.assertFails(userColRef.add(originalDataMap))
                                    await firebase.assertSucceeds(
                                        userColRef.add({
                                            [fieldCreatorId]: 'bob',
                                            someKey: 'someValue',
                                        })
                                    )
                                    await firebase.assertSucceeds(userDocRef.get())
                                    await firebase.assertFails(
                                        userDocRef.set(originalDataMap, { merge: true })
                                    )
                                    await firebase.assertFails(userDocRef.update(updateDataMap))
                                    await firebase.assertFails(userDocRef.delete())
                                    break
                            }
                        }

                        for (const membership of Object.keys(Membership)) {
                            await testDifferentMembership(membership)
                        }
                    })
                    describe('update', async () => {
                        it('isDocCreator', async () => {
                            const user = getAuthedFirestore('alice')
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await juntoRulesHelper.getDocumentRef(dbAdmin).set({
                                [fieldCreatorId]: 'alice',
                                someKey: 'someValue',
                            })

                            async function testDifferentMembership(membership: string) {
                                await juntoRulesHelper.createMembership('alice', membership)

                                switch (membership) {
                                    case Membership.owner:
                                    case Membership.admin:
                                    case Membership.mod:
                                    case Membership.facilitator:
                                    case Membership.member:
                                    case Membership.nonmember:
                                    case Membership.attendee:
                                        await firebase.assertSucceeds(
                                            userDocRef.set(originalDataMap, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.update(updateDataMap)
                                        )
                                        break
                                }
                            }

                            for (const membership of Object.keys(Membership)) {
                                await testDifferentMembership(membership)
                            }
                        })

                        it('isJuntoMod', async () => {
                            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                            const user = getAuthedFirestore('alice')
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            async function testDifferentMembership(membership: string) {
                                await juntoRulesHelper.createMembership('alice', membership)

                                switch (membership) {
                                    case Membership.owner:
                                    case Membership.admin:
                                    case Membership.mod:
                                        await firebase.assertSucceeds(
                                            userDocRef.set(originalDataMap, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.update(updateDataMap)
                                        )
                                        break
                                    case Membership.facilitator:
                                    case Membership.member:
                                    case Membership.nonmember:
                                    case Membership.attendee:
                                        await firebase.assertFails(
                                            userDocRef.set(originalDataMap, { merge: true })
                                        )
                                        await firebase.assertFails(userDocRef.update(updateDataMap))
                                        break
                                }
                            }

                            for (const membership of Object.keys(Membership)) {
                                await testDifferentMembership(membership)
                            }
                        })

                        it('juntoId - unify-america', async () => {
                            const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                                { collection: collectionJunto, document: 'unify-america' },
                                { collection: collectionTopics, document: 'topicId' },
                                { collection: collectionDiscussions, document: 'discussionId' },
                            ])

                            await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)

                            await firebase.assertSucceeds(
                                juntoRulesHelper
                                    .getDocumentRef(getAuthedFirestore(undefined))
                                    .update(updateDataMap)
                            )
                            await firebase.assertSucceeds(
                                juntoRulesHelper
                                    .getDocumentRef(getAuthedFirestore('alice'))
                                    .update(updateDataMap)
                            )
                        })
                    })
                })
                it('is not authorized', async () => {
                    await juntoRulesHelper.getDocumentRef(dbAdmin).set({
                        [fieldCreatorId]: null,
                        someKey: 'someValue',
                    })

                    const user = getAuthedFirestore(undefined)
                    const userColRef = juntoRulesHelper.getCollectionRef(user)
                    const userDocRef = juntoRulesHelper.getDocumentRef(user)

                    async function testDifferentMembership(membership: string) {
                        switch (membership) {
                            case Membership.owner:
                            case Membership.admin:
                            case Membership.mod:
                            case Membership.facilitator:
                            case Membership.member:
                            case Membership.nonmember:
                            case Membership.attendee:
                                await firebase.assertFails(userColRef.add(originalDataMap))
                                await firebase.assertFails(
                                    userColRef.add({
                                        [fieldCreatorId]: 'alice',
                                        someKey: 'someValue',
                                    })
                                )
                                await firebase.assertFails(userDocRef.get())
                                await firebase.assertFails(
                                    userDocRef.set(originalDataMap, { merge: true })
                                )
                                await firebase.assertFails(userDocRef.update(updateDataMap))
                                await firebase.assertFails(userDocRef.delete())
                                break
                        }
                    }

                    for (const membership of Object.keys(Membership)) {
                        await testDifferentMembership(membership)
                    }
                })

                describe('/discussion-participants/{participantId}', () => {
                    const collectionDiscussionsParticipants = 'discussion-participants'
                    const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                        { collection: collectionJunto, document: 'juntoId' },
                        { collection: collectionTopics, document: 'topicId' },
                        { collection: collectionDiscussions, document: 'discussionId' },
                        {
                            collection: collectionDiscussionsParticipants,
                            document: 'discussionParticipantId',
                        },
                    ])

                    beforeEach(async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                    })

                    it('different membership', async () => {
                        const user = getAuthedFirestore('alice')
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        async function testDifferentMembership(membership: string) {
                            await juntoRulesHelper.createMembership('alice', membership)

                            switch (membership) {
                                case Membership.owner:
                                case Membership.admin:
                                case Membership.mod:
                                    await firebase.assertSucceeds(userColRef.add(originalDataMap))
                                    await firebase.assertSucceeds(userDocRef.get())
                                    await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                                    await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                                    await firebase.assertSucceeds(userDocRef.delete())
                                    break
                                case Membership.facilitator:
                                case Membership.member:
                                case Membership.nonmember:
                                case Membership.attendee:
                                    await firebase.assertFails(userColRef.add(originalDataMap))
                                    await firebase.assertSucceeds(userDocRef.get())
                                    await firebase.assertFails(userDocRef.set(originalDataMap))
                                    await firebase.assertFails(userDocRef.update(updateDataMap))
                                    await firebase.assertFails(userDocRef.delete())
                                    break
                            }
                        }

                        for (const membership of Object.keys(Membership)) {
                            await testDifferentMembership(membership)
                        }
                    })
                    it('isDocCreator', async () => {
                        // When we are in discussion-participants collection, we check ownership of previous
                        // collection (discussion). Very important not to mix it.
                        const discussionsHelper = new JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionTopics, document: 'topicId' },
                            { collection: collectionDiscussions, document: 'discussionId' },
                        ])
                        await discussionsHelper.makeDocCreator('alice')

                        await juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'someValue' })
                        await juntoRulesHelper.createMembership('alice', 'nonmember')

                        const user = getAuthedFirestore('alice')
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        await firebase.assertSucceeds(userColRef.add(originalDataMap))
                        await firebase.assertSucceeds(userDocRef.get())
                        await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                        await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                        await firebase.assertSucceeds(userDocRef.delete())
                    })

                    describe('request by uid', () => {
                        it('request by same user', async () => {
                            const user = getAuthedFirestore('discussionParticipantId')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertSucceeds(userDocRef.set(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertSucceeds(userDocRef.delete())
                        })
                        it('request by different user', async () => {
                            const user = getAuthedFirestore('bob')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(userDocRef.set(originalDataMap))
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })
                    })

                    it('!isLiveStream', async () => {
                        // Only applicable to `get` but testing through more cases just in case.
                        // `liveStreamInfo` must be null (in `discussions` collection) in order `get` to succeed.
                        const discussionsHelper = new JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionTopics, document: 'topicId' },
                            { collection: collectionDiscussions, document: 'discussionId' },
                        ])
                        await discussionsHelper.updateDocumentsField({ liveStreamInfo: null })

                        await juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'someValue' })

                        const user = getAuthedFirestore('alice')
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        await firebase.assertFails(userColRef.add(originalDataMap))
                        await firebase.assertSucceeds(userDocRef.get())
                        await firebase.assertFails(userDocRef.set(originalDataMap))
                        await firebase.assertFails(userDocRef.update(updateDataMap))
                        await firebase.assertFails(userDocRef.delete())
                    })
                })

                describe('/chats/{messageId=**}', () => {
                    const collectionChats = 'chats'
                    const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                        { collection: collectionJunto, document: 'juntoId' },
                        { collection: collectionTopics, document: 'topicId' },
                        { collection: collectionDiscussions, document: 'discussionId' },
                        { collection: collectionChats, document: 'messageId' },
                    ])

                    beforeEach(async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                    })

                    describe('authorized', () => {
                        it('only authorized', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(userColRef.add({ creatorId: 'alice' }))
                            await firebase.assertFails(userColRef.add({ creatorId: 'bob' }))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertFails(userDocRef.set(originalDataMap))
                            await firebase.assertFails(userDocRef.set({ creatorId: 'alice' }))
                            await firebase.assertFails(userDocRef.set({ creatorId: 'bob' }))
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('isParticipant', async () => {
                            await juntoRulesHelper.makeParticipant(
                                'juntoId',
                                'topicId',
                                'discussionId',
                                'alice'
                            )
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertSucceeds(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set({ creatorId: 'alice' }, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('isDocCreator', async () => {
                            await juntoRulesHelper.makeDocCreator('alice')
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('different membership', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            async function testDifferentMembership(membership: string) {
                                await juntoRulesHelper.createMembership('alice', membership)

                                switch (membership) {
                                    case Membership.owner:
                                    case Membership.admin:
                                    case Membership.mod:
                                        await firebase.assertSucceeds(
                                            userColRef.add(originalDataMap)
                                        )
                                        await firebase.assertSucceeds(userDocRef.get())
                                        await firebase.assertSucceeds(
                                            userDocRef.set(originalDataMap)
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.update(updateDataMap)
                                        )
                                        await firebase.assertFails(userDocRef.delete())
                                        break
                                    case Membership.facilitator:
                                    case Membership.member:
                                    case Membership.nonmember:
                                    case Membership.attendee:
                                        await firebase.assertFails(userColRef.add(originalDataMap))
                                        await firebase.assertFails(
                                            userColRef.add({ creatorId: 'alice' })
                                        )
                                        await firebase.assertFails(
                                            userColRef.add({ creatorId: 'bob' })
                                        )
                                        await firebase.assertFails(userDocRef.get())
                                        await firebase.assertFails(userDocRef.set(originalDataMap))
                                        await firebase.assertFails(
                                            userDocRef.set({ creatorId: 'alice' })
                                        )
                                        await firebase.assertFails(
                                            userDocRef.set({ creatorId: 'bob' })
                                        )
                                        await firebase.assertFails(userDocRef.update(updateDataMap))
                                        await firebase.assertFails(userDocRef.delete())
                                        break
                                }
                            }

                            for (const membership of Object.keys(Membership)) {
                                await testDifferentMembership(membership)
                            }
                        })
                    })

                    it('not authorized', async () => {
                        const user = getAuthedFirestore(undefined)
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        await firebase.assertFails(userColRef.add(originalDataMap))
                        await firebase.assertFails(userDocRef.get())
                        await firebase.assertFails(userDocRef.set(originalDataMap))
                        await firebase.assertFails(userDocRef.update(updateDataMap))
                        await firebase.assertFails(userDocRef.delete())
                    })
                })

                describe('/discussion-messages/{discussionMessageId}', () => {
                    const collectionMessages = 'discussion-messages'
                    const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                        { collection: collectionJunto, document: 'juntoId' },
                        { collection: collectionTopics, document: 'topicId' },
                        { collection: collectionDiscussions, document: 'discussionId' },
                        { collection: collectionMessages, document: 'discussionMessageId' },
                    ])

                    beforeEach(async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                    })

                    describe('authorized', () => {
                        it('only authorized', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(userColRef.add({ creatorId: 'alice' }))
                            await firebase.assertFails(userColRef.add({ creatorId: 'bob' }))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertFails(userDocRef.set(originalDataMap))
                            await firebase.assertFails(userDocRef.set({ creatorId: 'alice' }))
                            await firebase.assertFails(userDocRef.set({ creatorId: 'bob' }))
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('isParticipant', async () => {
                            await juntoRulesHelper.makeParticipant(
                                'juntoId',
                                'topicId',
                                'discussionId',
                                'alice'
                            )
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set({ creatorId: 'alice' }, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('isDocCreator', async () => {
                            await juntoRulesHelper.makeDocCreator('alice')
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertFails(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertFails(userDocRef.update(updateDataMap))
                            await firebase.assertSucceeds(userDocRef.delete())
                        })
                    })

                    it('not authorized', async () => {
                        const user = getAuthedFirestore(undefined)
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        await firebase.assertFails(userColRef.add(originalDataMap))
                        await firebase.assertFails(userDocRef.get())
                        await firebase.assertFails(userDocRef.set(originalDataMap))
                        await firebase.assertFails(userDocRef.update(updateDataMap))
                        await firebase.assertFails(userDocRef.delete())
                    })
                })

                describe('/user-suggestions/{suggestionId=**}', () => {
                    const collectionUserSuggestions = 'user-suggestions'
                    const juntoRulesHelper = new JuntoRulesHelper(dbAdmin, [
                        { collection: collectionJunto, document: 'juntoId' },
                        { collection: collectionTopics, document: 'topicId' },
                        { collection: collectionDiscussions, document: 'discussionId' },
                        { collection: collectionUserSuggestions, document: 'suggestionId' },
                    ])

                    beforeEach(async () => {
                        await juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)
                    })

                    describe('authorized', () => {
                        it('only authorized', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add({ creatorId: 'alice' }))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('isDocCreator', async () => {
                            await juntoRulesHelper.makeDocCreator('alice')
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add(originalDataMap))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertSucceeds(userDocRef.delete())
                        })

                        it('isParticipant', async () => {
                            await juntoRulesHelper.makeParticipant(
                                'juntoId',
                                'topicId',
                                'discussionId',
                                'alice'
                            )
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertSucceeds(userColRef.add({ creatorId: 'alice' }))
                            await firebase.assertSucceeds(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('!isParticipant', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            await firebase.assertFails(userColRef.add({ creatorId: 'alice' }))
                            await firebase.assertFails(userDocRef.get())
                            await firebase.assertSucceeds(
                                userDocRef.set(originalDataMap, { merge: true })
                            )
                            await firebase.assertSucceeds(userDocRef.update(updateDataMap))
                            await firebase.assertFails(userDocRef.delete())
                        })

                        it('different membership', async () => {
                            const user = getAuthedFirestore('alice')
                            const userColRef = juntoRulesHelper.getCollectionRef(user)
                            const userDocRef = juntoRulesHelper.getDocumentRef(user)

                            async function testDifferentMembership(membership: string) {
                                await juntoRulesHelper.createMembership('alice', membership)

                                switch (membership) {
                                    case Membership.owner:
                                    case Membership.admin:
                                    case Membership.mod:
                                        await firebase.assertSucceeds(
                                            userColRef.add({ creatorId: 'alice' })
                                        )
                                        await firebase.assertFails(
                                            userColRef.add({ creatorId: 'bob' })
                                        )
                                        await firebase.assertSucceeds(userDocRef.get())
                                        await firebase.assertSucceeds(
                                            userDocRef.set({ creatorId: 'alice' }, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.set({ creatorId: 'bob' }, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.update(updateDataMap)
                                        )
                                        await firebase.assertSucceeds(userDocRef.delete())
                                        break
                                    case Membership.facilitator:
                                    case Membership.member:
                                    case Membership.nonmember:
                                    case Membership.attendee:
                                        await firebase.assertFails(
                                            userColRef.add({ creatorId: 'alice' })
                                        )
                                        await firebase.assertFails(
                                            userColRef.add({ creatorId: 'bob' })
                                        )
                                        await firebase.assertFails(userColRef.add(originalDataMap))
                                        await firebase.assertFails(userDocRef.get())
                                        await firebase.assertSucceeds(
                                            userDocRef.set({ creatorId: 'alice' }, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.set({ creatorId: 'bob' }, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.set({ creatorId: null }, { merge: true })
                                        )
                                        await firebase.assertSucceeds(
                                            userDocRef.update(updateDataMap)
                                        )
                                        await firebase.assertFails(userDocRef.delete())
                                        break
                                }
                            }

                            for (const membership of Object.keys(Membership)) {
                                await testDifferentMembership(membership)
                            }
                        })
                    })

                    it('not authorized', async () => {
                        const user = getAuthedFirestore(undefined)
                        const userColRef = juntoRulesHelper.getCollectionRef(user)
                        const userDocRef = juntoRulesHelper.getDocumentRef(user)

                        await firebase.assertFails(userColRef.add(originalDataMap))
                        await firebase.assertFails(userDocRef.get())
                        await firebase.assertFails(userDocRef.set(originalDataMap))
                        await firebase.assertFails(userDocRef.update(updateDataMap))
                        await firebase.assertFails(userDocRef.delete())
                    })
                })
            })
        })
    })
})

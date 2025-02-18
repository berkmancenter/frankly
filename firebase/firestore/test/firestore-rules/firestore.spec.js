"use strict";
/**
 * Main file for testing firestore-rules.
 *
 * Reference taken from https://github.com/firebase/quickstart-testing/tree/master/unit-test-security-rules.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const path = __importStar(require("path"));
const firestore_rules_helper_1 = require("./firestore-rules-helper");
require("mocha");
const firebase = require("@firebase/rules-unit-testing");
const fs = require("fs");
const http = require("http");
/**
 * The emulator will accept any project ID for testing.
 */
const PROJECT_ID = "firestore-emulator-example";
/**
 * The FIRESTORE_EMULATOR_HOST environment variable is set automatically
 * by "firebase emulators:exec"
 */
// Hard-coding path for now since we are running `npm run test`
// More about test report - https://firebase.google.com/docs/rules/emulator-reports
process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";
const COVERAGE_URL = `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}:ruleCoverage.html`;
// Fields
const fieldCreatorId = "creatorId";
const fieldMembershipStatusSnapshot = "membershipStatusSnapshot";
// Data
const originalDataMap = { someField: "someValue" };
const updateDataMap = { someField: "someUpdatedValue" };
// Create a reference for DB Admin
let dbAdmin;
/**
 * Creates a new client FirebaseApp with authentication and returns the Firestore instance.
 */
function getAuthedFirestore(userId) {
    return firebase
        .initializeTestApp({
        projectId: PROJECT_ID,
        auth: userId ? { uid: userId } : null,
    })
        .firestore();
}
afterEach(() => __awaiter(void 0, void 0, void 0, function* () {
    // Clear the database between tests
    yield firebase.clearFirestoreData({
        projectId: PROJECT_ID,
    });
}));
before(() => __awaiter(void 0, void 0, void 0, function* () {
    // Load the rules file before the tests begin
    const rules = fs.readFileSync(path.join(__dirname, "../", "../", "../", "firestore", "firestore.rules"), "utf8");
    yield firebase.loadFirestoreRules({
        projectId: PROJECT_ID,
        rules,
    });
}));
after(() => __awaiter(void 0, void 0, void 0, function* () {
    // Delete all the FirebaseApp instances created during testing
    // Note: this does not affect or clear any data
    yield Promise.all(firebase.apps().map((app) => app.delete()));
    // Write the coverage report to a file
    const coverageFile = "firestore-coverage.html";
    const fstream = fs.createWriteStream(coverageFile);
    yield new Promise((resolve, reject) => {
        http.get(COVERAGE_URL, (res) => {
            res.pipe(fstream, { end: true });
            res.on("end", resolve);
            res.on("error", reject);
        });
    });
    console.log(`View firestore rule coverage information at ${COVERAGE_URL} or ${coverageFile}\n`);
}));
describe("Firestore security rules", () => __awaiter(void 0, void 0, void 0, function* () {
    // For some reason `before` executes semi-after describe, leaving `dbAdmin` not initialised.
    dbAdmin = yield firebase
        .initializeAdminApp({ projectId: PROJECT_ID })
        .firestore();
    describe("/publicUser/{userId}", () => {
        const collection = "publicUser";
        const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
            { collection: collection, document: "alice" },
        ]);
        it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
            const user = getAuthedFirestore(undefined);
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertFails(userDocRef.get());
            yield firebase.assertFails(userDocRef.set(originalDataMap));
            yield firebase.assertFails(userDocRef.update(updateDataMap));
            yield firebase.assertFails(userDocRef.delete());
        }));
        it("authorized, same id", () => __awaiter(void 0, void 0, void 0, function* () {
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
            const user = getAuthedFirestore("alice");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.get());
            yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.update(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.delete());
        }));
        it("authorized, different id", () => __awaiter(void 0, void 0, void 0, function* () {
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
            const user = getAuthedFirestore("bob");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.get());
            yield firebase.assertFails(userDocRef.set(originalDataMap));
            yield firebase.assertFails(userDocRef.update(originalDataMap));
            yield firebase.assertFails(userDocRef.delete());
        }));
        it("authorized, updating with same appRole", () => __awaiter(void 0, void 0, void 0, function* () {
            const adminRoleDataMap = { appRole: "owner", otherField: "otherValue" };
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap);
            const user = getAuthedFirestore("alice");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.get());
            yield firebase.assertSucceeds(userDocRef.update(adminRoleDataMap));
            yield firebase.assertSucceeds(userDocRef.delete());
        }));
        it("authorized, updating with different appRole", () => __awaiter(void 0, void 0, void 0, function* () {
            const adminRoleDataMap = { appRole: "user", otherField: "otherValue" };
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap);
            const user = getAuthedFirestore("alice");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.get());
            yield firebase.assertFails(userDocRef.update({ appRole: "owner", otherField: "otherValue" }));
            yield firebase.assertSucceeds(userDocRef.delete());
        }));
    });
    describe("/privateUserData/{userId}", () => {
        const colPrivateUserData = "privateUserData";
        const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
            { collection: colPrivateUserData, document: "alice" },
        ]);
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
        }));
        it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
            const user = getAuthedFirestore(undefined);
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertFails(userDocRef.get());
            yield firebase.assertFails(userDocRef.set(originalDataMap));
            yield firebase.assertFails(userDocRef.update(updateDataMap));
            yield firebase.assertFails(userDocRef.delete());
        }));
        it("authorized, same id", () => __awaiter(void 0, void 0, void 0, function* () {
            const user = getAuthedFirestore("alice");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.get());
            yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
            yield firebase.assertSucceeds(userDocRef.delete());
        }));
        it("authorized, different id", () => __awaiter(void 0, void 0, void 0, function* () {
            const user = getAuthedFirestore("bob");
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertFails(userDocRef.get());
            yield firebase.assertFails(userDocRef.set(originalDataMap));
            yield firebase.assertFails(userDocRef.update(updateDataMap));
            yield firebase.assertFails(userDocRef.delete());
        }));
        describe("/communityUserSettings/{communityId}", () => {
            const colCommunityUserSettings = "communityUserSettings";
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                {
                    collection: colPrivateUserData,
                    document: "alice",
                },
                {
                    collection: colCommunityUserSettings,
                    document: "alice2",
                },
            ]);
            beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
            }));
            it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore(undefined);
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield firebase.assertFails(userColRef.add(originalDataMap));
                yield firebase.assertFails(userDocRef.get());
                yield firebase.assertFails(userDocRef.set(originalDataMap));
                yield firebase.assertFails(userDocRef.update(updateDataMap));
                yield firebase.assertFails(userDocRef.delete());
            }));
            it("authorized, same id", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("alice");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                yield firebase.assertSucceeds(userDocRef.get());
                yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                yield firebase.assertSucceeds(userDocRef.delete());
            }));
            it("authorized, different id", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("bob");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield firebase.assertFails(userColRef.add(originalDataMap));
                yield firebase.assertFails(userDocRef.get());
                yield firebase.assertFails(userDocRef.set(originalDataMap));
                yield firebase.assertFails(userDocRef.update(updateDataMap));
                yield firebase.assertFails(userDocRef.delete());
            }));
        });
    });
    describe("/community/{communityId}", () => {
        const collectionCommunity = "community";
        const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
            { collection: collectionCommunity, document: "communityId" },
        ]);
        beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
            yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
        }));
        it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
            const user = getAuthedFirestore(undefined);
            const userColRef = communityRulesHelper.getCollectionRef(user);
            const userDocRef = communityRulesHelper.getDocumentRef(user);
            yield firebase.assertFails(userColRef.add(originalDataMap));
            yield firebase.assertFails(userDocRef.get());
            yield firebase.assertFails(userDocRef.set(originalDataMap));
            yield firebase.assertFails(userDocRef.update(updateDataMap));
            yield firebase.assertFails(userDocRef.delete());
        }));
        describe("authorized reader", () => __awaiter(void 0, void 0, void 0, function* () {
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                { collection: collectionCommunity, document: "communityId" },
            ]);
            it("create", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("alice");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                // Trying to add a document without `creatorId` being the owner
                yield firebase.assertFails(userColRef.add(originalDataMap));
                // Trying to add a document with `creatorId` being the owner
                yield firebase.assertFails(userColRef.add({ [fieldCreatorId]: "alice" }));
            }));
            it("get", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("alice");
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield firebase.assertSucceeds(userDocRef.get());
            }));
            it("update", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("alice");
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield communityRulesHelper
                    .getDocumentRef(dbAdmin)
                    .set({ someKey: "value" });
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield communityRulesHelper.createMembership("alice", membership);
                    switch (membership) {
                        case firestore_rules_helper_1.Membership.owner:
                        case firestore_rules_helper_1.Membership.admin:
                        case firestore_rules_helper_1.Membership.mod:
                        case firestore_rules_helper_1.Membership.facilitator:
                        case firestore_rules_helper_1.Membership.member:
                        case firestore_rules_helper_1.Membership.nonmember:
                        case firestore_rules_helper_1.Membership.attendee:
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            break;
                    }
                }
            }));
            it("delete", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("alice");
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield communityRulesHelper
                    .getDocumentRef(dbAdmin)
                    .set({ someKey: "value" });
                yield firebase.assertFails(userDocRef.delete());
            }));
        }));
        describe("/chats/{messageId=**}", () => {
            const collectionChats = "chats";
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                { collection: collectionCommunity, document: "communityId" },
                { collection: collectionChats, document: "messageId" },
            ]);
            describe("authorized", () => {
                const user = getAuthedFirestore("alice");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper
                        .getDocumentRef(dbAdmin)
                        .set(originalDataMap);
                }));
                it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper.makeDocCreator("alice");
                    function testDifferentMembership(membership) {
                        return __awaiter(this, void 0, void 0, function* () {
                            yield communityRulesHelper.createMembership("alice", membership);
                            // Currently there is no influence based on membership rule. But in the future there might be
                            // so leaving this switch for now more convenience.
                            switch (membership) {
                                case firestore_rules_helper_1.Membership.owner:
                                case firestore_rules_helper_1.Membership.admin:
                                case firestore_rules_helper_1.Membership.mod:
                                case firestore_rules_helper_1.Membership.facilitator:
                                case firestore_rules_helper_1.Membership.member:
                                case firestore_rules_helper_1.Membership.nonmember:
                                case firestore_rules_helper_1.Membership.attendee:
                                    yield firebase.assertSucceeds(userDocRef.set({
                                        [fieldCreatorId]: "alice",
                                        someKey: "someValue",
                                    }));
                                    // Merging to keep `creatorId` set.
                                    yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                    yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                            }
                        });
                    }
                    for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                        yield testDifferentMembership(membership);
                    }
                }));
                it("not docCreator but mod", () => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper.makeDocCreator("bob");
                    function testDifferentMembership(membership) {
                        return __awaiter(this, void 0, void 0, function* () {
                            yield communityRulesHelper.createMembership("alice", membership);
                            switch (membership) {
                                case firestore_rules_helper_1.Membership.owner:
                                case firestore_rules_helper_1.Membership.admin:
                                case firestore_rules_helper_1.Membership.mod:
                                    yield firebase.assertSucceeds(userDocRef.set({
                                        [fieldCreatorId]: "bob",
                                        someKey: "someValue",
                                    }));
                                    // Merging to keep `creatorId` set.
                                    yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                    yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                                case firestore_rules_helper_1.Membership.facilitator:
                                case firestore_rules_helper_1.Membership.member:
                                case firestore_rules_helper_1.Membership.nonmember:
                                case firestore_rules_helper_1.Membership.attendee:
                                    yield firebase.assertFails(userDocRef.set({
                                        [fieldCreatorId]: "bob",
                                        someKey: "someValue",
                                    }));
                                    // Merging to keep `creatorId` set.
                                    yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                    yield firebase.assertFails(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                            }
                        });
                    }
                    for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                        yield testDifferentMembership(membership);
                    }
                }));
            });
            it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                const user = getAuthedFirestore("bob");
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
                yield communityRulesHelper.makeDocCreator("alice");
                function testDifferentMembership(membership) {
                    return __awaiter(this, void 0, void 0, function* () {
                        yield communityRulesHelper.createMembership("alice", membership);
                        // Currently there is no influence based on membership rule. But in the future there might be
                        // so leaving this switch for now more convenience.
                        switch (membership) {
                            case firestore_rules_helper_1.Membership.owner:
                            case firestore_rules_helper_1.Membership.admin:
                            case firestore_rules_helper_1.Membership.mod:
                            case firestore_rules_helper_1.Membership.facilitator:
                            case firestore_rules_helper_1.Membership.member:
                            case firestore_rules_helper_1.Membership.nonmember:
                            case firestore_rules_helper_1.Membership.attendee:
                                yield firebase.assertFails(userDocRef.set({
                                    [fieldCreatorId]: "alice",
                                    someKey: "someValue",
                                }));
                                // Merging to keep `creatorId` set.
                                yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                        }
                    });
                }
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield testDifferentMembership(membership);
                }
            }));
        });
        describe("/featured/{featuredId=**}", () => {
            const collectionFeatured = "featured";
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                { collection: collectionCommunity, document: "communityId" },
                { collection: collectionFeatured, document: "featuredId" },
            ]);
            describe("authorized", () => {
                beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper
                        .getDocumentRef(dbAdmin)
                        .set(originalDataMap);
                }));
                it("isCommunityAdmin", () => __awaiter(void 0, void 0, void 0, function* () {
                    const user = getAuthedFirestore("alice");
                    const userColRef = communityRulesHelper.getCollectionRef(user);
                    const userDocRef = communityRulesHelper.getDocumentRef(user);
                    function testDifferentMembership(membership) {
                        return __awaiter(this, void 0, void 0, function* () {
                            yield communityRulesHelper.createMembership("alice", membership);
                            switch (membership) {
                                case firestore_rules_helper_1.Membership.owner:
                                case firestore_rules_helper_1.Membership.admin:
                                    yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                                    yield firebase.assertSucceeds(userDocRef.get());
                                    yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                                    yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                    yield firebase.assertSucceeds(userDocRef.delete());
                                    break;
                                case firestore_rules_helper_1.Membership.mod:
                                case firestore_rules_helper_1.Membership.facilitator:
                                case firestore_rules_helper_1.Membership.member:
                                case firestore_rules_helper_1.Membership.nonmember:
                                case firestore_rules_helper_1.Membership.attendee:
                                    yield firebase.assertFails(userColRef.add(originalDataMap));
                                    yield firebase.assertSucceeds(userDocRef.get());
                                    yield firebase.assertFails(userDocRef.set(originalDataMap));
                                    yield firebase.assertFails(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                            }
                        });
                    }
                    for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                        yield testDifferentMembership(membership);
                    }
                }));
            });
            it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
                const user = getAuthedFirestore("bob");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                function testDifferentMembership(membership) {
                    return __awaiter(this, void 0, void 0, function* () {
                        yield communityRulesHelper.createMembership("alice", membership);
                        // Currently there is no influence based on membership rule. But in the future there might be
                        // so leaving this switch for now more convenience.
                        switch (membership) {
                            case firestore_rules_helper_1.Membership.owner:
                            case firestore_rules_helper_1.Membership.admin:
                            case firestore_rules_helper_1.Membership.mod:
                            case firestore_rules_helper_1.Membership.facilitator:
                            case firestore_rules_helper_1.Membership.member:
                            case firestore_rules_helper_1.Membership.nonmember:
                            case firestore_rules_helper_1.Membership.attendee:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertSucceeds(userDocRef.get());
                                yield firebase.assertFails(userDocRef.set(originalDataMap));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                        }
                    });
                }
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield testDifferentMembership(membership);
                }
            }));
        });
        describe("/announcements/{announcementId}", () => {
            const collectionAnnouncements = "announcements";
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                { collection: collectionCommunity, document: "communityId" },
                { collection: collectionAnnouncements, document: "announcementId" },
            ]);
            describe("authorized", () => {
                beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper
                        .getDocumentRef(dbAdmin)
                        .set(originalDataMap);
                }));
                it("isCommunityAdmin", () => __awaiter(void 0, void 0, void 0, function* () {
                    const user = getAuthedFirestore("alice");
                    const userColRef = communityRulesHelper.getCollectionRef(user);
                    const userDocRef = communityRulesHelper.getDocumentRef(user);
                    function testDifferentMembership(membership) {
                        return __awaiter(this, void 0, void 0, function* () {
                            yield communityRulesHelper.createMembership("alice", membership);
                            switch (membership) {
                                case firestore_rules_helper_1.Membership.owner:
                                case firestore_rules_helper_1.Membership.admin:
                                    yield firebase.assertFails(userColRef.add(originalDataMap));
                                    yield firebase.assertSucceeds(userColRef.add({
                                        [fieldCreatorId]: "alice",
                                        someKey: "someValue",
                                    }));
                                    yield firebase.assertSucceeds(userDocRef.get());
                                    yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                                    yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                                case firestore_rules_helper_1.Membership.mod:
                                case firestore_rules_helper_1.Membership.facilitator:
                                case firestore_rules_helper_1.Membership.member:
                                case firestore_rules_helper_1.Membership.nonmember:
                                case firestore_rules_helper_1.Membership.attendee:
                                    yield firebase.assertFails(userColRef.add(originalDataMap));
                                    yield firebase.assertFails(userColRef.add({
                                        [fieldCreatorId]: "alice",
                                        someKey: "someValue",
                                    }));
                                    yield firebase.assertSucceeds(userDocRef.get());
                                    yield firebase.assertFails(userDocRef.set(originalDataMap));
                                    yield firebase.assertFails(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                            }
                        });
                    }
                    for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                        yield testDifferentMembership(membership);
                    }
                }));
            });
            it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
                const user = getAuthedFirestore(undefined);
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                function testDifferentMembership(membership) {
                    return __awaiter(this, void 0, void 0, function* () {
                        // Currently there is no influence based on membership rule. But in the future there might be
                        // so leaving this switch for now more convenience.
                        switch (membership) {
                            case firestore_rules_helper_1.Membership.owner:
                            case firestore_rules_helper_1.Membership.admin:
                            case firestore_rules_helper_1.Membership.mod:
                            case firestore_rules_helper_1.Membership.facilitator:
                            case firestore_rules_helper_1.Membership.member:
                            case firestore_rules_helper_1.Membership.nonmember:
                            case firestore_rules_helper_1.Membership.attendee:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertFails(userColRef.add({
                                    [fieldCreatorId]: null,
                                    someKey: "someValue",
                                }));
                                yield firebase.assertFails(userDocRef.get());
                                yield firebase.assertFails(userDocRef.set(originalDataMap));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                        }
                    });
                }
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield testDifferentMembership(membership);
                }
            }));
        });
        describe("/templates/{templateId}", () => {
            const collectionTemplates = "templates";
            const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                { collection: collectionCommunity, document: "communityId" },
                { collection: collectionTemplates, document: "templateId" },
            ]);
            it("authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
                const user = getAuthedFirestore("alice");
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                function testDifferentMembership(membership) {
                    return __awaiter(this, void 0, void 0, function* () {
                        yield communityRulesHelper.createMembership("alice", membership);
                        switch (membership) {
                            case firestore_rules_helper_1.Membership.owner:
                            case firestore_rules_helper_1.Membership.admin:
                            case firestore_rules_helper_1.Membership.mod:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertSucceeds(userColRef.add({
                                    [fieldCreatorId]: "alice",
                                    someKey: "someValue",
                                }));
                                yield firebase.assertSucceeds(userDocRef.get());
                                yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                            case firestore_rules_helper_1.Membership.facilitator:
                            case firestore_rules_helper_1.Membership.member:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertSucceeds(userColRef.add({
                                    [fieldCreatorId]: "alice",
                                    someKey: "someValue",
                                }));
                                yield firebase.assertSucceeds(userDocRef.get());
                                yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                            case firestore_rules_helper_1.Membership.nonmember:
                            case firestore_rules_helper_1.Membership.attendee:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertFails(userColRef.add({
                                    [fieldCreatorId]: "alice",
                                    someKey: "someValue",
                                }));
                                yield firebase.assertSucceeds(userDocRef.get());
                                yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                        }
                    });
                }
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield testDifferentMembership(membership);
                }
            }));
            it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                yield communityRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap);
                const user = getAuthedFirestore(undefined);
                const userColRef = communityRulesHelper.getCollectionRef(user);
                const userDocRef = communityRulesHelper.getDocumentRef(user);
                function testDifferentMembership(membership) {
                    return __awaiter(this, void 0, void 0, function* () {
                        switch (membership) {
                            case firestore_rules_helper_1.Membership.owner:
                            case firestore_rules_helper_1.Membership.admin:
                            case firestore_rules_helper_1.Membership.mod:
                            case firestore_rules_helper_1.Membership.facilitator:
                            case firestore_rules_helper_1.Membership.member:
                            case firestore_rules_helper_1.Membership.nonmember:
                            case firestore_rules_helper_1.Membership.attendee:
                                yield firebase.assertFails(userColRef.add(originalDataMap));
                                yield firebase.assertFails(userColRef.add({
                                    [fieldCreatorId]: null,
                                    someKey: "someValue",
                                }));
                                yield firebase.assertFails(userDocRef.get());
                                yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                yield firebase.assertFails(userDocRef.update(updateDataMap));
                                yield firebase.assertFails(userDocRef.delete());
                                break;
                        }
                    });
                }
                for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                    yield testDifferentMembership(membership);
                }
            }));
            describe("/events/{eventId}", () => {
                const collectionEvents = "events";
                const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                    { collection: collectionCommunity, document: "communityId" },
                    { collection: collectionTemplates, document: "templateId" },
                    { collection: collectionEvents, document: "eventId" },
                ]);
                beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper
                        .getDocumentRef(dbAdmin)
                        .set(originalDataMap);
                }));
                describe("authorized", () => {
                    it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper.getDocumentRef(dbAdmin).set({
                            [fieldCreatorId]: "alice",
                            someKey: "someValue",
                        });
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        function testDifferentMembership(membership) {
                            return __awaiter(this, void 0, void 0, function* () {
                                yield communityRulesHelper.createMembership("alice", membership);
                                switch (membership) {
                                    case firestore_rules_helper_1.Membership.owner:
                                    case firestore_rules_helper_1.Membership.admin:
                                    case firestore_rules_helper_1.Membership.mod:
                                    case firestore_rules_helper_1.Membership.facilitator:
                                    case firestore_rules_helper_1.Membership.member:
                                    case firestore_rules_helper_1.Membership.nonmember:
                                    case firestore_rules_helper_1.Membership.attendee:
                                        yield firebase.assertFails(userColRef.add(originalDataMap));
                                        yield firebase.assertSucceeds(userColRef.add({
                                            [fieldCreatorId]: "alice",
                                            someKey: "someValue",
                                        }));
                                        yield firebase.assertSucceeds(userDocRef.get());
                                        yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                        yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                        yield firebase.assertFails(userDocRef.delete());
                                        break;
                                }
                            });
                        }
                        for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                            yield testDifferentMembership(membership);
                        }
                    }));
                    it("!isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper.getDocumentRef(dbAdmin).set({
                            [fieldCreatorId]: "alice",
                            someKey: "someValue",
                        });
                        const user = getAuthedFirestore("bob");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        function testDifferentMembership(membership) {
                            return __awaiter(this, void 0, void 0, function* () {
                                yield communityRulesHelper.createMembership("bob", membership);
                                switch (membership) {
                                    case firestore_rules_helper_1.Membership.owner:
                                    case firestore_rules_helper_1.Membership.admin:
                                    case firestore_rules_helper_1.Membership.mod:
                                        yield firebase.assertFails(userColRef.add(originalDataMap));
                                        yield firebase.assertSucceeds(userColRef.add({
                                            [fieldCreatorId]: "bob",
                                            someKey: "someValue",
                                        }));
                                        yield firebase.assertSucceeds(userDocRef.get());
                                        yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                        yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                        yield firebase.assertFails(userDocRef.delete());
                                        break;
                                    case firestore_rules_helper_1.Membership.facilitator:
                                    case firestore_rules_helper_1.Membership.member:
                                    case firestore_rules_helper_1.Membership.nonmember:
                                    case firestore_rules_helper_1.Membership.attendee:
                                        yield firebase.assertFails(userColRef.add(originalDataMap));
                                        yield firebase.assertSucceeds(userColRef.add({
                                            [fieldCreatorId]: "bob",
                                            someKey: "someValue",
                                        }));
                                        yield firebase.assertSucceeds(userDocRef.get());
                                        yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                        yield firebase.assertFails(userDocRef.update(updateDataMap));
                                        yield firebase.assertFails(userDocRef.delete());
                                        break;
                                }
                            });
                        }
                        for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                            yield testDifferentMembership(membership);
                        }
                    }));
                    describe("update", () => __awaiter(void 0, void 0, void 0, function* () {
                        it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield communityRulesHelper.getDocumentRef(dbAdmin).set({
                                [fieldCreatorId]: "alice",
                                someKey: "someValue",
                            });
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function* () {
                                    yield communityRulesHelper.createMembership("alice", membership);
                                    switch (membership) {
                                        case firestore_rules_helper_1.Membership.owner:
                                        case firestore_rules_helper_1.Membership.admin:
                                        case firestore_rules_helper_1.Membership.mod:
                                        case firestore_rules_helper_1.Membership.facilitator:
                                        case firestore_rules_helper_1.Membership.member:
                                        case firestore_rules_helper_1.Membership.nonmember:
                                        case firestore_rules_helper_1.Membership.attendee:
                                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                            break;
                                    }
                                });
                            }
                            for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                                yield testDifferentMembership(membership);
                            }
                        }));
                        it("isCommunityMod", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper
                                .getDocumentRef(dbAdmin)
                                .set(originalDataMap);
                            const user = getAuthedFirestore("alice");
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function* () {
                                    yield communityRulesHelper.createMembership("alice", membership);
                                    switch (membership) {
                                        case firestore_rules_helper_1.Membership.owner:
                                        case firestore_rules_helper_1.Membership.admin:
                                        case firestore_rules_helper_1.Membership.mod:
                                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                            break;
                                        case firestore_rules_helper_1.Membership.facilitator:
                                        case firestore_rules_helper_1.Membership.member:
                                        case firestore_rules_helper_1.Membership.nonmember:
                                        case firestore_rules_helper_1.Membership.attendee:
                                            yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                                            break;
                                    }
                                });
                            }
                            for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                                yield testDifferentMembership(membership);
                            }
                        }));
                    }));
                });
                it("is not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                    yield communityRulesHelper.getDocumentRef(dbAdmin).set({
                        [fieldCreatorId]: null,
                        someKey: "someValue",
                    });
                    const user = getAuthedFirestore(undefined);
                    const userColRef = communityRulesHelper.getCollectionRef(user);
                    const userDocRef = communityRulesHelper.getDocumentRef(user);
                    function testDifferentMembership(membership) {
                        return __awaiter(this, void 0, void 0, function* () {
                            switch (membership) {
                                case firestore_rules_helper_1.Membership.owner:
                                case firestore_rules_helper_1.Membership.admin:
                                case firestore_rules_helper_1.Membership.mod:
                                case firestore_rules_helper_1.Membership.facilitator:
                                case firestore_rules_helper_1.Membership.member:
                                case firestore_rules_helper_1.Membership.nonmember:
                                case firestore_rules_helper_1.Membership.attendee:
                                    yield firebase.assertFails(userColRef.add(originalDataMap));
                                    yield firebase.assertFails(userColRef.add({
                                        [fieldCreatorId]: "alice",
                                        someKey: "someValue",
                                    }));
                                    yield firebase.assertFails(userDocRef.get());
                                    yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                                    yield firebase.assertFails(userDocRef.update(updateDataMap));
                                    yield firebase.assertFails(userDocRef.delete());
                                    break;
                            }
                        });
                    }
                    for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                        yield testDifferentMembership(membership);
                    }
                }));
                describe("/event-participants/{participantId}", () => {
                    const collectionEventsParticipants = "event-participants";
                    const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                        { collection: collectionCommunity, document: "communityId" },
                        { collection: collectionTemplates, document: "templateId" },
                        { collection: collectionEvents, document: "eventId" },
                        {
                            collection: collectionEventsParticipants,
                            document: "eventParticipantId",
                        },
                    ]);
                    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(originalDataMap);
                    }));
                    it("different membership", () => __awaiter(void 0, void 0, void 0, function* () {
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        function testDifferentMembership(membership) {
                            return __awaiter(this, void 0, void 0, function* () {
                                yield communityRulesHelper.createMembership("alice", membership);
                                switch (membership) {
                                    case firestore_rules_helper_1.Membership.owner:
                                    case firestore_rules_helper_1.Membership.admin:
                                    case firestore_rules_helper_1.Membership.mod:
                                        yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                                        yield firebase.assertSucceeds(userDocRef.get());
                                        yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                                        yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                        yield firebase.assertSucceeds(userDocRef.delete());
                                        break;
                                    case firestore_rules_helper_1.Membership.facilitator:
                                    case firestore_rules_helper_1.Membership.member:
                                    case firestore_rules_helper_1.Membership.nonmember:
                                    case firestore_rules_helper_1.Membership.attendee:
                                        yield firebase.assertFails(userColRef.add(originalDataMap));
                                        yield firebase.assertSucceeds(userDocRef.get());
                                        yield firebase.assertFails(userDocRef.set(updateDataMap));
                                        yield firebase.assertFails(userDocRef.update({ someField: "adiffvalue" }));
                                        yield firebase.assertFails(userDocRef.delete());
                                        break;
                                }
                            });
                        }
                        for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                            yield testDifferentMembership(membership);
                        }
                    }));
                    it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                        // When we are in event-participants collection, we check ownership of previous
                        // collection (event). Very important not to mix it.
                        const eventsHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                            { collection: collectionCommunity, document: "communityId" },
                            { collection: collectionTemplates, document: "templateId" },
                            { collection: collectionEvents, document: "eventId" },
                        ]);
                        yield eventsHelper.makeDocCreator("alice");
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set({ someKey: "someValue" });
                        yield communityRulesHelper.createMembership("alice", "nonmember");
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                        yield firebase.assertSucceeds(userDocRef.get());
                        yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                        yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                        yield firebase.assertSucceeds(userDocRef.delete());
                    }));
                    describe("request by uid", () => {
                        it("request by same user", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("eventParticipantId");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertSucceeds(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertSucceeds(userDocRef.delete());
                        }));
                        it("request by different user", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("bob");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertSucceeds(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set(originalDataMap));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                    });
                    it("facilitator updating status to banned", () => __awaiter(void 0, void 0, void 0, function* () {
                        const statusDataMap = { status: "banned" };
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(statusDataMap);
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield communityRulesHelper.createMembership("alice", "facilitator");
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertSucceeds(userDocRef.get());
                        yield firebase.assertSucceeds(userDocRef.set(statusDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                    it("facilitator updating lastUpdatedTime and status to banned ", () => __awaiter(void 0, void 0, void 0, function* () {
                        const statusDataMap = { status: "banned", lastUpdatedTime: "123" };
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(statusDataMap);
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield communityRulesHelper.createMembership("alice", "facilitator");
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertSucceeds(userDocRef.get());
                        yield firebase.assertSucceeds(userDocRef.update(statusDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                    it("!isLiveStream", () => __awaiter(void 0, void 0, void 0, function* () {
                        // Only applicable to `get` but testing through more cases just in case.
                        // `liveStreamInfo` must be null (in `events` collection) in order `get` to succeed.
                        const eventsHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                            { collection: collectionCommunity, document: "communityId" },
                            { collection: collectionTemplates, document: "templateId" },
                            { collection: collectionEvents, document: "eventId" },
                        ]);
                        yield eventsHelper.updateDocumentsField({ liveStreamInfo: null });
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set({ someKey: "someValue" });
                        const user = getAuthedFirestore("alice");
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertSucceeds(userDocRef.get());
                        yield firebase.assertFails(userDocRef.set(originalDataMap));
                        yield firebase.assertFails(userDocRef.update(updateDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                });
                describe("/chats/{messageId=**}", () => {
                    const collectionChats = "chats";
                    const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                        { collection: collectionCommunity, document: "communityId" },
                        { collection: collectionTemplates, document: "templateId" },
                        { collection: collectionEvents, document: "eventId" },
                        { collection: collectionChats, document: "messageId" },
                    ]);
                    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(originalDataMap);
                    }));
                    describe("authorized", () => {
                        it("only authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                            yield firebase.assertFails(userColRef.add({ creatorId: "bob" }));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set(originalDataMap));
                            yield firebase.assertFails(userDocRef.set({ creatorId: "alice" }));
                            yield firebase.assertFails(userDocRef.set({ creatorId: "bob" }));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("isParticipant", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeParticipant("communityId", "templateId", "eventId", "alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                            yield firebase.assertSucceeds(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set({ creatorId: "alice" }, { merge: true }));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeDocCreator("alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("different membership", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function* () {
                                    yield communityRulesHelper.createMembership("alice", membership);
                                    switch (membership) {
                                        case firestore_rules_helper_1.Membership.owner:
                                        case firestore_rules_helper_1.Membership.admin:
                                        case firestore_rules_helper_1.Membership.mod:
                                            yield firebase.assertSucceeds(userColRef.add(originalDataMap));
                                            yield firebase.assertSucceeds(userDocRef.get());
                                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap));
                                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                            yield firebase.assertFails(userDocRef.delete());
                                            break;
                                        case firestore_rules_helper_1.Membership.facilitator:
                                        case firestore_rules_helper_1.Membership.member:
                                        case firestore_rules_helper_1.Membership.nonmember:
                                        case firestore_rules_helper_1.Membership.attendee:
                                            yield firebase.assertFails(userColRef.add(originalDataMap));
                                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                                            yield firebase.assertFails(userColRef.add({ creatorId: "bob" }));
                                            yield firebase.assertFails(userDocRef.get());
                                            yield firebase.assertFails(userDocRef.set(originalDataMap));
                                            yield firebase.assertFails(userDocRef.set({ creatorId: "alice" }));
                                            yield firebase.assertFails(userDocRef.set({ creatorId: "bob" }));
                                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                                            yield firebase.assertFails(userDocRef.delete());
                                            break;
                                    }
                                });
                            }
                            for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                                yield testDifferentMembership(membership);
                            }
                        }));
                    });
                    it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                        const user = getAuthedFirestore(undefined);
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertFails(userDocRef.get());
                        yield firebase.assertFails(userDocRef.set(originalDataMap));
                        yield firebase.assertFails(userDocRef.update(updateDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                });
                describe("/event-messages/{eventMessageId}", () => {
                    const collectionMessages = "event-messages";
                    const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                        { collection: collectionCommunity, document: "communityId" },
                        { collection: collectionTemplates, document: "templateId" },
                        { collection: collectionEvents, document: "eventId" },
                        { collection: collectionMessages, document: "eventMessageId" },
                    ]);
                    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(originalDataMap);
                    }));
                    describe("authorized", () => {
                        it("only authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                            yield firebase.assertFails(userColRef.add({ creatorId: "bob" }));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set(originalDataMap));
                            yield firebase.assertFails(userDocRef.set({ creatorId: "alice" }));
                            yield firebase.assertFails(userDocRef.set({ creatorId: "bob" }));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("isParticipant", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeParticipant("communityId", "templateId", "eventId", "alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertSucceeds(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set({ creatorId: "alice" }, { merge: true }));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeDocCreator("alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertFails(userDocRef.update(updateDataMap));
                            yield firebase.assertSucceeds(userDocRef.delete());
                        }));
                    });
                    it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                        const user = getAuthedFirestore(undefined);
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertFails(userDocRef.get());
                        yield firebase.assertFails(userDocRef.set(originalDataMap));
                        yield firebase.assertFails(userDocRef.update(updateDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                });
                describe("/user-suggestions/{suggestionId=**}", () => {
                    const collectionUserSuggestions = "user-suggestions";
                    const communityRulesHelper = new firestore_rules_helper_1.CommunityRulesHelper(dbAdmin, [
                        { collection: collectionCommunity, document: "communityId" },
                        { collection: collectionTemplates, document: "templateId" },
                        { collection: collectionEvents, document: "eventId" },
                        { collection: collectionUserSuggestions, document: "suggestionId" },
                    ]);
                    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
                        yield communityRulesHelper
                            .getDocumentRef(dbAdmin)
                            .set(originalDataMap);
                    }));
                    describe("authorized", () => {
                        it("only authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("isDocCreator", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeDocCreator("alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add(originalDataMap));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertSucceeds(userDocRef.delete());
                        }));
                        it("isParticipant", () => __awaiter(void 0, void 0, void 0, function* () {
                            yield communityRulesHelper.makeParticipant("communityId", "templateId", "eventId", "alice");
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertSucceeds(userColRef.add({ creatorId: "alice" }));
                            yield firebase.assertSucceeds(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("!isParticipant", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                            yield firebase.assertFails(userDocRef.get());
                            yield firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }));
                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                            yield firebase.assertFails(userDocRef.delete());
                        }));
                        it("different membership", () => __awaiter(void 0, void 0, void 0, function* () {
                            const user = getAuthedFirestore("alice");
                            const userColRef = communityRulesHelper.getCollectionRef(user);
                            const userDocRef = communityRulesHelper.getDocumentRef(user);
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function* () {
                                    yield communityRulesHelper.createMembership("alice", membership);
                                    switch (membership) {
                                        case firestore_rules_helper_1.Membership.owner:
                                        case firestore_rules_helper_1.Membership.admin:
                                        case firestore_rules_helper_1.Membership.mod:
                                            yield firebase.assertSucceeds(userColRef.add({ creatorId: "alice" }));
                                            yield firebase.assertFails(userColRef.add({ creatorId: "bob" }));
                                            yield firebase.assertSucceeds(userDocRef.get());
                                            yield firebase.assertSucceeds(userDocRef.set({ creatorId: "alice" }, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.set({ creatorId: "bob" }, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                            yield firebase.assertSucceeds(userDocRef.delete());
                                            break;
                                        case firestore_rules_helper_1.Membership.facilitator:
                                        case firestore_rules_helper_1.Membership.member:
                                        case firestore_rules_helper_1.Membership.nonmember:
                                        case firestore_rules_helper_1.Membership.attendee:
                                            yield firebase.assertFails(userColRef.add({ creatorId: "alice" }));
                                            yield firebase.assertFails(userColRef.add({ creatorId: "bob" }));
                                            yield firebase.assertFails(userColRef.add(originalDataMap));
                                            yield firebase.assertFails(userDocRef.get());
                                            yield firebase.assertSucceeds(userDocRef.set({ creatorId: "alice" }, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.set({ creatorId: "bob" }, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.set({ creatorId: null }, { merge: true }));
                                            yield firebase.assertSucceeds(userDocRef.update(updateDataMap));
                                            yield firebase.assertFails(userDocRef.delete());
                                            break;
                                    }
                                });
                            }
                            for (const membership of Object.keys(firestore_rules_helper_1.Membership)) {
                                yield testDifferentMembership(membership);
                            }
                        }));
                    });
                    it("not authorized", () => __awaiter(void 0, void 0, void 0, function* () {
                        const user = getAuthedFirestore(undefined);
                        const userColRef = communityRulesHelper.getCollectionRef(user);
                        const userDocRef = communityRulesHelper.getDocumentRef(user);
                        yield firebase.assertFails(userColRef.add(originalDataMap));
                        yield firebase.assertFails(userDocRef.get());
                        yield firebase.assertFails(userDocRef.set(originalDataMap));
                        yield firebase.assertFails(userDocRef.update(updateDataMap));
                        yield firebase.assertFails(userDocRef.delete());
                    }));
                });
            });
        });
    });
}));

"use strict";
/**
 * Main file for testing firestore-rules.
 *
 * Reference taken from https://github.com/firebase/quickstart-testing/tree/master/unit-test-security-rules.
 */
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var firestore_rules_helper_1 = require("./firestore-rules-helper");
require("mocha");
var firebase = require('@firebase/rules-unit-testing');
var fs = require('fs');
var http = require('http');
/**
 * The emulator will accept any project ID for testing.
 */
var PROJECT_ID = 'firestore-emulator-example';
/**
 * The FIRESTORE_EMULATOR_HOST environment variable is set automatically
 * by "firebase emulators:exec"
 */
// Hard-coding path for now since we are running `npm run test`
// More about test report - https://firebase.google.com/docs/rules/emulator-reports
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
var COVERAGE_URL = "http://".concat(process.env.FIRESTORE_EMULATOR_HOST, "/emulator/v1/projects/").concat(PROJECT_ID, ":ruleCoverage.html");
// Fields
var fieldCreatorId = 'creatorId';
var fieldMembershipStatusSnapshot = 'membershipStatusSnapshot';
// Data
var originalDataMap = { someField: 'someValue' };
var updateDataMap = { someField: 'someUpdatedValue' };
// Create a reference for DB Admin
var dbAdmin;
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
afterEach(function () { return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: 
            // Clear the database between tests
            return [4 /*yield*/, firebase.clearFirestoreData({
                    projectId: PROJECT_ID,
                })];
            case 1:
                // Clear the database between tests
                _a.sent();
                return [2 /*return*/];
        }
    });
}); });
before(function () { return __awaiter(void 0, void 0, void 0, function () {
    var rules;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                rules = fs.readFileSync(path.join(__dirname, '../', '../', '../', 'firestore', 'firestore.rules'), 'utf8');
                return [4 /*yield*/, firebase.loadFirestoreRules({
                        projectId: PROJECT_ID,
                        rules: rules,
                    })];
            case 1:
                _a.sent();
                return [2 /*return*/];
        }
    });
}); });
after(function () { return __awaiter(void 0, void 0, void 0, function () {
    var coverageFile, fstream;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: 
            // Delete all the FirebaseApp instances created during testing
            // Note: this does not affect or clear any data
            return [4 /*yield*/, Promise.all(firebase.apps().map(function (app) { return app.delete(); }))
                // Write the coverage report to a file
            ];
            case 1:
                // Delete all the FirebaseApp instances created during testing
                // Note: this does not affect or clear any data
                _a.sent();
                coverageFile = 'firestore-coverage.html';
                fstream = fs.createWriteStream(coverageFile);
                return [4 /*yield*/, new Promise(function (resolve, reject) {
                        http.get(COVERAGE_URL, function (res) {
                            res.pipe(fstream, { end: true });
                            res.on('end', resolve);
                            res.on('error', reject);
                        });
                    })];
            case 2:
                _a.sent();
                console.log("View firestore rule coverage information at ".concat(COVERAGE_URL, " or ").concat(coverageFile, "\n"));
                return [2 /*return*/];
        }
    });
}); });
describe('Firestore security rules', function () { return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, firebase.initializeAdminApp({ projectId: PROJECT_ID }).firestore()];
            case 1:
                // For some reason `before` executes semi-after describe, leaving `dbAdmin` not initialised.
                dbAdmin = _a.sent();
                describe('/publicUser/{userId}', function () {
                    var collection = 'publicUser';
                    var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                        { collection: collection, document: 'alice' },
                    ]);
                    it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                case 1:
                                    _a.sent();
                                    user = getAuthedFirestore(undefined);
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                case 5:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                case 6:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, same id', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                case 1:
                                    _a.sent();
                                    user = getAuthedFirestore('alice');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(originalDataMap))];
                                case 5:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                case 6:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, different id', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                case 1:
                                    _a.sent();
                                    user = getAuthedFirestore('bob');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(originalDataMap))];
                                case 5:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                case 6:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, updating with same appRole', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var adminRoleDataMap, user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    adminRoleDataMap = { appRole: 'owner', otherField: 'otherValue' };
                                    return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap)];
                                case 1:
                                    _a.sent();
                                    user = getAuthedFirestore('alice');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(adminRoleDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, updating with different appRole', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var adminRoleDataMap, user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    adminRoleDataMap = { appRole: 'user', otherField: 'otherValue' };
                                    return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(adminRoleDataMap)];
                                case 1:
                                    _a.sent();
                                    user = getAuthedFirestore('alice');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update({ appRole: 'owner', otherField: 'otherValue' }))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                });
                describe('/privateUserData/{userId}', function () {
                    var colPrivateUserData = 'privateUserData';
                    var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                        { collection: colPrivateUserData, document: 'alice' },
                    ]);
                    beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                case 1:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    user = getAuthedFirestore(undefined);
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 1:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, same id', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    user = getAuthedFirestore('alice');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 1:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('authorized, different id', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    user = getAuthedFirestore('bob');
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 1:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    describe('/juntoUserSettings/{juntoId}', function () {
                        var colJuntoUserSettings = 'juntoUserSettings';
                        var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                            {
                                collection: colPrivateUserData,
                                document: 'alice',
                            },
                            {
                                collection: colJuntoUserSettings,
                                document: 'alice2',
                            },
                        ]);
                        beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                            return __generator(this, function (_a) {
                                switch (_a.label) {
                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _a.sent();
                                        return [2 /*return*/];
                                }
                            });
                        }); });
                        it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            var user, userColRef, userDocRef;
                            return __generator(this, function (_a) {
                                switch (_a.label) {
                                    case 0:
                                        user = getAuthedFirestore(undefined);
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                    case 1:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                    case 2:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                    case 3:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                    case 4:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                    case 5:
                                        _a.sent();
                                        return [2 /*return*/];
                                }
                            });
                        }); });
                        it('authorized, same id', function () { return __awaiter(void 0, void 0, void 0, function () {
                            var user, userColRef, userDocRef;
                            return __generator(this, function (_a) {
                                switch (_a.label) {
                                    case 0:
                                        user = getAuthedFirestore('alice');
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                    case 1:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                    case 2:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                    case 3:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                    case 4:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                    case 5:
                                        _a.sent();
                                        return [2 /*return*/];
                                }
                            });
                        }); });
                        it('authorized, different id', function () { return __awaiter(void 0, void 0, void 0, function () {
                            var user, userColRef, userDocRef;
                            return __generator(this, function (_a) {
                                switch (_a.label) {
                                    case 0:
                                        user = getAuthedFirestore('bob');
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                    case 1:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                    case 2:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                    case 3:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                    case 4:
                                        _a.sent();
                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                    case 5:
                                        _a.sent();
                                        return [2 /*return*/];
                                }
                            });
                        }); });
                    });
                });
                describe('/junto/{juntoId}', function () {
                    var collectionJunto = 'junto';
                    var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                        { collection: collectionJunto, document: 'juntoId' },
                    ]);
                    beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                case 1:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var user, userColRef, userDocRef;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    user = getAuthedFirestore(undefined);
                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                case 1:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                case 2:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                case 3:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                case 4:
                                    _a.sent();
                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                case 5:
                                    _a.sent();
                                    return [2 /*return*/];
                            }
                        });
                    }); });
                    describe('authorized reader', function () { return __awaiter(void 0, void 0, void 0, function () {
                        var juntoRulesHelper;
                        return __generator(this, function (_a) {
                            juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                { collection: collectionJunto, document: 'juntoId' },
                            ]);
                            it('create', function () { return __awaiter(void 0, void 0, void 0, function () {
                                var user, userColRef;
                                var _a;
                                return __generator(this, function (_b) {
                                    switch (_b.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userColRef = juntoRulesHelper.getCollectionRef(user);
                                            // Trying to add a document without `creatorId` being the owner
                                            return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))
                                                // Trying to add a document with `creatorId` being the owner
                                            ];
                                        case 1:
                                            // Trying to add a document without `creatorId` being the owner
                                            _b.sent();
                                            // Trying to add a document with `creatorId` being the owner
                                            return [4 /*yield*/, firebase.assertFails(userColRef.add((_a = {}, _a[fieldCreatorId] = 'alice', _a)))];
                                        case 2:
                                            // Trying to add a document with `creatorId` being the owner
                                            _b.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('get', function () { return __awaiter(void 0, void 0, void 0, function () {
                                var user, userDocRef;
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                        case 1:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('update', function () { return __awaiter(void 0, void 0, void 0, function () {
                                var user, userDocRef, _i, _a, membership, _b;
                                return __generator(this, function (_c) {
                                    switch (_c.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'value' })];
                                        case 1:
                                            _c.sent();
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _c.label = 2;
                                        case 2:
                                            if (!(_i < _a.length)) return [3 /*break*/, 7];
                                            membership = _a[_i];
                                            return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                        case 3:
                                            _c.sent();
                                            _b = membership;
                                            switch (_b) {
                                                case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 4];
                                                case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 4];
                                            }
                                            return [3 /*break*/, 6];
                                        case 4: return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                        case 5:
                                            _c.sent();
                                            return [3 /*break*/, 6];
                                        case 6:
                                            _i++;
                                            return [3 /*break*/, 2];
                                        case 7: return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('delete', function () { return __awaiter(void 0, void 0, void 0, function () {
                                var user, userDocRef;
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'value' })];
                                        case 1:
                                            _a.sent();
                                            return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                        case 2:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            return [2 /*return*/];
                        });
                    }); });
                    describe('/chats/{messageId=**}', function () {
                        var collectionChats = 'chats';
                        var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionChats, document: 'messageId' },
                        ]);
                        describe('authorized', function () {
                            var user = getAuthedFirestore('alice');
                            var userColRef = juntoRulesHelper.getCollectionRef(user);
                            var userDocRef = juntoRulesHelper.getDocumentRef(user);
                            beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                        case 1:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                function testDifferentMembership(membership) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var _a;
                                        var _b;
                                        return __generator(this, function (_c) {
                                            switch (_c.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)
                                                    // Currently there is no influence based on membership rule. But in the future there might be
                                                    // so leaving this switch for now more convenience.
                                                ];
                                                case 1:
                                                    _c.sent();
                                                    _a = membership;
                                                    switch (_a) {
                                                        case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 2];
                                                    }
                                                    return [3 /*break*/, 7];
                                                case 2: return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set((_b = {},
                                                        _b[fieldCreatorId] = 'alice',
                                                        _b.someKey = 'someValue',
                                                        _b)))
                                                    // Merging to keep `creatorId` set.
                                                ];
                                                case 3:
                                                    _c.sent();
                                                    // Merging to keep `creatorId` set.
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    // Merging to keep `creatorId` set.
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _c.sent();
                                                    return [3 /*break*/, 7];
                                                case 7: return [2 /*return*/];
                                            }
                                        });
                                    });
                                }
                                var _i, _a, membership;
                                return __generator(this, function (_b) {
                                    switch (_b.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.makeDocCreator('alice')];
                                        case 1:
                                            _b.sent();
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _b.label = 2;
                                        case 2:
                                            if (!(_i < _a.length)) return [3 /*break*/, 5];
                                            membership = _a[_i];
                                            return [4 /*yield*/, testDifferentMembership(membership)];
                                        case 3:
                                            _b.sent();
                                            _b.label = 4;
                                        case 4:
                                            _i++;
                                            return [3 /*break*/, 2];
                                        case 5: return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('not docCreator but mod', function () { return __awaiter(void 0, void 0, void 0, function () {
                                function testDifferentMembership(membership) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var _a;
                                        var _b, _c;
                                        return __generator(this, function (_d) {
                                            switch (_d.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                case 1:
                                                    _d.sent();
                                                    _a = membership;
                                                    switch (_a) {
                                                        case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 7];
                                                        case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 7];
                                                        case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 7];
                                                        case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 7];
                                                    }
                                                    return [3 /*break*/, 12];
                                                case 2: return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set((_b = {},
                                                        _b[fieldCreatorId] = 'bob',
                                                        _b.someKey = 'someValue',
                                                        _b)))
                                                    // Merging to keep `creatorId` set.
                                                ];
                                                case 3:
                                                    _d.sent();
                                                    // Merging to keep `creatorId` set.
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    // Merging to keep `creatorId` set.
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _d.sent();
                                                    return [3 /*break*/, 12];
                                                case 7: return [4 /*yield*/, firebase.assertFails(userDocRef.set((_c = {},
                                                        _c[fieldCreatorId] = 'bob',
                                                        _c.someKey = 'someValue',
                                                        _c)))
                                                    // Merging to keep `creatorId` set.
                                                ];
                                                case 8:
                                                    _d.sent();
                                                    // Merging to keep `creatorId` set.
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 9:
                                                    // Merging to keep `creatorId` set.
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 10:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 11:
                                                    _d.sent();
                                                    return [3 /*break*/, 12];
                                                case 12: return [2 /*return*/];
                                            }
                                        });
                                    });
                                }
                                var _i, _a, membership;
                                return __generator(this, function (_b) {
                                    switch (_b.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.makeDocCreator('bob')];
                                        case 1:
                                            _b.sent();
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _b.label = 2;
                                        case 2:
                                            if (!(_i < _a.length)) return [3 /*break*/, 5];
                                            membership = _a[_i];
                                            return [4 /*yield*/, testDifferentMembership(membership)];
                                        case 3:
                                            _b.sent();
                                            _b.label = 4;
                                        case 4:
                                            _i++;
                                            return [3 /*break*/, 2];
                                        case 5: return [2 /*return*/];
                                    }
                                });
                            }); });
                        });
                        it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function () {
                                    var _a;
                                    var _b;
                                    return __generator(this, function (_c) {
                                        switch (_c.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)
                                                // Currently there is no influence based on membership rule. But in the future there might be
                                                // so leaving this switch for now more convenience.
                                            ];
                                            case 1:
                                                _c.sent();
                                                _a = membership;
                                                switch (_a) {
                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 2];
                                                }
                                                return [3 /*break*/, 7];
                                            case 2: return [4 /*yield*/, firebase.assertFails(userDocRef.set((_b = {},
                                                    _b[fieldCreatorId] = 'alice',
                                                    _b.someKey = 'someValue',
                                                    _b)))
                                                // Merging to keep `creatorId` set.
                                            ];
                                            case 3:
                                                _c.sent();
                                                // Merging to keep `creatorId` set.
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                            case 4:
                                                // Merging to keep `creatorId` set.
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 5:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 6:
                                                _c.sent();
                                                return [3 /*break*/, 7];
                                            case 7: return [2 /*return*/];
                                        }
                                    });
                                });
                            }
                            var user, userDocRef, _i, _a, membership;
                            return __generator(this, function (_b) {
                                switch (_b.label) {
                                    case 0:
                                        user = getAuthedFirestore('bob');
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _b.sent();
                                        return [4 /*yield*/, juntoRulesHelper.makeDocCreator('alice')];
                                    case 2:
                                        _b.sent();
                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                        _b.label = 3;
                                    case 3:
                                        if (!(_i < _a.length)) return [3 /*break*/, 6];
                                        membership = _a[_i];
                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                    case 4:
                                        _b.sent();
                                        _b.label = 5;
                                    case 5:
                                        _i++;
                                        return [3 /*break*/, 3];
                                    case 6: return [2 /*return*/];
                                }
                            });
                        }); });
                    });
                    describe('/featured/{featuredId=**}', function () {
                        var collectionFeatured = 'featured';
                        var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionFeatured, document: 'featuredId' },
                        ]);
                        describe('authorized', function () {
                            beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                        case 1:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('isJuntoAdmin', function () { return __awaiter(void 0, void 0, void 0, function () {
                                function testDifferentMembership(membership) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var _a;
                                        return __generator(this, function (_b) {
                                            switch (_b.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                case 1:
                                                    _b.sent();
                                                    _a = membership;
                                                    switch (_a) {
                                                        case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 8];
                                                        case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 8];
                                                        case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 8];
                                                        case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 8];
                                                        case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 8];
                                                    }
                                                    return [3 /*break*/, 14];
                                                case 2: return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                                case 3:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 4:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                                case 5:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 6:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                case 7:
                                                    _b.sent();
                                                    return [3 /*break*/, 14];
                                                case 8: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 9:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 10:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                case 11:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 12:
                                                    _b.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 13:
                                                    _b.sent();
                                                    return [3 /*break*/, 14];
                                                case 14: return [2 /*return*/];
                                            }
                                        });
                                    });
                                }
                                var user, userColRef, userDocRef, _i, _a, membership;
                                return __generator(this, function (_b) {
                                    switch (_b.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userColRef = juntoRulesHelper.getCollectionRef(user);
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _b.label = 1;
                                        case 1:
                                            if (!(_i < _a.length)) return [3 /*break*/, 4];
                                            membership = _a[_i];
                                            return [4 /*yield*/, testDifferentMembership(membership)];
                                        case 2:
                                            _b.sent();
                                            _b.label = 3;
                                        case 3:
                                            _i++;
                                            return [3 /*break*/, 1];
                                        case 4: return [2 /*return*/];
                                    }
                                });
                            }); });
                        });
                        it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function () {
                                    var _a;
                                    return __generator(this, function (_b) {
                                        switch (_b.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)
                                                // Currently there is no influence based on membership rule. But in the future there might be
                                                // so leaving this switch for now more convenience.
                                            ];
                                            case 1:
                                                _b.sent();
                                                _a = membership;
                                                switch (_a) {
                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 2];
                                                }
                                                return [3 /*break*/, 8];
                                            case 2: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 3:
                                                _b.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 4:
                                                _b.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 5:
                                                _b.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 6:
                                                _b.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 7:
                                                _b.sent();
                                                return [3 /*break*/, 8];
                                            case 8: return [2 /*return*/];
                                        }
                                    });
                                });
                            }
                            var user, userColRef, userDocRef, _i, _a, membership;
                            return __generator(this, function (_b) {
                                switch (_b.label) {
                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _b.sent();
                                        user = getAuthedFirestore('bob');
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                        _b.label = 2;
                                    case 2:
                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                        membership = _a[_i];
                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                    case 3:
                                        _b.sent();
                                        _b.label = 4;
                                    case 4:
                                        _i++;
                                        return [3 /*break*/, 2];
                                    case 5: return [2 /*return*/];
                                }
                            });
                        }); });
                    });
                    describe('/announcements/{announcementId}', function () {
                        var collectionAnnouncements = 'announcements';
                        var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionAnnouncements, document: 'announcementId' },
                        ]);
                        describe('authorized', function () {
                            beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                        case 1:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            it('isJuntoAdmin', function () { return __awaiter(void 0, void 0, void 0, function () {
                                function testDifferentMembership(membership) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var _a;
                                        var _b, _c;
                                        return __generator(this, function (_d) {
                                            switch (_d.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                case 1:
                                                    _d.sent();
                                                    _a = membership;
                                                    switch (_a) {
                                                        case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                        case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 9];
                                                        case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 9];
                                                        case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 9];
                                                        case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 9];
                                                        case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 9];
                                                    }
                                                    return [3 /*break*/, 16];
                                                case 2: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 3:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_b = {},
                                                            _b[fieldCreatorId] = 'alice',
                                                            _b.someKey = 'someValue',
                                                            _b)))];
                                                case 4:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 5:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                                case 6:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 7:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 8:
                                                    _d.sent();
                                                    return [3 /*break*/, 16];
                                                case 9: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 10:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add((_c = {},
                                                            _c[fieldCreatorId] = 'alice',
                                                            _c.someKey = 'someValue',
                                                            _c)))];
                                                case 11:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 12:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                case 13:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 14:
                                                    _d.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 15:
                                                    _d.sent();
                                                    return [3 /*break*/, 16];
                                                case 16: return [2 /*return*/];
                                            }
                                        });
                                    });
                                }
                                var user, userColRef, userDocRef, _i, _a, membership;
                                return __generator(this, function (_b) {
                                    switch (_b.label) {
                                        case 0:
                                            user = getAuthedFirestore('alice');
                                            userColRef = juntoRulesHelper.getCollectionRef(user);
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _b.label = 1;
                                        case 1:
                                            if (!(_i < _a.length)) return [3 /*break*/, 4];
                                            membership = _a[_i];
                                            return [4 /*yield*/, testDifferentMembership(membership)];
                                        case 2:
                                            _b.sent();
                                            _b.label = 3;
                                        case 3:
                                            _i++;
                                            return [3 /*break*/, 1];
                                        case 4: return [2 /*return*/];
                                    }
                                });
                            }); });
                        });
                        it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function () {
                                    var _a;
                                    var _b;
                                    return __generator(this, function (_c) {
                                        switch (_c.label) {
                                            case 0:
                                                _a = membership;
                                                switch (_a) {
                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 1];
                                                }
                                                return [3 /*break*/, 8];
                                            case 1: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 2:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add((_b = {},
                                                        _b[fieldCreatorId] = null,
                                                        _b.someKey = 'someValue',
                                                        _b)))];
                                            case 3:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                            case 4:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 5:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 6:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 7:
                                                _c.sent();
                                                return [3 /*break*/, 8];
                                            case 8: return [2 /*return*/];
                                        }
                                    });
                                });
                            }
                            var user, userColRef, userDocRef, _i, _a, membership;
                            return __generator(this, function (_b) {
                                switch (_b.label) {
                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _b.sent();
                                        user = getAuthedFirestore(undefined);
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                        _b.label = 2;
                                    case 2:
                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                        membership = _a[_i];
                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                    case 3:
                                        _b.sent();
                                        _b.label = 4;
                                    case 4:
                                        _i++;
                                        return [3 /*break*/, 2];
                                    case 5: return [2 /*return*/];
                                }
                            });
                        }); });
                    });
                    describe('/topics/{topicId}', function () {
                        var collectionTopics = 'topics';
                        var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                            { collection: collectionJunto, document: 'juntoId' },
                            { collection: collectionTopics, document: 'topicId' },
                        ]);
                        it('authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function () {
                                    var _a;
                                    var _b, _c, _d;
                                    return __generator(this, function (_e) {
                                        switch (_e.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                            case 1:
                                                _e.sent();
                                                _a = membership;
                                                switch (_a) {
                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 9];
                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 9];
                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 16];
                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 16];
                                                }
                                                return [3 /*break*/, 23];
                                            case 2: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 3:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_b = {},
                                                        _b[fieldCreatorId] = 'alice',
                                                        _b.someKey = 'someValue',
                                                        _b)))];
                                            case 4:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 5:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                            case 6:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                            case 7:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 8:
                                                _e.sent();
                                                return [3 /*break*/, 23];
                                            case 9: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 10:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_c = {},
                                                        _c[fieldCreatorId] = 'alice',
                                                        _c.someKey = 'someValue',
                                                        _c)))];
                                            case 11:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 12:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                            case 13:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 14:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 15:
                                                _e.sent();
                                                return [3 /*break*/, 23];
                                            case 16: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 17:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add((_d = {},
                                                        _d[fieldCreatorId] = 'alice',
                                                        _d.someKey = 'someValue',
                                                        _d)))];
                                            case 18:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 19:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                            case 20:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 21:
                                                _e.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 22:
                                                _e.sent();
                                                return [3 /*break*/, 23];
                                            case 23: return [2 /*return*/];
                                        }
                                    });
                                });
                            }
                            var user, userColRef, userDocRef, _i, _a, membership;
                            return __generator(this, function (_b) {
                                switch (_b.label) {
                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _b.sent();
                                        user = getAuthedFirestore('alice');
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                        _b.label = 2;
                                    case 2:
                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                        membership = _a[_i];
                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                    case 3:
                                        _b.sent();
                                        _b.label = 4;
                                    case 4:
                                        _i++;
                                        return [3 /*break*/, 2];
                                    case 5: return [2 /*return*/];
                                }
                            });
                        }); });
                        it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                            function testDifferentMembership(membership) {
                                return __awaiter(this, void 0, void 0, function () {
                                    var _a;
                                    var _b;
                                    return __generator(this, function (_c) {
                                        switch (_c.label) {
                                            case 0:
                                                _a = membership;
                                                switch (_a) {
                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 1];
                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 1];
                                                }
                                                return [3 /*break*/, 8];
                                            case 1: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 2:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add((_b = {},
                                                        _b[fieldCreatorId] = null,
                                                        _b.someKey = 'someValue',
                                                        _b)))];
                                            case 3:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                            case 4:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                            case 5:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 6:
                                                _c.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 7:
                                                _c.sent();
                                                return [3 /*break*/, 8];
                                            case 8: return [2 /*return*/];
                                        }
                                    });
                                });
                            }
                            var user, userColRef, userDocRef, _i, _a, membership;
                            return __generator(this, function (_b) {
                                switch (_b.label) {
                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                    case 1:
                                        _b.sent();
                                        user = getAuthedFirestore(undefined);
                                        userColRef = juntoRulesHelper.getCollectionRef(user);
                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                        _b.label = 2;
                                    case 2:
                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                        membership = _a[_i];
                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                    case 3:
                                        _b.sent();
                                        _b.label = 4;
                                    case 4:
                                        _i++;
                                        return [3 /*break*/, 2];
                                    case 5: return [2 /*return*/];
                                }
                            });
                        }); });
                        describe('/discussions/{discussionId}', function () {
                            var collectionDiscussions = 'discussions';
                            var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                { collection: collectionJunto, document: 'juntoId' },
                                { collection: collectionTopics, document: 'topicId' },
                                { collection: collectionDiscussions, document: 'discussionId' },
                            ]);
                            beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                        case 1:
                                            _a.sent();
                                            return [2 /*return*/];
                                    }
                                });
                            }); });
                            describe('authorized', function () {
                                it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    function testDifferentMembership(membership) {
                                        return __awaiter(this, void 0, void 0, function () {
                                            var _a;
                                            var _b;
                                            return __generator(this, function (_c) {
                                                switch (_c.label) {
                                                    case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                    case 1:
                                                        _c.sent();
                                                        _a = membership;
                                                        switch (_a) {
                                                            case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 2];
                                                        }
                                                        return [3 /*break*/, 9];
                                                    case 2: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                    case 3:
                                                        _c.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_b = {},
                                                                _b[fieldCreatorId] = 'alice',
                                                                _b.someKey = 'someValue',
                                                                _b)))];
                                                    case 4:
                                                        _c.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                    case 5:
                                                        _c.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                    case 6:
                                                        _c.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                    case 7:
                                                        _c.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                    case 8:
                                                        _c.sent();
                                                        return [3 /*break*/, 9];
                                                    case 9: return [2 /*return*/];
                                                }
                                            });
                                        });
                                    }
                                    var user, userColRef, userDocRef, _i, _a, membership;
                                    var _b;
                                    return __generator(this, function (_c) {
                                        switch (_c.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set((_b = {},
                                                    _b[fieldCreatorId] = 'alice',
                                                    _b.someKey = 'someValue',
                                                    _b))];
                                            case 1:
                                                _c.sent();
                                                user = getAuthedFirestore('alice');
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                _c.label = 2;
                                            case 2:
                                                if (!(_i < _a.length)) return [3 /*break*/, 5];
                                                membership = _a[_i];
                                                return [4 /*yield*/, testDifferentMembership(membership)];
                                            case 3:
                                                _c.sent();
                                                _c.label = 4;
                                            case 4:
                                                _i++;
                                                return [3 /*break*/, 2];
                                            case 5: return [2 /*return*/];
                                        }
                                    });
                                }); });
                                it('!isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    function testDifferentMembership(membership) {
                                        return __awaiter(this, void 0, void 0, function () {
                                            var _a;
                                            var _b, _c;
                                            return __generator(this, function (_d) {
                                                switch (_d.label) {
                                                    case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('bob', membership)];
                                                    case 1:
                                                        _d.sent();
                                                        _a = membership;
                                                        switch (_a) {
                                                            case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 9];
                                                            case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 9];
                                                            case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 9];
                                                            case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 9];
                                                        }
                                                        return [3 /*break*/, 16];
                                                    case 2: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                    case 3:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_b = {},
                                                                _b[fieldCreatorId] = 'bob',
                                                                _b.someKey = 'someValue',
                                                                _b)))];
                                                    case 4:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                    case 5:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                    case 6:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                    case 7:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                    case 8:
                                                        _d.sent();
                                                        return [3 /*break*/, 16];
                                                    case 9: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                    case 10:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userColRef.add((_c = {},
                                                                _c[fieldCreatorId] = 'bob',
                                                                _c.someKey = 'someValue',
                                                                _c)))];
                                                    case 11:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                    case 12:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                                    case 13:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                    case 14:
                                                        _d.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                    case 15:
                                                        _d.sent();
                                                        return [3 /*break*/, 16];
                                                    case 16: return [2 /*return*/];
                                                }
                                            });
                                        });
                                    }
                                    var user, userColRef, userDocRef, _i, _a, membership;
                                    var _b;
                                    return __generator(this, function (_c) {
                                        switch (_c.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set((_b = {},
                                                    _b[fieldCreatorId] = 'alice',
                                                    _b.someKey = 'someValue',
                                                    _b))];
                                            case 1:
                                                _c.sent();
                                                user = getAuthedFirestore('bob');
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                _c.label = 2;
                                            case 2:
                                                if (!(_i < _a.length)) return [3 /*break*/, 5];
                                                membership = _a[_i];
                                                return [4 /*yield*/, testDifferentMembership(membership)];
                                            case 3:
                                                _c.sent();
                                                _c.label = 4;
                                            case 4:
                                                _i++;
                                                return [3 /*break*/, 2];
                                            case 5: return [2 /*return*/];
                                        }
                                    });
                                }); });
                                describe('update', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                            function testDifferentMembership(membership) {
                                                return __awaiter(this, void 0, void 0, function () {
                                                    var _a;
                                                    return __generator(this, function (_b) {
                                                        switch (_b.label) {
                                                            case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                            case 1:
                                                                _b.sent();
                                                                _a = membership;
                                                                switch (_a) {
                                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 2];
                                                                }
                                                                return [3 /*break*/, 5];
                                                            case 2: return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                            case 3:
                                                                _b.sent();
                                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                            case 4:
                                                                _b.sent();
                                                                return [3 /*break*/, 5];
                                                            case 5: return [2 /*return*/];
                                                        }
                                                    });
                                                });
                                            }
                                            var user, userDocRef, _i, _a, membership;
                                            var _b;
                                            return __generator(this, function (_c) {
                                                switch (_c.label) {
                                                    case 0:
                                                        user = getAuthedFirestore('alice');
                                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                        return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set((_b = {},
                                                                _b[fieldCreatorId] = 'alice',
                                                                _b.someKey = 'someValue',
                                                                _b))];
                                                    case 1:
                                                        _c.sent();
                                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                        _c.label = 2;
                                                    case 2:
                                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                                        membership = _a[_i];
                                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                                    case 3:
                                                        _c.sent();
                                                        _c.label = 4;
                                                    case 4:
                                                        _i++;
                                                        return [3 /*break*/, 2];
                                                    case 5: return [2 /*return*/];
                                                }
                                            });
                                        }); });
                                        it('isJuntoMod', function () { return __awaiter(void 0, void 0, void 0, function () {
                                            function testDifferentMembership(membership) {
                                                return __awaiter(this, void 0, void 0, function () {
                                                    var _a;
                                                    return __generator(this, function (_b) {
                                                        switch (_b.label) {
                                                            case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                            case 1:
                                                                _b.sent();
                                                                _a = membership;
                                                                switch (_a) {
                                                                    case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                                    case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 5];
                                                                    case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 5];
                                                                    case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 5];
                                                                    case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 5];
                                                                }
                                                                return [3 /*break*/, 8];
                                                            case 2: return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                            case 3:
                                                                _b.sent();
                                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                            case 4:
                                                                _b.sent();
                                                                return [3 /*break*/, 8];
                                                            case 5: return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                                            case 6:
                                                                _b.sent();
                                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                            case 7:
                                                                _b.sent();
                                                                return [3 /*break*/, 8];
                                                            case 8: return [2 /*return*/];
                                                        }
                                                    });
                                                });
                                            }
                                            var user, userDocRef, _i, _a, membership;
                                            return __generator(this, function (_b) {
                                                switch (_b.label) {
                                                    case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                                    case 1:
                                                        _b.sent();
                                                        user = getAuthedFirestore('alice');
                                                        userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                        _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                        _b.label = 2;
                                                    case 2:
                                                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                                                        membership = _a[_i];
                                                        return [4 /*yield*/, testDifferentMembership(membership)];
                                                    case 3:
                                                        _b.sent();
                                                        _b.label = 4;
                                                    case 4:
                                                        _i++;
                                                        return [3 /*break*/, 2];
                                                    case 5: return [2 /*return*/];
                                                }
                                            });
                                        }); });
                                        it('juntoId - unify-america', function () { return __awaiter(void 0, void 0, void 0, function () {
                                            var juntoRulesHelper;
                                            return __generator(this, function (_a) {
                                                switch (_a.label) {
                                                    case 0:
                                                        juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                                            { collection: collectionJunto, document: 'unify-america' },
                                                            { collection: collectionTopics, document: 'topicId' },
                                                            { collection: collectionDiscussions, document: 'discussionId' },
                                                        ]);
                                                        return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                                    case 1:
                                                        _a.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(juntoRulesHelper
                                                                .getDocumentRef(getAuthedFirestore(undefined))
                                                                .update(updateDataMap))];
                                                    case 2:
                                                        _a.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(juntoRulesHelper
                                                                .getDocumentRef(getAuthedFirestore('alice'))
                                                                .update(updateDataMap))];
                                                    case 3:
                                                        _a.sent();
                                                        return [2 /*return*/];
                                                }
                                            });
                                        }); });
                                        return [2 /*return*/];
                                    });
                                }); });
                            });
                            it('is not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                function testDifferentMembership(membership) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var _a;
                                        var _b;
                                        return __generator(this, function (_c) {
                                            switch (_c.label) {
                                                case 0:
                                                    _a = membership;
                                                    switch (_a) {
                                                        case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 1];
                                                        case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 1];
                                                    }
                                                    return [3 /*break*/, 8];
                                                case 1: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add((_b = {},
                                                            _b[fieldCreatorId] = 'alice',
                                                            _b.someKey = 'someValue',
                                                            _b)))];
                                                case 3:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 4:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 5:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 6:
                                                    _c.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 7:
                                                    _c.sent();
                                                    return [3 /*break*/, 8];
                                                case 8: return [2 /*return*/];
                                            }
                                        });
                                    });
                                }
                                var user, userColRef, userDocRef, _i, _a, membership;
                                var _b;
                                return __generator(this, function (_c) {
                                    switch (_c.label) {
                                        case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set((_b = {},
                                                _b[fieldCreatorId] = null,
                                                _b.someKey = 'someValue',
                                                _b))];
                                        case 1:
                                            _c.sent();
                                            user = getAuthedFirestore(undefined);
                                            userColRef = juntoRulesHelper.getCollectionRef(user);
                                            userDocRef = juntoRulesHelper.getDocumentRef(user);
                                            _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                            _c.label = 2;
                                        case 2:
                                            if (!(_i < _a.length)) return [3 /*break*/, 5];
                                            membership = _a[_i];
                                            return [4 /*yield*/, testDifferentMembership(membership)];
                                        case 3:
                                            _c.sent();
                                            _c.label = 4;
                                        case 4:
                                            _i++;
                                            return [3 /*break*/, 2];
                                        case 5: return [2 /*return*/];
                                    }
                                });
                            }); });
                            describe('/discussion-participants/{participantId}', function () {
                                var collectionDiscussionsParticipants = 'discussion-participants';
                                var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                    { collection: collectionJunto, document: 'juntoId' },
                                    { collection: collectionTopics, document: 'topicId' },
                                    { collection: collectionDiscussions, document: 'discussionId' },
                                    {
                                        collection: collectionDiscussionsParticipants,
                                        document: 'discussionParticipantId',
                                    },
                                ]);
                                beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                            case 1:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                                it('different membership', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    function testDifferentMembership(membership) {
                                        return __awaiter(this, void 0, void 0, function () {
                                            var _a;
                                            return __generator(this, function (_b) {
                                                switch (_b.label) {
                                                    case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                    case 1:
                                                        _b.sent();
                                                        _a = membership;
                                                        switch (_a) {
                                                            case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                            case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 8];
                                                            case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 8];
                                                            case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 8];
                                                            case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 8];
                                                        }
                                                        return [3 /*break*/, 14];
                                                    case 2: return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                                    case 3:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                    case 4:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                                    case 5:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                    case 6:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                    case 7:
                                                        _b.sent();
                                                        return [3 /*break*/, 14];
                                                    case 8: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                    case 9:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                    case 10:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                    case 11:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                    case 12:
                                                        _b.sent();
                                                        return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                    case 13:
                                                        _b.sent();
                                                        return [3 /*break*/, 14];
                                                    case 14: return [2 /*return*/];
                                                }
                                            });
                                        });
                                    }
                                    var user, userColRef, userDocRef, _i, _a, membership;
                                    return __generator(this, function (_b) {
                                        switch (_b.label) {
                                            case 0:
                                                user = getAuthedFirestore('alice');
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                _b.label = 1;
                                            case 1:
                                                if (!(_i < _a.length)) return [3 /*break*/, 4];
                                                membership = _a[_i];
                                                return [4 /*yield*/, testDifferentMembership(membership)];
                                            case 2:
                                                _b.sent();
                                                _b.label = 3;
                                            case 3:
                                                _i++;
                                                return [3 /*break*/, 1];
                                            case 4: return [2 /*return*/];
                                        }
                                    });
                                }); });
                                it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    var discussionsHelper, user, userColRef, userDocRef;
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0:
                                                discussionsHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                                    { collection: collectionJunto, document: 'juntoId' },
                                                    { collection: collectionTopics, document: 'topicId' },
                                                    { collection: collectionDiscussions, document: 'discussionId' },
                                                ]);
                                                return [4 /*yield*/, discussionsHelper.makeDocCreator('alice')];
                                            case 1:
                                                _a.sent();
                                                return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'someValue' })];
                                            case 2:
                                                _a.sent();
                                                return [4 /*yield*/, juntoRulesHelper.createMembership('alice', 'nonmember')];
                                            case 3:
                                                _a.sent();
                                                user = getAuthedFirestore('alice');
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                            case 4:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 5:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                            case 6:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                            case 7:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                            case 8:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                                describe('request by uid', function () {
                                    it('request by same user', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('discussionParticipantId');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                case 5:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('request by different user', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('bob');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 5:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                });
                                it('!isLiveStream', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    var discussionsHelper, user, userColRef, userDocRef;
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0:
                                                discussionsHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                                    { collection: collectionJunto, document: 'juntoId' },
                                                    { collection: collectionTopics, document: 'topicId' },
                                                    { collection: collectionDiscussions, document: 'discussionId' },
                                                ]);
                                                return [4 /*yield*/, discussionsHelper.updateDocumentsField({ liveStreamInfo: null })];
                                            case 1:
                                                _a.sent();
                                                return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set({ someKey: 'someValue' })];
                                            case 2:
                                                _a.sent();
                                                user = getAuthedFirestore('alice');
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 3:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                            case 4:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 5:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 6:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 7:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                            });
                            describe('/chats/{messageId=**}', function () {
                                var collectionChats = 'chats';
                                var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                    { collection: collectionJunto, document: 'juntoId' },
                                    { collection: collectionTopics, document: 'topicId' },
                                    { collection: collectionDiscussions, document: 'discussionId' },
                                    { collection: collectionChats, document: 'messageId' },
                                ]);
                                beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                            case 1:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                                describe('authorized', function () {
                                    it('only authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'bob' }))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'alice' }))];
                                                case 6:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'bob' }))];
                                                case 7:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 8:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 9:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isParticipant', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeParticipant('juntoId', 'topicId', 'discussionId', 'alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'alice' }, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeDocCreator('alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('different membership', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        function testDifferentMembership(membership) {
                                            return __awaiter(this, void 0, void 0, function () {
                                                var _a;
                                                return __generator(this, function (_b) {
                                                    switch (_b.label) {
                                                        case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                        case 1:
                                                            _b.sent();
                                                            _a = membership;
                                                            switch (_a) {
                                                                case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 8];
                                                                case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 8];
                                                                case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 8];
                                                                case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 8];
                                                            }
                                                            return [3 /*break*/, 18];
                                                        case 2: return [4 /*yield*/, firebase.assertSucceeds(userColRef.add(originalDataMap))];
                                                        case 3:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                        case 4:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap))];
                                                        case 5:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                        case 6:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                        case 7:
                                                            _b.sent();
                                                            return [3 /*break*/, 18];
                                                        case 8: return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                        case 9:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                        case 10:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'bob' }))];
                                                        case 11:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                        case 12:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                        case 13:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'alice' }))];
                                                        case 14:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'bob' }))];
                                                        case 15:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                        case 16:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                        case 17:
                                                            _b.sent();
                                                            return [3 /*break*/, 18];
                                                        case 18: return [2 /*return*/];
                                                    }
                                                });
                                            });
                                        }
                                        var user, userColRef, userDocRef, _i, _a, membership;
                                        return __generator(this, function (_b) {
                                            switch (_b.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                    _b.label = 1;
                                                case 1:
                                                    if (!(_i < _a.length)) return [3 /*break*/, 4];
                                                    membership = _a[_i];
                                                    return [4 /*yield*/, testDifferentMembership(membership)];
                                                case 2:
                                                    _b.sent();
                                                    _b.label = 3;
                                                case 3:
                                                    _i++;
                                                    return [3 /*break*/, 1];
                                                case 4: return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                });
                                it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    var user, userColRef, userDocRef;
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0:
                                                user = getAuthedFirestore(undefined);
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 1:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                            case 2:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 3:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 4:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 5:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                            });
                            describe('/discussion-messages/{discussionMessageId}', function () {
                                var collectionMessages = 'discussion-messages';
                                var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                    { collection: collectionJunto, document: 'juntoId' },
                                    { collection: collectionTopics, document: 'topicId' },
                                    { collection: collectionDiscussions, document: 'discussionId' },
                                    { collection: collectionMessages, document: 'discussionMessageId' },
                                ]);
                                beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                            case 1:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                                describe('authorized', function () {
                                    it('only authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'bob' }))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'alice' }))];
                                                case 6:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'bob' }))];
                                                case 7:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 8:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 9:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isParticipant', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeParticipant('juntoId', 'topicId', 'discussionId', 'alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set({ creatorId: 'alice' }, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeDocCreator('alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                });
                                it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    var user, userColRef, userDocRef;
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0:
                                                user = getAuthedFirestore(undefined);
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 1:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                            case 2:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 3:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 4:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 5:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                            });
                            describe('/user-suggestions/{suggestionId=**}', function () {
                                var collectionUserSuggestions = 'user-suggestions';
                                var juntoRulesHelper = new firestore_rules_helper_1.JuntoRulesHelper(dbAdmin, [
                                    { collection: collectionJunto, document: 'juntoId' },
                                    { collection: collectionTopics, document: 'topicId' },
                                    { collection: collectionDiscussions, document: 'discussionId' },
                                    { collection: collectionUserSuggestions, document: 'suggestionId' },
                                ]);
                                beforeEach(function () { return __awaiter(void 0, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0: return [4 /*yield*/, juntoRulesHelper.getDocumentRef(dbAdmin).set(originalDataMap)];
                                            case 1:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                                describe('authorized', function () {
                                    it('only authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 5:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isDocCreator', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeDocCreator('alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('isParticipant', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0: return [4 /*yield*/, juntoRulesHelper.makeParticipant('juntoId', 'topicId', 'discussionId', 'alice')];
                                                case 1:
                                                    _a.sent();
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertSucceeds(userColRef.add({ creatorId: 'alice' }))];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 5:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 6:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('!isParticipant', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        var user, userColRef, userDocRef;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                case 1:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                case 2:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set(originalDataMap, { merge: true }))];
                                                case 3:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                case 4:
                                                    _a.sent();
                                                    return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                case 5:
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                    it('different membership', function () { return __awaiter(void 0, void 0, void 0, function () {
                                        function testDifferentMembership(membership) {
                                            return __awaiter(this, void 0, void 0, function () {
                                                var _a;
                                                return __generator(this, function (_b) {
                                                    switch (_b.label) {
                                                        case 0: return [4 /*yield*/, juntoRulesHelper.createMembership('alice', membership)];
                                                        case 1:
                                                            _b.sent();
                                                            _a = membership;
                                                            switch (_a) {
                                                                case firestore_rules_helper_1.Membership.owner: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.admin: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.mod: return [3 /*break*/, 2];
                                                                case firestore_rules_helper_1.Membership.facilitator: return [3 /*break*/, 10];
                                                                case firestore_rules_helper_1.Membership.member: return [3 /*break*/, 10];
                                                                case firestore_rules_helper_1.Membership.nonmember: return [3 /*break*/, 10];
                                                                case firestore_rules_helper_1.Membership.attendee: return [3 /*break*/, 10];
                                                            }
                                                            return [3 /*break*/, 20];
                                                        case 2: return [4 /*yield*/, firebase.assertSucceeds(userColRef.add({ creatorId: 'alice' }))];
                                                        case 3:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'bob' }))];
                                                        case 4:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.get())];
                                                        case 5:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set({ creatorId: 'alice' }, { merge: true }))];
                                                        case 6:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set({ creatorId: 'bob' }, { merge: true }))];
                                                        case 7:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                        case 8:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.delete())];
                                                        case 9:
                                                            _b.sent();
                                                            return [3 /*break*/, 20];
                                                        case 10: return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'alice' }))];
                                                        case 11:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userColRef.add({ creatorId: 'bob' }))];
                                                        case 12:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                                        case 13:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                                        case 14:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set({ creatorId: 'alice' }, { merge: true }))];
                                                        case 15:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set({ creatorId: 'bob' }, { merge: true }))];
                                                        case 16:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.set({ creatorId: null }, { merge: true }))];
                                                        case 17:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertSucceeds(userDocRef.update(updateDataMap))];
                                                        case 18:
                                                            _b.sent();
                                                            return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                                        case 19:
                                                            _b.sent();
                                                            return [3 /*break*/, 20];
                                                        case 20: return [2 /*return*/];
                                                    }
                                                });
                                            });
                                        }
                                        var user, userColRef, userDocRef, _i, _a, membership;
                                        return __generator(this, function (_b) {
                                            switch (_b.label) {
                                                case 0:
                                                    user = getAuthedFirestore('alice');
                                                    userColRef = juntoRulesHelper.getCollectionRef(user);
                                                    userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                    _i = 0, _a = Object.keys(firestore_rules_helper_1.Membership);
                                                    _b.label = 1;
                                                case 1:
                                                    if (!(_i < _a.length)) return [3 /*break*/, 4];
                                                    membership = _a[_i];
                                                    return [4 /*yield*/, testDifferentMembership(membership)];
                                                case 2:
                                                    _b.sent();
                                                    _b.label = 3;
                                                case 3:
                                                    _i++;
                                                    return [3 /*break*/, 1];
                                                case 4: return [2 /*return*/];
                                            }
                                        });
                                    }); });
                                });
                                it('not authorized', function () { return __awaiter(void 0, void 0, void 0, function () {
                                    var user, userColRef, userDocRef;
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0:
                                                user = getAuthedFirestore(undefined);
                                                userColRef = juntoRulesHelper.getCollectionRef(user);
                                                userDocRef = juntoRulesHelper.getDocumentRef(user);
                                                return [4 /*yield*/, firebase.assertFails(userColRef.add(originalDataMap))];
                                            case 1:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.get())];
                                            case 2:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.set(originalDataMap))];
                                            case 3:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.update(updateDataMap))];
                                            case 4:
                                                _a.sent();
                                                return [4 /*yield*/, firebase.assertFails(userDocRef.delete())];
                                            case 5:
                                                _a.sent();
                                                return [2 /*return*/];
                                        }
                                    });
                                }); });
                            });
                        });
                    });
                });
                return [2 /*return*/];
        }
    });
}); });

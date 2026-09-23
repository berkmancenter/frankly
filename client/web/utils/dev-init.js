// Delete the Firebase auth emulator's IndexedDB database on localhost so the
// auth emulator works correctly across hot-restarts.
if (window.location.hostname === "localhost") {
  window.indexedDB.deleteDatabase("firebaseLocalStorageDb");
}

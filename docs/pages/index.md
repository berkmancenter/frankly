# 🐣 Introduction

Welcome to the Frankly repo!

Frankly is an online deliberations platform that allows anyone to host video-enabled conversations about any topic. Key functionalities include:

- Matching participants into breakout rooms based on survey questions
- Creating structured event templates with different activities to take participants through

Frankly is a **Flutter** app with a **Firebase** backend.

<!-- See instructions [here](dev.md) for development. -->

# Overview

🪧 This README includes the following sections:

- **Overview**: An overview of the contents of the README and a description of the contents of major directories in the repo.
- **Running Frankly Locally for Development**: Instructions for setting up and running the app locally.
- **Testing**
- **Hosting Your Own Instance of Frankly**: Instructions for setting up a full production-ready instance of the app.
- **Troubleshooting and FAQ**

## Repo contents

This subsection provides a description of the contents of major directories in the repo.  
**💡 Important note:** For the rest of this README, most terminal commands should be executed from within the `client` directory (or subdirectories of it when specified).

- `client`
  The main Flutter app.

- `data_models`
  These are the data models used by both the client and Firestore.

- `firebase/functions`
  These are the Firebase Functions which are deployed on Google Cloud and called by the Flutter app. Firebase functions are built on top of Cloud Functions.

- `firestore/firestore.rules`
  This is a Firestore security rules file which defines which Firestore documents are readable by which users.

- `matching`
  Contains `lib/matching.dart`, which is the logic for matching participants into breakout rooms. See the README in this directory for links to helpful documentation on matching.


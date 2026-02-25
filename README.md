# template.ios

> **Branches:** [`main`](https://github.com/fastfiveproducts/template.ios/tree/main) contains the latest stable release.
> [`develop`](https://github.com/fastfiveproducts/template.ios/tree/develop) is the working branch.
> GitHub may show these branches as "behind" or "ahead" of each other — this is expected due to the squash-merge release process described [below](#branch-structure--change-approach).

## License

- Licensed under **AGPL-3.0 — with an author exception**
- See [LICENSE](./LICENSE) and [LICENSE-EXCEPTIONS.md](./LICENSE-EXCEPTIONS.md) for full terms
- For file-level authorship, licensing, and reuse details, see [CONTRIBUTING.md](./CONTRIBUTING.md)
- **FFP employees and internal contributors** should also carefully review [docs/CONTRIBUTING-FFP.md](./docs/CONTRIBUTING-FFP.md)

## App Dependencies

- Requires an implementation of Firebase, including Data Connect
- In particular, the FFP Firebase template: [template.firebase](https://github.com/fastfiveproducts/template.firebase)
- See [Firebase iOS setup](https://firebase.google.com/docs/ios/setup) as a reference

## Clone Project

- cd to your root Programs folder or directory
- clone project from GitHub via your preferred method (**main** branch)

## Dependencies to Run App via Xcode

1. Clone the FFP Firebase template and set up that project
   - Generate the SDK ("Add SDK to app") per instructions in that README
2. Install Xcode (if not already)
3. In Xcode:
   - Use "Add SDK to app" to add its generated code to the root of this project
   - Open the `.xcodeproj` file
   - Add the following Swift Packages:
     - DefaultConnector from FFP Firebase template project, "dataconnect-generated" directory
     - FirebaseAppCheck
     - FirebaseAuth
     - FirebaseCore
     - FirebaseDatabase
     - FirebaseFirestore
   - Add your secure `GoogleService-Info.plist` file to the project files root directory
     - Find this in the Firebase console, in "Project Settings" of the template project

## Run on iOS Simulator via Xcode (macOS)

1. Open the Xcode project file
2. Choose your simulator device
3. Build and run via **Product → Run**

## Run on iOS Device via Xcode (macOS)

1. Open the Xcode project file
2. Choose **Manage Run Destinations** and add your device
3. Select your physical device
4. Build and run via **Product → Run**

## Run on iOS Device via TestFlight

1. Install [TestFlight](https://apps.apple.com/us/app/testflight/id899247664) from the App Store
2. Use Xcode to **Archive** and **upload** the app to App Store Connect
3. Add testers via App Store Connect, and invite their Apple IDs
4. Accept the TestFlight invitation
5. Install the app from within TestFlight (appears like any other app)

## template Changes

### Branch Structure & Change Approach
- `develop` is the working/integration branch, where multiple feature branches get squash-merged
- `main` is the release/production branch, containing a clean linear history with one commit per release
- see your `OPERATE Developer Pipeline` document for detailed instructions

### Contribution Notes

All Swift files in this project follow a structured header format with attribution, versioning, and licensing details.

- **Public contributors**: see [CONTRIBUTING.md](./CONTRIBUTING.md)
- **FFP employees and internal contributors**: see [docs/CONTRIBUTING-FFP.md](./docs/CONTRIBUTING-FFP.md)

Please follow the documented file header formats and versioning guidelines.
All contributions must respect the AGPL-3.0 license and any stated exceptions.

### Contribution Workflow
Make feature branches from `develop` to work from; when that work is complete:
- rebase any changes that may have happened to `develop` back into your feature branch
- squash the feature branch commits into `develop` as one commit via a GH PR

When ready to release (`develop` to `main`):
- squash all of `develop`'s commits since last release
- make that one single commit on top of `main`

Results:
- `main` reflects the released state via a clean linear history with one commit per release
- but because the commit hashes will always differ between `main` and `develop`, git and GitHub sees `main` and `develop` as diverged (even though the content is equal after every release)

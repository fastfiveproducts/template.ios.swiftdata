# template.ios.swiftdata (contacts)
the Fast Five Products (FFP) LLC iOS application template App - SwiftData variant
- this template - https://github.com/fastfiveproducts/template.ios.swiftdata
- based on - https://github.com/fastfiveproducts/template.ios (v0.1.3)


##  License
- licensed under AGPL-3.0 — with an author exception
- see [LICENSE](./LICENSE) and [LICENSE-EXCEPTIONS.md](./LICENSE-EXCEPTIONS.md) for details


##  App Dependencies
- requires an implementation of Firebase Data Connect
- in particular the the FFP Firebase template (https://github.com/fastfiveproducts/template.firebase)
- see https://firebase.google.com/docs/ios/setup as a reference


##  Clone project
- open a terminal and cd to your root Programs folder or directory
- clone project from GitHub via your preferred method


##  Dependencies to run App via Xcode
- clone the FFP Firebase template, setup that project, and "Add SDK to app" to add its generated code to the root of this project
- add your secure FFP Firebase template `GoogleService-info.plist` file to the "CloudSupport" directory/group
  - find this in the Firebase console (https://console.firebase.google.com/), in the template Firebase project, in "Project Settings" 
- install Xcode if you have not already
- in Xcode, “Open a project or file” and open the Xcode project file.  Add the following packages:
  - the "Default Connector" from the FFP Firebase template
  - FirebaseAppCheck
  - FirebaseAuth
  - FirebaseCore
  - FirebaseDatabase
  - FirebaseFirestore


##  Run on an iOS Siumulator via Xcode on a Mac
- in Xcode, “Open a project or file” and open the Xcode project file
- choose your simulator device
- build and run via "Product -> Run"


##  Run on your iOS Device via Xcode on a Mac
- “Open a project or file” and open the Xcode project file
- when choosing your device, click "Manage Run Destinations" and add your device
- choose your device
- build and run via "Product -> Run"


##  Run on your iOS Device via Test Flight
- install TestFlight on your device: if you don't already have it:
        download the TestFlight app from the App Store (https://apps.apple.com/us/app/testflight/id899247664)
- you (or someone) needs to use Xcode to Archive the App, upload it to App Store Connect,
        and make the build available via Test Flight
- your Apple Id must be invited and/or added to the appropriate test group
- look for the invitation email from Apple and accept it; the app should then appear in TestFlight
- install app from within Test Flight; the app will then appear on your device like any other app

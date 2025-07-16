# template.ios.swiftdata (contacts)

The Fast Five Products (FFP) LLC iOS application template app — SwiftData variant

- this template: https://github.com/fastfiveproducts/template.ios.swiftdata
- was split-off from an early version of: https://github.com/fastfiveproducts/template.ios

---

## 🛡 License

- Licensed under **AGPL-3.0 — with an author exception**
- See [LICENSE](./LICENSE) and [LICENSE-EXCEPTIONS.md](./LICENSE-EXCEPTIONS.md) for full terms
- For file-level authorship, licensing, and reuse details, see [CONTRIBUTING.md](./CONTRIBUTING.md)
- **FFP employees and internal contributors** should also carefully review [docs/CONTRIBUTING-FFP.md](./docs/CONTRIBUTING-FFP.md)

---

## 📦 App Dependencies

- Requires an implementation of Firebase, including Data Connect
- In particular, the FFP Firebase template: https://github.com/fastfiveproducts/template.firebase
- See https://firebase.google.com/docs/ios/setup as a reference

---

## 🧱 Clone Project

```sh
cd ~/Programs
git clone https://github.com/fastfiveproducts/template.ios.swiftdata.git
```

---

## 🛠 Dependencies to Run App via Xcode

1. Clone the FFP Firebase template and set up that project
2. Install Xcode (if not already)
3. In Xcode:
   - Use "Add SDK to app" to add its generated code to the root of this project
   - Open the `.xcodeproj` file
   - Add the following Swift Packages:
     - Default Connector from FFP Firebase template
     - FirebaseAppCheck
     - FirebaseAuth
     - FirebaseCore
     - FirebaseDatabase
     - FirebaseFirestore
   - Add your secure `GoogleService-Info.plist` file to the `CloudSupport` group
     - Find this in the Firebase console, in "Project Settings" of the template project

---

## 📱 Run on iOS Simulator via Xcode (macOS)

1. Open the Xcode project file
2. Choose your simulator device
3. Build and run via **Product → Run**

---

## 📱 Run on iOS Device via Xcode (macOS)

1. Open the Xcode project file
2. Choose **Manage Run Destinations** and add your device
3. Select your physical device
4. Build and run via **Product → Run**

---

## 🚀 Run on iOS Device via TestFlight

1. Install TestFlight from the App Store:  
   https://apps.apple.com/us/app/testflight/id899247664
2. Use Xcode to **Archive** and **upload** the app to App Store Connect
3. Add testers via App Store Connect, and invite their Apple IDs
4. Accept the TestFlight invitation
5. Install the app from within TestFlight (appears like any other app)

---

## 🧾 Contribution Notes

All Swift files in this project follow a structured header format with attribution, versioning, and licensing details.  

- **Public contributors**: see [CONTRIBUTING.md](./CONTRIBUTING.md)  
- **FFP employees and internal contributors**: see [docs/CONTRIBUTING-FFP.md](./docs/CONTRIBUTING-FFP.md)

Please follow the documented file header formats and versioning guidelines.  
All contributions must respect the AGPL-3.0 license and any stated exceptions.


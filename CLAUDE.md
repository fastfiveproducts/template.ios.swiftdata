# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this iOS project.


## Build Command
```bash
xcodebuild build -scheme "default" -destination 'platform=iOS Simulator,name=iPhone 17' -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES -quiet
```

## Architecture

This is an iOS template app (SwiftUI, Swift 6, iOS 18+) with a Firebase backend using Data Connect (PostgreSQL) for primary data and Firestore for lightweight data.

### Project Structure
- ./ - this iOS app (Xcode project: `contacts.swiftdata.xcodeproj`)
- ../template.firebase/ — Firebase Data Connect schema, queries, and mutations
- ../dataconnect-generated/ — Auto-generated Swift connectors (read-only)

### App Layers

**Cloud Layer** (`Cloud/`)
- `CurrentUserService` — Singleton managing Firebase Auth state, user sign-in/out, and user account CRUD via Data Connect. Publishes `signInPublisher`/`signOutPublisher` for reactive state.
- `*Connector` classes — Bridge between app and Firebase services (Data Connect queries/mutations, Firestore)

**Repository Layer** (`Repositories/`, `RepositorySupport/`)
- `ListableStore<T>` — Generic base class for data stores with caching, placeholder support, and `Loadable<[T]>` state management (`.none`, `.loading`, `.loaded`, `.error`)
- Concrete stores (e.g., `AnnouncementStore`, `PostStores`) inherit from `ListableStore` and implement `fetchFromService`
- Stores observe sign-in/out via `SignInOutObserver` protocol

**Model Layer** (`Model/`, `ModelSupport/`)
- Domain models conforming to `Listable` protocol for store compatibility
- `Loadable<T>` enum for async state representation

**View Layer** (`Views/`, `ViewSupport/`)
- `LaunchView` — App entry point, initializes stores and manages splash/loading overlay
- `MainMenuView` / `MainTabView` — Two navigation patterns (template uses menu by default, comment out to switch)
- `VStackBox` — Standard content container used throughout
- `ViewConfig` — Centralized app configuration (brand name, colors, URLs, timing)

**ViewModel Layer** (`ViewModels/`)
- View-specific logic bridging views and services


## Key Patterns

**Navigation Style**: Developer chooses between `MainMenuView` and `MainTabView` in `LaunchView.swift`

**Store Initialization**: Stores are initialized in `LaunchView.task` and use singleton pattern (`*.shared`)

**File Headers**: All Swift files require structured headers with attribution and AGPL licensing (see `./CONTRIBUTING.md`)

**Git Workflow**: Feature branches from `develop`, squash-merge to `develop`, then squash to `main` for releases


## Testing
- Manual testing only (no automated test suite)


## Workflow
1. Claude: make code changes
2. Claude: build
3. Claude: fix compile errors and repeat

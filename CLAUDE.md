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

**File Headers**: All Swift files require structured headers with attribution and AGPL licensing (see `./CONTRIBUTING.md`).
When modifying an existing file:
- Add a "Modified by" line with your name and date (e.g., `Modified by Pete Maiser, Fast Five Products LLC, on 2/3/26.`)
- Update the template version to the current version with "(updated)" suffix (e.g., `Template v0.2.5 (updated) — `)
- Check other recently modified files to determine the current template version

When creating a new file file:
- Add a "Created by" line with your name and date (e.g., `Created by by Pete Maiser, Fast Five Products LLC, on 2/3/26.`)
- Start the template version with the current version (e.g., `Template v0.2.5 — Fast Five Products LLC's public AGPL template.`)

**Git Workflow**: Feature branches from `develop`, squash-merge to `develop`, then squash to `main` for releases


## Code Review

When asked to "do a code review", follow this process:

### Categories to Evaluate
1. **Bugs** — Logic errors, copy-paste mistakes, typos in code
2. **Security** — Auth gaps, data exposure, input validation, secrets in source control
3. **Error Handling** — Unhandled throws, force unwraps, silent failures, missing edge cases
4. **Deprecated APIs** — Use of deprecated functions
5. **Performance** — Redundant computation, missing caching, unbounded queries, expensive operations
6. **Style** — Inconsistencies with the rest of the existing codebase
7. **Licensing** — Attribution, copyright headers, commercial risks

### Output Format
Present findings as a numbered table with columns: ID, Category, Priority, Summary, and File(s). Use short IDs (e.g. B1, S1, E1, D1, P1, C1, L1) by category. Prioritize bugs and security issues first.

### Workflow
1. Explore the repo thoroughly, then present the full findings table
2. Discuss each finding with the user — they will decide to fix, close, or defer each one
3. For each fix: edit → build → commit → push
4. After each commit, regenerate the tracking table with updated statuses
5. Use `pbcopy` (with `sed 's/[[:space:]]*$//'`) when asked to copy tables to clipboard


## Testing
- Manual testing only (no automated test suite)


## Workflow
1. Claude: make code changes
2. Claude: build
3. Claude: fix compile errors and repeat

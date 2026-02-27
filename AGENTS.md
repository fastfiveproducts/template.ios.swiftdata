# AGENTS.md

This file provides guidance to AI tools such as Claude Code (claude.ai/code), Google Gemini CLI, OpenAI Codex CLI, and Cursor when working with code in this project.
Based on Fast Five Products LLC's public AGPL template for Apple development, version v0.2.7 (updated)


## Build Command
```bash
xcodebuild build -scheme "default" -destination 'platform=iOS Simulator,name=iPhone 17' -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES -quiet
```

## Architecture

This is an iOS template app (SwiftUI, Swift 6, iOS 18+) with a Firebase backend using Data Connect (PostgreSQL) for primary data and Firestore for lightweight data.

### Project Structure
- ./ - this iOS app (Xcode project: `template.xcodeproj`)
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
- Add a "Created by" line with your name and date (e.g., `Created by Pete Maiser, Fast Five Products LLC, on 2/3/26.`)
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

### Cross-Referencing
Before reporting any finding, cross-reference it against:
1. **Existing GitHub issues** (open and closed) — if a finding is already tracked by an issue, omit it
2. **Previous code review comments** — check prior code review issues (e.g., the body and comments of issues titled "code review") for findings that were previously reported and given a disposition (fixed, deferred, won't-fix, or explained). If a GitHub issue already exists for a finding (that isn't closed) or the finding was dispositioned won't-fix in a prior review, omit it unless circumstances have materially changed.  For other dispositions, report the past disposition.

Focus on genuinely new findings not already tracked or dispositioned.

### Workflow
1. Explore the repo thoroughly, cross-reference against existing issues and prior code review dispositions, then present the filtered findings table
2. Discuss each finding with the user — they will decide to fix, close, or defer each one
3. For each fix: edit → build → commit → push
4. After each commit, regenerate the tracking table with updated statuses
5. Use `pbcopy` (with `sed 's/[[:space:]]*$//'`) when asked to copy tables to clipboard

**Table regeneration rule**: Every regenerated table must include all original columns (ID, Category, Priority, Summary, File(s)) plus a Status column. Never abbreviate or drop columns — the table should be self-contained without cross-referencing a previous version.


## Testing
- Manual testing only (no automated test suite)


## Workflow (develop)

Work happens on feature branches off `develop`. Typical flow:

> **Examples for User Initiate**: "Start work on issue 42", "Create a branch for issue #15"

```bash
# 1. Create a feature branch from a GitHub issue
git fetch origin
git checkout develop
git pull origin develop
gh issue develop <issue-number> --base develop --checkout
```

2. Agent: make code changes
3. Agent: build (`xcodebuild ...`)
4. Agent: fix compile errors and repeat
5. User:  review, compile-to-simulators and test
6. User:  request commit and push
7. Agent: commit and push the feature branch
8. Agent: create a PR targeting `develop` via `gh pr create --base develop`
9. User: reviews and squash-merges the PR in GitHub
10. Agent: refresh develop locally:

```bash
git checkout develop
git pull origin develop
```

**Code Review**:  User may ask for a Code Review leading to a feature-branch merge, or at any time


## Release Process (develop to main)

Each commit on `main` represents a published release. Squash all of develop into a single commit on main.

> **Example for User to Initiate**: "Release develop to main as v0.3.1"

```bash
# 1. Ensure develop is current
git checkout develop
git pull origin develop

# 2. Checkout main and pull
git checkout main
git pull origin main

# 3. Squash merge develop into main
git merge --squash develop
git commit -m "$(cat <<'EOF'
Release vX.Y.Z

<release notes body>
EOF
)"
git push origin main

# 4. If step 3 fails with conflicts (common after file renames/moves):
git reset --hard origin/main
git read-tree --reset -u develop
git commit -m "$(cat <<'EOF'
Release vX.Y.Z

<release notes body>
EOF
)"
git push origin main

# 5. Verify content equivalence (should return nothing):
git diff main..develop
```

**Commit message**: The first line must be exactly `Release vX.Y.Z` with no suffix — this is the title GitHub displays. After a blank line, add the release notes body. Review `git log main..develop --oneline` and prior release messages on main (`git log main --oneline`) to match the established style. Group changes into categories (e.g. **Feature Area**, **Code Quality**, **Infrastructure**) with concise bullet points summarizing each PR/commit. Also look for previous commit messages that duplicate or cancel each other out and squash them. The body should read as release notes — what changed and why, not individual commit details.

After release, main and develop will have different commit hashes but identical content. GitHub may report main as "behind"/"ahead" of develop — this is expected and should be ignored.


## Common Issues
- **Making small changes without updating the version number (and ideally date) in the file header**: Not updating the date may make it harder for apps that use the template to recognize a change has happened when upgrading.
- **Using wrong build command**:  Always use the build command included above.  When agents invent their own they often include a Simulator that isn't installed, and the build command doesn't report back a problem so the process takes the full time-out period before it can move on.


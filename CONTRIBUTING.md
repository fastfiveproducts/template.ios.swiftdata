# Contributing Guidelines

This repository and derivations thereof may include open-source templates, internal apps, and client-facing software.  To maintain consistency and legal clarity, we follow structured header practices and versioning for all Swift source files.

---

## 📄 Template File Headers and Versioning

All Swift files should include a standard file header that provides authorship, licensing, and version context.

### General Rules

- **NEW files**: Use the current year.
- **CHANGED files**: Append new years (e.g., `2025, 2026`) to reflect modification history.
- **Template version**: Update the version number for any file added to or modified in the TEMPLATE project.

Version numbers in the examples below are example-only and need to be updated appropirately

---

## ✅ Header Case 1a: Original FFP TEMPLATE files

```swift
//
//  [Filename].swift
//
//  Created by [Template Developer Name], Fast Five Products LLC, on M/D/YY.
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//
```

---

## ✅ Header Case 1b: Adding new files to a TEMPLATE project

```swift
//
//  [Filename].swift
//
//  Created by [Template Developer Name][, Company Name if applicable], on M/D/YY.
//      Template v0.2.4 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 [App Developer Name][, Company Name if applicable].
//  All rights reserved.
//
//  This file is part of an open-source application based on a template originally released
//  under the GNU Affero General Public License v3.0 by Fast Five Products LLC.
//
//  This file is licensed under the AGPL-3.0 and must remain open when modified or redistributed.
//
//  See the LICENSE file at the root of this repository for full terms.
//  Please attribute changes clearly when redistributing.
//
```

---

## ✅ Header Case 2: TEMPLATE files changed WITHIN an APP

Keep the existing **Case 1** header
```swift
//  Created by [Template Developer Name], Fast Five Products LLC, on M/D/YY.
```

And add this line immediately below it: 
```swift
//  Modified by [App Developer Name][, Company Name if applicable], on M/D/YY.
```

---

## ✅ Header Case 3: NEW app files

```swift
//
//  [Filename].swift
//
//  Created by [App Developer Name][, Company Name if applicable], on M/D/YY.
//
//  Copyright © 2025 [App Developer Name][, Company Name if applicable].
//  All rights reserved.
//
//  This file is part of an open-source application based on a template originally released
//  under the GNU Affero General Public License v3.0 by Fast Five Products LLC.
//
//  This file is licensed under the AGPL-3.0 and must remain open when modified or redistributed.
//
//  See the LICENSE file at the root of this repository for full terms.
//  Please attribute changes clearly when redistributing.
//
```

---

Please keep headers current and consistent when submitting changes. For questions, contact: **licenses@fastfiveproducts.llc**

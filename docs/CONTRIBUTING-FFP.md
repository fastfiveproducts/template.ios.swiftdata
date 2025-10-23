# Contributing Guidelines (Internal - Fast Five Products LLC)

This guide is for FFP employees and internal contributors working on template projects, client work, or apps.  
It includes header guidance for both AGPL and proprietary use cases, and seeks to preserver our author exception when possible.

---

### 📄 Template File Headers and Versioning

All Swift files should include a standard file header that provides authorship, licensing, and version context.

### General Rules

- **NEW files**: Use the current year.
- **CHANGED files**: Append new years (e.g., `2025, 2026`) to reflect modification history.
- **Template version**: Update the version number for any file added to or modified in the TEMPLATE project.

Version numbers in the examples below are example-only and need to be updated appropirately

---

## ✅ Header Case 1: Adding new files to a TEMPLATE project

Even though these are **new**, they are still **FFP TEMPLATE files**, so please see **Case 1a** in the public [CONTRIBUTING.md](../CONTRIBUTING.md)  file — same format.

---

## ✅ Header Case 2: TEMPLATE files changed WITHIN an APP (open source)

If the app is also open source, please see **Case 2** in the public [CONTRIBUTING.md](../CONTRIBUTING.md)  file — same changes.  This will retain the FFP exception on **FFP TEMPLATE files**, and carry forward without it on TEMPLATE files created by others.  If this particular TEMPLATE file was created by others, the full AGPL-3.0 applies so this file must remain open when modified or redistributed.

---

## ✅ Header Case 3: NEW app files (open source)

If the app is also open source, use the **Case 1a** header from the public [CONTRIBUTING.md](../CONTRIBUTING.md)  file - thus adding the exception to this new file - but remove this template version line:
```swift
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
```

---

## ✅ Header Case 4: FFP TEMPLATE files changed WITHIN an APP (proprietary)

```swift
//
//  [Filename].swift
//
//  Template file created by [Template Developer Name], Fast Five Products LLC, on M/D/YY.
//  Modified by [App Developer Name], Fast Five Products LLC, on M/D/YY.
//      Template v0.2.3 (modified) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a derivative work based on code originally released
//  under the GNU Affero General Public License v3.0.
//
//  This version is licensed for proprietary or internal use by Fast Five Products LLC,
//  and is not subject to the AGPL or any open-source license.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//
```

---

## ✅ Header Case 5: NEW app files (proprietary, FFP)

```swift
//
//  [Filename].swift
//
//  Template file created by [Template Developer Name], Fast Five Products LLC, on M/D/YY.
//      Template v0.2.4 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This app is based on software originally released under the GNU Affero General Public License v3.0,
//  with an author exception for proprietary use by Fast Five Products LLC.
//
//  This file is provided under commercial licensing terms to [Client Name]
//. and is not subject to the AGPL.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//
```

---

## ✅ Header Case 6: NEW app files (proprietary, shared)

```swift
//
//  [Filename].swift
//
//  Created by [Developer Name], on M/D/YY.
//  Fast Five Products LLC for [Client Name]
//
//  Copyright © 2025 Fast Five Products LLC and [Client Name]. All rights reserved.
//
//  This app is based on software originally released under the GNU Affero General Public License v3.0,
//  with an author exception for proprietary use by Fast Five Products LLC.
//
//  This file was developed specifically for [Client Name] and is jointly owned by
//  Fast Five Products LLC and [Client Name] and is not subject to the AGPL.
//  Each party may use and modify this file for commercial purposes.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//
```

---

Please keep headers current and consistent.  
Questions? Email **licenses@fastfiveproducts.llc**

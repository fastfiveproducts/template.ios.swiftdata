# Contributing Guidelines (Internal - Fast Five Products LLC)

This guide is for FFP employees and internal contributors working on template projects, client work, or apps.
It includes header guidance for both AGPL and proprietary use cases, and seeks to preserve our author exception when possible.

For day-to-day workflow details (Modified-by lines, version updates, git workflow), see [AGENTS.md](../AGENTS.md).

---

## Open-Source Use Cases

### Adding New Files to a Template Project

These are still **FFP template files**, so use the **FFP Template Files** header from the public [CONTRIBUTING.md](../CONTRIBUTING.md) — same format.

### Template Files Changed Within an Open-Source App

Use the **FFP Template Files** header from the public [CONTRIBUTING.md](../CONTRIBUTING.md) with a "Modified by" line. This retains the FFP exception on FFP template files, and carries forward without it on template files created by others. If this particular template file was created by others, the full AGPL-3.0 applies so this file must remain open when modified or redistributed.

### New App Files (Open Source)

Use the **FFP Template Files** header from the public [CONTRIBUTING.md](../CONTRIBUTING.md) — thus adding the exception to this new file — but remove the template version line:
```swift
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
```

---

## Proprietary Use Cases

### Template Files Changed Within a Proprietary App

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

### New App Files (Proprietary, FFP)

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
//  and is not subject to the AGPL.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//
```

### New App Files (Proprietary, Shared with Client)

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

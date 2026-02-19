# Contributing Guidelines

This repository and derivations thereof may include open-source templates, internal apps, and client-facing software.  To maintain consistency and legal clarity, we follow structured header practices for all Swift source files.

For day-to-day workflow details (Modified-by lines, version updates, git workflow), see [AGENTS.md](./AGENTS.md).

---

## File Headers

All Swift files should include a standard file header that provides authorship, licensing, and version context. There are two header formats depending on who authored the file.

---

### FFP Template Files

Use this header for files created by Fast Five Products LLC for the template. It includes the AGPL license and the FFP author exception.

```swift
//
//  [Filename].swift
//
//  Created by [Developer Name], Fast Five Products LLC, on M/D/YY.
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

When modifying an FFP template file within an app, keep the existing header and add a "Modified by" line below the "Created by" line. See [AGENTS.md](./AGENTS.md) for details.

---

### Community Contributor Files

Use this header for files created by contributors other than Fast Five Products LLC. This header does not include the FFP author exception.

```swift
//
//  [Filename].swift
//
//  Created by [Developer Name][, Company Name if applicable], on M/D/YY.
//      Template v0.3.1 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 [Developer Name][, Company Name if applicable].
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

**FFP employees and internal contributors** should also review [docs/CONTRIBUTING-FFP.md](./docs/CONTRIBUTING-FFP.md) for proprietary use cases.

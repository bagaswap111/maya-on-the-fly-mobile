# Information Architecture: [Product/Application Name]

**Document:** SoT-2 | **Derived From:** SoT-1 (SRS) | **Status:** Draft | **Last Updated:** [Date]

## 1. Document Overview

### 1.1 Purpose
[What this IA defines: pages, navigation hierarchy, screen structure, routing. The structural blueprint downstream artifacts (Design System, User Flows, HiFi Prototype) build on.]

### 1.2 Related Sources of Truth
| SoT | Reference | Relationship |
|-----|-----------|--------------|
| SRS (SoT-1) | docs/srs.md | This IA realizes the features/scope defined there |
| Design System (SoT-3) | docs/design_system.md | Visual language applied to these pages |
| User Flows (SoT-4) | docs/user_flows/ | Flows traverse these pages |

## 2. Product Structure

### 2.1 Product Modules
| Module | Description | Key Features |
|--------|-------------|--------------|
| [Module name] | [What it groups] | [F00X IDs from SRS] |

### 2.2 Module Hierarchy
```
[Application Name]
├── [Module 1]
│   ├── [Sub-module / page]
│   └── [Sub-module / page]
└── [Module 2]
    └── [Sub-module / page]
```

## 3. Site Map

### 3.1 Navigation Tree
```
[Root]
├── /login                    (public)
├── /[default-landing]        (authenticated)
├── /[section-1]
└── /[section-2]
```

### 3.2 Navigation Type
- **Primary navigation:** [e.g., permanent left sidebar / top bar]
- **Secondary navigation:** [e.g., dropdown, tabs]
- **Behavior:** [e.g., collapses on tablet, hamburger below 768px]
- **Breadcrumbs:** [Enabled/disabled + why]

## 4. Page Inventory

| Page ID | Page Name | Route | Access | Module |
|---------|-----------|-------|--------|--------|
| PAGE-001 | [Name] | /login | Public | Auth |
| PAGE-002 | [Name] | /[route] | Authenticated | [Module] |
| PAGE-003 | [Name] | /[route] | Authenticated; [role] | [Module] |
| — | Redirector | /redirector | Session-aware | System |
| — | 404 | * | Public | System |

## 5. Page Definitions

### PAGE-001: [Page Name]
- **Route:** /[route]
- **Access:** [Public / Authenticated / Role]
- **Purpose:** [One sentence]
- **Key UI elements:** [e.g., form, table, chart, modal]
- **Primary actions:** [e.g., submit, add, filter]
- **Related use cases:** UC-[ID], UC-[ID]
- **Related features:** F00[X]

### PAGE-002: [Page Name]
- **Route:** /[route]
- **Access:** [Access]
- **Purpose:** [One sentence]
- **Key UI elements:** [Elements]
- **Primary actions:** [Actions]
- **Related use cases:** UC-[ID]
- **Related features:** F00[X]

## 6. User Navigation Flows

*High-level how users move between pages. Detailed step-level flows live in User Flows (SoT-4).*

| From Page | To Page | Trigger | Notes |
|-----------|---------|---------|-------|
| PAGE-001 | PAGE-002 | [e.g., Successful login] | [Redirect logic] |
| PAGE-002 | PAGE-003 | [e.g., Click sidebar item] | |

## 7. Content Hierarchy

*How information is prioritized within key pages.*

### [PAGE-002]: [Page Name]
| Priority | Content | Placement |
|----------|---------|-----------|
| 1 (primary) | [e.g., Transaction input] | [e.g., Left panel] |
| 2 (secondary) | [e.g., Cart summary] | [e.g., Right panel] |
| 3 (tertiary) | [e.g., Stock status badge] | [e.g., Inline] |

## 8. Routing Conventions

- **Route pattern:** [e.g., `/[section]/[resource]`, kebab-case]
- **Default landing (authenticated):** /[route]
- **Default landing (public):** /[route]
- **Auth guard behavior:** [e.g., unauthenticated → /login]
- **Not-found behavior:** [e.g., catch-all `*` → 404 page]
- **Redirect strategy:** [e.g., session-aware redirector on root]

## 9. Traceability Matrix (SRS → IA)

| SRS Feature | Page(s) | How the Page Satisfies the Feature |
|-------------|---------|------------------------------------|
| F001 | PAGE-001, PAGE-002 | [Mapping explanation] |
| F002 | PAGE-003 | [Mapping explanation] |
| F003 | PAGE-004 | [Mapping explanation] |
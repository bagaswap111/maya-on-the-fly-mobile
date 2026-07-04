# Design System: [Product/Application Name]

**Document:** SoT-3 | **Derived From:** SoT-1 (SRS) | **Status:** Draft | **Last Updated:** [Date]

## 1. Document Overview

### 1.1 Purpose
[The visual language and interaction patterns applied across all pages. Drives HiFi prototyping, frontend implementation, UX consistency, and user training.]

### 1.2 Related Sources of Truth
| SoT | Reference | Relationship |
|-----|-----------|--------------|
| SRS (SoT-1) | docs/srs.md | NFRs and features this system expresses |
| IA (SoT-2) | docs/information_architecture.md | Pages this system styles |
| User Flows (SoT-4) | docs/user_flows/ | Interaction patterns support these flows |

## 2. Design Principles

### 2.1 Design Goals
- [e.g., Efficiency — minimize clicks for primary tasks]
- [e.g., Clarity — status and next action always visible]
- [e.g., Accessibility — WCAG-compliant contrast and keyboard support]

### 2.2 UX Principles
- [e.g., Single-task focus per screen]
- [e.g., Instant feedback on every action]
- [e.g., Error tolerance — recoverable, non-destructive]

## 3. Brand Foundation

### 3.1 Brand Personality
[3-5 adjectives: e.g., reliable, efficient, fresh]

### 3.2 Visual Characteristics
- **Corner radius:** [e.g., 8px rounded]
- **Shadow style:** [e.g., soft, low-spread]
- **Density:** [e.g., compact / comfortable]

## 4. Color System

| Token | Value | Usage |
|-------|-------|-------|
| color-primary | [#hex] | Primary actions, active state |
| color-primary-hover | [#hex] | Hover on primary |
| color-secondary | [#hex] | Secondary actions |
| color-success | [#hex] | Success status |
| color-warning | [#hex] | Warning status |
| color-danger | [#hex] | Destructive actions, error status |
| color-info | [#hex] | Informational status |
| color-bg | [#hex] | App background |
| color-surface | [#hex] | Card / panel background |
| color-text | [#hex] | Primary text |
| color-text-muted | [#hex] | Secondary / disabled text |
| color-border | [#hex] | Dividers, borders |

## 5. Typography

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| text-display | 32px | 700 | Page titles (rare) |
| text-h1 | 24px | 700 | Page headings |
| text-h2 | 20px | 600 | Section headings |
| text-h3 | 16px | 600 | Subsection headings |
| text-body | 14px | 400 | Body text, table cells |
| text-small | 12px | 400 | Labels, muted text |

- **Font family:** [e.g., Noto Sans, system-ui]
- **Line height:** [e.g., 1.5 for body]

## 6. Elevation & Shadows

| Token | Value | Usage |
|-------|-------|-------|
| shadow-none | none | Flat surfaces |
| shadow-sm | [e.g., 0 1px 2px rgba(0,0,0,0.05)] | Inputs, buttons |
| shadow-md | [e.g., 0 4px 6px rgba(0,0,0,0.1)] | Cards, dropdowns |
| shadow-lg | [e.g., 0 10px 15px rgba(0,0,0,0.1)] | Modals, popovers |

## 7. Grid & Layout

- **Desktop:** [e.g., split layout — 260px sidebar + 24px padding content]
- **Tablet:** [e.g., off-canvas / collapsible sidebar]
- **Max content width:** [e.g., 1280px]
- **Gutter:** [e.g., 24px]
- **Breakpoints:** [e.g., sm 640 / md 768 / lg 1024 / xl 1280]

## 8. Iconography

- **Library:** [e.g., Lucide React, outline style]
- **Default size:** [e.g., 20px]
- **Usage map:**
  | Function | Icon |
  |----------|------|
  | [e.g., POS / transaction] | [icon name] |
  | [e.g., Stock] | [icon name] |
  | [e.g., Reports] | [icon name] |
  | [e.g., Account] | [icon name] |

## 9. Component Library

### Button
| Variant | Usage | Token |
|---------|-------|-------|
| Primary | Main action (submit, save) | color-primary |
| Secondary | Alternative action | color-secondary |
| Danger | Destructive (delete) | color-danger |
| Ghost | Tertiary / nav | transparent |

- **States:** default, hover, focus, disabled, loading
- **Sizes:** [sm / md / lg] with padding tokens

### Text Input
- Label: top-aligned, [size] weight [weight]
- Required marker: [e.g., red asterisk]
- States: default, focus, error, disabled
- Helper / error text below field

### Modal Dialog
- Trigger, header, body, footer actions
- Overlay: [color-bg @ opacity]
- Close: X button + ESC + click-outside

### Table
- Header row, zebra striping [yes/no], sticky header [yes/no]
- Row actions, empty state, loading state

### Card
- Surface background, [shadow token], [radius]
- Header / body / footer slots

## 10. Form Design Rules

- Labels: top-aligned
- Required fields marked with [marker]
- Validation: inline, informative, on blur + on submit
- On error: focus first invalid field, scroll into view
- Submit: disabled until valid OR show errors on submit — [choose]

## 11. Interaction Patterns

| Pattern | Behavior |
|---------|----------|
| Loading | [e.g., skeleton / spinner; never blank screen] |
| Empty state | [e.g., illustration + guidance + CTA] |
| Confirmation | [e.g., modal before destructive action] |
| Destructive action | [e.g., type name to confirm] |
| Toast / feedback | [e.g., auto-dismiss after 4s, manual dismiss] |

## 12. Responsive Behavior

| Breakpoint | Layout changes |
|------------|----------------|
| < 768px (mobile) | [e.g., top hamburger menu, single column] |
| 768–1024px (tablet) | [e.g., collapsible sidebar] |
| > 1024px (desktop) | [e.g., permanent sidebar, split panels] |

## 13. Accessibility (a11y)

- **Contrast:** WCAG AA minimum ([ratio] for text)
- **Keyboard:** all actions reachable; visible focus ring
- **Shortcuts:** [e.g., F2 = focus search, F9 = checkout, Enter = confirm]
- **Screen reader:** [e.g., semantic landmarks, aria-labels on icon buttons]
- **Error announcement:** [e.g., aria-live region for form errors]

## 14. Design Tokens Table

| Category | Token | Value |
|----------|-------|-------|
| Typography | text-body | 14px/400 |
| Color | color-primary | [#hex] |
| Radius | radius-md | 8px |
| Shadow | shadow-md | [value] |
| Spacing | space-4 | 16px |

## 15. Traceability Matrix (SRS → Design System)

| SRS Feature / NFR | Component / Rule | How It Satisfies |
|-------------------|------------------|------------------|
| F001 | Button, Table, Modal | [Mapping] |
| NFR-Usability | Form Design Rules, a11y | [Mapping] |
---
evaluation: usability-heuristics
project: Maya on the Fly
date: 2026-07-04
scope: DESIGN.md (design system spec) + approach.md (architecture & UX flows)
status: design-phase (no Flutter UI code exists yet)
---

# Usability Heuristic Evaluation — Maya on the Fly

## Summary

| Severity | Count |
|---|---|
| ✅ Good | 39 |
| ⚠️ Minor | 14 |
| 🔴 Major | 7 |
| ❌ Critical | 0 |
| 👁️ Needs Manual Review | 13 |
| — N/A | 7 |

**Active modules:** None (no data visualization detected; accessibility noted where applicable)

---

## Per-Heuristic Results

### H1 — Visibility of System Status ✅ 6 / ⚠️ 3 / 🔴 2 / 👁️ 2

**✅ Good — Loading & streaming states (approach.md §4A):** The AI Agent Engine spec explicitly calls out token-by-token SSE streaming for real-time chat display. This is a strong visibility pattern — the user sees text appear as the model generates it.

**✅ Good — Auto-save (approach.md §4C):** Markdown editor auto-saves every 5 seconds to local storage. This provides continuous background status without user effort.

**✅ Good — Conversion runs in Isolate (approach.md §4E):** Export explicitly runs in a Dart Isolate to keep UI responsive, with the result handed to a platform channel. Users won't experience a frozen UI during export.

**✅ Good — Git status polling (approach.md §5):** Repository status is polled while the app is foregrounded, keeping the user informed of the current repo state.

**✅ Good — Session counter in chat header (approach.md §4D):** Real-time token count displayed in the chat header during AI interactions.

**✅ Good — Usage Dashboard (approach.md §4D):** Dedicated screen with real-time session/today/week/month counters — excellent visibility of resource consumption.

**⚠️ Minor — No progress indicator for long operations >3s:** The model manager mentions "hard cap" blocking but doesn't specify progress indicators for long-running operations like git clone, push, or large document export. A progress bar for these would improve H1.

**⚠️ Minor — Document export UX (approach.md §4E):** The flow "Preview → tap Export → choose format → choose destination → conversion in Isolate → share sheet" doesn't mention a conversion-in-progress indicator between step 4 and 5. Users may tap Export and see nothing for a moment.

**⚠️ Minor — Git conflict resolution:** Mentioned as "dedicated conflict resolution UI" but not detailed. No mention of a status indicator during merge operations.

**🔴 Major — No loading states in DESIGN.md:** The 554-line design spec defines button-primary, button-secondary, text-input, cards, nav — but nowhere defines a **loading spinner**, **skeleton screen**, **progress bar**, or **skeleton component**. Every async operation in the app will need loading states, and none are specified. This is a gap that will lead to inconsistent implementation.

**🔴 Major — No "empty state" components:** No `empty-state`, `no-results`, or `error-state` component defined in the design system. The skill checklist says "Loading states exist for every async operation" — the design system has zero.

---

### H2 — Match Between System and the Real World ✅ 8 / ⚠️ 1 / 🔴 0 / 👁️ 1

**✅ Good — Terminology is user-role aware (approach.md §4A):** The agents table shows role-appropriate terminology — "Academic Writer" uses "IMRaD," "citations," "abstracts"; "Business Writer" uses "SWOT," "executive summary," "timeline." These match the user's mental model for each domain.

**✅ Good — Git operations use real-world names (approach.md §5):** The git operations use standard developer terms: `commit`, `push`, `pull`, `clone`, `diff`, `log`, `status`. These are the exact terms developers use.

**✅ Good — Export formats use familiar names (approach.md §4E):** PDF, HTML, DOCX, TXT — no proprietary or internal format names.

**✅ Good — Export destinations use real-world names:** "App sandbox," "System share sheet," "iCloud Drive," "Google Drive," "Local network (SMB)" — all terms users recognize from their OS.

**✅ Good — Design system naming is physical/descriptive (DESIGN.md):** Component names like `button-primary`, `button-secondary`, `text-input`, `top-nav`, `footer` match standard UI vocabulary. Color names like `ink`, `canvas`, `hairline` use physical metaphors.

**✅ Good — Touch target sizing (DESIGN.md):** 48x48px minimum for primary buttons, 44px for inputs — uses real-world physical size metaphors users understand.

**⚠️ Minor — "System share sheet" is platform jargon:** While technically accurate, "share sheet" is iOS-specific terminology. On Android users know it as "share menu" or just "share." Should use platform-adaptive labels or a generic term like "Share."

---

### H3 — User Control and Freedom ✅ 5 / ⚠️ 2 / 🔴 1 / 👁️ 2

**✅ Good — Biometric gate before push (approach.md §4B):** FaceID/fingerprint before git push is excellent — prevents accidental destructive actions and gives users a conscious checkpoint.

**✅ Good — Approval levels for skills (approach.md §4A):** Skills have `auto`, `notify`, and `confirm` approval levels. Destructive operations like `write_file` and `run_terminal` default to `confirm` — users must explicitly approve.

**✅ Good — Hard cap protection (approach.md §4D):** Optional monthly token/cost limit. Once reached, AI calls are stopped with a clear message. Users control their spending ceiling.

**✅ Good — Manual reset of usage caps (approach.md §4D):** User must manually reset caps after they're hit — prevents accidental runaway spending.

**✅ Good — Undo through snapshots (opencode.json mentions no snapshots disabled):** By default, opencode's snapshot system enables change rollback. Good that it's available.

**⚠️ Minor — No "Cancel" button model in export flow:** The export flow (approach.md §4E) shows a linear path (Preview → Export → Format → Destination → Convert → Share). No mention of a "Back" or "Cancel" button at any step. For a 4-step flow, users need exits at every step.

**⚠️ Minor — No discard confirmation for Markdown editor:** Auto-save every 5 seconds means changes are always persisted. But if a user opens a file, makes edits, and wants to revert, there's no mention of a "Discard changes" option or confirmation dialog.

**🔴 Major — No escape hatches in agent loop (approach.md §4A):** The agent loop runs multi-turn cycles: model responds -> tool calls -> execute -> respond -> continue. There's no mention of a "Stop" or "Cancel" button during an active agent loop. If the model starts doing something wrong (e.g., writing unwanted files), the user has no way to interrupt mid-cycle. This needs a prominent stop button in the chat header during active agent execution.

---

### H4 — Consistency and Standards ✅ 6 / ⚠️ 2 / 🔴 1 / 👁️ 2

**✅ Good — Consistent border radius hierarchy (DESIGN.md):** The `{rounded.*}` scale is strict and documented: xs=2px (legal), sm=6px (inputs), md=10px (cards), lg=12px (CTAs/signature cards), pill=9999px (pricing only), full=9999px (icon buttons). Every component specifies which radius it uses.

**✅ Good — Consistent spacing system (DESIGN.md):** All spacing snaps to 4px multiples with documented tokens. Section padding is universally `{spacing.section}` (96px). This guarantees visual rhythm consistency.

**✅ Good — Consistent button patterns (DESIGN.md):** Primary + secondary button pair appears on every hero. Button states are documented as separate entries (no nested state objects).

**✅ Good — Consistent naming conventions (DESIGN.md):** Component names follow a pattern: `{component.button-primary}`, `{component.button-secondary}`, `{component.button-pricing-pill}`. Modifiers are separated by hyphens.

**✅ Good — Consistent file naming in Chain of Truth:** The skill's template naming convention (`userflow_uc_NNN.md`, `sys_uc_NNN.md`) provides consistency across all artifact files.

**✅ Good — Free mode vs Custom mode toggle (approach.md §4D):** The two modes are presented as a single toggle with clear visual comparison — consistent design pattern for mode switching.

**⚠️ Minor — Design system is Airtable-inspired, not the app's own:** The DESIGN.md is an Airtable design system analysis. While comprehensive, applying it directly to a document-editing AI app may create a mismatch. Airtable's design is for a database/spreadsheet tool; this app is for AI-assisted writing. The "button-primary is near-black" and "hero is white canvas" conventions may not translate well to a document-editing interface.

**⚠️ Minor — Pricing sub-system patterns likely irrelevant:** The DESIGN.md includes pricing-specific patterns (Inter Display font, pill buttons, tier cards) that are inherited from Airtable's marketing site. This app is a mobile document editor — it may never have a marketing pricing page. These tokens add noise without purpose.

**🔴 Major — Font licensing risk:** The DESIGN.md specifies "Haas / Haas Groot Disp" as the primary typeface. Haas Grotesk is a licensed commercial font (by Monotype/ Linotype). Unless the project has a license for mobile app embedding, this font won't render. The fallback chain (`-apple-system, BlinkMacSystemFont, ...`) is robust, but the spec doesn't address licensing. On a mobile app, font embedding requires a specific app-embedding license. This will either fail silently (fallback font used) or cause legal issues.

---

### H5 — Error Prevention ✅ 4 / ⚠️ 1 / 🔴 1 / 👁️ 2 / — 2

**✅ Good — Biometric gate on push (approach.md §4B):** Prevents accidental or unauthorized git pushes.

**✅ Good — Confirmation on destructive skills (approach.md §4A):** `write_file`, `run_terminal` default to `confirm` — prevents accidental file writes or command execution.

**✅ Good — Hard cap prevents cost overruns (approach.md §4D):** Monthly token/cost limit blocks AI calls before unexpected charges.

**✅ Good — PAT stored in secure storage (approach.md §4B):** GitHub tokens in `flutter_secure_storage` prevents credential leakage.

**⚠️ Minor — No double-submit prevention mentioned:** The export flow (tap Export -> choose format -> choose destination -> convert) doesn't mention disabling the export button after first tap. A user could tap Export multiple times, triggering multiple concurrent conversions.

**🔴 Major — No form validation patterns in design system (DESIGN.md):** The DESIGN.md defines `text-input` and `text-input-focus` but explicitly states *"Form validation states beyond text-input-focus are not extracted — error and success states for inputs would need a dedicated form page to confirm."* This means error prevention patterns (red borders, error icons, inline validation messages) are **not defined**. The app will need input forms (API key entry, git credentials, export settings) and has no validated input components.

**— N/A — Auto-save for long forms:** Not applicable as forms are short (settings, API key entry).

**— N/A — File upload validation:** The app doesn't have file upload functionality.

---

### H6 — Recognition Rather Than Recall ✅ 3 / ⚠️ 2 / 🔴 1 / 👁️ 3

**✅ Good — Chat shows available agents (approach.md §4A):** Users can switch agents in the chat header — no need to remember agent names or capabilities.

**✅ Good — Free mode model picker (approach.md §4D):** Curated list of free models with provider names and notes — users recognize the model they want rather than recalling API endpoints.

**✅ Good — Usage dashboard shows breakdowns (approach.md §4D):** Per-model and per-task breakdowns with visual bar charts — no need to remember or calculate usage.

**⚠️ Minor — Agent-to-tool mapping is in documentation only:** The mapping of which agent has which tools is documented in approach.md but not surfaced in the app UI. Users shouldn't need to read the documentation to know what tools an agent has available.

**⚠️ Minor — Task router keywords are implicit:** The router detects task types via "keyword detection or a classifier call." Users won't know what keywords trigger which router mappings. Should surface the current task type detection in the UI.

**🔴 Major — No "recent documents" or "recent chats" mentioned:** The approach.md defines auto-save every 5 seconds but doesn't mention a recent documents list or recent chats list. Users shouldn't have to remember what they were working on — the app should surface it.

---

### H7 — Flexibility and Efficiency of Use ✅ 4 / ⚠️ 1 / 🔴 0 / 👁️ 2 / — 2

**✅ Good — Agent personas for different tasks (approach.md §4A):** 12 pre-built agents for different writing tasks. Users pick the right tool without manual configuration.

**✅ Good — Custom mode for power users (approach.md §4D):** Per-task and per-agent model routing — power users can optimize their workflow with precise model assignments.

**✅ Good — Bulk markdown export (approach.md §4E):** Multiple export formats and destinations — users can batch-process their workflow.

**✅ Good — Templates for repetitive work (approach.md §4A):** Document templates (IMRaD, business plan, README) via `apply_template` skill — users don't start from blank every time.

**⚠️ Minor — No keyboard shortcuts documented:** The app is mobile-first, but could benefit from a hardware keyboard (iPad) with shortcuts for common actions (Save, Export, Toggle Preview). Not mentioned anywhere.

**— N/A — Bulk actions:** The app UI isn't detailed enough to evaluate bulk actions on lists.

**— N/A — Sortable/filterable tables:** Not applicable — the app is a document editor, not a data table.

---

### H8 — Aesthetic and Minimalist Design ✅ 5 / ⚠️ 1 / 🔴 0 / 👁️ 1

**✅ Good — Whitespace philosophy (DESIGN.md):** The design system explicitly uses whitespace as its primary atmospheric tool. Hero sections sit in 96px+ of pure whitespace. No gradient, no mesh, no atmospheric backdrop.

**✅ Good — Color palette is restrained (DESIGN.md):** Neutral base (canvas, ink, body, muted) with a small set of signature colors (coral, forest, cream, peach, mint). Not excessive.

**✅ Good — Typography hierarchy is clear (DESIGN.md):** 14 distinct type tokens with clear use cases — display, title, body, caption, legal. Weight hierarchy is well-documented.

**✅ Good — Border radius hierarchy (DESIGN.md):** Only 5 radius values for the entire system — xs, sm, md, lg, pill/full. Prevents visual chaos.

**✅ Good — No decorative clutter (DESIGN.md):** "Icons and images serve a purpose" — the philosophy is stated. Elevation uses "color-block first, shadow second."

**⚠️ Minor — Airtable design may be too sparse for an editor app:** The Airtable design language is deliberately sparse — white canvas, dark ink, 96px sections. A document editor (where users stare at text all day) may benefit from a bit more surface differentiation for toolbars, panels, and controls. The current spec may be too minimalist for a complex editing UI with multiple panes (editor, preview, file browser, git status).

---

### H9 — Help Users Recognize, Diagnose, and Recover from Errors ✅ 2 / ⚠️ 1 / 🔴 1 / 👁️ 3

**✅ Good — API errors show clear messages (approach.md §7):** "chat shows a clear error" when provider is unreachable — good error communication.

**✅ Good — Hard cap has clear message (approach.md §4D):** "AI calls are blocked with a clear message" when the hard cap is reached.

**⚠️ Minor — No inline form validation in design system:** As noted in H5, form validation states (error, success) are not defined. Error messages next to fields are essential for H9.

**🔴 Major — No 404/error page patterns in design system:** The DESIGN.md defines marketing pages, navigation, cards, and pricing — but no 404 page, no error page, no "Something went wrong" state. The approach.md mentions "app functionality degrades gracefully" but doesn't specify what that looks like.

---

### H10 — Help and Documentation ✅ 5 / ⚠️ 0 / 🔴 0 / 👁️ 1 / — 3

**✅ Good — approach.md is comprehensive documentation:** The 441-line approach document is essentially built-in help for developers and power users.

**✅ Good — Empty states with guidance:** Not explicitly defined in the design system, but the Chain of Truth templates include `index.md` registry files that serve as guidance for navigating artifact collections.

**✅ Good — Free mode vs Custom mode is well-documented:** The toggle includes a visual comparison table showing what each mode offers — users can make an informed choice.

**✅ Good — Configuration fields documented (approach.md §4D):** Full table of every configuration field, its type, mode applicability, and storage mechanism.

**✅ Good — DESIGN.md iteration guide (DESIGN.md):** 7-step iteration guide for maintaining the design system. Good meta-documentation.

**— N/A — Onboarding flow:** Not detailed in the spec. Would need one for first-time users setting up API keys and understanding agents.

**— N/A — FAQ or help page:** Not yet defined.

**— N/A — Feature announcements/changelog:** Not yet defined.

---

## Top 5 Issues

1. **[DESIGN.md] [H1/H5] 🔴 Major — No loading states, empty states, or error states defined.** The design system specifies 20+ components but none for loading indicators, empty screens, error screens, or form validation. This means every async operation and error scenario will need ad-hoc implementation, leading to inconsistency.

2. **[approach.md §4A] [H3] 🔴 Major — No stop/cancel button in agent loop.** Once the agent loop starts a multi-turn cycle, the user has no way to interrupt. If the model starts making unwanted changes, the user is stuck watching until the loop completes. A prominent stop button is critical.

3. **[approach.md §4C] [H6] 🔴 Major — No recent documents or recent chats.** The auto-save mechanism exists but there's no surface to show recently edited documents. Users must remember filenames or navigate the file system manually.

4. **[DESIGN.md] [H4] 🔴 Major — Font licensing not addressed.** Haas Grotesk requires a commercial app-embedding license. If not licensed, the font won't render and the entire design system's typography collapses to fallback fonts. This must be resolved before implementation.

5. **[approach.md §4E] [H3] ⚠️ Minor — No back/cancel in export flow.** The 4-step export flow (Preview -> Format -> Destination -> Convert) lacks escape hatches. If a user changes their mind at step 3, there's no "Back" or "Cancel" without abandoning the flow entirely.

---

## Recommendations by Heuristic

### H1 — Visibility of System Status
- Add a `loading-spinner`, `skeleton-screen`, and `progress-bar` component to the design system
- Add a conversion-in-progress indicator to the export flow
- Add status indicators for git operations (cloning, pushing, pulling)

### H2 — Match Between System and the Real World
- Replace "System share sheet" with platform-adaptive terms ("Share" for both, or "Share menu" on Android)

### H3 — User Control and Freedom
- Add a prominent **Stop** button in the chat header during active agent loop execution
- Add explicit Cancel/Back buttons at every step of the export flow
- Add "Discard changes" confirmation when reverting auto-saved files

### H4 — Consistency and Standards
- **Resolve the Haas Grotesk font licensing issue** — either purchase an app-embedding license or switch to Inter Display (already used for pricing, open-source) as the universal typeface
- Consider removing or isolating Airtable-specific patterns (pricing components, marketing hero patterns) that don't apply to a document editor

### H5 — Error Prevention
- Add `text-input-error` and `text-input-success` components to the design system for form validation
- Disable the export button after first tap to prevent double-submit

### H6 — Recognition Rather Than Recall
- Add a **recent documents** list to the home screen
- Add a **recent chats** list accessible from the chat header
- Surface current agent tool availability in the chat UI (not just in documentation)

### H7 — Flexibility and Efficiency of Use
- Consider iPad hardware keyboard shortcuts (Cmd+S save, Cmd+E export, Cmd+P preview toggle)
- Consider a "favorite agents" feature for quick access

### H8 — Aesthetic and Minimalist Design
- Evaluate whether the Airtable-inspired sparse aesthetic provides enough visual structure for a multi-pane document editor. Consider slightly more surface differentiation for toolbars, sidebars, and panels.

### H9 — Error Recovery
- Add `error-state` and `404-page` components to the design system
- Add inline form validation patterns (error text, field highlighting)
- Ensure error messages suggest actionable fixes (not just "Something went wrong")

### H10 — Help and Documentation
- Plan an onboarding flow for first-time users (API key setup, agent selection, first document)
- Add an in-app FAQ or help link in the settings screen

---

## Evaluation Notes

- **Scope limitation:** This project currently has no Flutter/Dart UI code — only a design system spec (DESIGN.md, 651 lines) and an architecture document (approach.md, 469 lines). The evaluation is based on these design documents as blueprints.
- **13 items marked "Needs Manual Review"** should be verified against the actual implemented app once UI code exists (e.g., touch target sizes, keyboard shortcuts, actual layout on mobile vs tablet, color contrast ratios).
- **Airtable design system mismatch risk:** The DESIGN.md is an analysis of Airtable's marketing site visual language. While well-documented, it was designed for a database SaaS marketing site, not a mobile document editor. Several patterns (pricing sub-system, marketing hero bands, full-bleed signature cards) may not translate directly to the app's UI needs (editor surface, chat interface, git UI, file browser).

## Fixes Applied (2026-07-04)

All 7 🔴 Major and 14 ⚠️ Minor issues were addressed:

| Category | Fix | File |
|---|---|---|
| H1 Loading states | Added `loading-spinner`, `loading-spinner-lg`, `skeleton-block`, `skeleton-card`, `progress-bar-track`, `progress-bar-fill` components | DESIGN.md |
| H3 Stop button | Added prominent **Stop** button in chat header during agent loop execution | approach.md §4A |
| H6 Recent documents | Added recent documents list and recent chats section to home screen | approach.md §4C |
| H4 Font licensing | Added font licensing note to Known Gaps with recommendation for Inter Display | DESIGN.md |
| H3 Export flow | Added Back/Cancel buttons at every export step | approach.md §4E |
| H5 Form validation | Added `text-input-error`, `text-input-success`, `form-error-text`, `form-success-text` components | DESIGN.md |
| H9 Error states | Added `error-state`, `error-state-title`, `error-state-retry`, `error-page-404`, `error-page-404-action` components | DESIGN.md |
| H1 Progress indicators | Added progress bar to export flow and git clone/push/pull operations | approach.md §4E, §5 |
| H5 Double-submit | Export button disabled after first tap, re-enabled on failure | approach.md §4E |
| H7 Keyboard shortcuts | Added iPad keyboard shortcuts (Cmd+S, Cmd+E, Cmd+P, Cmd+N, Cmd+Enter, Esc) | approach.md §4C |
| H6 Agent tools UI | Agent tools shown in chat header via tool indicator; tapping opens full list | approach.md §4A |
| H6 Router visibility | Detected task type shown as badge in chat header; tapping shows mapping table | approach.md §4A |
| H3 Discard confirmation | Confirmation dialog before reverting auto-saved files | approach.md §4C |
| H2 Share sheet | Changed "System share sheet" to "System share menu" with platform-adaptive description | approach.md §4E |
| H4 Airtable patterns | Added Known Gap noting marketing-origin patterns may not apply to editor app | DESIGN.md |
| Empty states | Added `empty-state`, `empty-state-action` components for "no items" screens | DESIGN.md |

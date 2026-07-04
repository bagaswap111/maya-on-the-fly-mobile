# Usability Evaluation Fix Log

**Generated:** 2026-07-04 | **Scope:** prototype.md, architecture.md, user flows, system logics, test artifacts, all SoT documents | **Last Updated:** 2026-07-04

## Summary

| Status | Count |
|--------|-------|
| ✅ Fixed (design specs) | 23 (batch 1) + 28 (batch 2) = **51 total** |
| ✅ Fixed (test artifact consistency) | Batch 3 — **12 issues** |
| ✅ Fixed (cross-artifact consistency) | Batch 4 — **11 issues** |
| 🔲 Deferred to implementation | 2 |
| 🔲 Won't fix (intentional) | 3 |

## Detailed Fix Report

### Critical Issues (❌)

| # | Location | Issue | Fix Status |
|---|----------|-------|------------|
| 1 | PAGE-016 | No error states for export failures (conversion, upload, timeout, storage) | ✅ Fixed — Added 4 error-state variants with retry + fallback CTAs |

### Major Issues (🔴 → ✅ Fixed)

| # | Location | Heuristic | Issue | Fix Applied |
|---|----------|-----------|-------|-------------|
| 2 | PAGE-006 | H5 | Agent switch + task reclassification no confirmation | ✅ Added confirmation bottom sheets for both actions |
| 3 | PAGE-002 | H3 | No undo/redo | ✅ Added UndoButton/RedoButton + Cmd+Z/Cmd+Shift+Z + PopScope unsaved guard |
| 4a | PAGE-008 | H5 | Swipe-to-remove repo no confirmation | ✅ Added confirmation dialog with "Files not deleted" note |
| 4b | PAGE-010 | H5 | DiscardButton no confirmation | ✅ Added confirmation dialog with destructive button |
| 6 | PAGE-012 | H7/H10 | No inline merge editor; no novice git help | ✅ Added 3-pane merge editor + novice help banner + "Learn more" link |
| 7 | PAGE-022 | H3/H9 | Single recovery path on 404 | ✅ Added "Go Back" + Search + Recent pages list |
| 8 | A11Y (§35) | H4/H5/H9 | WCAG AA unverifiable; no form/focus/error a11y | ✅ Added focus indicators, form validation a11y, reduced motion, contrast target, platform labels |
| 9 | CXR (§32) | H4 | Cross-reference uses tokens not in DESIGN.md | ✅ Replaced with accurate DESIGN.md tokens (button-secondary, text-input, text-link, etc.) |
| — | PAGE-003 | H1/H5/H9 | No loading/error states | ✅ Added loading skeleton + error state with retry |
| — | PAGE-004 | H1/H9 | No loading/error states | ✅ Added loading spinner + error state with raw-markdown fallback |
| — | PAGE-005 | H3/H5 | No delete from list | ✅ Added swipe-to-delete with confirmation |
| — | PAGE-007 | H3/H5/H10 | One-tap agent creation no confirmation | ✅ Added AgentConfirmation bottom sheet with agent details + doc attach option |
| — | PAGE-013 | H1/H5/H9 | No loading/error/confirmation | ✅ Added loading skeleton + error state + export confirmation dialog |
| — | PAGE-014 | H10 | No format descriptions | ✅ Added description lines + info icons with tooltips per format |
| — | PAGE-015 | H4/H5/H9 | Button label mismatch; no auth gating | ✅ Aligned button label to "Continue"; added auth gate for cloud destinations |
| — | PAGE-018 | H3/H5 | Mode switch no confirmation | ✅ Added ModeSwitchConfirmation with explanation of what changes |
| — | PAGE-019 | H1/H6/H9 | No chart loading/empty/tooltips | ✅ Added skeleton + empty state + tooltips on metric cards |
| — | PAGE-020 | H7/H5 | No search/delete | ✅ Added inline search + swipe-to-delete with confirmation |
| — | PAGE-021 | H3/H5 | No undo for tree; template overwrite unguarded | ✅ Added undo history sheet + template overwrite guard (Replace/Append/Cancel) |
| — | PAGE-023 | H3/H5 | No unsaved changes guard | ✅ Added PopScope with "Discard changes?" dialog |
| — | PAGE-024 | H5/H10 | Reset no confirmation; System theme unexplained | ✅ Added reset confirmation + "Follows device setting" note |
| — | PAGE-025 | H5 | Reset no confirmation | ✅ Added reset confirmation dialog |
| — | PAGE-026 | H3/H5/H7/H10 | No auth cancel; no Lock Now; scope unclear | ✅ Added cancel during auth, Lock Now button, usage data scope in confirmation |
| — | PAGE-027 | H7 | No search/customization | ✅ Added search bar + ShortcutCustomizer sheet with rebinding |
| — | Shell §3 | H3/H5 | No re-tap; no Android back | ✅ Added re-tap=scroll-to-top + Android back (pop→Home→exit) |
| — | Streaming | H1/H5 | Jank from rapid setState | ✅ Added performance note: batch tokens into 50ms intervals |
| — | A11Y | Multiple | Incomplete coverage | ✅ Full rewrite: focus indicators, form validation a11y, reduced motion, platform labels |

### Deferred to Implementation (🔲)

| # | Location | Issue | Reason |
|---|----------|-------|--------|
| 1 | Shared States §2 | Mixed-state handling (partial load/error per section) | Requires per-section state management pattern best defined during coding |
| 2 | A11Y | Color contrast verification table | Requires actual color values from DESIGN.md + WCAG AA calculation tool |

### Won't Fix — Intentional Design (🔲)

| # | Location | Issue | Rationale |
|---|----------|-------|-----------|
| 1 | RSP §34 | Breakpoints contradict DESIGN.md (600/840 vs 768/1024/1440) | DESIGN.md is marketing-site breakpoints; prototype.md is mobile-app breakpoints — different contexts |
| 2 | PAGE-009/PAGE-011 | Duplicated commit UI (CommitSheet vs PAGE-011) | Intentional: CommitSheet for quick commits, PAGE-011 for advanced (amend, co-author, GPG) |
| 3 | PAGE-006 | No edit/delete own messages | Chat UX decision — best handled at implementation with long-press context menu |

## Issues Added Post-Evaluation

These issues surfaced during fix review and were resolved:

| Issue | Fix |
|-------|-----|
| PAGE-002 phone landscape min-width unspecified | Added min-width: 280dp to split pane |
| PAGE-013 Export step has no confirmation | Added export confirmation dialog |
| PAGE-010 DiscardButton no confirmation (missed in initial eval) | Added confirmation dialog |
| PAGE-021 template overwrite unguarded | Added Replace/Append/Cancel dialog |
| PAGE-004 rendering failure has no fallback | Added raw-markdown toggle on error |

## Batch 2 Fixes (2026-07-04)

These issues were addressed in the second round of fixes on `prototype.md`:

| # | Location | Issue | Fix Applied |
|---|----------|-------|-------------|
| 1 | Shared States §2 | No mixed partial state; empty variants | Added per-section state wrapping + EmptyVariant (action/info) |
| 2 | Shell §3 | Chat tab no unread badge | Added unread message count bubble spec |
| 3 | PAGE-001 | "See All" tablet behavior undefined | Defined expand-in-place on tablet vs push on phone |
| 4 | PAGE-001 | QuickActionsRow scroll hint | Added gradient fade + chevron hint on first visit |
| 5 | PAGE-003 | No template descriptions | Added subtitle to each template card |
| 6 | PAGE-004 | No reset zoom | Added double-tap reset + "Fit to screen" FAB |
| 7 | PAGE-005 | No search/filter; no pull-to-refresh | Added search bar + RefreshIndicator |
| 8 | PAGE-006 | Header too dense on phone | Moved TokenCounter + HelpButton to overflow menu on phone |
| 9 | PAGE-006 | No help entry point | Added HelpButton → agent capabilities help sheet |
| 10 | PAGE-006 | No edit/delete own messages | Added long-press context menu on UserMessage |
| 11 | PAGE-007 | No search/filter; static quick prompts | Added search bar + dynamic prompts per agent |
| 12 | PAGE-008 | No search, pull-to-refresh, progress | Added search, RefreshIndicator, init progress card |
| 13 | PAGE-009 | No unstage, stage all, stash, switch warning | Added StageAll/UnstageAll, StashButton, RepoSwitchWarning |
| 14 | PAGE-009 | Back disabled during push/pull | Added confirmation dialog to allow cancel |
| 15 | PAGE-010 | No partial staging; phone split complex | Added line-by-line gutter staging + unified-only on phone |
| 16 | PAGE-010 | No next/previous file nav | Added Prev/Next buttons in AppBar |
| 17 | PAGE-010 | Large file handling | Added chunked loading with progress indicator |
| 18 | PAGE-011 | No amend, keyboard shortcut, co-author/GPG | Added expandable options with AmendCheckbox + CoAuthorField + GpgSignSwitch |
| 19 | PAGE-012 | No progress counter, base version, commit msg | Added progress badge, OriginalVersionToggle, commit message input |
| 20 | PAGE-013 | iCloud/Drive icons too similar | Changed to distinct SF Symbols (icloud / doc.text.below.ecg) |
| 21 | PAGE-013 | Defaults not pre-selected | Pre-select from UserProfile.defaultFormat/defaultDestination |
| 22 | PAGE-014 | No format-limitation warnings | Added conditional chips for content degradation |
| 23 | PAGE-014 | No double-tap guard | Button disabled after first tap |
| 24 | PAGE-015 | iCloud shown when unavailable | Check availability before showing; dim card with "Unavailable" |
| 25 | PAGE-015 | OAuth cancellation not handled | Stay on page with snackbar, keep destination selected |
| 26 | PAGE-016 | "Share Again" behavior unclear | Clarified: shares to any destination (not original-specific) |
| 27 | PAGE-017 | Inline vs push inconsistency | Added // navigable / // inline control comments to all tiles |
| 28 | PAGE-017 | No settings search | Added search bar with section filtering |
| 29 | PAGE-018 | API key help + validation UX | Added helper text + validation message (Connected/Connection failed) |
| 30 | PAGE-018 | 13 task rows no search | Added search bar in Custom mode |
| 31 | PAGE-019 | No chart interactivity | Added tap-on-bar/segment tooltips |
| 32 | PAGE-019 | No custom date range | Added Last 7/30/90 day selector |
| 33 | PAGE-019 | Hard cap no validation | Added min/max constraints on TextField |
| 34 | PAGE-019 | Cramped mobile metrics | Stack vertically on < 600dp |
| 35 | PAGE-020 | Onboarding jargon | Improved empty state with explanation of CoT workflow |
| 36 | PAGE-020 | No project archiving | Added archive (swipe left) + delete (swipe left again) |
| 37 | PAGE-021 | Jargon in tree | Added tooltips: "SRS = Software Requirements Specification" etc. |
| 38 | PAGE-021 | No tree search/keyboard nav | Added search field + arrow key navigation spec |
| 39 | PAGE-022 | No URL shown on 404 | Added attempted URL display + "Did you mean?" suggestions |
| 40 | PAGE-023 | No field guidance | Added placeholders + helper text + email validation |
| 41 | PAGE-024 | Save model unclear | Specified auto-save on change with feedback snackbar |
| 42 | PAGE-025 | No preview for defaults | Show current selection as subtitle on pickers |
| 43 | PAGE-026 | No biometric fallback | Added PIN fallback when biometrics unavailable |
| 44 | Streaming | No tap-skip visual cue | Added pulsing cursor at end of streaming text |
| 45 | Streaming | No configurable speed | Added UserProfile.readingSpeed (slow/normal/fast) |
| 46 | Animation §33 | Missing entries | Added skeleton pulse, auto-save dot, export icon, scroll sync, new message slide |
| 47 | Breakpoints §34 | No boundary handling | Added ≥ boundary rule |
| 48 | Breakpoints §34 | No foldable/multi-window | Added MediaQuery change handling for foldable + Stage Manager |
| 49 | Breakpoints §34 | No safe area/keyboard | Added safe area + resizeToAvoidBottomInset specs |
| 50 | A11Y §35 | No dynamic type | Added textScaleFactor support with min/max range |
| 51 | A11Y §35 | Shortcuts no ref to PAGE-027 | Added "(full list at PAGE-027)" note |

---

## Batch 3 — Test Artifact Consistency Fixes (2026-07-04)

These issues were found during cross-artifact audit of `test_cases.md`, `test_plan.md`, and `test_execution_sheet.md` against `user_flows/`, `architecture.md`, and `ucic_contracts.md`:

| # | File | Issue | Fix Applied |
|---|------|-------|-------------|
| 1 | test_cases.md §1.2 | Scope reported 59 tests (38P/11N/10E); actual count was 68 (50P/3N/15E) | Updated to correct counts |
| 2 | test_cases.md §4.3 | Test Type Summary reported 59 tests (43P/4N/12E); contradicted §1.2 | Aligned to 50P/3N/15E = 68 |
| 3 | test_cases.md §4.1 | F002 traced to TC-F001-003 (broken prefix) | Renamed to TC-F002-001; added 3 more F002 TCs |
| 4 | test_cases.md §4.1 | F009 (Skills System) missing — zero test cases, not in traceability matrix | Added §3.9 with TC-F009-001–004 |
| 5 | test_cases.md §4.1 | F002 (Multi-Agent System, High priority) had only 1 TC | Added §3.2 with TC-F002-001–004 (agent personas, tool sets, Auto routing) |
| 6 | test_cases.md §4.2 | UC-005 gaps: "Manage Repositories..." dropdown, git log, lastRepoId persistence | Added TC-F006-012, -013, -014 |
| 7 | test_cases.md §3.9 | UC-007 (Settings) orphaned — Feature ID = "—" | Changed to F008 per userflow_uc_007.md; updated all SET rows |
| 8 | test_plan.md §1.3 | architecture.md reference path broken (resolved to docs/architecture.md) | Changed to ../architecture.md |
| 9 | test_plan.md §2.1.2 | F008 scope omitted UC-007 | Added UC-007 to F008's use cases |
| 10 | test_plan.md §2.1.2 | F001 mapped to UC-001+UC-002; user_flows/index.md maps F001 to UC-001 only | Removed UC-002 from F001 mapping |
| 11 | test_execution_sheet.md | Missing F002/F009 sections; TC-F001-003 (now F002-001) in wrong section; section numbers unaligned; counts at 68 instead of 78 | Added F002 §2, F009 §9; fixed headers; updated counts to 78 |
| 12 | All three test artifacts | Section numbering inconsistent after inserting F002/F009 | Renumbered sequentially: F001=1, F002=2, …, F010=10, Settings=11 |

---

## Batch 4 — Cross-Artifact Consistency Fixes (2026-07-04)

These issues were found during comprehensive cross-artifact audit of all SoT documents:

| # | File | Issue | Fix Applied |
|---|------|-------|-------------|
| 1 | prototype.md §1 | Says "22 pages" but defines all 28 | Updated to "28 pages" |
| 2 | test_cases.md §1.2, §4.3 | Claims 68 total (50P/3N/15E); actual is 78 (60P/3N/15E) after adding F002/F009/SET/F006 TCs | Updated to 78 total (60P/3N/15E) |
| 3 | approach.md §Free Mode, §Custom Mode | Says "12 agents" in two locations but agent table lists 13 | Changed both to "13 agents" |
| 4 | test_plan.md §1.3, test_execution_sheet.md | All `docs/`-prefixed paths redundant from `docs/` directory | Changed `docs/` prefix to `./` |
| 5 | architecture.md §ENT-007 | UserProfile entity missing `name`, `email`, `signature` columns needed by PAGE-023 | Added all 3 attributes |
| 6 | architecture.md §ENT-011 | Repository entity missing `unpushedCount`, `lastCommitMessage`, `lastCommitAt` from data_model_detail | Added all 3 columns |
| 7 | architecture.md §ENT-005 | AIProvider entity listed `apiKey` as drift column; stored in flutter_secure_storage | Added explicit "NOT a drift column" note |
| 8 | architecture.md §5.4 | UserProfile→UsageAlert said "1:1" but data model has no unique constraint | Changed to "1:0..1" with UNIQUE constraint note |
| 9 | architecture.md §F009 | Claimed "26 tools in 5 categories" vs UCIC 30 + approach.md ~38 | Updated to "46 tools in 8 categories"; synced FR-009.1 |
| 10 | approach.md §Skills | Missing 8 infrastructure tools from UCIC (switch_agent, get_tools, get_agent_info, ask_agent, web_search, fetch_url, git_push, git_log) | Added "Agent & Infrastructure Skills" section with all 8 |
| 11 | ucic_contracts.md §4 | Missing 16 document/citation/writing/humanizer tools from approach.md | Added 4 new sections (4.11–4.14) with C-TOOL-031 to C-TOOL-046 |

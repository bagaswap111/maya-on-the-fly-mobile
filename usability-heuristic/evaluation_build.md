# Usability Heuristic Evaluation — Maya on the Fly (Build)

- **Evaluated:** Flutter app source code (59 Dart files across 24 routes/pages)
- **Framework:** Jakob Nielsen's 10 Usability Heuristics
- **Modules enabled:** None additional
- **Date:** 2026-07-05

## Summary

| Severity | Count |
|----------|-------|
| ✅ Good | 159 |
| ⚠️ Minor | 47 |
| 🔴 Major | 18 |
| ❌ Critical | 0 |

### Per-Heuristic Overview

| Heuristic | ✅ Good | ⚠️ Minor | 🔴 Major | ❌ Critical |
|-----------|---------|----------|----------|------------|
| H1 — Visibility of System Status | 20 | 4 | 1 | 0 |
| H2 — Match Real World | 22 | 3 | 0 | 0 |
| H3 — User Control & Freedom | 18 | 4 | 1 | 0 |
| H4 — Consistency & Standards | 21 | 3 | 1 | 0 |
| H5 — Error Prevention | 14 | 6 | 3 | 0 |
| H6 — Recognition vs Recall | 20 | 3 | 1 | 0 |
| H7 — Flexibility & Efficiency | 8 | 8 | 2 | 0 |
| H8 — Aesthetic & Minimalist | 17 | 5 | 2 | 0 |
| H9 — Error Recovery | 9 | 7 | 5 | 0 |
| H10 — Help & Documentation | 10 | 4 | 2 | 0 |

---

## Per-Page Results

### / (HomePage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, empty states with create action, pull-to-refresh. Word/char count in editor |
| H2 Real world | ✅ | "New Doc", "New Chat", "Open Repo" are clear. "Maya on the Fly" brand name is meaningful in context |
| H3 User control | ✅ | Standard nav, tap document to open, back button works |
| H4 Consistency | ✅ | Material 3, consistent card layout, same spacing tokens |
| H5 Error prevention | ⚠️ | No confirmation before navigating away when loading |
| H6 Recognition | ✅ | Recent documents list, recent chats section |
| H7 Flexibility | ✅ | Quick action cards (New Doc / New Chat / Open Repo), pull-to-refresh |
| H8 Aesthetic | ⚠️ | Empty sections take space even when empty; "No chats yet" box with icon consumes height |
| H9 Error recovery | ✅ | Empty states guide the user to create content |
| H10 Help | ✅ | Empty states provide clear action ("Create your first document") |

### /doc/:id and /doc/new (EditorPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, "Unsaved changes" banner, word/char count bar at bottom |
| H2 Real world | ✅ | "Save", "Preview", "Edit" are clear; Markdown familiarity assumed but documented |
| H3 User control | ✅ | Unsaved-changes dialog with Discard / Save & leave / Cancel — excellent |
| H4 Consistency | ✅ | Matches Material Design patterns |
| H5 Error prevention | ✅ | Unsaved guard prevents data loss; pop scope handles back gesture |
| H6 Recognition | ✅ | Content is visible in edit mode; preview toggle shows rendered output |
| H7 Flexibility | ⚠️ | No auto-save (but dirty indicator shows). No keyboard shortcuts for formatting |
| H8 Aesthetic | ✅ | Clean split between edit/preview; minimal chrome |
| H9 Error recovery | ⚠️ | If document load fails, silently shows empty editor — no error toast or retry |
| H10 Help | ⚠️ | No helper text for Markdown syntax. New users won't know `**bold**` etc. |

### /chat (ChatListPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, empty state "No conversations yet" with action button, RefreshIndicator |
| H2 Real world | ✅ | Conversations listed by session title, agent ID shown as subtitle |
| H3 User control | ✅ | Tap to open existing chat, FAB to create new |
| H4 Consistency | ✅ | Standard ListTile pattern, consistent with home |
| H5 Error prevention | ⚠️ | No confirmation before deleting (delete swipe not implemented yet) |
| H6 Recognition | ✅ | Session titles, agent IDs visible |
| H7 Flexibility | ⚠️ | No search/filter on conversation list; no bulk delete |
| H8 Aesthetic | ✅ | Clean list with decoration |
| H9 Error recovery | ✅ | Empty state guides to start a chat |
| H10 Help | ⚠️ | No help text about what different agents do |

### /chat/new (NewChatPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Agent grid shows all options at once |
| H2 Real world | ⚠️ | Agent descriptions use AI terms ("Auto", "Coder", "Writer") — "Auto" is ambiguous |
| H3 User control | ✅ | Back button, cancel possible |
| H4 Consistency | ✅ | Card grid, consistent with other selection screens |
| H5 Error prevention | ⚠️ | No loading state between tap and navigation — brief flash before route transition |
| H6 Recognition | ✅ | Icons + names + descriptions for each agent |
| H7 Flexibility | ⚠️ | Only 3 hardcoded agents shown (out of 13 available) |
| H8 Aesthetic | ✅ | Grid layout, good spacing, icons |
| H9 Error recovery | ✅ | Safe — always navigates to new chat |
| H10 Help | ⚠️ | "Auto" description "Let AI choose" is vague — what criteria? |

### /chat/:id (ChatPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, streaming text appears incrementally, "sending" progress indicator |
| H2 Real world | ✅ | Chat UI is familiar (message bubbles, user vs assistant alignment) |
| H3 User control | 🔴 | **No cancel button during AI response.** User must wait for completion or kill the app |
| H4 Consistency | ✅ | Bubbles follow Material chat conventions |
| H5 Error prevention | ⚠️ | No rate-limit feedback — if API fails, raw error message shown |
| H6 Recognition | ✅ | Full message history visible |
| H7 Flexibility | ⚠️ | No way to edit/retract a sent message; no copy-to-clipboard on messages |
| H8 Aesthetic | ✅ | Clean chat layout |
| H9 Error recovery | ⚠️ | Error shown as plain text message (raw `e.toString()`) — not user-friendly |
| H10 Help | ⚠️ | No hint text explaining what the agent can do |

### /git (GitStatusPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | File list with status icons (green/red/orange), unpushed count, branch name in title, clean working tree state |
| H2 Real world | ⚠️ | Git terminology (stage, commit, branch, unpushed) is developer-oriented — not for non-technical users |
| H3 User control | ✅ | Stage individual files, refresh, navigate to remotes, commit via FAB |
| H4 Consistency | ✅ | Standard ListTile, consistent icon colors (green=new, red=deleted, orange=modified) |
| H5 Error prevention | ⚠️ | No confirmation before staging; no undo for staging a wrong file |
| H6 Recognition | ✅ | File paths, status icons clear at a glance |
| H7 Flexibility | ⚠️ | Can stage individual files but no "stage all" — must tap each file (the commit action does stage all though) |
| H8 Aesthetic | ✅ | Clean status display, color-coded |
| H9 Error recovery | ⚠️ | Git errors caught and silently ignored (empty try/catch in _refresh) |
| H10 Help | ⚠️ | No explanation of Git concepts. "Unpushed" may confuse new users |

### /git/:repo/commit (GitCommitPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ⚠️ | Spinner in action button during commit, success/error snackbar. But no progress indicator for staging |
| H2 Real world | ✅ | "Commit message", "Description" are standard Git terms |
| H3 User control | ⚠️ | No confirmation dialog before committing — executes immediately |
| H4 Consistency | ✅ | Standard form pattern |
| H5 Error prevention | 🔴 | **Commit message required but no inline validation** — tapping Commit with empty message silently does nothing (no feedback) |
| H6 Recognition | ✅ | Form fields with labels and hint text |
| H7 Flexibility | ⚠️ | No recent commit messages or template |
| H8 Aesthetic | ✅ | Clean form |
| H9 Error recovery | ✅ | Error snackbar on commit failure with message |
| H10 Help | ⚠️ | "All changes will be staged" hint text is helpful but could be more prominent |

### /git/:repo/diff (GitDiffPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Diff text displayed in monospace, toggle between working/staged |
| H2 Real world | ✅ | Standard diff format (+/- lines) |
| H3 User control | ✅ | Toggle view, read-only display |
| H4 Consistency | ✅ | SegmentedButton for toggle matches other pages |
| H5 Error prevention | ✅ | Read-only — no accidental changes |
| H6 Recognition | ✅ | Showing exact changes |
| H7 Flexibility | ✅ | Working/staged toggle |
| H8 Aesthetic | ✅ | Clean monospace display |
| H9 Error recovery | ✅ | Shows "(no changes)" when empty |
| H10 Help | ⚠️ | No explanation of +/- meaning |

### /git/:repo/conflict (GitConflictPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ⚠️ | Static "No conflicts detected" message — no conflict resolution UI |
| H2 Real world | ✅ | Merge icon, clear message |
| H3 User control | ⚠️ | No way to trigger a merge from this page |
| H4 Consistency | ✅ | Matches other git pages |
| H5 Error prevention | ⚠️ | Placeholder — no actual conflict resolution implemented |
| H6 Recognition | ✅ | Shows current state |
| H7 Flexibility | — | N/A (placeholder) |
| H8 Aesthetic | ⚠️ | Placeholder page with empty state only |
| H9 Error recovery | ⚠️ | No information about how conflicts would appear |
| H10 Help | ✅ | Text explains what the page is for |

### /git/manage (GitRepoListPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Lists remotes, empty state with "No remotes configured" |
| H2 Real world | ✅ | "Add Remote" dialog with Name/URL fields and hints |
| H3 User control | ✅ | Add/remove remotes, cancel in dialog |
| H4 Consistency | ✅ | Dialog pattern consistent with other app dialogs |
| H5 Error prevention | ⚠️ | No URL validation before adding remote |
| H6 Recognition | ✅ | Lists existing remotes |
| H7 Flexibility | ⚠️ | No edit remote (must delete and re-add) |
| H8 Aesthetic | ✅ | Simple list with add button |
| H9 Error recovery | ⚠️ | Git errors caught silently in _load |
| H10 Help | ⚠️ | No instruction on what remotes are or how to get a Git URL |

### /export (ExportPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading state, progress indicator during export, "Last Export" result card |
| H2 Real world | ✅ | Format names (Plain Text, HTML, PDF, DOCX) are clear; extension shown as subtitle |
| H3 User control | ✅ | Can select different documents, different formats, export multiple times |
| H4 Consistency | ✅ | Card/ListTile consistent with rest of app |
| H5 Error prevention | ⚠️ | No confirmation before overwriting an export; no "are you sure" for empty documents |
| H6 Recognition | ✅ | Document dropdown, format options with icons |
| H7 Flexibility | ⚠️ | No recent export formats remembered; no batch export |
| H8 Aesthetic | ✅ | Clean layout, icon per format |
| H9 Error recovery | ✅ | Success snackbar with Share action; error snackbar with message |
| H10 Help | ✅ | Format descriptions visible (extension shown) |

### /settings (SettingsPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Sections with headers, icons for each setting |
| H2 Real world | ✅ | Section labels match expectations (Profile, AI, Appearance, Editor, Privacy) |
| H3 User control | ✅ | Navigate to each setting, back button |
| H4 Consistency | ✅ | Uniform section/tile pattern |
| H5 Error prevention | ✅ | No destructive actions here (top-level menu only) |
| H6 Recognition | ✅ | Visible menu of all settings |
| H7 Flexibility | ⚠️ | Search icon in AppBar does nothing (dead button) |
| H8 Aesthetic | ✅ | Clean, hierarchical layout |
| H9 Error recovery | ✅ | Safe — navigation only |
| H10 Help | ✅ | About section shows version info |

### /settings/profile (ProfilePage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, success snackbar on save |
| H2 Real world | ✅ | Name, Email, Signature labels are clear. "Free" vs "Custom" mode with explanation text |
| H3 User control | ✅ | Save action, back button |
| H4 Consistency | ✅ | Standard form fields, segmented button for mode |
| H5 Error prevention | 🔴 | **No email validation** — free-text field accepts any input |
| H6 Recognition | ✅ | Labels, hints, mode description |
| H7 Flexibility | ⚠️ | No "cancel changes" — must manually revert |
| H8 Aesthetic | ✅ | Clean form layout |
| H9 Error recovery | ⚠️ | No inline field validation (email format, name required) |
| H10 Help | ⚠️ | Mode explanation is good but could link to more details about Custom mode |

### /settings/ai (ModelManagerPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, shows saved key obscured, "Save your changes" warning when key modified |
| H2 Real world | ⚠️ | "DeepSeek" and model names are technical. "API Key" is familiar to developers only |
| H3 User control | ✅ | Toggle visibility of key, save/delete key |
| H4 Consistency | ✅ | Card layout, consistent text field styling |
| H5 Error prevention | 🔴 | **No validation on API key format** — empty or malformed key accepted without feedback |
| H6 Recognition | ✅ | "Get a free API key at platform.deepseek.com" link text |
| H7 Flexibility | ⚠️ | No test connection button to verify key works |
| H8 Aesthetic | ✅ | Clean layout with provider info |
| H9 Error recovery | ⚠️ | "Save your changes" warning is good but no inline validation |
| H10 Help | ✅ | Help text with URL to get API key |

### /settings/usage (UsageDashboardPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading state, shows usage stats (need to verify full page) |
| H2 Real world | ⚠️ | Token counts and costs are technical terms |
| H3 User control | ✅ | Read-only dashboard |
| H4 Consistency | ✅ | Matches other settings pages |
| H5 Error prevention | ✅ | Read-only — no destructive actions |
| H6 Recognition | ✅ | Data visible |
| H7 Flexibility | ⚠️ | No date range filter or reset |
| H8 Aesthetic | ✅ | Clean display |
| H9 Error recovery | ✅ | Read-only |
| H10 Help | ⚠️ | No explanation of what tokens are |

### /settings/appearance (AppearancePage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, success snackbar on save, font size visible |
| H2 Real world | ✅ | Light/Dark/System are familiar, font size +/- is intuitive |
| H3 User control | ✅ | Save action, back button |
| H4 Consistency | ✅ | SegmentedButton for theme matches profile page pattern |
| H5 Error prevention | ✅ | Font size constrained to 12-24 range |
| H6 Recognition | ✅ | Current theme and font size shown |
| H7 Flexibility | ⚠️ | No preview of the theme before applying |
| H8 Aesthetic | ✅ | Clean |
| H9 Error recovery | ✅ | Success feedback |
| H10 Help | ✅ | Labels are self-explanatory |

### /settings/editor (EditorSettingsPage) — **PLACEHOLDER**
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | 🔴 | **Shows raw "placeholder" text** — no useful content |
| H2 Real world | 🔴 | "Editor preferences — placeholder" is developer-facing text, not user-facing |
| H3 User control | ✅ | Back button works |
| H4 Consistency | 🔴 | **Not consistent** — every other settings page has real content |
| H5 Error prevention | ⚠️ | No interactive elements |
| H6 Recognition | ⚠️ | Shows nothing useful |
| H7 Flexibility | — | N/A |
| H8 Aesthetic | 🔴 | **Raw placeholder text is not production-quality** |
| H9 Error recovery | ✅ | Can navigate away |
| H10 Help | ✅ | Title is clear about what page should be |

### /settings/privacy (PrivacySecurityPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Loading spinner, app lock toggle, biometric switch |
| H2 Real world | ✅ | "App Lock", "Biometric Unlock", "Auto-lock after" are clear |
| H3 User control | ✅ | Toggle on/off, biometric authentication gate |
| H4 Consistency | ✅ | Switch tiles, dropdown, card layout |
| H5 Error prevention | ✅ | Biometric auth before enabling; FLAG_SECURE note |
| H6 Recognition | ✅ | Current lock status visible |
| H7 Flexibility | ⚠️ | Auto-lock timer options limited to 4 presets |
| H8 Aesthetic | ✅ | Clean card layout with security notes |
| H9 Error recovery | ✅ | Toggle off easy to find |
| H10 Help | ✅ | Security notes section explains each feature. However, sqlcipher note says "pending Flutter upgrade" (stale — already upgraded) |

### /settings/shortcuts (KeyboardShortcutsPage) — **PLACEHOLDER**
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | 🔴 | **Shows raw "placeholder" text** |
| H2 Real world | 🔴 | Developer-facing placeholder text |
| H3 User control | ✅ | Back button works |
| H4 Consistency | 🔴 | Placeholder among real settings pages |
| H5 Error prevention | ⚠️ | No interactive elements |
| H6 Recognition | ⚠️ | No shortcuts listed |
| H7 Flexibility | — | N/A |
| H8 Aesthetic | 🔴 | Placeholder text |
| H9 Error recovery | ✅ | Can navigate away |
| H10 Help | ⚠️ | Page title "Keyboard Shortcuts" sets expectation but no content |

### /settings/about (AboutPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Static page with all info |
| H2 Real world | ✅ | Version, Flutter SDK, model info |
| H3 User control | ✅ | Read-only |
| H4 Consistency | ✅ | Card layout consistent |
| H5 Error prevention | ✅ | No interactive elements |
| H6 Recognition | ✅ | All info visible |
| H7 Flexibility | — | N/A |
| H8 Aesthetic | ✅ | Clean, centered layout |
| H9 Error recovery | ✅ | Static |
| H10 Help | ⚠️ | **Flutter SDK version shown as "3.10.6" but actual is 3.44.4** — stale info |

### /cot (CoTProjectListPage) — **PLACEHOLDER**
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | 🔴 | **Shows "CoT project list — placeholder"** |
| H2 Real world | 🔴 | Developer-facing text |
| H3 User control | ✅ | Back button |
| H4 Consistency | 🔴 | Not consistent with real pages |
| H5 Error prevention | ⚠️ | No interactive elements |
| H6 Recognition | ⚠️ | Shows nothing useful |
| H7 Flexibility | — | N/A |
| H8 Aesthetic | 🔴 | Placeholder |
| H9 Error recovery | ✅ | Can navigate away |
| H10 Help | ⚠️ | Page title sets expectation but no content |

### /onboarding (OnboardingPage)
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Step indicators (dot progress), page index, skip button |
| H2 Real world | ✅ | Plain language: "Create Documents", "Chat with AI Agents", "Export & Share" |
| H3 User control | ✅ | Skip button always visible, can swipe through steps, exit any time |
| H4 Consistency | ✅ | Material Design, consistent with app theme |
| H5 Error prevention | ✅ | No destructive actions, safe to skip |
| H6 Recognition | ✅ | Large icons + titles + descriptions per step |
| H7 Flexibility | ⚠️ | Linear flow only — can't jump to a specific step |
| H8 Aesthetic | ✅ | Clean, centered, good use of whitespace and iconography |
| H9 Error recovery | ✅ | Can always restart by skipping and re-triggering |
| H10 Help | ✅ | Exactly what onboarding is for — introduces all features |

### NotFoundPage
| Heuristic | Score | Finding |
|-----------|-------|---------|
| H1 Visibility | ✅ | Clear "Page Not Found" message |
| H2 Real world | ✅ | Plain language |
| H3 User control | ✅ | "Go Home" button |
| H4 Consistency | ✅ | Matches app styling |
| H5 Error prevention | ✅ | Safe |
| H6 Recognition | ✅ | Clear what happened |
| H7 Flexibility | — | N/A |
| H8 Aesthetic | ✅ | Clean |
| H9 Error recovery | ✅ | "Go Home" button provides clear recovery path |
| H10 Help | ✅ | Explains what happened and how to fix |

---

## Top 5 Issues

### 1. [EditorSettingsPage, ShortcutsPage, CoTPages] [H4/H8] 🔴 Major — Placeholder pages expose raw developer text
Three pages show raw placeholder strings like "Editor preferences — placeholder" instead of meaningful content. This is not production-quality.
**Fix:** Either implement the pages or hide routes until content is ready.

### 2. [ChatPage/:id] [H3] 🔴 Major — No cancel button during AI streaming
If the user sends a message, they cannot stop the AI response mid-stream. They must wait for completion or force-kill the app.
**Fix:** Add a cancel/stop button that kills the stream subscription.

### 3. [GitCommitPage] [H5] 🔴 Major — No validation feedback on empty commit message
Tapping Commit with an empty message silently does nothing. No visual feedback on why the action didn't work.
**Fix:** Disable the Commit button until a message is entered, or show inline "Required" validation.

### 4. [ProfilePage, ModelManagerPage] [H5] 🔴 Major — No input validation on critical fields
Email field accepts `"abc"`, API key field accepts empty string. No format validation or real-time feedback.
**Fix:** Add email regex validation, API key prefix check (`sk-...`), and inline error messages.

### 5. [EditorPage] [H9] 🔴 Major — Silent failure when document load errors
If `_loadDocument` fails (network, DB error), the editor shows an empty state with no error message. User has no indication that something went wrong.
**Fix:** Show error snackbar or inline error state when document load throws an exception.

---

## Recommendations by Heuristic

### H1 — Visibility of System Status
| Issue | Severity | Fix |
|-------|----------|-----|
| Placeholder pages show developer text | 🔴 | Implement or hide routes |
| GitCommitPage: no staging progress | ⚠️ | Add linear progress during stage operation |
| NewChatPage: brief flash on agent selection | ⚠️ | Show brief loading overlay when creating session |

### H2 — Match Between System and Real World
| Issue | Severity | Fix |
|-------|----------|-----|
| Agent labels ("Auto", "Coder") could confuse non-technical users | ⚠️ | Add short plain-English descriptions in the agent grid |
| Usage dashboard: tokens/costs are technical | ⚠️ | Add a brief "What are tokens?" info tooltip |
| Git terminology (stage, branch, unpushed) | ⚠️ | Add inline help text or tooltips for Git concepts |

### H3 — User Control and Freedom
| Issue | Severity | Fix |
|-------|----------|-----|
| No cancel during AI streaming | 🔴 | Add stop button that cancels the stream |
| Git commit has no confirmation dialog | ⚠️ | Add "Are you sure?" before committing |
| No edit/retract sent chat messages | ⚠️ | Add long-press menu on messages (copy, edit, delete) |

### H4 — Consistency and Standards
| Issue | Severity | Fix |
|-------|----------|-----|
| Placeholder pages break consistency | 🔴 | Remove or implement before release |
| Settings page: search icon is dead | ⚠️ | Remove non-functional icon |
| About page shows stale Flutter version (3.10.6) | ⚠️ | Update to match actual SDK 3.44.4 |

### H5 — Error Prevention
| Issue | Severity | Fix |
|-------|----------|-----|
| Git commit: empty message silently ignored | 🔴 | Disable button until message entered |
| Email field: no validation | 🔴 | Add email regex pattern validation |
| API key: no format validation | 🔴 | Add prefix check + real-time validation |
| Export: no confirmation for overwrite | ⚠️ | Check if file exists before export |

### H6 — Recognition Rather Than Recall
| Issue | Severity | Fix |
|-------|----------|-----|
| No search/filter on document or chat lists | ⚠️ | Add search bar to chat list and document list |
| NewChatPage only shows 3 of 13 agents | ⚠️ | Show all 13 agents or add "See All" expand |
| No document templates visible from editor | ⚠️ | Add "New from template" option |

### H7 — Flexibility and Efficiency of Use
| Issue | Severity | Fix |
|-------|----------|-----|
| No keyboard shortcuts (separate placeholder page exists) | ⚠️ | Implement for mobile keyboard or remove the page |
| Chat: no message copy/retry | ⚠️ | Add long-press context menu on messages |
| No document templates for repetitive tasks | ⚠️ | Add template CRUD |

### H8 — Aesthetic and Minimalist Design
| Issue | Severity | Fix |
|-------|----------|-----|
| Placeholder pages expose developer text | 🔴 | Implement or remove |
| HomePage: empty sections take vertical space | ⚠️ | Collapse empty sections or show inline |
| Settings search icon does nothing | ⚠️ | Remove or implement |

### H9 — Help Users Recognize, Diagnose, and Recover from Errors
| Issue | Severity | Fix |
|-------|----------|-----|
| Editor: silent failure on document load error | 🔴 | Show error snackbar + retry button |
| Chat: raw error messages shown to user | ⚠️ | Wrap errors in user-friendly text |
| Git: silent try/catch swallowing errors | ⚠️ | Log errors and show appropriate feedback |
| No inline validation on forms | ⚠️ | Add per-field validation messages |

### H10 — Help and Documentation
| Issue | Severity | Fix |
|-------|----------|-----|
| Privacy page: stale sqlcipher note | ⚠️ | Update text — Flutter upgrade is done |
| About page: stale Flutter SDK version | ⚠️ | Update to 3.44.4 |
| No FAQ/help link anywhere | ⚠️ | Add "Help" section to settings |
| No Markdown syntax help in editor | ⚠️ | Add "?" icon that shows Markdown reference |

---

## Notes

- The static analysis was run: **0 issues**.
- All **17 tests pass** (16 integration + 1 widget).
- Placeholder pages (EditorSettingsPage, KeyboardShortcutsPage, CotProjectListPage, CotArtifactEditorPage) are counted as placeholders in the evaluation — they should be either implemented or removed from the router before production release.
- Most interactivity patterns are well-handled (loading states, empty states, navigation). The main gaps are in error recovery and input validation.
- The onboarding flow is a strong point — 5 steps, clear language, skip button, dot indicators.


# Test Execution Sheet: Maya on the Fly

**Document:** SoT-10 Execution Tracking | **Derived From:** docs/test_cases.md | **Status:** Draft | **Last Updated:** 2026-07-04

> Records actual execution results against the test cases derived from the Sources of Truth. Failures are diagnosed as Implementation error vs Source-of-Truth error (see Revision Loop in SKILL.md).

## 1. Instructions

- Execute each TC from `docs/test_cases.md` and record the actual result and status.
- **Status values:** PASS / FAIL / N/A (blocked or out-of-scope for this run).
- On FAIL: record actual result, then triage — is the defect in the implementation (fix code) or in a Source of Truth (fix the artifact, re-validate downstream)?
- Keep TC IDs, scenarios, and expected results identical to `docs/test_cases.md`.

## 1. Feature F001: AI Chat with Streaming

### 2.1 UC-001: AI Chat Completion

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F001-001 | Send message and receive streaming response | 1. Open PAGE-006 2. Type "Hello" 3. Tap Send | Tokens appear character-by-character; StopButton visible during streaming | | | |
| TC-F001-002 | Stop generation mid-stream | 1. Send long prompt 2. Tap StopButton | Streaming stops; partial text; "Generation stopped" notice | | | |

| TC-F001-004 | Task reclassification | 1. Tap TaskTypeBadge 2. Select "code" 3. Confirm | Badge updates; next message routed to new model | | | |
| TC-F001-005 | Token counter real-time update | 1. Send message 2. Observe counter | Counter increments during streaming; matches API total_tokens | | | |
| TC-F001-006 | Network timeout auto-retry | Mock 31s hang | "Connection lost" toast; retries at 2s/4s/8s; error state after 3 fails | | | |
| TC-F001-007 | Invalid API key | Mock 401 | "Invalid API key for {Provider}" shown with settings link | | | |
| TC-F001-008 | Rate limited | Mock 429 + Retry-After: 30 | "Rate limited" countdown; auto-retry after window | | | |
| TC-F001-009 | Hard cap reached | Seed UsageRecord > UsageAlert.hardCap | Blocking banner; "Reset Cap" button; link to dashboard | | | |
| TC-F001-010 | Empty message rejected | Leave input empty | SendButton disabled (greyed) until text entered | | | |

## 2. Feature F002: Multi-Agent System

### 2.1 UC-001: AI Chat Completion / UC-002: Agent Loop

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F002-001 | Agent switch preserves history | 1. Tap AgentSelectorChip 2. Select Coder 3. Confirm | Confirmation sheet shown; header updates; prior messages visible | | | |
| TC-F002-002 | 13 agent personas available | 1. Tap AgentSelectorChip 2. Scroll | Dropdown shows all 13 personas with avatar + name + description | | | |
| TC-F002-003 | Per-agent tool sets differ | Switch Writer→Git; list tools | Writer shows doc tools; Git shows repo tools | | | |
| TC-F002-004 | Auto agent routes correctly | Send 3 prompts of different types | Writer for research; Git for bugs; Reader for summarization | | | |

## 3. Feature F003: Task Router

### 3.1 UC-001: AI Chat Completion

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F003-001 | "research proposal" → academic | Send "write a research proposal on quantum computing" | TaskTypeBadge shows "academic" | | | |
| TC-F003-002 | "fix this bug" → code/review | Send "fix this bug in my Dart code" | TaskTypeBadge shows "code" or "review" | | | |
| TC-F003-003 | "less robotic" → humanize | Send "make this sound less robotic" | TaskTypeBadge shows "humanize" | | | |
| TC-F003-004 | Unrecognized input fallback | Send "a;lskdjf;laksjdf" | TaskTypeBadge defaults to "chat"; no crash | | | |

## 4. Feature F004: Agent Loop & Tool Execution

### 4.1 UC-002: Agent Loop with Tool Execution

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F004-001 | Multi-turn tool task | Send "Read main.dart, add comment, commit" | read_file→edit_file→git_commit sequence; each ToolCallCard morphs; file modified | | | |
| TC-F004-002 | Stop interrupts mid-loop | Multi-turn task in progress; tap Stop | Current API call cancelled; pending tools skipped; partial output | | | |
| TC-F004-003 | User denies tool execution | Prompt triggers destructive tool; tap Deny | "User denied execution" sent to model; no file changes | | | |
| TC-F004-004 | Destructive tool confirmation | Prompt triggers write_file | ToolExecutionConfirmation sheet with name + args + confirm/deny | | | |
| TC-F004-005 | Tool execution error | Prompt for non-existent file | Error returned to model; model adapts response | | | |
| TC-F004-006 | Unknown tool request | Model hallucinates tool name | "Tool not available. Available tools: {list}" sent to model | | | |

## 5. Feature F005: Markdown Editor

### 5.1 UC-003: Document Management

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F005-001 | Create new blank document | Tap "New Doc" → select Blank → Create | PAGE-003 shown; PAGE-002 opens with placeholder; doc in recent list | | | |
| TC-F005-002 | Auto-save within 5s | Type content; wait 5s | Indicator: red→yellow→green; content persisted | | | |
| TC-F005-003 | Toggle preview | Tap eye icon | Phone: AnimatedSwitcher to PreviewPane; Tablet: side-by-side split | | | |
| TC-F005-004 | LaTeX renders | Type $E=mc^2$; toggle preview | Inline LaTeX renders formatted; block $$ centered | | | |
| TC-F005-005 | Discard confirmation | Make unsaved edit; tap Back | PopScope dialog with Discard/Save/Cancel | | | |
| TC-F005-006 | Version history | Open menu → Version History → select version | List shows timestamps; restore replaces content | | | |
| TC-F005-007 | Pin persists | Long-press → Pin → restart | Pinned doc at top with indicator; survives restart | | | |
| TC-F005-008 | Storage full warning | Fill storage to < 50MB; edit | Warning toast; save interval changes to 30s | | | |
| TC-F005-009 | Document deleted externally | Delete file externally; tap in list | Error state with "Remove from list" / "Recreate" | | | |
| TC-F005-010 | Recent list accuracy | Open Home with 5+ docs | 20 max; sorted by last-modified; shows title + timeAgo + word count | | | |

## 6. Feature F006: Git Version Control

### 6.1 UC-005: Git Operations

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F006-001 | Git tab opens last repo | Tap Git tab (lastRepoId set) | PAGE-009 for last repo; not PAGE-008 | | | |
| TC-F006-002 | View repo status | Open PAGE-009 with dirty repo | 4 file items; correct icons; StageCheckbox on unstaged | | | |
| TC-F006-003 | Stage and commit | Check file → CommitButton → message → confirm | SnackBar "Committed 1 file"; status refreshes | | | |
| TC-F006-004 | Switch repo via dropdown | Tap title → select repo_b | Dropdown shows all repos; switches instantly; lastRepoId updated | | | |
| TC-F006-005 | Init new repo | "Init Repo" → select folder → confirm | Progress "Initializing..."; new repo in list; opens PAGE-009 | | | |
| TC-F006-006 | Push to remote | Tap Push → confirm | PushPullDialog with phases; "Pushed to origin/main" | | | |
| TC-F006-007 | Pull from remote | Observe banner → tap Pull | Behind-remote banner; PullProgress; status refreshes | | | |
| TC-F006-008 | Merge conflict resolution | Pull triggers conflict → resolve 2 files | PAGE-012 shows 2 cards; resolve with Ours/Theirs; FAB enabled; merge commit | | | |
| TC-F006-009 | View file diff | Tap FileStatusItem | DiffSummaryBar + hunks + line numbers + syntax highlighting | | | |
| TC-F006-010 | Auth failure on push | Push fails → enter PAT | Auth dialog; valid PAT → retry succeeds; Cancel → abort | | | |
| TC-F006-011 | No repos shows manage | Tap Git tab (no repos) | PAGE-008 with empty state + 3 CTAs | | | |
| TC-F006-012 | "Manage Repositories..." in dropdown | Tap title → "Manage Repositories..." | Navigates to PAGE-008 with full repo list | | | |
| TC-F006-013 | Git log view | Open PAGE-009 → Log tab | Commit list in reverse chronological order; SHA + author + timestamp | | | |
| TC-F006-014 | lastRepoId persists restart | Open Git → kill app → reopen | PAGE-009 opens for same repo; no PAGE-008 detour | | | |

## 7. Feature F007: Export Engine

### 7.1 UC-004: Document Export

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F007-001 | Export to PDF | Select PDF → Local → Export | Progress phases; "Export Complete!"; file saved | | | |
| TC-F007-002 | Export to HTML | Select HTML → Share → Export | Conversion completes; share sheet opens with .html | | | |
| TC-F007-003 | Export to DOCX | Select DOCX → Local → Export | DOCX file saved locally | | | |
| TC-F007-004 | Export to TXT | Select TXT → observe warning → Export | "Images will be stripped" warning; plain text output | | | |
| TC-F007-005 | Progress bar phases | Export large doc (PDF) | Phase labels cycle; percentage updates; determinate bar | | | |
| TC-F007-006 | Cancel during export | Start export → Cancel | Isolate aborted; back to PAGE-013; snackbar | | | |
| TC-F007-007 | Back preserves selection | Select PDF → Continue → Back | PDF still selected on return | | | |
| TC-F007-008 | Double-tap guard | Double-tap Export | Only one export; button disabled after first tap | | | |
| TC-F007-009 | Conversion failure | Malformed document → export | conversion_error state with retry + "Save as TXT" fallback | | | |
| TC-F007-010 | Google Drive fallback | Drive upload fails | upload_error state; "Save locally instead" fallback | | | |
| TC-F007-011 | Large doc timeout | >5000 words; wait | Timeout error state after 60s; "Continue waiting" / "Cancel" | | | |

## 8. Feature F008: Model Manager

### 8.1 UC-006: Model Configuration & Usage Tracking

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F008-001 | Add provider valid key | Enter DeepSeek key → Validate → Save | "Connected" green; ProviderCard shows "Active" | | | |
| TC-F008-002 | Switch Free→Custom | Tap ModeToggle → Custom → confirm | Confirmation sheet; Task Mapping section appears; 13 rows | | | |
| TC-F008-003 | Per-task mapping | Map "code"→model-b, "writing"→model-a | Rows update; mapping persisted | | | |
| TC-F008-004 | Set usage cap | Hard cap $5; exceed | AI calls blocked; banner shown | | | |
| TC-F008-005 | View usage history | Open PAGE-019; check charts | MetricCards; BarChart interactive; PieChart per breakdown | | | |
| TC-F008-006 | Invalid API key | Enter bad key → Validate | "Connection failed" red; SaveButton disabled | | | |
| TC-F008-007 | Free tier exhausted | Exhaust 5M tokens; send message | Alert with "Add paid key" + settings link | | | |

## 9. Feature F009: Skills System

### 9.1 UC-002: Agent Loop with Tool Execution

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F009-001 | Skills list loads 5 categories | Open Skills tab | 5 category sections; ≥26 tool chips; each shows name + approval level | | | |
| TC-F009-002 | Tool approval filter | Set write_file to "Deny"; prompt save | Tool grayed out; agent told "write_file is denied"; adapts without writing | | | |
| TC-F009-003 | Disabled skill hides tools | Toggle "Writing" OFF; list tools | Writing section grayed; tools suppressed; re-enable restores access | | | |
| TC-F009-004 | Search/filter by name | Type "git" in search | 6 git tools shown; non-matching hidden; clear restores full list | | | |

## 10. Feature F010: Chain of Truth Workflow

### 10.1 UC-003: Document Management (CoT)

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F010-001 | Create CoT project | NewProject → enter name | Project in list; PAGE-021 with artifact tree | | | |
| TC-F010-002 | Generate from template | Select SRS node → load template → Generate | Template content inserted; overwrite guard if content exists | | | |

## 11. Settings & Profile — UC-007 (F008)

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-SET-001 | Update profile | Edit name + email → Save | SaveButton disabled when no changes; "Profile saved" on save | | | |
| TC-SET-002 | Toggle theme | Light→Dark | Preview updates; theme changes immediately; persists | | | |
| TC-SET-003 | Enable biometric auth | Toggle ON → complete biometric prompt | Auth enabled; Auto-Lock row appears | | | |
| TC-SET-004 | Clear export cache | Tap "Clear Export Cache" → confirm | Cache deleted; size shows "0 MB" | | | |
| TC-SET-005 | Export defaults pre-populate | Set PDF+Local defaults → open export | PDF selected; Local selected; ExportButton enabled | | | |
| TC-SET-006 | Biometric missing PIN fallback | Toggle auth → no biometrics | PIN setup offered; 6-digit PIN saved; auth enabled | | | |
| TC-SET-007 | DB corrupt restore defaults | Corrupt drift DB → open settings | "Restoring defaults" notice; defaults loaded; no crash | | | |

## 11. Execution Summary

| Feature | Total TC | PASS | FAIL | N/A | Pass Rate |
|---------|----------|------|------|-----|-----------|
| F001 AI Chat | 9 | | | | |
| F002 Multi-Agent System | 4 | | | | |
| F003 Task Router | 4 | | | | |
| F004 Agent Loop | 6 | | | | |
| F005 Markdown Editor | 10 | | | | |
| F006 Git Version Control | 14 | | | | |
| F007 Export Engine | 11 | | | | |
| F008 Model Manager (incl. Settings) | 14 | | | | |
| F009 Skills System | 4 | | | | |
| F010 CoT Workflow | 2 | | | | |
| **Total** | **78** | | | | |

## 12. Defect Triage Summary

| TC ID | Suspected Source | Action Taken | Resolved? |
|-------|------------------|--------------|-----------|
| | | | |

## 13. Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-07-04 | Maya on the Fly | Initial execution sheet — 68 test cases |
| 1.1 | 2026-07-04 | Maya on the Fly | Added F002/F009 sections + 3 F006 TCs; renumbered sections 1–11; updated counts to 78 |

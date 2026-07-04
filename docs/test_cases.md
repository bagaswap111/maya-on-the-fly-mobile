# Test Cases: Maya on the Fly

**Document:** SoT-9 Test Cases | **Derived From:** SoT-4 (User Flows) + SoT-7 (UCIC) | **Status:** Draft | **Last Updated:** 2026-07-04

> Every test case traces to a Use Case (User Flow) and a Feature (SRS). Derive from the SoT — do not reverse-engineer from code.

## 1. Introduction

### 1.1 Purpose
Provide testable, traceable cases that verify the implementation against the validated Sources of Truth across all 10 SRS features and 7 use cases.

### 1.2 Scope
All 10 features (F001–F010) and 7 use cases (UC-001–UC-007). 78 test cases total: 60 positive, 3 negative, 15 exception.

### 1.3 Test Case Format

| Field | Description |
|-------|-------------|
| TC ID | Unique identifier: TC-F[feature]-[seq] |
| Related UC | Use Case ID this case exercises |
| Related Feature | SRS Feature ID |
| Test Scenario | One-line description of what is being verified |
| Type | Positive / Negative / Exception |
| Preconditions | State required before execution |
| Test Data | Specific inputs / seeded data |
| Test Steps | Ordered actions to perform |
| Expected Result | Observable outcome per User Flow / UCIC |

## 2. Test Case Index

| TC ID | Feature | Use Case | Scenario | Type |
|-------|---------|----------|----------|------|
| TC-F001-001 | F001 | UC-001 | Send message and receive streaming response | Positive |
| TC-F001-002 | F001 | UC-001 | Stop generation mid-stream | Positive |
| TC-F002-001 | F002 | UC-001 | Agent switch preserves conversation history | Positive |
| TC-F001-004 | F001 | UC-001 | Task reclassification updates model routing | Positive |
| TC-F001-005 | F001 | UC-001 | Session token counter updates in real-time | Positive |
| TC-F001-006 | F001 | UC-001 | Network timeout with auto-retry | Exception |
| TC-F001-007 | F001 | UC-001 | Invalid API key shows config error | Exception |
| TC-F001-008 | F001 | UC-001 | Rate limited with countdown | Exception |
| TC-F001-009 | F001 | UC-001 | Hard cap reached blocks AI calls | Exception |
| TC-F001-010 | F001 | UC-001 | Empty message rejected | Negative |
| TC-F002-002 | F002 | UC-001, UC-002 | 13 agent personas available for selection | Positive |
| TC-F002-003 | F002 | UC-002 | Per-agent tool sets differ by persona | Positive |
| TC-F002-004 | F002 | UC-002 | Auto agent routes task to correct agent | Positive |
| TC-F003-001 | F003 | UC-001 | "write a research proposal" → academic task type | Positive |
| TC-F003-002 | F003 | UC-001 | "fix this bug" → code or review task type | Positive |
| TC-F003-003 | F003 | UC-001 | "make this sound less robotic" → humanize task type | Positive |
| TC-F003-004 | F003 | UC-001 | Unrecognized input falls back gracefully | Negative |
| TC-F004-001 | F004 | UC-002 | Agent completes multi-turn tool task (read→edit→commit) | Positive |
| TC-F004-002 | F004 | UC-002 | Stop button interrupts mid-loop, returns partial output | Positive |
| TC-F004-003 | F004 | UC-002 | User denies tool execution, model adapts | Positive |
| TC-F004-004 | F004 | UC-002 | Destructive tool requires user confirmation | Positive |
| TC-F004-005 | F004 | UC-002 | Tool execution error returned to model gracefully | Exception |
| TC-F004-006 | F004 | UC-002 | Unknown tool request handled | Exception |
| TC-F005-001 | F005 | UC-003 | Create new blank document | Positive |
| TC-F005-002 | F005 | UC-003 | Edit content triggers auto-save within 5s | Positive |
| TC-F005-003 | F005 | UC-003 | Toggle preview between edit and rendered view | Positive |
| TC-F005-004 | F005 | UC-003 | LaTeX equations render correctly in preview | Positive |
| TC-F005-005 | F005 | UC-003 | Discard confirmation prevents data loss on navigation | Positive |
| TC-F005-006 | F005 | UC-003 | Version history shows auto-save snapshots | Positive |
| TC-F005-007 | F005 | UC-003 | Pin document persists across restarts | Positive |
| TC-F005-008 | F005 | UC-003 | Storage full triggers warning, reduces save interval | Exception |
| TC-F005-009 | F005 | UC-003 | Document deleted externally shows error state | Exception |
| TC-F005-010 | F005 | UC-003 | Recent documents list shows accurate data | Positive |
| TC-F006-001 | F006 | UC-005 | Git tab opens last repo status directly | Positive |
| TC-F006-002 | F006 | UC-005 | View repo status with modified files | Positive |
| TC-F006-003 | F006 | UC-005 | Stage file and commit with message | Positive |
| TC-F006-004 | F006 | UC-005 | Switch repository via AppBar dropdown | Positive |
| TC-F006-005 | F006 | UC-005 | Initialize new local repository | Positive |
| TC-F006-006 | F006 | UC-005 | Push commits to remote with progress | Positive |
| TC-F006-007 | F006 | UC-005 | Pull from remote with behind-remote banner | Positive |
| TC-F006-008 | F006 | UC-005 | Merge conflict resolution (Ours/Theirs/Manual) | Positive |
| TC-F006-009 | F006 | UC-005 | View file diff with syntax highlighting | Positive |
| TC-F006-010 | F006 | UC-005 | Auth failure on push shows credential entry | Exception |
| TC-F006-011 | F006 | UC-005 | No repos exist shows manage page with CTAs | Positive |
| TC-F006-012 | F006 | UC-005 | "Manage Repositories..." opens full repo list | Positive |
| TC-F006-013 | F006 | UC-005 | Git log view shows commit history | Positive |
| TC-F006-014 | F006 | UC-005 | lastRepoId persists across app restart | Positive |
| TC-F007-001 | F007 | UC-004 | Export document to PDF successfully | Positive |
| TC-F007-002 | F007 | UC-004 | Export document to HTML successfully | Positive |
| TC-F007-003 | F007 | UC-004 | Export document to DOCX successfully | Positive |
| TC-F007-004 | F007 | UC-004 | Export document to TXT successfully | Positive |
| TC-F007-005 | F007 | UC-004 | Progress bar shows phase labels during conversion | Positive |
| TC-F007-006 | F007 | UC-004 | Cancel during export aborts Isolate cleanly | Positive |
| TC-F007-007 | F007 | UC-004 | Back at each step preserves previous selection | Positive |
| TC-F007-008 | F007 | UC-004 | Double-tap Export only triggers one conversion | Positive |
| TC-F007-009 | F007 | UC-004 | Conversion failure shows error and re-enables button | Exception |
| TC-F007-010 | F007 | UC-004 | Google Drive fallback saves locally on failure | Exception |
| TC-F007-011 | F007 | UC-004 | Large document shows timeout option | Exception |
| TC-F008-001 | F008 | UC-006 | Add provider with valid API key | Positive |
| TC-F008-002 | F008 | UC-006 | Switch Free to Custom mode | Positive |
| TC-F008-003 | F008 | UC-006 | Per-task model mapping in Custom mode | Positive |
| TC-F008-004 | F008 | UC-006 | Set usage cap and verify enforcement | Positive |
| TC-F008-005 | F008 | UC-006 | View usage history with daily breakdown | Positive |
| TC-F008-006 | F008 | UC-006 | Invalid API key rejected with clear error | Negative |
| TC-F008-007 | F008 | UC-006 | DeepSeek free tier exhausted alert | Exception |
| TC-F009-001 | F009 | UC-002 | Skills list loads all 5 categories | Positive |
| TC-F009-002 | F009 | UC-002 | Tool-level approval filter works | Positive |
| TC-F009-003 | F009 | UC-002 | Disabled skill suppresses its tools | Positive |
| TC-F009-004 | F009 | UC-002 | Skill search/filter by name works | Positive |
| TC-F010-001 | F010 | UC-003 | Create CoT project with artifacts | Positive |
| TC-F010-002 | F010 | UC-003 | Generate artifact from template | Positive |
| TC-SET-001 | — | UC-007 | Update user profile fields | Positive |
| TC-SET-002 | — | UC-007 | Toggle theme between Light/Dark/System | Positive |
| TC-SET-003 | — | UC-007 | Enable biometric or PIN authentication | Positive |
| TC-SET-004 | — | UC-007 | Clear export cache frees storage | Positive |
| TC-SET-005 | — | UC-007 | Set export defaults pre-populate export flow | Positive |
| TC-SET-006 | — | UC-007 | Biometric enrollment missing shows PIN fallback | Exception |
| TC-SET-007 | — | UC-007 | Database corruption restores defaults gracefully | Exception |

## 3. Test Cases

### 3.1 Feature F001: AI Chat with Streaming

#### 3.1.1 UC-001: AI Chat Completion

**TC-F001-001: Send message and receive streaming response**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-001 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | User sends message and sees token-by-token streaming response |
| Type | Positive |
| Preconditions | Chat session exists; AI provider configured; internet available |
| Test Data | Message: "Hello, what is Flutter?" |
| Test Steps | 1. Open PAGE-006 with active session. 2. Type "Hello, what is Flutter?" in ChatInputBar. 3. Tap Send button. |
| Expected Result | 1. Message appears in thread immediately. 2. Typing indicator shows in header. 3. Response tokens appear character-by-character in StreamingTextWidget. 4. Token counter updates incrementally. 5. Full response visible. 6. StopButton visible during streaming, hidden after. |

**TC-F001-002: Stop generation mid-stream**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-002 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | User stops generation while response is streaming |
| Type | Positive |
| Preconditions | AI response currently streaming |
| Test Data | Prompt that produces a long response (e.g., "Write a 500-word essay") |
| Test Steps | 1. Send prompt. 2. While streaming, tap StopButton in header. |
| Expected Result | 1. Streaming stops immediately. 2. Partial text displayed. 3. StopButton hides. 4. "Generation stopped" system message appears. 5. User can send new message. |

**TC-F001-004: Task reclassification updates model routing**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-004 |
| Related UC | UC-001 (Alt-2) |
| Related Feature | F001 |
| Test Scenario | User changes task type badge, next message uses new model |
| Type | Positive |
| Preconditions | Custom mode enabled; different models mapped per task type |
| Test Data | Change from "chat" to "code" task type |
| Test Steps | 1. Tap TaskTypeBadge. 2. Select "code" from dropdown. 3. Confirm reclassification. |
| Expected Result | 1. Badge updates to "code". 2. Next message routed to model configured for "code" task type. |

**TC-F001-005: Session token counter updates in real-time**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-005 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | Token counter in chat header updates incrementally during streaming |
| Type | Positive |
| Preconditions | Chat session open; streaming a response |
| Test Data | — |
| Test Steps | 1. Send message. 2. Observe TokenCounter during streaming. 3. Observe after completion. |
| Expected Result | 1. TokenCounter begins at pre-stream count. 2. Number increments as tokens arrive. 3. Final count matches API response `usage.total_tokens`. 4. On phone < 600dp, TokenCounter is in overflow menu. |

**TC-F001-006: Network timeout with auto-retry**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-006 |
| Related UC | UC-001 (Exc-1) |
| Related Feature | F001 |
| Test Scenario | Network timeout triggers auto-retry with exponential backoff |
| Type | Exception |
| Preconditions | Mock HTTP client that hangs for 31s then responds |
| Test Data | — |
| Test Steps | 1. Send message. 2. Wait for timeout. |
| Expected Result | 1. After 30s: "Connection lost. Retrying..." toast shown. 2. Auto-retries at 2s, 4s, 8s intervals. 3. On successful retry: response streams normally. 4. On all 3 retries fail: error-state with retry button. |

**TC-F001-007: Invalid API key shows config error**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-007 |
| Related UC | UC-001 (Exc-2) |
| Related Feature | F001 |
| Test Scenario | HTTP 401 from provider shows invalid key error |
| Type | Exception |
| Preconditions | Mock HTTP returns 401 |
| Test Data | — |
| Test Steps | 1. Send message. |
| Expected Result | 1. "Invalid API key for {Provider}. Check your settings." error shown. 2. Link to settings page present. |

**TC-F001-008: Rate limited with countdown**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-008 |
| Related UC | UC-001 (Exc-3) |
| Related Feature | F001 |
| Test Scenario | HTTP 429 triggers rate limit countdown and auto-retry |
| Type | Exception |
| Preconditions | Mock HTTP returns 429 with Retry-After: 30 |
| Test Data | — |
| Test Steps | 1. Send message. |
| Expected Result | 1. "Rate limited by {Provider}. Waiting..." shown with countdown. 2. Auto-retries after rate limit window. 3. Success on retry: flow resumes. |

**TC-F001-009: Hard cap reached blocks AI calls**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-009 |
| Related UC | UC-001 (Exc-4) |
| Related Feature | F001 |
| Test Scenario | Monthly usage cap exceeded prevents AI calls |
| Type | Exception |
| Preconditions | UsageAlert hard cap = $10; UsageRecord total this month > $10 |
| Test Data | — |
| Test Steps | 1. Send message. |
| Expected Result | 1. Before API call: "Monthly usage cap of $10 reached. AI calls paused." blocking banner. 2. "Reset Cap" button present. 3. Link to usage dashboard present. |

**TC-F001-010: Empty message rejected**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-010 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | Send button disabled when input is empty |
| Type | Negative |
| Preconditions | Chat session open; input field empty |
| Test Data | Empty string |
| Test Steps | 1. Leave input empty. 2. Observe SendButton state. |
| Expected Result | 1. SendButton disabled (greyed out). 2. Send button remains disabled until text entered. |

---

### 3.2 Feature F002: Multi-Agent System

#### 3.2.1 UC-001: AI Chat Completion (Agent Switch)

**TC-F002-001: Agent switch preserves conversation history**

| Field | Value |
|-------|-------|
| TC ID | TC-F002-001 |
| Related UC | UC-001 (Alt-1) |
| Related Feature | F002 |
| Test Scenario | User switches agent mid-conversation, history preserved |
| Type | Positive |
| Preconditions | Chat session with at least 3 prior messages from Writer agent |
| Test Data | Current agent: Writer. Switch to: Coder. |
| Test Steps | 1. Tap AgentSelectorChip. 2. Select "Coder" from dropdown. 3. Confirm in SwitchAgentConfirmation. |
| Expected Result | 1. Confirmation bottom sheet appears with "Switching agent clears context" note. 2. On confirm, header updates to Coder avatar + name. 3. Previous messages remain visible. 4. New message uses Coder's system prompt. |

**TC-F002-002: 13 agent personas available for selection**

| Field | Value |
|-------|-------|
| TC ID | TC-F002-002 |
| Related UC | UC-001, UC-002 |
| Related Feature | F002 |
| Test Scenario | All 13 agent personas appear in AgentSelectorChip |
| Type | Positive |
| Preconditions | Chat session open |
| Test Data | — |
| Test Steps | 1. Tap AgentSelectorChip. 2. Scroll through dropdown list. |
| Expected Result | 1. Dropdown shows all 13 agent personas. 2. Each shows avatar + name + short description. 3. Current agent highlighted with checkmark. |

**TC-F002-003: Per-agent tool sets differ by persona**

| Field | Value |
|-------|-------|
| TC ID | TC-F002-003 |
| Related UC | UC-002 |
| Related Feature | F002 |
| Test Scenario | Writer agent has document tools, Git agent has repo tools |
| Type | Positive |
| Preconditions | Chat session with Writer agent active |
| Test Data | Switch between Writer and Git agents |
| Test Steps | 1. With Writer agent, send "list available tools". 2. Switch to Git agent. 3. Repeat tool list request. |
| Expected Result | 1. Writer shows read_file, edit_file, search_web. 2. Git shows git_status, git_commit, git_push, git_pull. 3. Each agent's available tools match its persona definition. |

**TC-F002-004: Auto agent routes task to correct agent**

| Field | Value |
|-------|-------|
| TC ID | TC-F002-004 |
| Related UC | UC-002 |
| Related Feature | F002 |
| Test Scenario | Auto agent correctly routes 3 distinct task types |
| Type | Positive |
| Preconditions | Auto agent selected; Custom mode with all 13 agents available |
| Test Data | Prompt 1: "write a research paper on AI". Prompt 2: "fix bugs on main branch". Prompt 3: "summarize my notes about quantum computing". |
| Test Steps | 1. Send "write a research paper on AI". 2. Observe selected agent. 3. Send "fix bugs on main branch". 4. Observe selected agent. 5. Send "summarize my notes about quantum computing". 6. Observe selected agent. |
| Expected Result | 1. "write a research paper on AI" → Writer agent selected. 2. "fix bugs on main branch" → Git agent selected. 3. "summarize my notes about quantum computing" → Reader agent selected. 4. Each agent change shows confirmation bottom sheet. |

---

### 3.3 Feature F003: Task Router

#### 3.3.1 UC-001: AI Chat Completion

**TC-F003-001: "write a research proposal" → academic task type**

| Field | Value |
|-------|-------|
| TC ID | TC-F003-001 |
| Related UC | UC-001 |
| Related Feature | F003 |
| Test Scenario | Research/writing prompt classified as "academic" task type |
| Type | Positive |
| Preconditions | Chat session open |
| Test Data | Prompt: "write a research proposal on quantum computing" |
| Test Steps | 1. Send prompt. 2. Observe TaskTypeBadge. |
| Expected Result | 1. TaskTypeBadge shows "academic". 2. Model selected for academic type is used. |

**TC-F003-002: "fix this bug" → code or review task type**

| Field | Value |
|-------|-------|
| TC ID | TC-F003-002 |
| Related UC | UC-001 |
| Related Feature | F003 |
| Test Scenario | Code-related prompt classified as "code" or "review" |
| Type | Positive |
| Preconditions | Chat session open |
| Test Data | Prompt: "fix this bug in my Dart code" |
| Test Steps | 1. Send prompt. 2. Observe TaskTypeBadge. |
| Expected Result | 1. TaskTypeBadge shows either "code" or "review". |

**TC-F003-003: "make this sound less robotic" → humanize task type**

| Field | Value |
|-------|-------|
| TC ID | TC-F003-003 |
| Related UC | UC-001 |
| Related Feature | F003 |
| Test Scenario | Humanization prompt classified as "humanize" |
| Type | Positive |
| Preconditions | Chat session open |
| Test Data | Prompt: "make this sound less robotic" |
| Test Steps | 1. Send prompt. 2. Observe TaskTypeBadge. |
| Expected Result | 1. TaskTypeBadge shows "humanize". |

**TC-F003-004: Unrecognized input falls back gracefully**

| Field | Value |
|-------|-------|
| TC ID | TC-F003-004 |
| Related UC | UC-001 |
| Related Feature | F003 |
| Test Scenario | Garbled input falls back to default task type |
| Type | Negative |
| Preconditions | Chat session open |
| Test Data | Prompt: "a;lskdjf;laksjdf" |
| Test Steps | 1. Send garbled prompt. 2. Observe TaskTypeBadge. 3. Observe response. |
| Expected Result | 1. TaskTypeBadge defaults to "chat" (general). 2. Model responds with fallback acknowledgment. 3. No crash or error state. |

---

### 3.4 Feature F004: Agent Loop & Tool Execution

#### 3.4.1 UC-002: Agent Loop with Tool Execution

**TC-F004-001: Agent completes multi-turn tool task**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-001 |
| Related UC | UC-002 |
| Related Feature | F004 |
| Test Scenario | Agent executes read_file → edit → git_commit sequence |
| Type | Positive |
| Preconditions | Chat session with Coder agent; document exists; git repo active |
| Test Data | Prompt: "Read main.dart, add a comment, and commit" |
| Test Steps | 1. Send prompt. 2. Observe tool calls. 3. Approve each tool when confirmation shown. |
| Expected Result | 1. Model sends tool_calls: read_file → tool result → edit_file → tool result → git_commit. 2. Each ToolCallCard shows status: pending → running → done. 3. Confirmation shown for write_file and git_commit (destructive). 4. Final response summarizing actions. 5. File modified; commit created. |

**TC-F004-002: Stop button interrupts mid-loop**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-002 |
| Related UC | UC-002 (Alt-2) |
| Related Feature | F004 |
| Test Scenario | User stops agent loop mid-execution |
| Type | Positive |
| Preconditions | Agent loop currently running (e.g., multi-turn task) |
| Test Data | Prompt requiring 3+ tool calls |
| Test Steps | 1. Send prompt. 2. While loop is executing (during tool call or between turns), tap StopButton. |
| Expected Result | 1. Current API call cancelled immediately. 2. Pending tool calls not executed. 3. Partial output displayed. 4. "Generation stopped" system notice. 5. User can send new message. |

**TC-F004-003: User denies tool execution, model adapts**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-003 |
| Related UC | UC-002 (Alt-1) |
| Related Feature | F004 |
| Test Scenario | User denies a tool execution, model adapts response |
| Type | Positive |
| Preconditions | Agent requests tool with `confirm` level |
| Test Data | Prompt: "Delete the temp files" (triggers destructive tool) |
| Test Steps | 1. Send prompt. 2. When ToolExecutionConfirmation appears, tap "Deny". |
| Expected Result | 1. Confirmation dialog shows tool name + arguments. 2. On Deny: "User denied execution of {tool_name}" sent to model. 3. Model responds without executing tool. 4. No file changes made. |

**TC-F004-004: Destructive tool requires user confirmation**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-004 |
| Related UC | UC-002 |
| Related Feature | F004 |
| Test Scenario | write_file tool shows confirmation before executing |
| Type | Positive |
| Preconditions | Agent tries to use write_file tool |
| Test Data | Prompt: "Save this content to output.md" |
| Test Steps | 1. Send prompt. 2. Observe tool call. |
| Expected Result | 1. ToolExecutionConfirmation bottom sheet appears. 2. Shows tool name "write_file" + filename + content preview. 3. Confirm/Deny buttons. 4. On Confirm: tool executes. 5. On Deny: tool skipped. |

**TC-F004-005: Tool execution error returned to model gracefully**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-005 |
| Related UC | UC-002 (Exc-1) |
| Related Feature | F004 |
| Test Scenario | Tool throws exception, error sent back to model |
| Type | Exception |
| Preconditions | Tool that will fail (e.g., read_file on non-existent path) |
| Test Data | Prompt: "Read file nonexistent.txt" |
| Test Steps | 1. Send prompt. 2. Observe tool call. |
| Expected Result | 1. ToolExecutor catches FileNotFoundException. 2. "Error executing read_file: File not found" sent to model. 3. Model adapts response (e.g., "That file doesn't exist. Let me check the directory..."). |

**TC-F004-006: Unknown tool request handled**

| Field | Value |
|-------|-------|
| TC ID | TC-F004-006 |
| Related UC | UC-002 (Exc-2) |
| Related Feature | F004 |
| Test Scenario | Model requests tool not in SkillRegistry |
| Type | Exception |
| Preconditions | Model hallucinates a tool name |
| Test Data | Prompt designed to trigger hallucinated tool |
| Test Steps | 1. Send prompt. 2. Observe tool call. |
| Expected Result | 1. System checks SkillRegistry → tool not found. 2. "Tool {name} not available. Available tools: {list}" sent to model. 3. Model adapts. |

---

### 3.5 Feature F005: Markdown Editor

#### 3.5.1 UC-003: Document Management

**TC-F005-001: Create new blank document**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-001 |
| Related UC | UC-003 |
| Related Feature | F005 |
| Test Scenario | User creates a new blank document from home screen |
| Type | Positive |
| Preconditions | App open on PAGE-001 (Home) |
| Test Data | Template: "Blank Document" |
| Test Steps | 1. Tap "New Doc" QuickActionsRow card. 2. Select "Blank Document" template. 3. Tap "Create from Blank Document". |
| Expected Result | 1. PAGE-003 shows template carousel. 2. PAGE-002 opens with empty editor. 3. Placeholder "Start writing..." shown. 4. Document row appears in Home recent list. |

**TC-F005-002: Edit content triggers auto-save within 5s**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-002 |
| Related UC | UC-003 |
| Related Feature | F005 |
| Test Scenario | Typing triggers auto-save within 5 seconds |
| Type | Positive |
| Preconditions | Document open in editor |
| Test Data | Type: "# Hello\n\nThis is a test document." |
| Test Steps | 1. Type content into editor. 2. Wait 5 seconds. 3. Observe AutoSaveIndicator. |
| Expected Result | 1. AutoSaveIndicator shows red dot (unsaved) immediately. 2. After ~5s: dot turns yellow (saving) then green (saved). 3. Document content persisted to drift. |

**TC-F005-003: Toggle preview between edit and rendered view**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-003 |
| Related UC | UC-003 |
| Related Feature | F005 |
| Test Scenario | User toggles preview to see rendered markdown |
| Type | Positive |
| Preconditions | Document with markdown content open in editor |
| Test Data | Content with headings, lists, bold, code blocks |
| Test Steps | 1. Tap PreviewToggleButton (eye icon). 2. Observe view change. 3. Tap again to return to edit. |
| Expected Result | 1. Phone portrait: AnimatedSwitcher fades to PreviewPane. 2. Phone landscape + tablet: side-by-side split appears. 3. Markdown rendered with flutter_markdown. 4. Toggle back to edit mode preserves cursor position. |

**TC-F005-004: LaTeX equations render correctly in preview**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-004 |
| Related UC | UC-003 |
| Related Feature | F005 |
| Test Scenario | LaTeX math renders in preview pane |
| Type | Positive |
| Preconditions | Document with LaTeX content open |
| Test Data | Content: "The energy-mass equivalence is $E=mc^2$. The integral $\int_a^b f(x)dx$." |
| Test Steps | 1. Toggle to preview. 2. Observe LaTeX rendering. |
| Expected Result | 1. Inline $E=mc^2$ renders as formatted math. 2. Block $$...$$ renders centered. 3. No raw LaTeX source visible in preview. |

**TC-F005-005: Discard confirmation prevents data loss on navigation**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-005 |
| Related UC | UC-003 (Alt-2) |
| Related Feature | F005 |
| Test Scenario | Navigating back with unsaved changes shows confirmation |
| Type | Positive |
| Preconditions | Document with unsaved edits |
| Test Data | — |
| Test Steps | 1. Make unsaved edit. 2. Tap BackButton. 3. Observe dialog. |
| Expected Result | 1. PopScope fires. 2. Dialog: "Save before leaving?" with Discard/Save/Cancel. 3. Tap Save → auto-saves then pops. 4. Tap Discard → pops without saving. 5. Tap Cancel → stays in editor. |

**TC-F005-006: Version history shows auto-save snapshots**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-006 |
| Related UC | UC-003 (Alt-2) |
| Related Feature | F005 |
| Test Scenario | User views and restores previous document version |
| Type | Positive |
| Preconditions | Document has multiple auto-save versions |
| Test Data | — |
| Test Steps | 1. Open document menu. 2. Tap "Version History". 3. Select previous version. 4. Confirm restore. |
| Expected Result | 1. Version list shows timestamps + content previews. 2. Selecting a version shows confirmation dialog. 3. On confirm: document content replaced with selected version. |

**TC-F005-007: Pin document persists across restarts**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-007 |
| Related UC | UC-003 (Alt-3) |
| Related Feature | F005 |
| Test Scenario | Pinned document stays at top of recent list |
| Type | Positive |
| Preconditions | Multiple documents exist in recent list |
| Test Data | — |
| Test Steps | 1. Long-press a non-pinned document. 2. Tap "Pin to Top". 3. Restart app. 4. Open home screen. |
| Expected Result | 1. Pinned document shows at top of recent list. 2. Pin indicator icon visible. 3. Survives app restart. |

**TC-F005-008: Storage full triggers warning, reduces save interval**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-008 |
| Related UC | UC-003 (Exc-1) |
| Related Feature | F005 |
| Test Scenario | Storage full warning shown, save interval relaxed |
| Type | Exception |
| Preconditions | Device storage nearly full (< 50MB free) |
| Test Data | — |
| Test Steps | 1. Edit document. 2. Attempt auto-save. |
| Expected Result | 1. Warning toast: "Storage almost full. Document may not save." 2. Auto-save interval changes from 5s to 30s. 3. Document content still in memory. |

**TC-F005-009: Document deleted externally shows error state**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-009 |
| Related UC | UC-003 (Exc-2) |
| Related Feature | F005 |
| Test Scenario | Opening a document that was deleted externally shows error |
| Type | Exception |
| Preconditions | Document record exists in drift but file deleted from filesystem |
| Test Data | — |
| Test Steps | 1. Tap deleted document in recent list. 2. Observe result. |
| Expected Result | 1. Error state: "Document not found. It may have been deleted." 2. Options: "Remove from list" or "Recreate". |

**TC-F005-010: Recent documents list shows accurate data**

| Field | Value |
|-------|-------|
| TC ID | TC-F005-010 |
| Related UC | UC-003 |
| Related Feature | F005 |
| Test Scenario | Home screen recent list shows correct titles and timestamps |
| Type | Positive |
| Preconditions | 5+ documents exist, some edited recently, some old |
| Test Data | — |
| Test Steps | 1. Open PAGE-001 (Home). 2. Observe Recent Documents list. |
| Expected Result | 1. List shows max 20 documents. 2. Sorted by last-modified descending. 3. Each item shows title, timeAgo, word count. 4. Pinned items at top. 5. Empty state if no documents. |

---

### 3.6 Feature F006: Git Version Control

#### 3.6.1 UC-005: Git Operations

**TC-F006-001: Git tab opens last repo status directly**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-001 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | Git tab opens last-opened repo status (not repo list) |
| Type | Positive |
| Preconditions | UserProfile.lastRepoId set; repo still exists |
| Test Data | lastRepoId = repo_uuid_1 |
| Test Steps | 1. Tap Git tab in bottom nav. |
| Expected Result | 1. PAGE-009 opens directly for repo_uuid_1. 2. Status loaded and displayed. 3. No navigation stack push to PAGE-008. |

**TC-F006-002: View repo status with modified files**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-002 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | Repo status shows all modified, staged, untracked files |
| Type | Positive |
| Preconditions | Repo with 2 modified, 1 staged, 1 untracked file |
| Test Data | git status mock: M file1.md, M file2.dart, A file3.txt staged, ?? file4.py |
| Test Steps | 1. Open PAGE-009. 2. Observe file list. |
| Expected Result | 1. SectionHeader: "Changes (3 files)". 2. FileStatusItem × 4 with correct StatusIcon colors. 3. StageCheckbox visible on unstaged items. 4. Behind-remote banner if applicable. |

**TC-F006-003: Stage file and commit with message**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-003 |
| Related UC | UC-005 (Main Flow) |
| Related Feature | F006 |
| Test Scenario | User stages a file, enters commit message, and commits |
| Type | Positive |
| Preconditions | Repo with unstaged changes |
| Test Data | Stage file2.dart. Commit message: "fix: update error handling" |
| Test Steps | 1. Check StageCheckbox on file2.dart. 2. Tap CommitButton. 3. Enter message "fix: update error handling". 4. Tap CommitButton in sheet. 5. Confirm in dialog. |
| Expected Result | 1. StageCheckbox becomes checked; file moves to staged section. 2. CommitSheet slides up. 3. ConfirmDialog shows summary. 4. On confirm: SnackBar "Committed 1 file — fix: update error handling". 5. Status refreshes, working tree clean. |

**TC-F006-004: Switch repository via AppBar dropdown**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-004 |
| Related UC | UC-005 (Alt-1) |
| Related Feature | F006 |
| Test Scenario | User switches active repo via dropdown |
| Type | Positive |
| Preconditions | 3 repos configured; on repo A's status page |
| Test Data | Switch from repo_a to repo_b |
| Test Steps | 1. Tap repo name in AppBar title area. 2. Select repo_b from dropdown. |
| Expected Result | 1. Dropdown shows all 3 repos, repo_a highlighted with checkmark. 2. Tapping repo_b: PAGE-009 switches to repo_b's status instantly. 3. UserProfile.lastRepoId updated to repo_b. |

**TC-F006-005: Initialize new local repository**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-005 |
| Related UC | UC-005 (Alt-3) |
| Related Feature | F006 |
| Test Scenario | User inits a new git repo in a local folder |
| Type | Positive |
| Preconditions | PAGE-008 with no repos or "Init Repo" visible |
| Test Data | Folder: /Documents/my-project |
| Test Steps | 1. Tap "Init Repo". 2. Select folder. 3. Confirm. |
| Expected Result | 1. Progress indicator: "Initializing..." 2. Success: "Git repo initialized". 3. New repo appears in list. 4. Tapping opens PAGE-009 with empty status. |

**TC-F006-006: Push commits to remote with progress**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-006 |
| Related UC | UC-005 (Alt-2) |
| Related Feature | F006 |
| Test Scenario | User pushes committed changes to remote |
| Type | Positive |
| Preconditions | Local commits exist, remote "origin" configured |
| Test Data | — |
| Test Steps | 1. Tap Push button. 2. Observe PushPullDialog. 3. Confirm. |
| Expected Result | 1. PushPullDialog shows "Connecting..." → "Pushing {n} objects...". 2. ProgressBar indeterminate then determinate. 3. On success: dialog closes. 4. SnackBar: "Pushed to origin/main". |

**TC-F006-007: Pull from remote with behind-remote banner**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-007 |
| Related UC | UC-005 (Alt-3) |
| Related Feature | F006 |
| Test Scenario | User pulls changes when branch is behind remote |
| Type | Positive |
| Preconditions | Local branch behind remote by 2 commits |
| Test Data | — |
| Test Steps | 1. Observe behind-remote banner. 2. Tap Pull button. 3. Confirm. |
| Expected Result | 1. Warning banner: "Branch is 2 commits behind. Pull to update." 2. PullProgress shown. 3. On success: status refreshes, behind count = 0. |

**TC-F006-008: Merge conflict resolution**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-008 |
| Related UC | UC-005 (Exc-1) |
| Related Feature | F006 |
| Test Scenario | Merge conflict shows resolution options |
| Type | Positive |
| Preconditions | Pull results in merge conflict on 2 files |
| Test Data | — |
| Test Steps | 1. Pull triggers conflict. 2. Navigate to PAGE-012. 3. Resolve file1 with "Accept Ours". 4. Resolve file2 with Accept Theirs. 5. Commit merge. |
| Expected Result | 1. PAGE-012 shows 2 ConflictFileCards. 2. File1 resolved with Ours: shows green checkmark. 3. File2 resolved with Theirs: shows green checkmark. 4. FAB: "Mark All Resolved & Commit". 5. On commit: merge commit created. |

**TC-F006-009: View file diff with syntax highlighting**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-009 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | User taps file to view diff |
| Type | Positive |
| Preconditions | Repo with modified file |
| Test Data | — |
| Test Steps | 1. Tap FileStatusItem. 2. Observe PAGE-010. |
| Expected Result | 1. DiffSummaryBar shows +5 -2. 2. DiffViewer shows hunks with line numbers. 3. Syntax highlighting applied per file extension. 4. Toggle unified/split view works (split only on tablet). |

**TC-F006-010: Auth failure on push shows credential entry**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-010 |
| Related UC | UC-005 (Exc-2) |
| Related Feature | F006 |
| Test Scenario | Push fails with auth error, user enters credentials |
| Type | Exception |
| Preconditions | Remote requires auth; no credentials stored |
| Test Data | — |
| Test Steps | 1. Tap Push. 2. Auth fails. 3. Enter PAT in dialog. 4. Retry push. |
| Expected Result | 1. Push starts → fails with auth error. 2. Dialog: "Authentication required for {remote_url}". 3. Options: Enter PAT, SSH key, Cancel. 4. On valid credential entry: push retries and succeeds. |

**TC-F006-011: No repos exist shows manage page with CTAs**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-011 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | Git tab opens manage page when no repos configured |
| Type | Positive |
| Preconditions | UserProfile.lastRepoId null; no repos in database |
| Test Data | — |
| Test Steps | 1. Tap Git tab. |
| Expected Result | 1. PAGE-008 opens (not PAGE-009). 2. Empty state: "No repositories yet". 3. CTAs: InitLocalRepo, CloneRemoteRepo, OpenExistingFolder. |

**TC-F006-012: "Manage Repositories..." opens full repo list**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-012 |
| Related UC | UC-005 (Alt-1) |
| Related Feature | F006 |
| Test Scenario | "Manage Repositories..." option in dropdown opens full repo list |
| Type | Positive |
| Preconditions | 2+ repos configured; on repo A's status page |
| Test Data | — |
| Test Steps | 1. Tap repo name in AppBar. 2. Tap "Manage Repositories..." at bottom of dropdown. 3. Observe navigation. |
| Expected Result | 1. Dropdown shows all repos + "Manage Repositories..." at bottom. 2. Tapping "Manage Repositories..." navigates to PAGE-008. 3. PAGE-008 shows full repo list with all CRUD options. |

**TC-F006-013: Git log view shows commit history**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-013 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | Git log tab shows commit history with correct ordering |
| Type | Positive |
| Preconditions | Repo with 3+ commits |
| Test Data | — |
| Test Steps | 1. Open PAGE-009. 2. Tap Log tab. 3. Observe commit list. |
| Expected Result | 1. CommitHistory shows commits in reverse chronological order. 2. Each entry shows SHA, author, timestamp, message. 3. Tapping a commit shows full diff. |

**TC-F006-014: lastRepoId persists across app restart**

| Field | Value |
|-------|-------|
| TC ID | TC-F006-014 |
| Related UC | UC-005 |
| Related Feature | F006 |
| Test Scenario | UserProfile.lastRepoId survives app restart |
| Type | Positive |
| Preconditions | UserProfile.lastRepoId = repo_uuid_1; UserProfile persisted to drift |
| Test Data | — |
| Test Steps | 1. Open Git tab → PAGE-009 opens for repo_uuid_1. 2. Kill and restart app. 3. Tap Git tab. |
| Expected Result | 1. After restart: PAGE-009 opens directly for repo_uuid_1. 2. No navigation to PAGE-008. 3. Status loaded correctly. |

---

### 3.7 Feature F007: Export Engine

#### 3.7.1 UC-004: Document Export

**TC-F007-001: Export document to PDF successfully**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-001 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Document exported to PDF and saved locally |
| Type | Positive |
| Preconditions | Document with mixed content (headings, lists, code, LaTeX) open in editor |
| Test Data | Format: PDF. Destination: Local Save. |
| Test Steps | 1. Tap Export in toolbar. 2. Select PDF. 3. Select Local Save. 4. Tap Export. 5. Observe progress. |
| Expected Result | 1. ExportPage opens with format Picker. 2. Progress bar shows: Parsing → Building layout → Rendering pages → Done. 3. Success: "Export Complete!" checkmark. 4. File saved to app sandbox. 5. OpenFileButton opens system viewer. |

**TC-F007-002: Export document to HTML successfully**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-002 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Document exported to HTML and shared |
| Type | Positive |
| Preconditions | Document exists |
| Test Data | Format: HTML. Destination: Share. |
| Test Steps | 1. Tap Export. 2. Select HTML. 3. Select Share. 4. Tap Export. |
| Expected Result | 1. Conversion runs. 2. On completion: platform share sheet opens with .html file. 3. ShareAgainButton present. |

**TC-F007-003: Export document to DOCX successfully**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-003 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Document exported to DOCX format |
| Type | Positive |
| Preconditions | Document with tables and images |
| Test Data | Format: DOCX. Destination: Local Save. |
| Test Steps | 1. Tap Export. 2. Select DOCX. 3. Select Local Save. 4. Tap Export. |
| Expected Result | 1. Conversion phases shown. 2. DOCX file saved locally. 3. Open in compatible app works. |

**TC-F007-004: Export document to TXT successfully**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-004 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Document exported to plain text |
| Type | Positive |
| Preconditions | Document with formatting, images |
| Test Data | Format: TXT. Destination: Local Save. |
| Test Steps | 1. Tap Export. 2. Select TXT. 3. Observe format warning. 4. Select Local Save. 5. Tap Export. |
| Expected Result | 1. Warning chip: "Images will be stripped" + "Tables will be flattened". 2. Conversion completes. 3. TXT file contains plain text only, no markdown/formatting symbols. |

**TC-F007-005: Progress bar shows phase labels during conversion**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-005 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Progress bar updates with phase labels and percentage |
| Type | Positive |
| Preconditions | Large document (1000+ words) selected for export |
| Test Data | Format: PDF. Destination: Local Save. |
| Test Steps | 1. Start export. 2. Observe PAGE-016. |
| Expected Result | 1. ProgressBar shows determinate fill. 2. PhaseLabel cycles: "Parsing Markdown..." (0-25%) → "Building layout..." (25-50%) → "Rendering pages..." (50-95%) → "Done" (100%). 3. Percentage shows "{n}%". |

**TC-F007-006: Cancel during export aborts Isolate cleanly**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-006 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | User cancels export during conversion |
| Type | Positive |
| Preconditions | Export in progress, < 50% complete |
| Test Data | — |
| Test Steps | 1. Start export. 2. Tap Cancel. |
| Expected Result | 1. Isolate aborted immediately. 2. Navigates back to PAGE-013. 3. SnackBar: "Export cancelled". 4. ExportButton re-enabled. |

**TC-F007-007: Back at each step preserves previous selection**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-007 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Back from destination preserves format selection |
| Type | Positive |
| Preconditions | — |
| Test Data | Select PDF format, tap Continue, tap Back |
| Test Steps | 1. Select PDF format. 2. Tap Continue → PAGE-015. 3. Tap Back. |
| Expected Result | 1. PAGE-014 shows PDF still selected. 2. Back from PAGE-013 returns to editor. |

**TC-F007-008: Double-tap Export only triggers one conversion**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-008 |
| Related UC | UC-004 |
| Related Feature | F007 |
| Test Scenario | Rapid double-tap on ExportButton only starts one export |
| Type | Positive |
| Preconditions | Format and destination selected |
| Test Data | — |
| Test Steps | 1. Tap ExportButton twice rapidly. |
| Expected Result | 1. ExportButton disabled after first tap. 2. Only one PAGE-016 instance shown. 3. Only one Isolate spawned. |

**TC-F007-009: Conversion failure shows error and re-enables button**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-009 |
| Related UC | UC-004 (Exc-1) |
| Related Feature | F007 |
| Test Scenario | Document conversion fails, error state shown |
| Type | Exception |
| Preconditions | Document with unsupported content (e.g., malformed LaTeX) |
| Test Data | Format: PDF |
| Test Steps | 1. Start export. 2. Observe error. |
| Expected Result | 1. PAGE-016 shows conversion_error state. 2. Title: "Conversion Failed". 3. Detail: "Could not convert to PDF. {reason}". 4. RetryButton and FallbackButton "Save as TXT instead" visible. |

**TC-F007-010: Google Drive fallback saves locally on failure**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-010 |
| Related UC | UC-004 (Exc-2) |
| Related Feature | F007 |
| Test Scenario | Google Drive upload fails, file saved locally |
| Type | Exception |
| Preconditions | Google Drive destination selected; upload will fail |
| Test Data | Destination: Google Drive |
| Test Steps | 1. Select Google Drive. 2. Authenticate (or skip). 3. Start export. 4. Upload fails. |
| Expected Result | 1. Conversion succeeds. 2. Upload fails → upload_error state shown. 3. "Upload to Google Drive failed. {reason}". 4. FallbackButton "Save locally instead" → saves to app sandbox. |

**TC-F007-011: Large document shows timeout option**

| Field | Value |
|-------|-------|
| TC ID | TC-F007-011 |
| Related UC | UC-004 (Exc-3) |
| Related Feature | F007 |
| Test Scenario | Large document conversion exceeds timeout |
| Type | Exception |
| Preconditions | Very large document (> 5000 words) |
| Test Data | Format: PDF |
| Test Steps | 1. Start export. 2. Wait for timeout. |
| Expected Result | 1. After 30s: "Taking longer than expected..." shown. 2. After 60s: "Export Timed Out" error state. 3. "Continue waiting" and "Cancel" options. |

---

### 3.8 Feature F008: Model Manager

#### 3.8.1 UC-006: Model Configuration & Usage Tracking

**TC-F008-001: Add provider with valid API key**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-001 |
| Related UC | UC-006 |
| Related Feature | F008 |
| Test Scenario | User adds DeepSeek provider with valid API key |
| Type | Positive |
| Preconditions | PAGE-018 open; no providers configured |
| Test Data | Provider: DeepSeek. API Key: sk-valid-test-key. Base URL: https://api.deepseek.com |
| Test Steps | 1. Tap AddProviderButton. 2. Enter DeepSeek details. 3. Tap ValidateButton. 4. Tap Save. |
| Expected Result | 1. ProviderDetailSheet opens. 2. ValidateButton sends test request → shows green "Connected". 3. ProviderCard appears in list with "Active" badge. |

**TC-F008-002: Switch Free to Custom mode**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-002 |
| Related UC | UC-006 (Alt-1) |
| Related Feature | F008 |
| Test Scenario | User toggles from Free to Custom mode |
| Type | Positive |
| Preconditions | Free mode active; multiple providers configured |
| Test Data | — |
| Test Steps | 1. Tap ModeToggleCard. 2. Select "Custom". 3. Confirm mode switch. |
| Expected Result | 1. ModeSwitchConfirmation shown with explanation. 2. On confirm: Task Model Mapping section appears. 3. 13 task type rows shown. 4. Each row shows current model assignment. |

**TC-F008-003: Per-task model mapping in Custom mode**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-003 |
| Related UC | UC-006 (Alt-1) |
| Related Feature | F008 |
| Test Scenario | User assigns different models to different task types |
| Type | Positive |
| Preconditions | Custom mode active, 2+ providers configured |
| Test Data | Map "code" task → model-b from Provider-B. Map "writing" task → model-a from Provider-A. |
| Test Steps | 1. Tap "code" task row. 2. Select model-b. 3. Tap "writing" task row. 4. Select model-a. |
| Expected Result | 1. ModelPickerSheet shows available models from all providers. 2. After selection: row updates to show selected model. 3. TaskModelMapping persisted. |

**TC-F008-004: Set usage cap and verify enforcement**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-004 |
| Related UC | UC-006 (Alt-2) |
| Related Feature | F008 |
| Test Scenario | User sets hard cap, AI calls blocked when exceeded |
| Type | Positive |
| Preconditions | UsageAlert configured with $5 hard cap |
| Test Data | — |
| Test Steps | 1. Set hard cap to $5. 2. Run usage to exceed $5. 3. Attempt to send message. |
| Expected Result | 1. Hard cap saved to UsageAlert. 2. After exceeding: AI calls blocked. 3. Blocking banner shown. |

**TC-F008-005: View usage history with daily breakdown**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-005 |
| Related UC | UC-006 (Alt-3) |
| Related Feature | F008 |
| Test Scenario | Usage dashboard shows accurate daily chart |
| Type | Positive |
| Preconditions | 30+ days of usage records exist |
| Test Data | — |
| Test Steps | 1. Navigate to PAGE-019. 2. Observe charts. 3. Switch breakdown tabs. |
| Expected Result | 1. MetricCards show Today/Week/Month. 2. BarChart shows last 30 days (or selected range). 3. Tapping a bar shows tooltip with exact tokens + date. 4. BreakdownPieChart updates per selected tab. |

**TC-F008-006: Invalid API key rejected with clear error**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-006 |
| Related UC | UC-006 (Exc-1) |
| Related Feature | F008 |
| Test Scenario | Invalid API key shows validation error |
| Type | Negative |
| Preconditions | AddProvider flow open |
| Test Data | API Key: "invalid-key-that-fails-validation" |
| Test Steps | 1. Enter invalid API key. 2. Tap ValidateButton. |
| Expected Result | 1. Test request fails. 2. ValidationMessage shows "Connection failed: {detail}" in red. 3. SaveButton disabled. 4. User can edit key and retry. |

**TC-F008-007: DeepSeek free tier exhausted alert**

| Field | Value |
|-------|-------|
| TC ID | TC-F008-007 |
| Related UC | UC-006 (Exc-2) |
| Related Feature | F008 |
| Test Scenario | DeepSeek free tier 5M tokens exhausted |
| Type | Exception |
| Preconditions | DeepSeek as only provider; free tier exhausted |
| Test Data | — |
| Test Steps | 1. Attempt to send message. |
| Expected Result | 1. Alert: "DeepSeek free tier exhausted. Add a paid API key or switch providers." 2. Link to provider settings. |

---

### 3.9 Feature F009: Skills System

#### 3.9.1 UC-002: Agent Loop with Tool Execution

**TC-F009-001: Skills list loads all 5 categories**

| Field | Value |
|-------|-------|
| TC ID | TC-F009-001 |
| Related UC | UC-002 |
| Related Feature | F009 |
| Test Scenario | Skills tab shows all 5 categories with expected tool count |
| Type | Positive |
| Preconditions | Skills system initialized; agent loop available |
| Test Data | — |
| Test Steps | 1. Open Skills tab from settings. 2. Observe category list. |
| Expected Result | 1. 5 category sections rendered (Writing, Code, Data, Research, System). 2. Each section shows 4–8 tool chips. 3. Total tools ≥ 26 across all categories. 4. Each chip shows tool name + approval level badge. |

**TC-F009-002: Tool-level approval filter works**

| Field | Value |
|-------|-------|
| TC ID | TC-F009-002 |
| Related UC | UC-002 |
| Related Feature | F009 |
| Test Scenario | Setting tool to "deny" suppresses it in agent loop |
| Type | Positive |
| Preconditions | Skills system open, agent loop available |
| Test Data | Set write_file tool approval to "deny". Prompt agent to "save this file". |
| Test Steps | 1. Find write_file tool in skills list. 2. Set approval level to "Deny". 3. Send prompt "save this content to test.md". 4. Observe agent behavior. |
| Expected Result | 1. Approval Picker cycles through Allow/Confirm/Deny. 2. On "Deny": tool is grayed out. 3. Agent attempts to use write_file → receives "Tool write_file is denied". 4. Agent adapts response without writing. |

**TC-F009-003: Disabled skill suppresses its tools**

| Field | Value |
|-------|-------|
| TC ID | TC-F009-003 |
| Related UC | UC-002 |
| Related Feature | F009 |
| Test Scenario | Disabling a skill hides all its tools from agent |
| Type | Positive |
| Preconditions | Skills system open |
| Test Data | Disable "Writing" skill |
| Test Steps | 1. Toggle "Writing" skill OFF. 2. List available tools via agent. |
| Expected Result | 1. "Writing" section grayed out with "Disabled" badge. 2. All writing tools (write_file, edit_file, etc.) unavailable to agent. 3. Re-enabling restores tool access. |

**TC-F009-004: Skill search/filter by name works**

| Field | Value |
|-------|-------|
| TC ID | TC-F009-004 |
| Related UC | UC-002 |
| Related Feature | F009 |
| Test Scenario | Search bar filters tools by name |
| Type | Positive |
| Preconditions | Skills system open with 26+ tools |
| Test Data | Search query: "git" |
| Test Steps | 1. Tap search bar. 2. Type "git". 3. Observe filtered results. |
| Expected Result | 1. Only tools containing "git" shown (git_status, git_commit, git_push, git_pull, git_log, git_branch). 2. Non-matching tools hidden. 3. Clearing search restores full list. |

---

### 3.10 Feature F010: Chain of Truth Workflow

#### 3.10.1 UC-003: Document Management (CoT)

**TC-F010-001: Create CoT project with artifacts**

| Field | Value |
|-------|-------|
| TC ID | TC-F010-001 |
| Related UC | UC-003 |
| Related Feature | F010 |
| Test Scenario | User creates a new CoT project with artifact tree |
| Type | Positive |
| Preconditions | App open, user on PAGE-020 |
| Test Data | Project name: "My Research Paper" |
| Test Steps | 1. Tap NewProjectButton. 2. Enter "My Research Paper". 3. Observe PAGE-021. |
| Expected Result | 1. New project appears in list. 2. Tapping opens PAGE-021 with artifact tree. 3. Tree shows SoT#1–SoT#7 nodes. 4. Each node is selectable. |

**TC-F010-002: Generate artifact from template**

| Field | Value |
|-------|-------|
| TC ID | TC-F010-002 |
| Related UC | UC-003 |
| Related Feature | F010 |
| Test Scenario | User generates artifact content from template |
| Type | Positive |
| Preconditions | CoT project open, artifact node selected |
| Test Data | Select SRS node. Template: "SRS Template". |
| Test Steps | 1. Select SRS node. 2. Tap TemplateSelector. 3. Select "SRS Template". 4. Tap "Generate from template". |
| Expected Result | 1. TemplateSelector shows available templates. 2. If editor has existing content: overwrite guard dialog shown. 3. On confirm: template content inserted into editor. 4. Content saved to artifact. |

---

### 3.11 Settings & Profile — UC-007 (F008)

**TC-SET-001: Update user profile fields**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-001 |
| Related UC | UC-007 |
| Related Feature | F008 |
| Test Scenario | User updates profile name and email |
| Type | Positive |
| Preconditions | PAGE-023 open with existing profile |
| Test Data | Name: "Alice". Email: "alice@example.com" |
| Test Steps | 1. Edit name field. 2. Edit email field. 3. Tap Save. |
| Expected Result | 1. Fields show current values on load. 2. SaveButton disabled when no changes. 3. On save: SnackBar "Profile saved". 4. UserProfile updated. |

**TC-SET-002: Toggle theme between Light/Dark/System**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-002 |
| Related UC | UC-007 |
| Related Feature | F008 |
| Test Scenario | User changes app theme |
| Type | Positive |
| Preconditions | PAGE-024 open |
| Test Data | Switch: Light → Dark |
| Test Steps | 1. Tap "Dark" in ThemePicker. |
| Expected Result | 1. Live preview card updates to dark theme. 2. App theme changes immediately. 3. Setting persists after restart. 4. System mode shows "Follows device setting" note. |

**TC-SET-003: Enable biometric or PIN authentication**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-003 |
| Related UC | UC-007 (Alt-1) |
| Related Feature | F008 |
| Test Scenario | User enables app lock with biometrics |
| Type | Positive |
| Preconditions | Device has biometric sensor enrolled |
| Test Data | — |
| Test Steps | 1. Navigate to PAGE-026. 2. Toggle "Require Auth to Open" ON. 3. Complete biometric prompt. |
| Expected Result | 1. OS biometric prompt appears. 2. On success: switch stays ON. 3. Auto-Lock timer row appears. 4. On next app launch: biometric required. |

**TC-SET-004: Clear export cache frees storage**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-004 |
| Related UC | UC-007 (Alt-2) |
| Related Feature | F008 |
| Test Scenario | User clears cached export files |
| Type | Positive |
| Preconditions | Cache directory has files totaling 5 MB |
| Test Data | — |
| Test Steps | 1. Tap "Clear Export Cache". 2. Confirm dialog. |
| Expected Result | 1. Subtitle shows current cache size: "5 MB". 2. Confirmation dialog: "Delete 5 cached export files? (5 MB)". 3. On confirm: cache cleared. 4. Size updates to "0 MB". |

**TC-SET-005: Set export defaults pre-populate export flow**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-005 |
| Related UC | UC-007 (Alt-3) |
| Related Feature | F008 |
| Test Scenario | Default format pre-selected in export flow |
| Type | Positive |
| Preconditions | Export defaults set to PDF + Local Save |
| Test Data | Default format: PDF. Default destination: Local Save. |
| Test Steps | 1. Open PAGE-013 from editor. 2. Observe format picker. |
| Expected Result | 1. PDF card shows selected state (coral border). 2. Destination Local Save pre-selected. 3. ExportButton enabled immediately. |

**TC-SET-006: Biometric enrollment missing shows PIN fallback**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-006 |
| Related UC | UC-007 (Exc-1) |
| Related Feature | F008 |
| Test Scenario | No biometrics enrolled, PIN offered as fallback |
| Type | Exception |
| Preconditions | Device has no biometrics enrolled |
| Test Data | — |
| Test Steps | 1. Toggle "Require Auth to Open" ON. 2. Biometric prompt fails. |
| Expected Result | 1. Dialog: "No fingerprints or Face ID enrolled. Set up in device Settings or use PIN." 2. Options: "Go to Settings", "Use PIN", "Cancel". 3. "Use PIN": 6-digit PIN setup → confirm → saved. 4. Auth enabled with PIN. |

**TC-SET-007: Database corruption restores defaults gracefully**

| Field | Value |
|-------|-------|
| TC ID | TC-SET-007 |
| Related UC | UC-007 (Exc-2) |
| Related Feature | F008 |
| Test Scenario | Corrupt database restores defaults |
| Type | Exception |
| Preconditions | Drift database deliberately corrupted |
| Test Data | — |
| Test Steps | 1. Open Settings page with corrupt DB. |
| Expected Result | 1. Error caught: "Settings database issue. Restoring defaults." 2. Database deleted and recreated. 3. All settings reset to defaults. 4. Settings page loads with default values. 5. No crash. |

## 4. Traceability Matrix

### 4.1 Test Case → Feature

| Feature ID | Feature Name | TC IDs |
|------------|--------------|--------|
| F001 | AI Chat with Streaming | TC-F001-001, -002, -004, -005, -006, -007, -008, -009, -010 |
| F002 | Multi-Agent System | TC-F002-001, -002, -003, -004 |
| F003 | Task Router | TC-F003-001, -002, -003, -004 |
| F004 | Agent Loop & Tool Execution | TC-F004-001, -002, -003, -004, -005, -006 |
| F005 | Markdown Editor | TC-F005-001, -002, -003, -004, -005, -006, -007, -008, -009, -010 |
| F006 | Git Version Control | TC-F006-001, -002, -003, -004, -005, -006, -007, -008, -009, -010, -011, -012, -013, -014 |
| F007 | Export Engine | TC-F007-001, -002, -003, -004, -005, -006, -007, -008, -009, -010, -011 |
| F008 | Model Manager | TC-F008-001, -002, -003, -004, -005, -006, -007 |
| F009 | Skills System | TC-F009-001, -002, -003, -004 |
| F010 | CoT Workflow | TC-F010-001, -002 |
| F008 | Settings (UC-007) | TC-SET-001, -002, -003, -004, -005, -006, -007 |

### 4.2 Test Case → Use Case

| Use Case ID | Use Case Name | TC IDs |
|-------------|---------------|--------|
| UC-001 | AI Chat Completion | TC-F001-001, -002, -004, -005, -006, -007, -008, -009, -010, TC-F002-001, TC-F003-001–004 |
| UC-002 | Agent Loop with Tool Execution | TC-F002-002, -003, -004, TC-F004-001–006, TC-F009-001–004 |
| UC-003 | Document Management | TC-F005-001–010, TC-F010-001–002 |
| UC-004 | Document Export | TC-F007-001–011 |
| UC-005 | Git Operations | TC-F006-001–014 |
| UC-006 | Model Config & Usage | TC-F008-001–007 |
| UC-007 | Settings & Profile | TC-SET-001–007 |

### 4.3 Test Type Summary

| Type | Count |
|------|-------|
| Positive | 60 |
| Negative | 3 |
| Exception | 15 |
| **Total** | **78** |

## 5. Test Execution Notes

### 5.1 Test Environment
| Component | Specification |
|-----------|---------------|
| Flutter SDK | 3.10.6+ |
| Test framework | flutter_test, patrol (e2e) |
| Database | In-memory drift (integration), flutter_secure_storage mock |
| AI Provider mock | Mock HTTP client returning UCIC-compliant responses |
| Git mock | git2dart mock returning fixture data |

### 5.2 Test Data Setup
- Seed 3 documents (blank, short content, long content with LaTeX)
- Seed 2 chat sessions (one empty, one with 5 messages)
- Seed 3 git repos (clean, dirty with staged+unstaged, with conflict)
- Seed 2 AI providers (DeepSeek valid, OpenAI valid)
- Seed usage records for 30 days
- Reset database between test suites

### 5.3 Acronyms
| Acronym | Definition |
|---------|------------|
| TC | Test Case |
| UC | Use Case |
| SoT | Source of Truth |
| UAT | User Acceptance Testing |
| UCIC | Unified Client Interface Contract |
| PAT | Personal Access Token |

## 6. Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-07-04 | Maya on the Fly | Initial version — 59 test cases |
| 1.1 | 2026-07-04 | Maya on the Fly | Fixed counts (50P/3N/15E=68), added F002 section (4 TCs), F009 section (4 TCs), UC-005 gap TCs (3), fixed UC-007 Feature ID → F008, renumbered sections 3.1–3.11, updated traceability matrices |

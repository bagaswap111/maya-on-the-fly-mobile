# HiFi Prototype Specification

**Document:** SoT-5 | **Derived From:** SoT-1 (SRS) + SoT-2 (IA) | **Status:** Draft | **Last Updated:** 2026-07-04

## 1. Introduction

This document specifies the HiFi prototype widget trees for all 28 pages of Maya on the Fly. Each page definition covers:

- Widget composition tree (rendered Flutter widget hierarchy)
- State handling (loading / empty / error / success)
- Responsive behavior (phone < 600dp vs tablet >= 600dp)
- Animation & transition specifications
- Component references to DESIGN.md tokens

## 2. Shared States Convention

All list/detail pages follow the same state pattern:

| State | Widget | Behavior |
|-------|--------|----------|
| Loading | `skeleton-block` / `skeleton-card` x 5 | Pulse animation, no text |
| Empty (action) | `empty-state` + `empty-state-action` | Illustration + guidance text + CTA to create first item |
| Empty (info) | `empty-state` (no action) | Illustration + informational text only — no CTA |
| Partial (multi-source) | Per-section state wrapping | Each independent section (e.g., docs + chats on Home) gets its own Loading/Empty/Error wrapper; sections don't block each other |
| Error | `error-state` + `error-state-retry` | Error icon + message + retry button |
| Data | Content widget | Normal rendering with state-driven rebuilds |

## 3. Layout Shell

### Bottom Navigation Bar

```
ShellScaffold (ConsumerStatefulWidget)
├── BottomNavigationBar (4 tabs)
│   ├── Tab 0: Home (icon: house)
│   ├── Tab 1: Chat (icon: bubble.left.and.bubble.right / chat)
│   ├── Tab 2: Git (icon: arrow.branch / code.branch)
│   └── Tab 3: Settings (icon: gear)
├── body: GoRouter (per-tab nested navigation stack)
└── PopScope (Android back handling)
    └── onPopInvokedWithResult:
        ├── If current tab has navigation stack > 1 → pop to previous route
        ├── If on tab root → switch to Home tab (if not already Home)
        └── If on Home tab root → show "Exit app?" dialog
```
- **Active tab indicator:** Airtable coral/blue underline
- **Badge:** Unread/unpushed count (Git tab when applicable)
- **Transition:** No animation on tab switch (instant)
- **Badge:** Unread/unpushed count (Git tab when applicable); unread message count bubble (Chat tab)
- **Re-tap behavior:** Tapping already-active tab scrolls to top of its content
- **Android back:** Back button pops the current tab's navigation stack; on tab root, switches to Home; on Home root, shows exit dialog

### Navigation Flow

Each tab maintains its own Navigator stack. Pushing a route from within a tab only stacks on that tab's stack. Deep links (`/doc/:id`, `/chat/:id`) override the shell and push onto the appropriate tab.

---

## 4. PAGE-001: Home

**Route:** `/` | **Tab:** Home (index 0)

### Widget Tree

```
HomePage (ConsumerWidget)
├── AppBar
│   ├── Title: "Maya on the Fly"
│   └── Actions: [SearchIconButton, SettingsIconButton]
├── Body (CustomScrollView → slivers)
│   ├── SliverAppBar (pinned section)
│   │   └── QuickActionsRow
│   │       ├── ActionCard(icon: plus.doc, label: "New Doc", onTap: → PAGE-003)
│   │       ├── ActionCard(icon: plus.bubble, label: "New Chat", onTap: → PAGE-007)
│   │       └── ActionCard(icon: arrow.branch, label: "Open Repo", onTap: → PAGE-008)
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader(title: "Recent Documents", action: "See All")
│   ├── SliverList (recent documents)
│   │   └── DocumentListItem (for each doc)
│   │       ├── Leading: PinnedIcon (if isPinned)
│   │       ├── Title: doc.title (1 line, bold)
│   │       ├── Subtitle: "Edited {timeAgo}" + word count
│   │       ├── Trailing: ChevronIcon
│   │       └── onTap: → PAGE-002
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader(title: "Recent Chats", action: "See All")
│   └── SliverList (recent chats)
│       └── ChatSessionItem
│           ├── Title: session.title (1 line)
│           ├── Subtitle: session.agentId + " · {timeAgo}"
│           ├── Trailing: TokenCountBadge(session.tokenCount)
│           └── onTap: → PAGE-006
```

### State Handling

| State | Behavior |
|-------|----------|
| Loading | 5× `skeleton-card` rows in each list |
| Empty (docs) | `empty-state` "No documents yet" + "Create your first document" CTA |
| Empty (chats) | `empty-state` "No chats yet" + "Start a conversation" CTA in chat section |
| Error | `error-state` with retry button (re-fetches lists) |

### Responsive

| Phone | Tablet |
|-------|--------|
| Single column, vertical scroll | Two-column grid: documents left (60%), chats right (40%) |
| QuickActionsRow horizontal scroll | Full-width quick action cards |
| SectionHeader "See All" → push list page | SectionHeader "See All" → reveal on same page |

### Behaviors

- **"See All" on phone:** Pushes a dedicated list page to the navigation stack
- **"See All" on tablet:** Expands the section inline beneath the section header (animated height transition) showing full list; same section header toggles to "Show less"
- **QuickActionsRow scroll hint:** Shows a subtle gradient fade on right edge with chevron hint on first visit; fades after 3s

### Animations

| Element | Animation |
|---------|-----------|
| DocumentListItem appear | Fade-in + slide-up, staggered (50ms delay per item) |
| QuickActionsRow tap | Scale 0.95 → 1.0 (spring) |

---

## 5. PAGE-002: Document Editor

**Route:** `/doc/:id` | **Tab:** Home stack

### Widget Tree

```
EditorPage (ConsumerStatefulWidget)
├── EditorToolbar (SliverAppBar, floating)
│   ├── Leading: BackButton
│   ├── Title: EditableText(doc.title)
│   ├── Actions:
│   │   ├── AutoSaveIndicator (saved/saving/unsaved dot)
│   │   ├── PreviewToggleButton (eye icon, toggle)
│   │   └── ExportButton (square.and.arrow.up)
│   └── Bottom: ActionChipRow
│       ├── FormatToolbar (bold/italic/heading/bullet/code/link)
│       └── InsertMenu (table, image, divider, LaTeX block)
├── Body
│   ├── Phone (portrait):
│   │   └── AnimatedSwitcher
│   │       ├── Child 0: EditableArea (super_editor)
│   │       └── Child 1: PreviewPane (flutter_markdown)
│   ├── Phone (landscape):
│   │   └── Row
│   │       ├── EditableArea (flex: 2, min-width: 280dp)
│   │       └── PreviewPane (flex: 1, overlay handle)
│   └── Tablet (both orientations):
│       └── Row
│           ├── EditableArea (flex: 1)
│           └── PreviewPane (flex: 1, always visible)
└── (Back navigation guard)
    └── PopScope (canPop: !hasUnsavedChanges)
        └── onPopInvokedWithResult:
            ├── if unsaved → show dialog: "Save before leaving?"
            │   ├── "Discard" → pop without saving
            │   ├── "Save" → save then pop
            │   └── "Cancel" → stay
            └── if saved → allow pop
└── (Undo/Redo — integrated into FormatToolbar)
    └── UndoButton (arrow.uturn.left, disabled when nothing to undo)
        └── onTap: editorController.undo()
    └── RedoButton (arrow.uturn.right, disabled when nothing to redo)
        └── onTap: editorController.redo()
    └── Keyboard: Cmd+Z (undo), Cmd+Shift+Z (redo)
└── FloatingActionButton
    └── "Ask Maya" → opens PAGE-006 with doc context
```

### State Handling

| State | Behavior |
|-------|----------|
| Loading doc | Full-screen skeleton (title block + 10 lines of skeleton paragraphs) |
| Document not found | `error-state` "Document not found" + "Go Home" button |
| Auto-save in progress | Toolbar dot turns yellow (saving) → green (saved) |
| Unsaved changes | Toolbar dot turns red (unsaved) — persists until auto-save completes |
| Empty document | EditableArea shows "Start writing..." placeholder |

### Responsive

| Phone portrait | Phone landscape / Tablet |
|----------------|--------------------------|
| Single pane (edit OR preview, toggled) | Side-by-side split view |
| Format toolbar in overflow menu | Full toolbar row visible |
| InsertMenu as bottom sheet | InsertMenu as popup menu |

### Animations

| Element | Animation |
|---------|-----------|
| Preview toggle | `AnimatedSwitcher` with `fadeThrough` transition (200ms) |
| Auto-save indicator | Dot pulses yellow → solid green on save complete |
| Preview scroll sync | Editor scroll → preview scrolls to matching heading (debounced 300ms) |
| Format toolbar tap | Button press highlight (100ms) |

---

## 6. PAGE-003: New Document

**Route:** `/doc/new` | **Tab:** Home stack

### Widget Tree

```
NewDocPage (ConsumerWidget)
├── AppBar
│   ├── Title: "New Document"
│   └── Actions: [CancelButton]
├── Body
│   ├── Loading: full-screen skeleton (5 template card blocks in carousel shape)
│   ├── Error: error-state with retry ("Could not load templates")
│   └── Data (Column)
│       ├── TemplateCarousel
│       │   ├── TemplateCard("Blank Document", subtitle: "Start from scratch")
│       │   ├── TemplateCard("Research Paper", subtitle: "Abstract, methods, results, citations")
│       │   ├── TemplateCard("Business Proposal", subtitle: "Executive summary, scope, pricing")
│       │   ├── TemplateCard("Meeting Notes", subtitle: "Agenda, attendees, action items")
│       │   └── TemplateCard("Technical Spec", subtitle: "Architecture, API, deployment")
│       └── CreateButton (full-width, "Create from {selected template}")
```
- **On create:** Inserts Document into drift, navigates to PAGE-002
- **Error handling:** If template fetch fails (local asset I/O error), show error state with retry
- **Loading:** Templates loaded from assets; if assets not yet available (first launch), show skeleton

---

## 7. PAGE-004: Full Preview

**Route:** `/doc/:id/preview` | **Tab:** Home stack

### Widget Tree

```
FullPreviewPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: doc.title
│   └── Actions: [ShareButton, ExportButton]
├── Body
│   ├── Loading: centered CircularProgressIndicator with doc title skeleton
│   ├── Error: error-state "Could not render preview" + retry
│   └── Data: InteractiveViewer
│       └── MarkdownPreview (flutter_markdown, full-width)
```
- **Loading:** If document content not yet loaded from drift, show spinner
- **Error:** Rendering failure (malformed markdown, unsupported LaTeX) → show error with retry and "Edit document" fallback
- Full-screen preview with pinch-to-zoom
- **Reset zoom:** Double-tap gesture resets to fit-screen; "Fit to screen" FAB appears when zoomed > 1.5×
- **State preservation:** ConsumerStatefulWidget preserves zoom/scroll state across navigation
- LaTeX renders with `flutter_markdown` LaTeX extension
- Code blocks render with `highlight` package theme from settings
- **Markdown sanitization:** Raw HTML tags (script, iframe, object, embed) stripped before rendering; configured via `flutter_markdown` extension set

---

## 8. PAGE-005: Chat List

**Route:** `/chat` | **Tab:** Chat (index 1)

### Widget Tree

```
ChatListPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Chats"
│   └── Actions: [SearchButton, NewChatButton → PAGE-007]
│       └── SearchButton → toggles SearchBar inline below AppBar
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (autofocus, placeholder: "Search conversations...")
│   │   ├── ClearButton
│   │   └── Filters sessions by title match (case-insensitive)
│   ├── PullToRefresh (RefreshIndicator)
│   │   └── onRefresh: re-fetches session list
│   ├── Loading: skeleton-card x 5
│   ├── Empty: empty-state "No conversations yet" + "Start a chat" CTA
│   ├── Empty (search no match): empty-state "No conversations match '{query}'"
│   ├── Error: error-state with retry
│   └── Data: ListView.builder
│       └── ChatSessionItem (per session)
│           ├── Leading: AgentAvatar(agentId)
│           ├── Title: session.title (1 line)
│           ├── Subtitle: agent.name + " · {timeAgo}" + " · {messageCount} msgs"
│           ├── Trailing: TokenBadge(session.tokenCount)
│           ├── onTap: → PAGE-006
│           └── Swipe left: delete session
│               └── Confirmation dialog: "Delete '{title}'?" + "This cannot be undone." + CancelButton + DeleteButton (destructive)
```

---

## 9. PAGE-006: Chat Conversation

**Route:** `/chat/:id` | **Tab:** Chat stack

### Widget Tree

```
ChatPage (ConsumerStatefulWidget)
├── ChatHeader (SliverAppBar, collapsed height: 48, expanded: 96)
│   ├── Leading: BackButton
│   ├── Title: session.title (editable on tap)
│   ├── Subtitle:
│   │   ├── AgentSelectorChip(agentId, onChanged: switchAgent)
│   │   │   ├── PopupMenu: list of 13 agents
│   │   │   └── onSelect: show SwitchAgentConfirmation
│   │   │       └── SwitchAgentConfirmation (BottomSheet):
│   │   │           ├── Title: "Switch Agent?"
│   │   │           ├── Message: "Changing the agent mid-conversation clears the current agent's context. The conversation history is preserved."
│   │   │           ├── Note: "The new agent will not see previous tool results."
│   │   │           ├── CancelButton, ConfirmSwitchButton
│   │   │           └── "Don't show again" checkbox (stored in UserProfile)
│   │   └── TaskTypeBadge(taskType, onTap: reclassify)
│   │       ├── Dropdown: all 13 task types
│   │       └── onSelect: show ReclassifyConfirmation
│   │           └── ReclassifyConfirmation (BottomSheet):
│   │               ├── Title: "Reclassify Task?"
│   │               ├── Message: "Changing the task type from '{old}' to '{new}' affects model routing in Custom mode."
│   │               ├── CancelButton, ConfirmReclassifyButton
│   ├── Trailing:
│   │   ├── TokenCounter(session.tokenCount) → on phone < 600dp, moves to overflow menu (⋯) alongside HelpButton
│   │   ├── HelpButton(icon: questionmark.circle, onTap: → agent capabilities help sheet)
│   │   │   └── HelpSheet: "What can {agent.name} do?" with agent description + example prompts
│   │   └── StopButton(visible only when generating, onTap: cancel)
│   └── Bottom: AgentToolIndicator(list of active tools)
│       └── Phone < 600dp: collapses to tappable icon (wrench) that expands inline on tap
├── Body
│   ├── Loading: centered CircularProgressIndicator
│   ├── Empty: empty-state "Send a message to start" + suggested prompts
│   ├── Error: error-state with retry
│   └── Data: MessageList (ListView.builder, reverse: true)
│       ├── UserMessage
│       │   ├── Role indicator: user avatar
│       │   ├── Content: Markdown body
│       │   ├── Timestamp
│       │   └── Long press: ContextMenu (Edit / Delete)
│       │       ├── "Edit" → opens message in ChatInputBar for editing
│       │       └── "Delete" → confirmation → removes message from session
│       ├── AssistantMessage
│       │   ├── Role indicator: Maya avatar
│       │   ├── Content: StreamingTextWidget (animated text reveal)
│       │   │   └── Uses AnimatedBuilder for smooth token insertion
│       │   ├── ToolCallsBlock (if any)
│       │   │   └── ToolCallCard (name, status: pending/running/done/error)
│       │   └── Timestamp + token count
│       ├── ToolResultMessage
│       │   ├── Tool name + status badge
│       │   ├── Result summary (collapsible)
│       │   └── onTap: expand full result
│       └── SystemMessage
│           ├── "Agent switched to {agent}"
│           ├── "Task reclassified to {task}"
│           └── "Generation stopped"
├── ChatInputBar (bottom, safe area aware)
│   ├── ContextDocumentChip (if linked doc, shows doc.title, tappable)
│   ├── TextField (Expanded, multi-line, max 8 lines)
│   │   ├── Placeholder: "Message Maya... (Cmd+Enter to send)"
│   │   └── onSubmitted: sendMessage
│   ├── SendButton (icon: arrow.up.circle.fill)
│   │   └── disabled when empty or generating
│   └── ModelOverrideChip (Custom mode only, shows current model, tappable)
└── (bottom sheet) ToolExecutionConfirmation
    ├── Title: "Run {toolName}?"
    ├── Arguments preview (JSON formatted)
    ├── CancelButton, ApproveButton
    └── "Remember for this session" checkbox
```

### Streaming Text Widget

```
StreamingTextWidget (StatefulWidget)
├── State tracks: full text, displayed text, animation progress
├── on new token: batch tokens (max 50ms timer), setState with batch
├── Render: RichText with typewriter effect (10ms per character)
├── Performance: batches incoming tokens into 50ms intervals to avoid excessive rebuilds
├── Full text appears instantly on tap (skip animation)
│   └── Visual cue: pulsing cursor at end of streaming text signals "tap to reveal all"
└── Configurable speed: UserProfile.readingSpeed (slow/normal/fast) adjusts 20ms/10ms/5ms per character
```

### State Handling

| State | Behavior |
|-------|----------|
| Loading messages | skeleton cards (3 message-shaped blocks) |
| Empty session | Suggested prompts as action chips in empty space |
| Sending message | SendButton shows progress indicator, input disabled |
| Streaming response | StopButton visible, tokens animate into view |
| Tool call pending | ToolCallCard shows "pending..." spinner |
| Tool call complete | ToolCallCard shows checkmark + result summary |
| Error response | AssistantMessage shows error state + retry button |
| Hard cap hit | Non-blocking banner above input: "Monthly cap reached. AI paused." |

### Responsive

| Phone | Tablet |
|-------|--------|
| Full-width message list | Max-width 720px centered message list |
| Agent selector shows icon only | Agent selector shows icon + name |
| Input bar full width | Input bar centered at 720px max |
| Tool confirmation as bottom sheet | Tool confirmation as dialog |

### Animations

| Element | Animation |
|---------|-----------|
| New message appear | Slide-up + fade-in (200ms, ease-out) |
| Token arrival | Typewriter effect (10ms/char, skippable on tap) |
| Stop button appear | Scale-in from 0 → 1 (150ms spring) |
| Tool call status change | Icon morph: spinner → checkmark / X (300ms) |
| Agent switch | Header subtitle cross-fade (200ms) |

---

## 10. PAGE-007: New Chat

**Route:** `/chat/new` | **Tab:** Chat stack

### Widget Tree

```
NewChatPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "New Chat"
│   └── Actions: [SearchButton, CancelButton]
│       └── SearchButton → toggles search bar: filters agents by name + description
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (autofocus, placeholder: "Search agents...")
│   │   └── Filters agent grid in real-time
│   ├── AgentGrid (2 columns on phone, 4 on tablet)
│   │   └── AgentCard (per agent, 13 total)
│   │       ├── AgentAvatar (icon per role)
│   │       ├── AgentName
│   │       ├── AgentDescription (1 line)
│   │       ├── ToolCountBadge ("{n} tools")
│   │       └── onTap: createSession(agentId)
│   └── QuickPromptRow (below agent grid, dynamic per agent selection)
│       └── Chip("Help me brainstorm")
│           Chip("Write an outline")
│           Chip("Review my document")
│           Chip("Debug my code")
│       └── Chips change based on last-tapped agent's capabilities
```
- **On agent tap:** Show AgentConfirmation bottom sheet before creating session
    └── AgentConfirmation (BottomSheet):
        ├── AgentAvatar + AgentName (large)
        ├── AgentDescription (2-3 lines describing capabilities)
        ├── ToolListChips (tools this agent can use)
        ├── ExamplePrompts (2-3 example prompts relevant to agent)
        ├── Divider
        ├── "Start with blank chat" button (primary)
        ├── "Attach current document" button (if doc open in editor)
        └── CancelButton
- **Error handling:** If session creation fails, show error-state with retry button

---

## 11. PAGE-008: Git Repo List (Manage Repositories)

**Route:** `/git/manage` | **Tab:** Pushed from PAGE-009 switcher or Home

### Widget Tree

```
GitRepoListPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton (to PAGE-009 if arrived from switcher)
│   ├── Title: "Manage Repositories"
│   └── Actions: [SearchButton, InitRepoButton, CloneRepoButton]
│       └── SearchButton → toggles SearchBar
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (autofocus, placeholder: "Search repositories...")
│   │   └── Filters repos by name + localPath
│   ├── PullToRefresh (RefreshIndicator)
│   │   └── onRefresh: re-scans repo directories for changes
│   ├── Loading: skeleton-card x 3
│   ├── Empty (no repos): empty-state "No repositories yet" + AddButtonRow: [InitLocalRepo, CloneRemoteRepo, OpenExistingFolder]
│   ├── Empty (search no match): empty-state "No repositories match '{query}'"
│   ├── Error: error-state with retry
│   ├── InitInProgress: Progress indicator card "Initializing {name}..." with indeterminate bar
│   └── Data: ListView
│       └── RepoListItem
│           ├── Leading: FolderIcon (pinned indicator if pinned)
│           ├── Title: repo.name
│           ├── Subtitle: repo.localPath (truncated) + branch name
│           ├── Trailing: UnpushedBadge(repo.unpushedCount, if > 0)
│           ├── onTap: → PAGE-009(repo.id) // switches active repo
│           └── SwipeActions:
│               ├── Swipe left: Remove from list
│               │   └── Confirmation dialog: "Remove {name}?" + "Files NOT deleted." + Cancel + Remove
│               ├── Swipe right (if not pinned): Pin to top
│               └── Swipe right (if pinned): Unpin
└── AddButtonRow (always visible at bottom, not only in empty state)
    └── [InitLocalRepo, CloneRemoteRepo, OpenExistingFolder]
```

---

## 12. PAGE-009: Git Status

**Route:** `/git/:repo` | **Tab:** Git stack

### Widget Tree

```
GitStatusPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: null (no back button — switcher handles navigation)
│   ├── Title: RepoSwitcherDropdown
│   │   ├── Trigger: repo.name + branch badge + chevron.down icon
│   │   └── Dropdown (PopUpMenu, full-width on phone, 400px max on tablet)
│   │       ├── HeaderSection: "Current Repository"
│   │       ├── CurrentRepoRow (repo.name, branch, checkmark, bold)
│   │       ├── RecentReposSection ("Recent")
│   │       │   ├── RepoRow(repo2.name, branch)
│   │       │   └── RepoRow(repo3.name, branch)
│   │       ├── Divider
│   │       └── ActionRow("Manage Repositories...", icon: gear)
│   │           └── onTap: → PAGE-008
│   └── Actions: [PushButton, PullButton, FetchButton, StashButton, LogButton → PAGE-012]
│       └── StashButton → bottom sheet: "Stash all changes?" + "Include untracked" checkbox + StashButton
├── Body (CustomScrollView)
│   ├── SliverToBoxAdapter
│   │   └── RepoInfoCard
│   │       ├── BranchChip(repo.defaultBranch)
│   │       ├── RemoteChip(repo.remoteUrl, if any)
│   │       └── LastSyncBadge(repo.lastSyncedAt)
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Changes ({staged + unstaged} files)")
│   │       └── Actions: [StageAllButton (if any unstaged), UnstageAllButton (if any staged)]
│   ├── SliverList
│   │   └── FileStatusItem (per changed file)
│   │       ├── Leading: StatusIcon (M/A/D/R/? colored)
│   │       ├── Title: file.path (relative)
│   │       ├── Subtitle: "+{add} -{del}" lines
│   │       ├── Trailing: StageCheckbox (tap to toggle stage/unstage)
│   │       └── onTap: → PAGE-010
│   └── SliverToBoxAdapter
│       └── CommitButton (full-width, "Commit {n} files", disabled if no staged)
├── RepoSwitchWarning (shown when switching repo with unstaged changes)
│   └── "You have unstaged changes. Stash or commit before switching?" with Stash + Commit + Cancel
├── CommitSheet (DraggableScrollableSheet, triggered by CommitButton)
│   ├── Header: "Commit to {branch}"
│   ├── CommitMessageField (TextField, multi-line, placeholder: "Describe your changes...")
│   ├── CommitPreview (staged files list + diff summary)
│   ├── Actions: CancelButton, CommitButton
│   └── Shortcut: "Use a conventional commit" chip (feat/fix/docs/refactor)
│       └── onCommit: → calls git2dart commit, closes sheet, refreshes status
└── PushPullDialog (AlertDialog, triggered by Push/Pull)
    ├── ProgressBar (indeterminate during network, determinate during data transfer)
    ├── PhaseLabel ("Connecting...", "Pushing {n} objects...")
    ├── CancelButton (hidden during finalizing phase)
    └── Back during push/pull: shows confirmation "Cancel the {operation}?" with Wait + Cancel
```

### Repo Switcher Dropdown Behavior

| Aspect | Detail |
|--------|--------|
| Trigger | Tap repo name in AppBar title area |
| Position | Anchored below AppBar, left-aligned |
| Sort order | Last opened repo first, then alpha |
| Current repo | Highlighted + checkmark, at top |
| Empty state | "No repositories. Add one to get started." + "Add Repository" button |
| Keyboard | Down arrow opens dropdown, type to filter (fuzzy search by name) |
| Selection | Instantly switches status view to selected repo, no animation |
| "Manage" action | Pushes PAGE-008 to navigation stack (not a tab switch) |
| Persistence | Last viewed repo ID stored in UserProfile or SharedPreferences |

### Git Tab Entry Point Logic

```
GitTabEntry → Check UserProfile.lastRepoId
  ├── Has value AND repo exists → PAGE-009(lastRepoId)
  └── No repos → PAGE-008 (empty state with init/clone CTAs)
```

This replaces the previous behavior where the Git tab always opened to PAGE-008 with the repo list.

### Repo Switcher State Handling

| Scenario | Behavior |
|----------|----------|
| No repos exist | PAGE-009 never shown; Git tab opens to PAGE-008 "Manage" with empty state and init/clone CTAs |
| Single repo | Switcher dropdown disabled or shows single item with checkmark — no switching needed |
| Multiple repos | Dropdown shows all repos sorted by last-opened; switching is instant (no navigation stack change) |
| Repo deleted externally | Status load fails → auto-remove from switcher, show error, fall back to PAGE-008 |
| First repo created | Auto-set as lastRepoId, PAGE-009 shown immediately

### State Handling

| State | Behavior |
|-------|----------|
| Loading status | skeleton-list: 5 file rows |
| No changes | Empty state: "Working tree clean" with ✔ icon |
| Behind remote | Warning banner: "Branch is {n} commits behind. Pull to update." |
| Pre-commit | CommmitButton enabled only when ≥ 1 file staged |
| Push/Pull in progress | PushPullDialog shown, back button disabled |

---

## 13. PAGE-010: Git Diff

**Route:** `/git/:repo/diff?file={path}` | **Tab:** Git stack

### Widget Tree

```
GitDiffPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: file.name
│   ├── Subtitle: file.path (relative)
│   ├── PreviousFileButton (chevron.left, disabled on first file)
│   ├── NextFileButton (chevron.right, disabled on last file)
│   └── Actions: [AddToStageButton, DiscardButton]
│       └── DiscardButton onTap: Confirmation dialog
│           ├── "Discard all changes to {file.name}?"
│           ├── Message: "This action cannot be undone. All modifications will be lost."
│           ├── CancelButton, DiscardButton (destructive, red)
├── Body
│   ├── DiffSummaryBar
│   │   ├── AdditionsBadge (+{n})
│   │   ├── DeletionsBadge (-{n})
│   │   └── ViewToggle (Unified / Split)
│   └── DiffViewer (ListView)
│       └── DiffHunk
│           ├── HunkHeader ("@@ -{start},{count} +{start},{count} @@")
│           ├── HunkActions (on gutter long-press): Stage this hunk / Discard this hunk
│           └── DiffLine (per line)
│               ├── Leading: LineNumber (old) + LineNumber (new)
│               ├── GutterIndicator (green bar / red bar / empty)
│               │   └── onTap on gutter: Stage this line (partial staging)
│               └── Content: code text (monospace, highlighted by extension)
```
- **Unified view:** Single pane with +/- gutter (only mode on phone < 600dp)
- **Split view:** Two panes side-by-side (tablet only, > 840dp)
- **Partial staging:** Tap gutter on a line to stage that single line; long-press hunk header to stage whole hunk
- **Large files (> 500 lines diff):** Chunked loading — first 200 lines loaded, then progressively; "Showing {n} of {m} lines" indicator
- **Syntax highlighting:** Uses theme from settings (default: GitHub Dark)

---

## 14. PAGE-011: Git Commit

**Route:** `/git/:repo/commit` | **Tab:** Git stack

### Widget Tree

```
GitCommitPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Commit — {repo.name}"
│   └── Actions: [CommitButton (disabled if no message)]
├── Body (Column)
│   ├── CommitMessageField (TextField, multi-line, 4 lines visible)
│   │   ├── Placeholder: "Describe your changes..."
│   │   └── Keyboard shortcut: Cmd+Return to commit
│   ├── ConventionalCommitChips
│   │   ├── Chip("feat"), Chip("fix"), Chip("docs")
│   │   ├── Chip("refactor"), Chip("style"), Chip("test")
│   │   └── onTap: prefix field with "type: "
│   ├── ExpandableOptions (collapsed by default)
│   │   ├── AmendCheckbox: SwitchRow("Amend last commit")
│   │   │   └── When enabled: message pre-fills with last commit message; replaces last commit instead of creating new
│   │   ├── CoAuthorField (TextFormField, "Co-authored-by: Name <email>")
│   │   └── GpgSignSwitch (if GPG key configured): SwitchRow("Sign with GPG")
│   ├── Divider
│   ├── StagedFilesPreview (ListView)
│   │   └── FileChip(file.path, status: added/modified/deleted)
│   ├── DiffSummary
│   │   └── Text: "+{n} additions, -{n} deletions in {m} files"
│   └── CommitButton (full-width, primary)
│       └── disabled: message empty or no staged files
└── ConfirmDialog (on commit tap)
    ├── "Commit to {branch}" / "Amend commit on {branch}"
    ├── Summary: message preview + file count + diff stats
    ├── CancelButton, ConfirmCommitButton
    └── onConfirm: calls git2dart commit, pops to PAGE-009
```

---

## 15. PAGE-012: Git Conflict

**Route:** `/git/:repo/conflict` | **Tab:** Git stack

### Widget Tree

```
GitConflictPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Resolve Conflicts"
│   └── Subtitle: "{n} conflicting files"
├── Body (ListView)
│   └── ConflictFileCard (per conflicted file)
│       ├── Header: file.path + "· {status}"
│       │   └── Status values: unresolved, resolved, partially-resolved
│       ├── ProgressBadge ("2/5 resolved" in AppBar subtitle)
│       ├── ConflictSection
│       │   ├── VersionLabel: "Ours (current)"
│       │   ├── CodeSnippet (syntax highlighted, read-only)
│       │   ├── OriginalVersionToggle ("Show original") → shows pre-merge base version
│       │   ├── Divider
│       │   ├── VersionLabel: "Theirs (incoming)"
│       │   └── CodeSnippet (syntax highlighted, read-only)
│       ├── InlineMergeEditor (collapsible, hidden by default)
│       │   ├── Tri-pane: Ours (top) / Merged (middle, editable) / Theirs (bottom)
│       │   ├── Per-hunk resolution: resolve one conflict section at a time (partial resolution)
│       │   ├── AcceptOursButton → copies ours into merged pane
│       │   ├── AcceptTheirsButton → copies theirs into merged pane
│       │   └── SaveResolvedButton → marks file as resolved with merged content
│       └── Actions
│           ├── ExpandMergeEditorButton → opens InlineMergeEditor
│           ├── AcceptOursButton
│           ├── AcceptTheirsButton
│           └── EditManuallyButton → opens PAGE-002 with conflict markers
├── FloatingActionButton
│   └── "Mark All Resolved {n}/{m}" (enabled when all files resolved)
│       └── onTap: CommitMessageInputSheet → "Resolve merge conflicts in {branch}" (pre-filled) + CommitButton
├── (Novice help)
│   └── InfoBanner (collapsible): "New to merge conflicts?" + "Learn more" link → in-app guide
```
- **InlineMergeEditor:** allows resolving conflicts without leaving the page
- **Auto-resolve:** When Ours or Theirs is accepted, merged pane pre-fills with that version
- **Per-hunk resolution:** Each conflict hunk can be resolved independently (partial resolution)
- **Progress:** Resolved files count shown in AppBar subtitle and FAB label
- **Commit message:** Pre-filled with "Resolve merge conflicts in {branch}", editable
- **Resolved state:** File card shows green checkmark, collapse merge editor

---

## 16. PAGE-013: Export

**Route:** `/export` | **Tab:** Home stack (pushed from editor)

### Widget Tree

```
ExportPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Export"
│   └── Actions: [CancelButton]
├── Body (CustomScrollView)
│   ├── Loading: skeleton (summary card block + 4 format card blocks + 4 dest card blocks)
│   ├── Error: error-state "Could not load document" + retry + "Return to editor"
│   └── Data:
│       ├── SliverToBoxAdapter
│       │   └── DocumentSummaryCard
│       │       ├── Title: doc.title
│       │       ├── Subtitle: "{n} words · {m} characters"
│       │       └── Thumbnail (first 5 lines of markdown, truncated)
│       ├── SliverToBoxAdapter
│       │   └── SectionHeader("Format")
│       ├── SliverToBoxAdapter
│       │   └── FormatPicker (2×2 grid)
│       │       ├── FormatCard("PDF", icon: doc.text.fill)
│       │       │   ├── Description: "Page layout preserved"
│       │       │   └── selected: coral border overlay
│       │       ├── FormatCard("HTML", icon: globe)
│       │       │   ├── Description: "Web-ready, no styling loss"
│       │       │   └── selected: coral border overlay
│       │       ├── FormatCard("DOCX", icon: doc.richtext)
│       │       │   ├── Description: "Microsoft Word compatible"
│       │       │   └── selected: coral border overlay
│       │       └── FormatCard("TXT", icon: doc.plaintext)
│       │           ├── Description: "Plain text, markdown stripped"
│       │           └── selected: coral border overlay
│       ├── SliverToBoxAdapter
│       │   └── SectionHeader("Destination")
│       ├── SliverToBoxAdapter
│       │   └── DestinationPicker (2×2 grid)
│       │       ├── DestCard("Local Save", icon: folder)
│       │       ├── DestCard("Share", icon: square.and.arrow.up)
│       │       ├── DestCard("iCloud", icon: icloud) (iOS only, distinct cloud-with-circle icon)
│       │       └── DestCard("Google Drive", icon: doc.text.below.ecg) (distinct from iCloud)
│       └── SliverToBoxAdapter
│           └── ExportButton (full-width, disabled until format + dest selected)
│               └── onTap: ExportConfirmation dialog → "Export as {format} to {destination}?"
│                   ├── Summary: "{title} · {n} words"
│                   ├── CancelButton, ConfirmExportButton
│                   └── onConfirm: → PAGE-016
```
- **Loading state:** Document not yet loaded from drift; show skeleton
- **Error state:** Document deleted or inaccessible
- **Defaults:** Format pre-selected from UserProfile.defaultFormat (if set); destination pre-selected from UserProfile.defaultDestination (if set)
- **Double-tap guard:** ExportButton disabled immediately after first tap, re-enabled on error

---

## 17. PAGE-014: Export Format

**Route:** `/export/:docId/format` | **Tab:** Export stack

### Widget Tree

```
ExportFormatPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Select Format"
│   └── Actions: [CancelButton]
├── Body (Padding)
│   └── FormatPicker (2×2 grid)
│       ├── FormatCard("PDF", icon: doc.text.fill)
│       │   ├── Description: "Page layout preserved, best for printing"
│       │   ├── InfoIcon (i.circle, onTap: tooltip "Uses pdf_gen package, supports embedded fonts")
│       │   └── selected: coral border overlay + checkmark
│       ├── FormatCard("HTML", icon: globe)
│       │   ├── Description: "Web-ready, no styling loss"
│       │   ├── InfoIcon (onTap: tooltip "Exports as standalone .html with inline CSS")
│       │   └── selected: coral border overlay + checkmark
│       ├── FormatCard("DOCX", icon: doc.richtext)
│       │   ├── Description: "Microsoft Word compatible"
│       │   ├── InfoIcon (onTap: tooltip "Uses open XML format; tables and images supported")
│       │   └── selected: coral border overlay + checkmark
│       └── FormatCard("TXT", icon: doc.plaintext)
│           ├── Description: "Plain text, markdown stripped"
│           ├── InfoIcon (onTap: tooltip "Strips all formatting; retains line breaks")
│           └── selected: coral border overlay + checkmark
└── BottomNavigationBar
    └── ContinueButton (disabled until format selected)
        ├── onTap: → PAGE-015
        └── Double-tap guard: button disabled immediately after first tap
- **Format warnings:** On selection, show chip below grid if content may degrade:
  - TXT selected with images: "Images will be stripped"
  - TXT selected with tables: "Tables will be flattened"
  - LaTeX in doc + TXT/DOCX: "LaTeX may not render in {format}"
```

---

## 18. PAGE-015: Export Destination

**Route:** `/export/:docId/destination` | **Tab:** Export stack

### Widget Tree

```
ExportDestinationPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Save To"
│   └── Actions: [CancelButton]
├── Body (Padding)
│   └── DestinationPicker (2×2 grid)
│       ├── DestCard("Local Save", icon: folder)
│       │   ├── Description: "Save to app storage"
│       │   └── selected: coral border overlay
│       ├── DestCard("Share", icon: square.and.arrow.up)
│       │   ├── Description: "Share via system menu"
│       │   └── selected: coral border overlay
│       ├── DestCard("iCloud", icon: icloud) (iOS only, hidden on Android; check availability before showing)
│       │   ├── Description: "Save to iCloud Drive"
│       │   └── selected: coral border overlay
│       └── DestCard("Google Drive", icon: doc.text.below.ecg) (distinct from iCloud)
│           ├── Description: "Upload to Google Drive"
│           └── selected: coral border overlay
│               └── if not authenticated: warning chip "Not signed in" below card
└── BottomNavigationBar
    └── ContinueButton (disabled until destination selected)
        ├── Label: "Export as {format}" (dynamic, shows selected format)
        └── onTap: 
            ├── If destination requires auth (iCloud, Google Drive) and not authenticated:
            │   └── Show AuthGate sheet: "Sign in to {destination}" with SignInButton
            │       └── If user cancels auth → stay on page, show snackbar "Authentication cancelled", keep destination selected (retryable)
            └── If authenticated → PAGE-016
- **Error handling:** If iCloud is not mounted or Drive fails availability check, dim the card with "Unavailable" subtitle and tooltip explaining why
```

---

## 19. PAGE-016: Export Progress

**Route:** `/export/:docId/progress` | **Tab:** Export stack

### Widget Tree

```
ExportProgressPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Exporting..."
│   └── Actions: [CancelButton (aborts Isolate)]
├── Body (Column, centered)
│   ├── [State: converting]
│   │   ├── Icon (animated document with gear, looped rotation)
│   │   ├── ProgressBar (determinate)
│   │   │   └── fill width = progress * 100%
│   │   ├── PhaseLabel ("Parsing Markdown..." / "Converting..." / "Saving...")
│   │   ├── ProgressPercentage ("{n}%")
│   │   └── CancelButton (text, "Cancel")
│   ├── [State: conversion_error]
│   │   └── ErrorState
│   │       ├── Icon (exclamationmark.triangle)
│   │       ├── Title: "Conversion Failed"
│   │       ├── Message: "Could not convert to {format}. {detail}"
│   │       ├── Detail examples:
│   │       │   ├── "The document contains unsupported LaTeX in the PDF renderer."
│   │       │   ├── "A table with merged cells could not be converted to DOCX."
│   │       │   └── "An image in the document could not be processed."
│   │       ├── RetryButton → re-starts conversion
│   │       └── FallbackButton "Save as TXT instead" → re-starts export as TXT
│   ├── [State: upload_error]
│   │   └── ErrorState
│   │       ├── Title: "Upload Failed"
│   │       ├── Message: "Could not upload to {destination}. {reason}"
│   │       ├── Reason examples:
│   │       │   ├── "Google Drive session expired. Please sign in again."
│   │       │   ├── "iCloud Drive is not available on this device."
│   │       │   └── "Network connection lost during upload."
│   │       ├── RetryButton → re-attempts upload
│   │       └── FallbackButton "Save locally instead" → saves to app sandbox
│   ├── [State: timeout]
│   │   └── ErrorState
│   │       ├── Title: "Export Timed Out"
│   │       ├── Message: "The export took longer than expected. This may happen with very large documents."
│   │       ├── RetryButton → re-starts conversion
│   │       └── FallbackButton "Export in smaller sections" → opens editor split guidance
│   ├── [State: storage_full]
│   │   └── ErrorState
│   │       ├── Title: "Not Enough Storage"
│   │       ├── Message: "There isn't enough free space to save this file. Free up space or choose a different destination."
│   │       ├── StorageInfo: "Available: {n} MB, Required: {n} MB"
│   │       └── DismissButton → returns to export hub (PAGE-013)
│   └── [State: complete]
│       ├── "Export Complete!" checkmark animation
│       ├── OpenFileButton → opens file in system viewer
│       └── ShareAgainButton → re-opens share sheet with same file (shares again to any destination, unlike original which was specific)
```
- **Determinate mode:** Parsing (0-25%), Converting (25-80%), Rendering (80-95%), Finalizing (95-100%)
- **Double-tap guard:** ExportButton disabled immediately after first tap, re-enabled on error/cancel
- **Cancel behavior:** Aborts Isolate, navigates back to PAGE-013 with SnackBar "Export cancelled"
- **Cancel confirmation:** If export > 50% complete, shows dialog: "Cancel export? {n}% done." with "Wait" and "Cancel" buttons
- **Timeout threshold:** 120 seconds for conversion; 60 seconds for upload
- **Filename sanitization:** User-provided export filenames sanitized — strip `/`, `\`, `..`, null bytes, limit to 255 chars
- **File size limits:** Docs > 50MB rejected for AI processing; > 200MB for Git clone operations

---

## 20. PAGE-017: Settings

**Route:** `/settings` | **Tab:** Settings (index 3)

### Widget Tree

```
SettingsPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Settings"
│   └── Actions: [SearchButton]
│       └── SearchButton → toggles inline search bar
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (autofocus, placeholder: "Search settings...")
│   │   └── Filters list items by title + section name
│   ├── ListView (filtered by search if active)
│   ├── Section: "Profile"
│   │   └── ListTile(icon: person, title: "Profile", trailing: name + chevron, onTap: → PAGE-023)  // navigable
│   ├── Section: "AI Configuration"
│   │   ├── ListTile(icon: brain, title: "Model Manager", trailing: mode.label + chevron, onTap: → PAGE-018)  // navigable
│   │   └── ListTile(icon: chart.bar, title: "Usage Dashboard", trailing: tokenCount + chevron, onTap: → PAGE-019)  // navigable
│   ├── Section: "Appearance"
│   │   ├── ListTile(icon: sun.max, title: "Theme", trailing: currentTheme + chevron, onTap: → PAGE-024)  // navigable
│   │   └── ListTile(icon: textformat.size, title: "Font Size", trailing: slider(12-24))  // inline control
│   ├── Section: "Editor"
│   │   ├── ListTile(icon: text.quote, title: "Spell Check", trailing: Switch)  // inline control
│   │   ├── ListTile(icon: number, title: "Line Numbers", trailing: Switch)  // inline control
│   │   └── ListTile(icon: square.resize, title: "Tab Size", trailing: SegmentedControl(2/4/8))  // inline control
│   ├── Section: "Privacy & Security"
│   │   ├── ListTile(icon: lock, title: "App Lock", trailing: Switch + chevron, onTap: auth flow)  // mixed: inline toggle + navigable
│   │   └── ListTile(icon: clock, title: "Auto-Lock Timer", trailing: picker(30s/1m/5m/never))  // inline control
│   └── Section: "About"
│       ├── ListTile(title: "Version", trailing: "v1.0.0")  // read-only
│       └── ListTile(icon: doc.text, title: "Licenses", trailing: chevron, onTap: → LicensePage)  // navigable
```

---

## 21. PAGE-018: Model Manager

**Route:** `/settings/ai` | **Tab:** Settings stack

### Security

- **PAGE-018** sets `FLAG_SECURE` on `ModelManagerPage` — prevents screenshots/screen recording of API keys and provider credentials
- API key fields use `obscureText: true` with optional reveal toggle
- Clipboard cleared when API key field loses focus (prevents paste-leak from task switcher)

### Widget Tree

```
ModelManagerPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Model Manager"
│   └── Actions: [AddProviderButton → bottom sheet]
├── Body (CustomScrollView)
│   ├── SliverToBoxAdapter
│   │   └── ModeToggleCard
│   │       ├── Label: "AI Mode"
│   │       ├── SegmentedControl(Free / Custom)
│   │       ├── Description: Free = one model for all tasks, Custom = per-task model routing
│   │       └── onSwitch: show ModeSwitchConfirmation
│   │           └── ModeSwitchConfirmation (BottomSheet):
│   │               ├── Switched from {old} to {new}
│   │               ├── Explanation of what changes (model routing, available settings)
│   │               ├── "Switch" confirm button
│   │               └── "Cancel" button
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Providers")
│   ├── SliverList
│   │   └── ProviderCard (per configured provider)
│   │       ├── Leading: ProviderLogo (DeepSeek/OpenAI/Anthropic icon)
│   │       ├── Title: provider.name
│   │       ├── Subtitle: provider.defaultModel
│   │       ├── Trailing: StatusBadge(active/error/unconfigured) + Chevron
│   │       └── onTap: → ProviderDetailSheet
│   ├── SliverToBoxAdapter (if Custom mode)
│   │   └── SectionHeader("Task Model Mapping")
│   ├── SearchBar (if Custom mode, visible when search active)
│   │   ├── TextField (placeholder: "Search tasks...")
│   │   └── Filters task mapping rows by name
│   └── SliverList (if Custom mode, filtered by search)
│       └── TaskMappingRow (per task type, up to 13 rows)
│           ├── TaskTypeLabel + icon
│           ├── ModelChip (currently assigned model)
│           └── onChange: ModelPickerSheet
└── ProviderDetailSheet (DraggableScrollableSheet)
    ├── Header: provider.name
    ├── ApiKeyField (TextFormField, obscure, validation on submit)
    │   ├── ValidateButton → test request, shows status indicator (spinner → checkmark / X)
    │   ├── ValidationMessage: "Connected" (green) / "Connection failed: {detail}" (red)
    │   └── HelperText: "Find your API key in your provider's dashboard"
    ├── BaseUrlField (TextFormField, default: api.deepseek.com)
    ├── DefaultModelPicker (DropdownButton)
    ├── ModelListEditor (add/remove model entries)
    ├── DeleteProviderButton (destructive, with confirmation)
    └── SaveButton
```

---

## 22. PAGE-019: Usage Dashboard

**Route:** `/settings/usage` | **Tab:** Settings stack

### Widget Tree

```
UsageDashboardPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Usage"
│   └── Actions: [ExportCsvButton]
├── Body (CustomScrollView)
│   ├── Loading: skeleton (3 metric cards + bar chart block + pie chart block)
│   ├── Empty: empty-state "No usage data yet" + "Usage tracking starts when you send your first message"
│   ├── Error: error-state with retry
│   └── Data:
│       ├── SliverToBoxAdapter
│       │   └── UsageSummaryRow
│       │   ├── MetricCard("Today", tokenCount, cost, onTap: tooltip "Tokens used today across all tasks")
│       │   ├── MetricCard("This Week", tokenCount, cost, onTap: tooltip "7-day rolling window")
│       │   └── MetricCard("This Month", tokenCount, cost, onTap: tooltip "Current billing cycle")
│       │   └── Mobile (< 600dp): stack vertically instead of 3-across
│       ├── SliverToBoxAdapter
│       │   └── SectionHeader("Daily Usage")
│       │       └── DateRangeSelector (SegmentedControl: Last 7 / Last 30 / Last 90 days)
│       ├── SliverToBoxAdapter
│       │   ├── [has data]: BarChart (fl_chart, interactive)
│       │   │   ├── X-axis: dates (every 5 days labeled)
│       │   │   ├── Y-axis: token count
│       │   │   ├── Bar color: coral → blue gradient
│       │   │   └── Tap on bar: tooltip showing exact tokens + date
│       │   └── [no data]: empty-state "No usage in this period"
│       ├── SliverToBoxAdapter
│       │   └── SectionHeader("Breakdown")
│       ├── SliverToBoxAdapter
│       │   └── BreakdownTabs (SegmentedControl: By Model / By Agent / By Task)
│       ├── SliverToBoxAdapter
│       │   ├── [has data]: PieChart (fl_chart, per selected breakdown, interactive)
│       │   │   └── Tap on segment: tooltip with label + percentage + exact tokens
│       │   └── [no data]: empty-state "No breakdown data available"
│       ├── SliverToBoxAdapter
│       │   └── SectionHeader("Alerts")
│       └── SliverToBoxAdapter
│           └── AlertConfigCard
│               ├── HardCapRow: Switch + TextField("${threshold}", keyboardType: number, min: 1000, max: 100000000)
│               ├── SoftCapRow: Switch + Slider(50-95%, step: 5)
│               └── ResetButton("Reset monthly counters", with confirmation)
```

---

## 23. PAGE-020: CoT Project List

**Route:** `/cot` | **Tab:** Settings stack (or standalone tab)

### Widget Tree

```
CotProjectListPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Chain of Truth"
│   └── Actions: [SearchButton, NewProjectButton]
│       └── SearchButton → toggles SearchBar inline below AppBar
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (autofocus, placeholder: "Search projects...")
│   │   ├── ClearButton
│   │   └── Results: filters projects by name match (case-insensitive)
│   ├── Loading: skeleton-card x 3
│   ├── Empty (no projects): empty-state "No projects" + "Chain of Truth helps you create documents systematically: from requirements → architecture → prototype → test." + "Create your first project" CTA
│   ├── Empty (search no match): empty-state "No projects match '{query}'"
│   ├── Error: error-state with retry
│   └── Data: ListView
│       └── CotProjectCard
│           ├── Title: project.name
│           ├── Subtitle: "{n} artifacts · updated {timeAgo}"
│           ├── Trail: StatusBadge (Draft/In Review/Complete)
│           ├── onTap: → PAGE-021
│           ├── Long press: ContextMenu (Archive project / Delete project)
│           ├── Swipe left: Archive project (with undo snackbar: "Archived · Undo")
│           └── Swipe left again (while archived): Delete project
│               └── Confirmation dialog: "Delete '{name}' and all artifacts?" + "This cannot be undone." + CancelButton + DeleteButton (destructive)
```

---

## 24. PAGE-021: CoT Artifact Editor

**Route:** `/cot/:project` | **Tab:** CoT stack

### Widget Tree

```
CotArtifactEditorPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: project.name
│   └── Actions: [ExportButton]
├── Body (Row on tablet, Column on phone)
│   ├── ArtifactTreePanel (left / top, 240dp wide on tablet)
│   │   ├── SearchField (below header, optional): filter tree nodes by name
│   │   └── TreeView (keyboard navigable: arrow keys = expand/collapse/select)
│   │       ├── SoT#1: SRS (file icon) — tooltip: "Software Requirements Specification"
│   │       │   ├── SoT#2: IA — tooltip: "Information Architecture"
│   │       │   ├── SoT#3: Design System
│   │       │   ├── SoT#4: User Flows
│   │       │   │   ├── UC-001 — tooltip: "Use Case: AI Chat"
│   │       │   │   └── UC-002 — tooltip: "Use Case: Agent Loop"...
│   │       │   ├── SoT#5: Prototype
│   │       │   ├── SoT#6: Data Model
│   │       │   ├── SoT#7: UCIC — tooltip: "Unified Client Interface Contracts"
│   │       │   ├── SoT#8-10: Test artifacts
│   │       │   └── + Add Artifact
│   │       └── onTap: select artifact → right panel updates
│   └── ArtifactEditorPanel (right / bottom)
│       └── Uses MarkdownEditor (PAGE-002) internally
│           ├── TemplateSelector (top bar)
│           │   └── Chip("Load {template} template")
│           └── Editor (super_editor)
└── (Undo tree — built into ArtifactEditorPanel)
    └── UndoHistorySheet (triggered by button in editor toolbar)
        ├── List of past edits with timestamps
        ├── Tap any entry to preview that version (read-only overlay)
        └── "Restore this version" → confirmation → replaces current content
└── (Template overwrite guard)
    └── When "Generate from template" is tapped with existing content:
        └── Confirmation dialog: "Replace current content?" + "This replaces the artifact content with the template. You can undo this later." + "Replace" + "Append to bottom" + CancelButton
└── FloatingActionButton
    └── "Generate from template" → inserts template content
```

---

## 25. PAGE-022: 404

**Route:** `*` | **Tab:** System

### Widget Tree

```
NotFoundPage (StatelessWidget)
├── AppBar (transparent, empty)
├── Body (Center, Column)
│   ├── Icon (questionmark.folder, size: 64, color: muted)
│   ├── Text("Page Not Found", bold, 24)
│   ├── Text("The page you're looking for doesn't exist.", muted)
│   ├── AttemptedUrl (if deep link): Text("'{url}'", code style, muted smaller)
│   ├── SuggestionText (if path matches known pattern): "Did you mean '/doc/{id}'?" with link
│   ├── RecoveryOptions (row, centered)
│   │   ├── TextButton.icon(icon: house, label: "Go Home", onTap: → `/`)
│   │   ├── TextButton.icon(icon: magnifying.glass, label: "Search", onTap: → search docs drawer)
│   │   └── TextButton.icon(icon: clock, label: "Recent", onTap: → recent docs sheet)
│   └── RecentPagesList (collapsed, max 5 items): recent documents with timestamps
└── Animated: icon wobbles (rotate: -5° → 5°) on page load, settles to 0°
```

## 26. PAGE-023: Profile

**Route:** `/settings/profile` | **Tab:** Settings stack

### Widget Tree

```
ProfilePage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   │   └── onPop: if hasUnsavedChanges → show "Discard changes?" dialog
│   ├── Title: "Profile"
│   └── Actions: [SaveButton (disabled if no changes)]
└── Body (Form)
    ├── AvatarPicker (circle avatar, tap to change from gallery)
    ├── NameField (TextFormField, "Display Name", placeholder: "Your name")
    ├── EmailField (TextFormField, "Email for Git commits", placeholder: "you@example.com", keyboardType: email)
    │   └── Validation: must be valid email format; error: "Please enter a valid email"
    ├── SignatureField (TextFormField, "Default document signature", placeholder: "Best regards,\n{name}", helperText: "Appended to exported documents")
    └── SaveButton (disabled if no changes, shows SnackBar "Profile saved" on success)
```

---

## 27. PAGE-024: Appearance

**Route:** `/settings/appearance` | **Tab:** Settings stack

### Widget Tree

```
AppearancePage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Appearance"
│   └── Actions: [ResetDefaultsButton]
│       └── onTap: ResetConfirmation dialog → "Reset all appearance settings to defaults?" + CancelButton + ResetButton
├── Body (ListView)
    ├── SectionHeader("Theme")
    ├── ThemePicker (SegmentedControl: Light / Dark / System)
    │   ├── Live preview card showing current theme
    │   └── System mode note: "Follows device theme" (shown only when System selected)
    ├── SectionHeader("Editor Font")
    ├── FontSizeSlider (12–24, step 2)
    │   └── Preview text showing current size
    ├── SectionHeader("Code Theme")
    └── CodeThemePicker (Dropdown / Grid of theme swatches)
        └── Preview: `code snippet` in selected theme
```
- **Save model:** Auto-save on change (no manual SaveButton); each picker/slider selection persists immediately to UserProfile
- **Feedback:** "Saved" snackbar shown briefly on first change; subsequent saves silent

---

## 28. PAGE-025: Editor Settings

**Route:** `/settings/editor` | **Tab:** Settings stack

### Widget Tree

```
EditorSettingsPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Editor"
│   └── Actions: [ResetDefaultsButton]
│       └── onTap: ResetConfirmation dialog → "Reset all editor settings to defaults?" + CancelButton + ResetButton
└── Body (ListView)
    ├── SwitchRow("Spell Check", icon: text.quote)
    ├── SwitchRow("Line Numbers", icon: number)
    ├── SwitchRow("Auto-Close Brackets", icon: chevron.left.forwardslash.chevron.right)
    ├── SectionHeader("Tabs")
    ├── SegmentedControlRow("Tab Size", values: [2, 4, 8])
    ├── SectionHeader("Export Defaults")
    ├── FormatPickerRow (default format, tap → picker, shows current selection as subtitle: "PDF")
    └── DestinationPickerRow (default destination, tap → picker, shows current selection as subtitle: "Local Save")
```

---

## 29. PAGE-026: Privacy & Security

**Route:** `/settings/privacy` | **Tab:** Settings stack

### Security

- Sets `FLAG_SECURE` — prevents screenshots of the auth configuration
- PIN (6-digit) hashed with PBKDF2 (100k iterations, 16-byte salt), stored in `flutter_secure_storage`, never in drift
- Listens for `local_auth` `onAuthenticationChanged`; re-prompts for credentials if biometric enrollment changes
- App switcher preview blurred when app lock enabled and app is backgrounded
- Auto-lock default: 1 minute; minimum: 30 seconds

### Widget Tree

```
PrivacySecurityPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Privacy & Security"
└── Body (ListView)
    ├── SectionHeader("App Lock")
    ├── SwitchRow("Require Auth to Open", icon: lock)
    │   └── onToggle: 
    │       ├── If enabling → biometric enrollment flow (Face ID / Touch ID / fingerprint)
    │       │   ├── If biometrics unavailable or user declines → fallback to PIN setup flow (6-digit PIN)
    │       │   │   └── User cancels PIN → switch reverts to off
    │       │   └── If biometrics enroll successfully → switch stays on
    │       └── If disabling → confirm current auth first
    ├── PickerRow("Auto-Lock Timer", options: [30s, 1m, 5m, Never])
    │   └── visible only when auth enabled
    ├── ActionRow("Lock Now", icon: lock.fill)
    │   └── onTap: immediately lock app (require auth to resume)
    │   └── visible only when auth enabled
    ├── SectionHeader("Data")
    ├── ActionRow("Clear Export Cache", subtitle: "{n} MB", icon: trash)
    │   └── onTap: confirmation dialog → delete cache files
    └── ActionRow("Delete All Usage Data", icon: exclamationmark.triangle, destructive)
        └── onTap: double-confirmation → "This deletes all usage records, export history, and token logs." + "Scope: {n} days of data" + CancelButton + DeleteButton
```

---

## 30. PAGE-027: Keyboard Shortcuts

**Route:** `/settings/shortcuts` | **Tab:** Settings stack

### Security

- No sensitive data displayed on this page; FLAG_SECURE not required

### Widget Tree

```
KeyboardShortcutsPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Keyboard Shortcuts"
│   └── Actions: [SearchButton, CustomizeButton]
│       ├── SearchButton → toggles inline search: "Search shortcuts..."
│       └── CustomizeButton → opens ShortcutCustomizer sheet
├── Body
│   ├── SearchBar (visible when search active)
│   │   ├── TextField (placeholder: "Search shortcuts...")
│   │   └── Filters list to matching shortcut or action name
│   └── ListView (filtered by search if active)
│       ├── SectionHeader("Navigation")
│       ├── ShortcutRow("New Document", "Cmd + N")
│       ├── ShortcutRow("New Chat", "Cmd + Shift + N")
│       ├── ShortcutRow("Go to Home", "Cmd + 1")
│       ├── ShortcutRow("Go to Chat", "Cmd + 2")
│       ├── SectionHeader("Editing")
│       ├── ShortcutRow("Send Message", "Cmd + Return")
│       ├── ShortcutRow("Manual Save", "Cmd + S")
│       ├── ShortcutRow("Toggle Preview", "Cmd + P")
│       ├── SectionHeader("Actions")
│       ├── ShortcutRow("Export", "Cmd + E")
│       └── ShortcutRow("Search Documents", "Cmd + F")
└── ShortcutCustomizer (BottomSheet, triggered by CustomizeButton)
    ├── List of all shortcuts (key + action pairs)
    ├── Tap any shortcut → record next keypress to rebind
    ├── "Reset to defaults" button
    └── Close button
```

---

## 31. PAGE-028: About

**Route:** `/settings/about` | **Tab:** Settings stack

### Widget Tree

```
AboutPage (StatelessWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "About"
└── Body (ListView)
    ├── LogoSection (centered)
    │   ├── AppIcon (app icon, 80dp)
    │   └── Text("Maya on the Fly", bold, 20)
    ├── ListTile(title: "Version", trailing: "1.0.0 (build 1)")
    ├── ListTile(title: "Changelog", trailing: chevron, onTap: → ChangelogPage)
    ├── ListTile(title: "Open Source Licenses", trailing: chevron, onTap: → LicensePage)
    └── Footer: Text("Built with Flutter · © 2026")
```

---

## 32. Component Cross-Reference

| DESIGN.md Component | Used In |
|---------------------|---------|
| `skeleton-block` / `skeleton-card` | All loading states |
| `empty-state` / `empty-state-action` | All empty states |
| `error-state` / `error-state-retry` | All error states |
| `progress-bar-track` / `progress-bar-fill` | PAGE-016, PAGE-009 (PushPullDialog) |
| `button-primary` | SendButton, ExportButton, CommitButton, CreateButton |
| `button-secondary` | CancelButton, BackButton variants |
| `button-legal` | Cookie consent, destructive confirmations |
| `text-input` / `text-input-focus` | ChatInputBar, CommitMessageField, profile fields |
| `form-error-text` | PAGE-018 (API key validation), CommitMessageField |
| `text-link` | "Learn more" links, "Go Home" on 404 |
| `signature-coral-card` | ProviderCard usage highlight |
| `demo-grid-card` | FormatPicker, DestinationPicker, Templates |
| `article-card` | ChatSessionItem, DocumentListItem |
| `topic-filter-rail` | Agent selector sidebar (tablet) |

## 33. Animation & Transition Spec

| Transition | Type | Duration | Curve |
|------------|------|----------|-------|
| Page push (nav stack) | Slide left (iOS) / fade-up (Android) | 350ms | easeInOut |
| Page pop | Slide right / fade-down | 350ms | easeInOut |
| Bottom sheet appear | Slide up + fade | 300ms | easeOut |
| Bottom sheet dismiss | Slide down + fade | 250ms | easeIn |
| Dialog appear | Scale 0.9 → 1.0 + fade | 200ms | easeOutBack |
| Dialog dismiss | Scale 1.0 → 0.9 + fade | 150ms | easeIn |
| List item insert | slideUp + fadeIn, staggered 50ms | 200ms | easeOut |
| Skeleton pulse (loading) | Opacity 0.3→1.0 loop | 800ms | easeInOut |
| Auto-save indicator | Dot pulse yellow → solid green | 300ms | easeOut |
| Preview scroll sync | Editor scroll → preview scroll to matching heading | 300ms debounce | linear |
| Export icon rotation | Gear icon 360° spin (looped during conversion) | 2s per rotation | linear |
| New message slide-up | Slide-up + fadeIn | 200ms | easeOut |
| Stream token | typewriter 10ms/char | variable | linear |
| Tool call morph | Scale + crossfade icon | 300ms | easeOut |
| Progress bar fill | AnimatedContainer width | 300ms | easeOut |
| Repo switcher open | Fade + scale-down (menu) | 150ms | easeOut |
| Repo switcher close | Fade + scale-up | 100ms | easeIn |
| Repo status rebuild (switch) | Cross-fade entire body | 200ms | easeOut |
| Tab switch | instant | 0ms | none |
| 404 icon wobble | Rotate -5° → +5° → 0° on page load | 500ms | spring |

## 34. Responsive Breakpoints

**Note:** The prototype.md breakpoints (app-native Flutter) differ from DESIGN.md breakpoints (marketing-site web). DESIGN.md uses 768/1024/1440 for responsive web layout; prototype.md uses 600/840 for native mobile/tablet layout. These serve different contexts and are intentionally not reconciled.

| Breakpoint | Layout | Notes |
|------------|--------|-------|
| < 600dp (phone portrait) | Single-column | Bottom nav, overlay preview, full-width lists, stacked metrics |
| 600–840dp (phone landscape / small tablet) | 2-column | Side-by-side editor, 2-column agent grid, compact bottom nav |
| > 840dp (large tablet) | 2-column + sidebar | Max-width centered content (720px lists), 4-column grids, full toolbar |
| Orientation change | Portrait ↔ Landscape | Editor: AnimatedSwitcher (phone) ↔ Row (phone landscape/tablet) |
- **Boundary behavior:** At exact breakpoint, use ≥ upper boundary (≥ 600dp → tablet layout)
- **Foldable / multi-window:** Layout recalculates on `MediaQuery` change (foldable hinge detected via display cutouts); Stage Manager split on iPad treated as ≥ 600dp
- **Safe areas:** All pages respect `MediaQuery.padding` for notches, status bar, home indicator
- **Keyboard avoidance:** Chat input, editor, and form pages use `resizeToAvoidBottomInset: true` with `AnimatedPadding` for smooth keyboard transition

## 35. Accessibility Notes

- All icons paired with `Semantics` labels
- Minimum tap target: 44×44dp (WCAG AAA)
- Streaming text supports `AccessibilityFeatures.accessibleNavigation` → skip typewriter, show full text
- All buttons support `onLongPress` for tooltip
- Keyboard shortcuts (iPad): `Cmd+N` new doc, `Cmd+Shift+N` new chat, `Cmd+Return` send, `Cmd+E` export, `Cmd+S` manual save (full list at PAGE-027)
- Color contrast ratios: minimum 4.5:1 for text, 3:1 for large text + UI components (per WCAG AA)
- **Focus indicators:** All interactive elements show visible focus ring (2px offset outline) in high-contrast mode
- **Form validation:** Error messages linked to inputs via `Semantics` error label; screen reader announces "Error: {message}" on focus
- **Reduced motion:** Respects `AccessibilityFeatures.disableAnimations` — all animations (stagger, typewriter, scale) disabled; instant transitions used instead
- **Dynamic type:** All text scales with device font size via `MediaQuery.textScaleFactor`; minimum 12sp, maximum 32sp
- **Platform a11y:** Android `contentDescription`, iOS `accessibilityLabel` on all semantic elements; `MergeSemantics` for grouped controls (e.g., FormatToolbar)

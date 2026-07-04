# HiFi Prototype Specification

**Document:** SoT-5 | **Derived From:** SoT-1 (SRS) + SoT-2 (IA) | **Status:** Draft | **Last Updated:** 2026-07-04

## 1. Introduction

This document specifies the HiFi prototype widget trees for all 22 pages of Maya on the Fly. Each page definition covers:

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
| Empty | `empty-state` + `empty-state-action` | Illustration + guidance text + CTA |
| Error | `error-state` + `error-state-retry` | Error icon + message + retry button |
| Data | Content widget | Normal rendering with state-driven rebuilds |

## 3. Layout Shell

### Bottom Navigation Bar

```
ShellScaffold
├── BottomNavigationBar (4 tabs)
│   ├── Tab 0: Home (icon: house)
│   ├── Tab 1: Chat (icon: bubble.left.and.bubble.right / chat)
│   ├── Tab 2: Git (icon: arrow.branch / code.branch)
│   └── Tab 3: Settings (icon: gear)
├── body: GoRouter (per-tab nested navigation stack)
```
- **Active tab indicator:** Airtable coral/blue underline
- **Badge:** Unread/unpushed count (Git tab when applicable)
- **Transition:** No animation on tab switch (instant)

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
│   │       ├── EditableArea (flex: 1)
│   │       └── PreviewPane (flex: 1, overlay handle)
│   └── Tablet (both orientations):
│       └── Row
│           ├── EditableArea (flex: 1)
│           └── PreviewPane (flex: 1, always visible)
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
├── Body (Column)
│   ├── TemplateCarousel
│   │   ├── TemplateCard("Blank Document")
│   │   ├── TemplateCard("Research Paper")
│   │   ├── TemplateCard("Business Proposal")
│   │   ├── TemplateCard("Meeting Notes")
│   │   └── TemplateCard("Technical Spec")
│   └── CreateButton (full-width, "Create from {selected template}")
```
- **On create:** Inserts Document into drift, navigates to PAGE-002

---

## 7. PAGE-004: Full Preview

**Route:** `/doc/:id/preview` | **Tab:** Home stack

### Widget Tree

```
FullPreviewPage (StatelessWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: doc.title
│   └── Actions: [ShareButton, ExportButton]
└── Body: InteractiveViewer
    └── MarkdownPreview (flutter_markdown, full-width)
```
- Full-screen preview with pinch-to-zoom
- LaTeX renders with `flutter_markdown` LaTeX extension
- Code blocks render with `highlight` package theme from settings

---

## 8. PAGE-005: Chat List

**Route:** `/chat` | **Tab:** Chat (index 1)

### Widget Tree

```
ChatListPage (ConsumerWidget)
├── AppBar
│   ├── Title: "Chats"
│   └── Actions: [NewChatButton → PAGE-007]
└── Body
    ├── Loading: skeleton-card x 5
    ├── Empty: empty-state "No conversations yet" + "Start a chat" CTA
    ├── Error: error-state with retry
    └── Data: ListView.builder
        └── ChatSessionItem (per session)
            ├── Leading: AgentAvatar(agentId)
            ├── Title: session.title (1 line)
            ├── Subtitle: agent.name + " · {timeAgo}" + " · {messageCount} msgs"
            ├── Trailing: TokenBadge(session.tokenCount)
            └── onTap: → PAGE-006
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
│   │   │   └── PopupMenu: list of 13 agents
│   │   └── TaskTypeBadge(taskType, onTap: reclassify)
│   │       └── Dropdown: all 13 task types
│   ├── Trailing:
│   │   ├── TokenCounter(session.tokenCount)
│   │   └── StopButton(visible only when generating, onTap: cancel)
│   └── Bottom: AgentToolIndicator(list of active tools for current agent)
├── Body
│   ├── Loading: centered CircularProgressIndicator
│   ├── Empty: empty-state "Send a message to start" + suggested prompts
│   ├── Error: error-state with retry
│   └── Data: MessageList (ListView.builder, reverse: true)
│       ├── UserMessage
│       │   ├── Role indicator: user avatar
│       │   ├── Content: Markdown body
│       │   └── Timestamp
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
├── on new token: setState with new displayed text
├── Render: RichText with typewriter effect (10ms per character)
└── Full text appears instantly on tap (skip animation)
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
NewChatPage (ConsumerWidget)
├── AppBar
│   ├── Title: "New Chat"
│   └── Actions: [CancelButton]
├── Body
│   ├── AgentGrid (2 columns on phone, 4 on tablet)
│   │   └── AgentCard (per agent, 13 total)
│   │       ├── AgentAvatar (icon per role)
│   │       ├── AgentName
│   │       ├── AgentDescription (1 line)
│   │       ├── ToolCountBadge ("{n} tools")
│   │       └── onTap: createSession(agentId)
│   └── QuickPromptRow (below agent grid)
│       └── Chip("Help me brainstorm")
│           Chip("Write an outline")
│           Chip("Review my document")
│           Chip("Debug my code")
```
- **On agent tap:** Creates ChatSession with selected agent, navigates to PAGE-006

---

## 11. PAGE-008: Git Repo List (Manage Repositories)

**Route:** `/git/manage` | **Tab:** Pushed from PAGE-009 switcher or Home

### Widget Tree

```
GitRepoListPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton (to PAGE-009 if arrived from switcher)
│   ├── Title: "Manage Repositories"
│   └── Actions: [InitRepoButton, CloneRepoButton]
├── Body
│   ├── Loading: skeleton-card x 3
│   ├── Empty: empty-state "No repositories yet" + "Init a repo" CTA
│   ├── Error: error-state with retry
│   └── Data: ListView
│       └── RepoListItem
│           ├── Leading: FolderIcon
│           ├── Title: repo.name
│           ├── Subtitle: repo.localPath (truncated) + branch name
│           ├── Trailing: UnpushedBadge(repo.unpushedCount, if > 0)
│           └── onTap: → PAGE-009(repo.id) // switches active repo
├── SwipeActions (per RepoListItem)
│   ├── Swipe left: Remove from list (unlink, does NOT delete files)
│   └── Swipe right: Pin to top (frequent repos stay accessible)
└── EmptyAppBarActions (when no repos)
    └── AddButtonRow: [InitLocalRepo, CloneRemoteRepo, OpenExistingFolder]
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
│   └── Actions: [PushButton, PullButton, FetchButton, LogButton → PAGE-012]
├── Body (CustomScrollView)
│   ├── SliverToBoxAdapter
│   │   └── RepoInfoCard
│   │       ├── BranchChip(repo.defaultBranch)
│   │       ├── RemoteChip(repo.remoteUrl, if any)
│   │       └── LastSyncBadge(repo.lastSyncedAt)
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Changes ({staged + unstaged} files)")
│   ├── SliverList
│   │   └── FileStatusItem (per changed file)
│   │       ├── Leading: StatusIcon (M/A/D/R/? colored)
│   │       ├── Title: file.path (relative)
│   │       ├── Subtitle: "+{add} -{del}" lines
│   │       ├── Trailing: StageCheckbox (if unstaged)
│   │       └── onTap: → PAGE-010
│   └── SliverToBoxAdapter
│       └── CommitButton (full-width, "Commit {n} files", disabled if no staged)
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
    └── CancelButton
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
│   └── Actions: [AddToStageButton, DiscardButton]
├── Body
│   ├── DiffSummaryBar
│   │   ├── AdditionsBadge (+{n})
│   │   ├── DeletionsBadge (-{n})
│   │   └── ViewToggle (Unified / Split)
│   └── DiffViewer (ListView)
│       └── DiffHunk
│           ├── HunkHeader ("@@ -{start},{count} +{start},{count} @@")
│           └── DiffLine (per line)
│               ├── Leading: LineNumber (old) + LineNumber (new)
│               ├── GutterIndicator (green bar / red bar / empty)
│               └── Content: code text (monospace, highlighted by extension)
```
- **Unified view:** Single pane with +/- gutter
- **Split view:** Two panes side-by-side (tablet) or tab-switched (phone)
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
│   │   └── Placeholder: "Describe your changes..."
│   ├── ConventionalCommitChips
│   │   ├── Chip("feat"), Chip("fix"), Chip("docs")
│   │   ├── Chip("refactor"), Chip("style"), Chip("test")
│   │   └── onTap: prefix field with "type: "
│   ├── Divider
│   ├── StagedFilesPreview (ListView)
│   │   └── FileChip(file.path, status: added/modified/deleted)
│   ├── DiffSummary
│   │   └── Text: "+{n} additions, -{n} deletions in {m} files"
│   └── CommitButton (full-width, primary)
│       └── disabled: message empty or no staged files
└── ConfirmDialog (on commit tap)
    ├── "Commit to {branch}"
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
│       ├── ConflictSection
│       │   ├── VersionLabel: "Ours (current)"
│       │   ├── CodeSnippet (syntax highlighted, read-only)
│       │   └── Divider
│       │   └── VersionLabel: "Theirs (incoming)"
│       │   └── CodeSnippet (syntax highlighted, read-only)
│       └── Actions
│           ├── AcceptOursButton
│           ├── AcceptTheirsButton
│           └── EditManuallyButton → opens PAGE-002 with conflict markers
└── FloatingActionButton
    └── "Mark All Resolved & Commit" (enabled when all files resolved)
```

---

## 16. PAGE-013: Export

**Route:** `/export` | **Tab:** Home stack (pushed from editor)

### Widget Tree

```
ExportPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Export"
│   └── Actions: [CancelButton]
└── Body (CustomScrollView)
    ├── SliverToBoxAdapter
    │   └── DocumentSummaryCard
    │       ├── Title: doc.title
    │       ├── Subtitle: "{n} words · {m} characters"
    │       └── Thumbnail (first 5 lines of markdown, truncated)
    ├── SliverToBoxAdapter
    │   └── SectionHeader("Format")
    ├── SliverToBoxAdapter
    │   └── FormatPicker (2×2 grid)
    │       ├── FormatCard("PDF", icon: doc.text.fill)
    │       │   └── selected: coral border overlay
    │       ├── FormatCard("HTML", icon: globe)
    │       ├── FormatCard("DOCX", icon: doc.richtext)
    │       └── FormatCard("TXT", icon: doc.plaintext)
    ├── SliverToBoxAdapter
    │   └── SectionHeader("Destination")
    ├── SliverToBoxAdapter
    │   └── DestinationPicker (2×2 grid)
    │       ├── DestCard("Local Save", icon: folder)
    │       ├── DestCard("Share", icon: square.and.arrow.up)
    │       ├── DestCard("iCloud", icon: cloud) (iOS only)
    │       └── DestCard("Google Drive", icon: cloud.fill) (conditional)
    └── SliverToBoxAdapter
        └── ExportButton (full-width, disabled until format + dest selected)
            └── onTap: → PAGE-016 (or return to editor if in progress)
```

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
│       │   └── selected: coral border overlay + checkmark
│       ├── FormatCard("HTML", icon: globe)
│       │   └── selected: coral border overlay + checkmark
│       ├── FormatCard("DOCX", icon: doc.richtext)
│       │   └── selected: coral border overlay + checkmark
│       └── FormatCard("TXT", icon: doc.plaintext)
│           └── selected: coral border overlay + checkmark
└── BottomNavigationBar
    └── ContinueButton (disabled until format selected)
        └── onTap: → PAGE-015
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
│       ├── DestCard("iCloud", icon: cloud) (iOS only, hidden on Android)
│       │   ├── Description: "Save to iCloud Drive"
│       │   └── selected: coral border overlay
│       └── DestCard("Google Drive", icon: cloud.fill)
│           ├── Description: "Upload to Google Drive"
│           └── selected: coral border overlay
└── BottomNavigationBar
    └── ExportButton (disabled until destination + format selected)
        └── onTap: → PAGE-016
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
│   ├── Icon (animated document with gear, looped rotation)
│   ├── ProgressBar (determinate)
│   │   └── fill width = progress * 100%
│   ├── PhaseLabel ("Parsing Markdown..." / "Converting..." / "Saving...")
│   ├── ProgressPercentage ("{n}%")
│   └── CancelButton (text, "Cancel")
└── (Completion → pushed to native share sheet or saved locally)
    ├── "Export Complete!" checkmark animation
    └── SecondaryButton: "Open File" / "Share Again"
```
- **Determinate mode:** Parsing (0-25%), Converting (25-80%), Rendering (80-95%), Finalizing (95-100%)
- **Double-tap guard:** ExportButton disabled immediately after first tap, re-enabled on error/cancel

---

## 20. PAGE-017: Settings

**Route:** `/settings` | **Tab:** Settings (index 3)

### Widget Tree

```
SettingsPage (ConsumerWidget)
├── AppBar
│   └── Title: "Settings"
├── Body (ListView)
│   ├── Section: "Profile"
│   │   └── ListTile(icon: person, title: "Profile", trailing: name, onTap: → PAGE-023)
│   ├── Section: "AI Configuration"
│   │   ├── ListTile(icon: brain, title: "Model Manager", trailing: mode.label, onTap: → PAGE-018)
│   │   └── ListTile(icon: chart.bar, title: "Usage Dashboard", trailing: tokenCount, onTap: → PAGE-019)
│   ├── Section: "Appearance"
│   │   ├── ListTile(icon: sun.max, title: "Theme", trailing: currentTheme, onTap: → PAGE-024)
│   │   └── ListTile(icon: textformat.size, title: "Font Size", trailing: slider(12-24))
│   ├── Section: "Editor"
│   │   ├── ListTile(icon: text.quote, title: "Spell Check", trailing: Switch)
│   │   ├── ListTile(icon: number, title: "Line Numbers", trailing: Switch)
│   │   └── ListTile(icon: square.resize, title: "Tab Size", trailing: SegmentedControl(2/4/8))
│   ├── Section: "Privacy & Security"
│   │   ├── ListTile(icon: lock, title: "App Lock", trailing: Switch, onTap: auth flow)
│   │   └── ListTile(icon: clock, title: "Auto-Lock Timer", trailing: picker(30s/1m/5m/never))
│   └── Section: "About"
│       ├── ListTile(title: "Version", trailing: "v1.0.0")
│       └── ListTile(icon: doc.text, title: "Licenses" onTap: → LicensePage)
```

---

## 21. PAGE-018: Model Manager

**Route:** `/settings/ai` | **Tab:** Settings stack

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
│   │       └── Description: Free = one model for all tasks, Custom = per-task model routing
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
│   └── SliverList (if Custom mode)
│       └── TaskMappingRow (per task type, 13 rows)
│           ├── TaskTypeLabel + icon
│           ├── ModelChip (currently assigned model)
│           └── onChange: ModelPickerSheet
└── ProviderDetailSheet (DraggableScrollableSheet)
    ├── Header: provider.name
    ├── ApiKeyField (TextFormField, obscure, validation on submit)
    │   └── ValidateButton → test request, shows status indicator
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
UsageDashboardPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Usage"
│   └── Actions: [ExportCsvButton]
├── Body (CustomScrollView)
│   ├── SliverToBoxAdapter
│   │   └── UsageSummaryRow
│   │       ├── MetricCard("Today", tokenCount, cost)
│   │       ├── MetricCard("This Week", tokenCount, cost)
│   │       └── MetricCard("This Month", tokenCount, cost)
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Daily Usage (Last 30 Days)")
│   ├── SliverToBoxAdapter
│   │   └── BarChart (fl_chart)
│   │       ├── X-axis: dates (every 5 days labeled)
│   │       ├── Y-axis: token count
│   │       └── Bar color: coral → blue gradient
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Breakdown")
│   ├── SliverToBoxAdapter
│   │   └── BreakdownTabs (SegmentedControl: By Model / By Agent / By Task)
│   ├── SliverToBoxAdapter
│   │   └── PieChart (fl_chart, per selected breakdown)
│   ├── SliverToBoxAdapter
│   │   └── SectionHeader("Alerts")
│   └── SliverToBoxAdapter
│       └── AlertConfigCard
│           ├── HardCapRow: Switch + TextField("${threshold}")
│           ├── SoftCapRow: Switch + Slider(50-95%)
│           └── ResetButton("Reset monthly counters")
```

---

## 23. PAGE-020: CoT Project List

**Route:** `/cot` | **Tab:** Settings stack (or standalone tab)

### Widget Tree

```
CotProjectListPage (ConsumerWidget)
├── AppBar
│   ├── Title: "Chain of Truth"
│   └── Actions: [NewProjectButton]
├── Body
│   ├── Loading: skeleton-card x 3
│   ├── Empty: empty-state "No projects" + "Use Chain of Truth for structured document creation"
│   ├── Error: error-state with retry
│   └── Data: ListView
│       └── CotProjectCard
│           ├── Title: project.name
│           ├── Subtitle: "{n} artifacts · updated {timeAgo}"
│           ├── Trail: StatusBadge (Draft/In Review/Complete)
│           └── onTap: → PAGE-021
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
│   │   └── TreeView
│   │       ├── SoT#1: SRS (file icon)
│   │       │   ├── SoT#2: IA
│   │       │   ├── SoT#3: Design System
│   │       │   ├── SoT#4: User Flows
│   │       │   │   ├── UC-001
│   │       │   │   └── UC-002...
│   │       │   ├── SoT#5: Prototype
│   │       │   ├── SoT#6: Data Model
│   │       │   ├── SoT#7: UCIC
│   │       │   ├── SoT#8-10: Test artifacts
│   │       │   └── + Add Artifact
│   │       └── onTap: select artifact → right panel updates
│   └── ArtifactEditorPanel (right / bottom)
│       └── Uses MarkdownEditor (PAGE-002) internally
│           ├── TemplateSelector (top bar)
│           │   └── Chip("Load {template} template")
│           └── Editor (super_editor)
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
│   └── TextButton.icon(icon: house, label: "Go Home", onTap: → `/`)
└── Animated: icon wobbles (rotate: -5° → 5°) on page load, settles to 0°
```

## 26. PAGE-023: Profile

**Route:** `/settings/profile` | **Tab:** Settings stack

### Widget Tree

```
ProfilePage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Profile"
│   └── Actions: [SaveButton]
└── Body (Form)
    ├── AvatarPicker (circle avatar, tap to change from gallery)
    ├── NameField (TextFormField, "Display Name")
    ├── EmailField (TextFormField, "Email for Git commits")
    ├── SignatureField (TextFormField, "Default document signature")
    └── SaveButton (disabled if no changes)
```

---

## 27. PAGE-024: Appearance

**Route:** `/settings/appearance` | **Tab:** Settings stack

### Widget Tree

```
AppearancePage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Appearance"
│   └── Actions: [ResetDefaultsButton]
└── Body (ListView)
    ├── SectionHeader("Theme")
    ├── ThemePicker (SegmentedControl: Light / Dark / System)
    │   └── Live preview card showing current theme
    ├── SectionHeader("Editor Font")
    ├── FontSizeSlider (12–24, step 2)
    │   └── Preview text showing current size
    ├── SectionHeader("Code Theme")
    └── CodeThemePicker (Dropdown / Grid of theme swatches)
        └── Preview: `code snippet` in selected theme
```

---

## 28. PAGE-025: Editor Settings

**Route:** `/settings/editor` | **Tab:** Settings stack

### Widget Tree

```
EditorSettingsPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Editor"
│   └── Actions: [ResetDefaultsButton]
└── Body (ListView)
    ├── SwitchRow("Spell Check", icon: text.quote)
    ├── SwitchRow("Line Numbers", icon: number)
    ├── SwitchRow("Auto-Close Brackets", icon: chevron.left.forwardslash.chevron.right)
    ├── SectionHeader("Tabs")
    ├── SegmentedControlRow("Tab Size", values: [2, 4, 8])
    ├── SectionHeader("Export Defaults")
    ├── FormatPickerRow (default format, tap → picker)
    └── DestinationPickerRow (default destination, tap → picker)
```

---

## 29. PAGE-026: Privacy & Security

**Route:** `/settings/privacy` | **Tab:** Settings stack

### Widget Tree

```
PrivacySecurityPage (ConsumerStatefulWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Privacy & Security"
└── Body (ListView)
    ├── SectionHeader("App Lock")
    ├── SwitchRow("Require Auth to Open", icon: lock)
    │   └── onToggle: biometric enrollment or PIN setup flow
    ├── PickerRow("Auto-Lock Timer", options: [30s, 1m, 5m, Never])
    │   └── visible only when auth enabled
    ├── SectionHeader("Data")
    ├── ActionRow("Clear Export Cache", subtitle: "{n} MB", icon: trash)
    │   └── onTap: confirmation dialog → delete cache files
    └── ActionRow("Delete All Usage Data", icon: exclamationmark.triangle, destructive)
        └── onTap: double-confirmation → truncate UsageRecords + ExportRecords
```

---

## 30. PAGE-027: Keyboard Shortcuts

**Route:** `/settings/shortcuts` | **Tab:** Settings stack

### Widget Tree

```
KeyboardShortcutsPage (ConsumerWidget)
├── AppBar
│   ├── Leading: BackButton
│   ├── Title: "Keyboard Shortcuts"
└── Body (ListView)
    ├── SectionHeader("Navigation")
    ├── ShortcutRow("New Document", "Cmd + N")
    ├── ShortcutRow("New Chat", "Cmd + Shift + N")
    ├── ShortcutRow("Go to Home", "Cmd + 1")
    ├── ShortcutRow("Go to Chat", "Cmd + 2")
    ├── SectionHeader("Editing")
    ├── ShortcutRow("Send Message", "Cmd + Return")
    ├── ShortcutRow("Manual Save", "Cmd + S")
    ├── ShortcutRow("Toggle Preview", "Cmd + P")
    ├── SectionHeader("Actions")
    ├── ShortcutRow("Export", "Cmd + E")
    └── ShortcutRow("Search Documents", "Cmd + F")
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
| `card` | ProviderCard, RepoListItem, ConflictFileCard, MetricCard |
| `skeleton-block` | All loading states |
| `empty-state` | All empty states |
| `error-state` | All error states |
| `progress-bar` | PAGE-016, PAGE-009 (PushPullDialog) |
| `form-error-text` | PAGE-018 (API key validation), CommitMessageField |
| `text-input-error` | PAGE-018 error state |
| `badge` / `badge-warning` | TaskTypeBadge, StatusBadge, UnpushedBadge |
| `overlay` / `overlay-lift` | PreviewPane on phone, ToolExecutionConfirmation |
| `button-primary` | SendButton, ExportButton, CommitButton, CreateButton |
| `button-destructive` | DeleteProviderButton, DiscardButton |
| `logo` | App bar (future: OpenAI/Anthropic provider logos) |

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
| Stream token | typewriter 10ms/char | variable | linear |
| Tool call morph | Scale + crossfade icon | 300ms | easeOut |
| Progress bar fill | AnimatedContainer width | 300ms | easeOut |
| Repo switcher open | Fade + scale-down (menu) | 150ms | easeOut |
| Repo switcher close | Fade + scale-up | 100ms | easeIn |
| Repo status rebuild (switch) | Cross-fade entire body | 200ms | easeOut |
| Tab switch | instant | 0ms | none |

## 34. Responsive Breakpoints

| Breakpoint | Layout | Notes |
|------------|--------|-------|
| < 600dp | Phone single-column | Bottom nav, overlay preview, full-width lists |
| 600-840dp | Small tablet 2-column | Side-by-side editor, 2-column agent grid |
| > 840dp | Large tablet 2-column + sidebar | Max-width centered content (720px lists), 4-column grids |

## 35. Accessibility Notes

- All icons paired with `Semantics` labels
- Minimum tap target: 44×44dp
- Streaming text supports `AccessibilityFeatures.accessibleNavigation` → skip typewriter, show full text
- All buttons support `onLongPress` for tooltip
- Keyboard shortcuts (iPad): `Cmd+N` new doc, `Cmd+Shift+N` new chat, `Cmd+Return` send, `Cmd+E` export, `Cmd+S` manual save
- Color contrast ratios: minimum 4.5:1 for text, 3:1 for large text + UI components (per WCAG AA)

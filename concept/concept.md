# Maya on the Fly — Concept & Technical Specification

A native mobile experience for AI-assisted document creation, bringing Markdown editing, AI writing agents, and Git operations to Android, iOS, and tablet devices.

---

## 1. System Architecture

| Layer | Technology | Rationale |
|---|---|---|
| Framework | Flutter (Dart) | Single codebase, native performance on both platforms |
| State Management | Riverpod | Type-safe, testable, minimal boilerplate for chat, file, and Git state |
| UI Adaptation | `LayoutBuilder` + `MediaQuery` | Automatic single-pane (phone) / multi-pane (tablet) layout |

### Layout Strategy

- **Phone**: Single-pane with bottom navigation. A floating button toggles the Markdown preview panel.
- **Tablet (≥600dp)**: Multi-pane split view — File Explorer + AI Chat in the left column, Markdown editor + preview on the right.

---

## 2. Core Modules

### A. Markdown Studio

Full-featured Markdown authoring with live preview.

- **Editor engine**: `super_editor` — stable rich-text editing with Markdown source support.
- **Rendering**: `flutter_markdown` — accurate preview with tables, syntax-highlighted code blocks, and image embeds.
- **Auto-save**: Writes to local storage every 5 seconds. Unsaved changes are recovered on app restart.

### B. OpenCode AI Agent

The intelligence layer that powers code review, content generation, and file-aware chat.

- **Connection modes**:
  - *Local* — FFI bridge to the OpenCode CLI (requires Termux on Android).
  - *Remote* — Persistent WebSocket to a remote OpenCode server (LAN or VPS).
- **Streaming**: Token-by-token rendering so the user never stares at a blank screen.
- **Context awareness**: When the user invokes AI help, the currently open file is automatically included as context.

### C. Git Manager

Version control without leaving the editor.

- **Engine**: `libgit2dart` — pure-Dart bindings for `libgit2`. All Git operations (clone, add, commit, push, pull, log) run in-process with zero shell dependency.
- **Authentication**: GitHub OAuth or PAT stored via `flutter_secure_storage` (biometric gate on push).
- **Conflict resolution**: Dedicated diff view that surfaces merge conflict markers and lets the user resolve inline.

---

## 3. Platform-Specific Considerations

| Concern | Strategy |
|---|---|
| **iOS sandbox** | No arbitrary CLI execution. Use `libgit2dart` for Git; AI agent connects in remote mode or via URL scheme to iSH. |
| **Battery** | Git status polling only while the app is foregrounded. Background fetch disabled by default. |
| **Performance** | Heavy work (large Markdown parse, Git history) dispatched to Dart `Isolate`s to keep the UI at 60 fps. |
| **Security** | Tokens and PATs live in the OS keychain; biometric prompt required before any network push. |

---

## 4. Project Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── opencode_service.dart    # WebSocket / FFI connection to AI
│   │   ├── git_service.dart         # libgit2dart wrapper
│   │   └── storage_service.dart     # Local file I/O
│   └── utils/
│       └── markdown_parser.dart     # Custom parsing helpers
├── features/
│   ├── editor/
│   │   ├── widgets/
│   │   │   ├── editor_pane.dart
│   │   │   └── preview_pane.dart
│   │   └── notifier/
│   │       └── editor_notifier.dart
│   ├── ai_chat/
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   └── prompt_input.dart
│   │   └── notifier/
│   │       └── chat_notifier.dart
│   └── git/
│       ├── widgets/
│       │   ├── repo_status_list.dart
│       │   └── commit_sheet.dart
│       └── notifier/
│           └── git_notifier.dart
├── main.dart
└── app_router.dart
```

---

## 5. Open Questions

1. Should the Markdown editor use a rich-text surface (`super_editor`) or a plain-text editor with a source-code approach? super_editor
2. For remote AI mode: should the app bundle a lightweight OpenCode proxy, or delegate entirely to a user-hosted server?
3. Should Git provider support extend beyond GitHub to GitLab / Bitbucket from day one? yes
</content>
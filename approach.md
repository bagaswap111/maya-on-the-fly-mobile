# Maya on the Fly — Approach

## 1. Core Reality

DeepSeek V4 Flash runs on DeepSeek's servers, not on-device. The app calls it via a standard OpenAI-compatible HTTP API (`api.deepseek.com`). No local model, no embedded Node.js runtime, no on-device inference.

## 2. Why opencode can't run on mobile

opencode is a TypeScript/Node.js CLI app. iOS blocks process spawning at the OS level. Android requires Termux + Node.js install. Neither is acceptable for a mainstream mobile app.

## 3. Architecture

```
             Flutter App (Dart)
  ┌──────────────────────────────────────────────┐
  │  ┌──────────┐  ┌──────────────────┐         │
  │  │ AI Chat  │  │ Markdown Editor  │         │
  │  │ (streams │  │ (super_editor)   │         │
  │  │  tokens) │  │                  │         │
  │  └────┬─────┘  └────────┬─────────┘         │
  │       │                 │                   │
  │  ┌────▼─────────────────▼──────────────┐    │
  │  │         Dart Service Layer          │    │
  │  │                                     │    │
  │  │  ┌───────────────────────┐ ┌──────┐ │    │
  │  │  │   AI Agent Engine     │ │git2  │ │    │
  │  │  │                       │ │dart  │ │    │
  │  │  │  Task Router          │ │      │ │    │
  │  │  │  chat  -> flash       │ │  +   │ │    │
  │  │  │  code  -> pro         │ │OAuth │ │    │
  │  │  │  review -> pro        │ │      │ │    │
  │  │  │  commit -> flash      │ └──┬───┘ │    │
  │  │  │  plan   -> pro        │    │     │    │
  │  │  └────────┬────────┘     │    ▼     │    │
  │  │           │              │ .git     │    │
  │  │  ┌────────▼────────┐    │ repo     │    │
  │  │  │  Agent Loop      │    │          │    │
  │  │  │  ┌──────────┐    │    │          │    │
  │  │  │  │ Tool     │    │    └──────────┘    │
  │  │  │  │ Executor │    │                    │
  │  │  │  │ skills   │    │  ┌──────────────┐  │
  │  │  │  └──────────┘    │  │ Model        │  │
  │  │  └──────────────────┘  │ Manager      │  │
  │  │                        │  profiles    │  │
  │  │                        │  A/B/C       │  │
  │  └──────────┬─────────────┴──────┬───────┘  │
  └─────────────┼────────────────────┼──────────┘
                │                    │
                ▼                    ▼
       api.deepseek.com        Provider API
       (selected per           (model list,
        task by router)         cost info)
```

Everything is native Dart. No external processes, no shells, no Node.js. The agent loop and task router run fully in-process.

## 4. Components

### A. AI Agent Engine

The core runtime that powers chat, autonomous writing, coding, research, and multi-step task execution.

- OpenAI-compatible HTTP client pointed at the configured provider (DeepSeek, OpenAI, etc.)
- **Streaming**: token-by-token via SSE for real-time chat display
- **Context injection**: current open file content appended to system/user messages automatically
- **Tool calling**: model can request tool execution; the engine runs the tool and feeds results back
- **Agent loop**: multi-turn cycle — model responds → tool calls are parsed and executed → results sent back → model continues until complete
- **Orchestrator**: for complex tasks, the engine can break work into sub-steps, execute them sequentially, and synthesize the final result

#### Agents

The app ships with built-in agent personas. Each agent has a default tool set and a suggested model tier. Users can switch agents in the chat header.

| Agent | Purpose | Default tools | Suggested model tier |
|---|---|---|---|
| **Writer** | General document writing, essays, notes | `read_file`, `write_file`, `edit_file`, `list_files`, `apply_template`, `generate_toc` | Flash |
| **Academic Writer** | Research papers, journals, theses. IMRaD structure, citations, abstracts | `read_file`, `write_file`, `edit_file`, `insert_citation`, `generate_bibliography`, `format_citation_style`, `insert_equation`, `generate_abstract` | Pro |
| **Business Writer** | Proposals, reports, executive summaries, business plans | `read_file`, `write_file`, `edit_file`, `create_timeline`, `swot_analysis`, `generate_executive_summary`, `insert_table` | Flash |
| **Technical Writer** | API docs, README, technical specs, code documentation | `read_file`, `write_file`, `edit_file`, `search_code`, `list_files`, `insert_figure` | Flash |
| **Coder** | Write, edit, and debug code | All code skills + `git_diff`, `git_commit`, `run_terminal` | Pro |
| **Editor** | Proofreading, grammar, tone, consistency, readability | `check_grammar`, `adjust_tone`, `rewrite`, `simplify`, `check_readability`, `check_consistency` | Flash |
| **Humanizer** | Make AI text sound human, bypass AI detection | `check_ai_score`, `humanize`, `remove_ai_patterns`, `add_personal_voice`, `vary_structure`, `humanize_academic` | Flash |
| **Researcher** | Literature search, citation gathering, related work, evidence synthesis | `literature_search`, `suggest_references`, `extract_citations`, `search_code`, `read_file` | Pro |
| **Reviewer** | Simulated peer review, critical analysis, methodology checks | `read_file`, `check_structure`, `check_methodology`, `search_code`, `git_diff` | Pro |
| **Formatter** | Template application, TOC, cross-references, export prep | `apply_template`, `generate_toc`, `manage_sections`, `insert_figure`, `insert_table` | Flash |
| **Data Analyst** | Tables, charts, statistics, data summaries | `insert_chart`, `insert_table`, `read_file`, `write_file` | Flash |
| **Collaborator** | Orchestrates multiple sub-agents for complex documents, manages versions | All tools (router decides delegation) | By task |
| **Auto** (default) | Routes to best agent based on task content | All tools (router decides) | By task mapping |

In **Free mode**, all agents are unlocked. **Custom mode** lets users restrict which agents a profile can use and map each agent to a different model.

**Agent tools are surfaced in the chat UI** — when a user selects or switches agents, the chat header shows a tool indicator (e.g. "Writer: read_file, write_file, edit_file, ...") so users know what capabilities the current agent has without consulting documentation. Tapping the indicator opens the full tool list.

#### Task Router

The Task Router assigns each request to the optimal agent and model based on the type of work. Users configure the mapping in their profile.

**The detected task type is shown in the chat header** — a small badge (e.g. `[chat]`, `[academic]`, `[code]`) appears next to the user's message showing what the router classified it as. This transparency helps users learn which keywords trigger which routes. Tapping the badge shows the router's full task-type mapping table.

| Task type | Description | Recommended model tier |
|---|---|---|
| `chat` | Casual Q&A, explanations, brainstorming | Cheap/fast (Flash) |
| `write` | Essays, articles, general document writing | Medium (Flash) |
| `academic` | Research papers, journals, theses | Strong reasoning (Pro) |
| `business` | Proposals, reports, executive summaries | Medium (Flash) |
| `code` | Write or modify code | Strong coder (Pro) |
| `review` | Code review, peer review, methodology checks | Reasoning (Pro/Opus) |
| `edit` | Proofreading, grammar, style, tone | Cheap (Flash) |
| `humanize` | Make text sound human, bypass AI detection | Cheap (Flash) |
| `research` | Literature search, citation gathering | Strong reasoning (Pro) |
| `commit` | Generate commit messages | Cheap (Flash) |
| `plan` | Architecture, design decisions, outlines | Powerful reasoning (Pro) |
| `format` | Templates, TOC, layout, export prep | Cheap (Flash) |
| `search` | Grep/search across files | No AI needed (Dart regex) |

The router checks the incoming user message against these categories (via keyword detection or a classifier call) and selects the configured model and agent. If no match, it falls back to the profile's default agent.

```
User: "write a research proposal on quantum computing"
  -> router detects "academic" task
  -> picks configured model for "academic" (e.g. deepseek-v4-pro)
  -> loads Academic Writer agent with its tool set
  -> Agent Loop starts

User: "make this paragraph sound less robotic"
  -> router detects "humanize" task
  -> picks configured model for "humanize" (e.g. deepseek-v4-flash)
  -> loads Humanizer agent
  -> runs humanize skills
```

#### Skills (Tools)

Skills are declared as OpenAI-compatible function definitions and registered with the engine at startup.

| Skill | Tool function | Description |
|---|---|---|---|
| `read_file` | `readFile(path)` | Read a file from the project directory |
| `write_file` | `writeFile(path, content)` | Write or overwrite a file |
| `edit_file` | `editFile(path, old, new)` | Make a surgical edit (find/replace) |
| `search_code` | `searchCode(pattern)` | Regex/grep search across the project |
| `list_files` | `listFiles(dir)` | List files in a directory |
| `git_status` | `gitStatus()` | Get current repo status |
| `git_commit` | `gitCommit(message)` | Stage all and commit |
| `git_diff` | `gitDiff(file)` | Show unstaged diff |
| `run_terminal` | `runTerminal(cmd)` | Run a shell command (Android only, shows approval dialog) |

##### Document Structure Skills

| Skill | Tool function | Description |
|---|---|---|
| `apply_template` | `applyTemplate(path, template)` | Apply a document template (IMRaD, report, business plan, README, etc.) |
| `generate_toc` | `generateToc(path)` | Generate or regenerate table of contents |
| `manage_sections` | `manageSections(action, path, ...)` | Reorder, merge, split, or delete sections |
| `insert_figure` | `insertFigure(path, caption, ref)` | Insert a figure placeholder with caption and cross-reference |
| `insert_table` | `insertTable(path, rows, cols, caption)` | Insert a table with caption |
| `insert_equation` | `insertEquation(path, latex)` | Insert a LaTeX equation |
| `generate_abstract` | `generateAbstract(path, style, length)` | Generate an abstract/summary from document content |

##### Research & Citation Skills

| Skill | Tool function | Description |
|---|---|---|
| `literature_search` | `literatureSearch(query)` | Search for relevant papers/articles via API (Semantic Scholar, arXiv, CrossRef) |
| `suggest_references` | `suggestReferences(topic, count)` | Suggest references for a given topic |
| `insert_citation` | `insertCitation(path, citationKey)` | Insert a citation placeholder at cursor |
| `generate_bibliography` | `generateBibliography(path, style)` | Generate formatted bibliography (APA, MLA, Chicago, IEEE) |
| `format_citation_style` | `formatCitationStyle(content, style)` | Convert inline citations to a specific style |
| `extract_citations` | `extractCitations(text)` | Parse and extract all citations from text |

##### Writing Quality Skills

| Skill | Tool function | Description |
|---|---|---|
| `check_grammar` | `checkGrammar(text)` | Check grammar, spelling, punctuation |
| `adjust_tone` | `adjustTone(text, target)` | Adjust tone (formal, casual, persuasive, technical) |
| `rewrite` | `rewrite(text, instruction)` | Rewrite paragraph per user instruction |
| `simplify` | `simplify(text, level)` | Simplify text to a target reading level |
| `check_readability` | `checkReadability(text)` | Score text for readability (Flesch, Dale-Chall, etc.) |
| `check_consistency` | `checkConsistency(text)` | Flag terminology, tense, voice, and style inconsistencies |
| `swot_analysis` | `swotAnalysis(content)` | Generate SWOT analysis from business document |
| `create_timeline` | `createTimeline(content)` | Extract/create timeline from project plan or proposal |
| `generate_executive_summary` | `generateExecutiveSummary(path, length)` | Summarize a long document to executive summary |

##### Humanizer & AI Detection Skills

| Skill | Tool function | Description |
|---|---|---|
| `check_ai_score` | `checkAiScore(text)` | Estimate AI-likeness score (0-100%) using local heuristics + API |
| `humanize` | `humanize(text, intensity)` | Increase perplexity and burstiness, reduce AI patterns |
| `humanize_academic` | `humanizeAcademic(text)` | Academic-flavored humanization (preserve formal style, remove robotic word choices) |
| `humanize_business` | `humanizeBusiness(text)` | Business-flavored humanization (conversational but professional) |
| `remove_ai_patterns` | `removeAiPatterns(text)` | Strip common AI tell-phrases ("it's important to note", "in conclusion", "furthermore") |
| `add_personal_voice` | `addPersonalVoice(text, traits)` | Inject personal voice markers (anecdotes, opinions, personality) |
| `vary_structure` | `varyStructure(text)` | Vary sentence length and structure to match human writing distribution |

Each skill has an **approval level**: `auto` (no prompt), `notify` (show in log), or `confirm` (require user tap). Destructive skills like `write_file` and `run_terminal` default to `confirm`. Humanizer skills default to `auto` but show a notification when applied.

##### AI Detection API Integration

The `check_ai_score` skill supports multiple detection backends. Users configure which backend to use in settings.

| Service | Free tier | Method |
|---|---|---|
| **GPTZero** | 10,000 words/month | HTTP API (JSON) |
| **Originality.ai** | Trial credits | HTTP API (JSON) |
| **Copyleaks** | Limited trial | HTTP API (JSON) |
| **Local heuristics** | Unlimited | Pure Dart — burstiness/perplexity scoring via character-level analysis |

Detection runs in an Isolate to avoid blocking the UI. Results include a score (0-100%) and flagged phrases/clauses. The humanizer skills use these results to target specific patterns.

#### Agent Loop

```
User prompt -> Router selects model -> API call (with tools)
    -> Model replies with tool calls
    -> Dart executes tools locally -> API call (with results)
    -> Model replies with more tool calls or final answer -> displayed to user
```

The loop runs entirely in Dart. No external orchestrator, no Python, no Node.js.

**Stop button:** During active agent loop execution, a prominent **Stop** button appears in the chat header next to the agent name. Tapping it immediately cancels the current API call, discards any pending tool results, and returns the partial output the model has generated so far. The user can then review, continue with a new prompt, or start over. This prevents unwanted file modifications or runaway multi-turn cycles.

#### Orchestrator

For high-level tasks like "refactor this file to use Riverpod":
1. Orchestrator prompt: *"Read the file, analyze the state management, plan the refactor step by step, then execute."*
2. Engine calls the model with `read_file` tool available
3. Model reads the file
4. Engine calls model again — model plans the refactor in text
5. Engine calls model again with `edit_file` tool — model makes changes
6. Engine calls model again with `git_commit` tool — model commits

This is the same pattern opencode, Cline, and Claude Code use — just implemented in Dart instead of TypeScript.

### B. Git Manager

- Uses `git2dart` (active fork, supports Android + iOS natively via FFI to libgit2)
- All operations run in-process: `init`, `clone`, `add`, `commit`, `push`, `pull`, `log`, `diff`, `status`
- Authentication via GitHub OAuth or PAT stored in `flutter_secure_storage`
- Biometric gate (FaceID / fingerprint) required before push operations
- Dedicated conflict resolution UI when merge conflicts occur

### C. Markdown Editor & Preview

- `super_editor` for rich-text editing with Markdown source support
- `flutter_markdown` for live **preview pane** — renders tables, code blocks with syntax highlighting, images, and LaTeX math
- Side-by-side mode on tablet; toggleable overlay on phone
- Auto-save to local storage every 5 seconds

**Recent documents:** The home screen shows a list of recently edited documents (last 20, sorted by last-modified timestamp). Each entry shows the filename, a preview of the first line, and the time since last edit. Users tap to open, swipe to delete. Empty state shows "No documents yet. Create your first document with AI."

**Recent chats:** A collapsible section on the home screen lists recent AI chat sessions (last 20). Each entry shows the first message preview and timestamp. Tapping restores the full chat history.

**Discard changes:** When reverting an auto-saved file (e.g. "Revert to last commit" or "Discard changes"), a confirmation dialog appears: *"You have unsaved changes. Discard them?"* with [Cancel] [Discard] buttons. This prevents accidental loss of auto-saved work.

**Keyboard shortcuts (iPad hardware keyboard):**
- `Cmd+S` — Save document
- `Cmd+E` — Open export sheet
- `Cmd+P` — Toggle Markdown preview
- `Cmd+N` — New document
- `Cmd+Shift+N` — New chat session
- `Cmd+Enter` — Send message (chat mode)
- `Esc` — Close panels, dismiss modals

### D. Model Manager

Central configuration and usage management hub for all AI providers.

A **Mode Toggle** at the top of the settings screen switches between two configuration styles:

```
  [Free]                    [Custom]
  ─────────────────────────────────────────
  One model for all tasks   Per-task model selection
  Free models only          Any model available
  No API key required       API key required per provider
  All agents & skills open  Agent/model mapping table
  Ideal for beginners       Ideal for power users
```

#### Free Mode

- User picks **one free model** from a curated list of models with free tiers or free API grants
- That single model is used for all task types and all agents
- No API key required — the app uses the provider's free tier or bundled proxy
- **All 12 agents and all skills are fully unlocked** — no restricted features
- Ideal for beginners, students, evaluation, or users who don't want to manage keys

| Available free models | Provider | Notes |
|---|---|---|
| DeepSeek V4 Flash | DeepSeek (free API grant) | 5M free tokens for new accounts |
| Gemini 2.0 Flash | Google (free API tier) | 60 req/min free |
| GPT-5o-mini | OpenAI (free grant) | Limited free tier |
| Llama 4 (8B) | OpenRouter (free) | Rate-limited but $0/token |

#### Custom Mode

- User assigns a **different model per task type** and **different model per agent**
- API keys are required for each provider used
- Full access to paid models (DeepSeek Pro, GPT-5, Claude, etc.)
- Per-task routing as described in section 4A (Task Router)
- Can restrict which agents are available per profile
- Usage dashboard tracks cost per model and per task

#### Configuration fields by mode

| Field | Free mode | Custom mode | Storage |
|---|---|---|---|---|
| Active mode | `free` | `custom` | Shared prefs |
| Chosen free model | `deepseek-v4-flash` | — | Shared prefs |
| Provider URL | — | `https://api.deepseek.com` | `flutter_secure_storage` |
| API key | — | `sk-xxxx` | `flutter_secure_storage` |
| Default model | — | `deepseek-v4-pro` | Shared prefs |
| Model for `write` | — | `deepseek-v4-flash` | Shared prefs |
| Model for `academic` | — | `deepseek-v4-pro` | Shared prefs |
| Model for `business` | — | `deepseek-v4-flash` | Shared prefs |
| Model for `code` | — | `deepseek-v4-pro` | Shared prefs |
| Model for `review` | — | `deepseek-v4-pro` | Shared prefs |
| Model for `edit` | — | `deepseek-v4-flash` | Shared prefs |
| Model for `humanize` | — | `deepseek-v4-flash` | Shared prefs |
| Model for `research` | — | `deepseek-v4-pro` | Shared prefs |
| Model for `commit` | — | `deepseek-v4-flash` | Shared prefs |
| Model for `plan` | — | `deepseek-v4-pro` | Shared prefs |
| Model for `format` | — | `deepseek-v4-flash` | Shared prefs |
| Agent-to-model mapping | — | Per agent (12 agents) | Shared prefs |
| Max tokens | Inherited from free model | `8192` | Shared prefs |
| Temperature | `0.7` | `0.7` | Shared prefs |
| Active profile | — | `"Balanced"` | Shared prefs |

#### Usage Tracking & Cost Monitoring

| Feature | Detail |
|---|---|
| **Session counter** | Tokens used per session (input + output), displayed in real-time in the chat header |
| **Per-model breakdown** | Tokens and cost split by model — how much went to Flash vs Pro vs other providers |
| **Per-task breakdown** | Tokens and cost split by task type — how much spent on chat vs code vs review |
| **Daily / weekly / monthly** | Aggregated usage for each period, stored persistently in a local SQLite database |
| **Cost estimation** | Estimated USD cost based on the provider's published pricing (user-configurable if rates differ) |
| **Usage alerts** | Configurable thresholds — e.g. warn at $5, block at $10 (per day or per session) |
| **Hard cap** | Optional monthly token or cost limit. Once reached, AI calls are blocked with a clear message. User must manually reset. |
| **Usage history** | Scrollable chart showing daily usage for the last 30/60/90 days. Data never leaves the device. |
| **Reset & export** | Reset counters for a new billing cycle. Export usage data as CSV for personal accounting. |

#### Usage Dashboard

A dedicated screen accessible from the main navigation showing:

```
             Usage Dashboard
  ┌─────────────────────────────────────┐
  │  This Session          Today        │
  │  12,340 tokens        45,678 tokens │
  │  $0.02                $0.08        │
  │                                     │
  │  This Week             This Month   │
  │  234,567 tokens       1,234,567     │
  │  $0.42                $2.15        │
  ├─────────────────────────────────────┤
  │  By Model                           │
  │  ┌──────────────────────────────┐   │
  │  │ deepseek-v4-flash   65% ████│   │
  │  │ deepseek-v4-pro     30% ███ │   │
  │  │ gpt-5o-mini          5% █   │   │
  │  └──────────────────────────────┘   │
  │                                     │
│  By Task                            │
│  ┌──────────────────────────────┐   │
│  │ code        25% ███         │   │
│  │ chat        15% ██          │   │
│  │ write       15% ██          │   │
│  │ academic    10% ██          │   │
│  │ research    10% ██          │   │
│  │ review       8% █           │   │
│  │ business     5% █           │   │
│  │ edit         5% █           │   │
│  │ humanize     3% █           │   │
│  │ commit       2% █           │   │
│  │ plan         2% █           │   │
│  └──────────────────────────────┘   │
  │                                     │
  │  Usage Alert: Off                   │
  │  [Warn at $5.00] [Block at $10.00] │
  └─────────────────────────────────────┘
```

#### Data storage

| Data | Storage | Scope |
|---|---|---|
| Session usage | In-memory `Riverpod` state | Current session only, lost on app close |
| Persistent usage | `drift` (SQLite) local DB | Daily/weekly/monthly aggregates, retained indefinitely |
| Provider pricing | User-configured in profile | Per provider, used for cost estimation |
| Usage limits | Shared prefs | Threshold values for alerts and hard caps |

### E. Export Engine

Converts Markdown files to other formats and sends them to user-chosen destinations.

#### Supported export formats

| Format | Approach | Library |
|---|---|---|
| **HTML** | Wrap rendered Markdown in a styled HTML template | `flutter_markdown` -> manual HTML wrapping |
| **PDF** | Render Markdown to widget, then capture as PDF | `pdf` or `printing` |
| **DOCX** | Convert Markdown AST to OpenXML via template | Custom Dart module (lightweight) |
| **Plain text** | Strip Markdown syntax, keep raw text | `flutter_markdown` plain text extension |

#### Export destinations

| Destination | Mechanism | Platforms |
|---|---|---|
| App sandbox (local) | `path_provider` + `dart:io` | Android, iOS |
| System share menu | `share_plus` | Android (share menu), iOS (share sheet) |
| iCloud Drive | `icloud_storage` or system file picker | iOS |
| Google Drive | Google Drive API (OAuth via `google_sign_in`) | Android, iOS |
| Local network (SMB) | `smb` package or third-party file manager integration | Android |

#### UX flow

```
Preview -> tap Export -> choose format (PDF/HTML/DOCX/TXT)
    -> choose destination (Save/Share/Cloud)
    -> conversion runs in an Isolate with progress bar
    -> result handed to platform channel
    -> platform share menu opens (iOS share sheet / Android share menu)
```

**Back and Cancel at every step:** The format and destination pickers each have a visible **Back** button (top-left arrow) and **Cancel** button (top-right X). Tapping Back returns to the previous step without losing selections. Tapping Cancel dismisses the entire export flow.

**Progress indicator during conversion:** While the Isolate processes the document, a determinate progress bar (`{component.progress-bar-fill}`) shows conversion progress. For large documents, the progress is updated via Isolate messages at key phases: "Parsing Markdown...", "Building layout...", "Rendering pages...", "Done." The Export button is disabled and shows "Converting..." during this phase.

**Double-submit prevention:** The Export button is disabled after the first tap. It remains disabled until conversion completes or fails. On failure, it re-enables so the user can retry.

Conversion runs in a Dart `Isolate` to keep the UI at 60 fps. Large documents (1000+ lines) are processed off the main thread.

## 5. Git Operations Detail

| Operation | git2dart method | UX | Progress indicator |
|---|---|---|---|
| `git status` | `Repository.status()` | Polled while app is foregrounded | None (instant) |
| `git add .` | `Index.addAll()` | Automatic on file save | None (instant) |
| `git commit` | `Repository.commit()` | Bottom sheet for commit message | None (instant) |
| `git push` | `Remote.push()` | Requires PAT, biometric gate | Determinate progress bar in status bar during push |
| `git pull` | `Remote.fetch()` + `Repository.merge()` | Merge conflict UI if needed | Determinate progress bar during fetch; conflict resolution shows step indicator |
| `git clone` | `Clone()` | First-time repo setup flow | Determinate progress bar with phases: "Connecting...", "Downloading objects (XX%)", "Checking out files...", "Done." |
| `git diff` | `Diff` APIs | Inline diff viewer | None (instant) |
| `git log` | `RevWalk` | Commit history list | None (instant) |

## 6. What This Eliminates vs. the Original Concept

| Original concept | Reality | Reason |
|---|---|---|
| FFI bridge to opencode CLI | Removed | opencode is TypeScript, not a C library |
| Embedded Node.js runtime | Removed | Unnecessary — DeepSeek is a cloud API |
| Termux / iSH dependency | Removed | Not acceptable for mainstream users |
| Process spawning | Removed | Blocked on iOS, fragile on Android |
| `libgit2dart` | Replaced with `git2dart` | Actively maintained, iOS-compatible |
| opencode agent wrapper | Replaced with direct DeepSeek API | Simpler, fewer dependencies |
| Cross-runtime complexity | Single-language Dart stack | One language, one runtime |

## 7. Constraints

- **Internet required**: All AI models are cloud APIs. No offline AI mode.
- **iOS push authentication**: GitHub PAT must be stored securely; biometric gate required before any network write operation.
- **File system**: All Markdown files live in the app's sandboxed document directory. No arbitrary file system access.
- **API key security**: Keys are stored in the OS keychain (`flutter_secure_storage`) and never logged or exposed in network error messages.
- **Provider dependency**: App functionality degrades gracefully if the configured provider is unreachable — chat shows a clear error, editor and git remain fully usable.

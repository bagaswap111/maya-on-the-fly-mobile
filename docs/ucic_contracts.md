# UCIC — Use Case Interaction Contracts

**Document:** SoT-7 | **Derived From:** SoT-1 (SRS) + SoT-4 (User Flows) | **Status:** Draft | **Last Updated:** 2026-07-04

## 1. Contract Overview

All AI API interactions use the OpenAI-compatible chat completions format. All requests are direct HTTPS from device to provider — no backend proxy.

| Aspect | Value |
|--------|-------|
| Transport | HTTPS (TLS 1.2+) |
| Auth | Bearer token via `Authorization` header |
| Content-Type | `application/json` |
| Streaming | Server-Sent Events (SSE), `stream: true` |
| Timeout | 30s connect, 120s response |

---

## 2. C-CM-001: Chat Completion (Streaming)

### Description
Send a chat completion request with streaming enabled. Used for all AI interactions — plain chat, agent reasoning, tool calls.

### Request

```
POST {baseUrl}/chat/completions
Authorization: Bearer {apiKey}
Content-Type: application/json
```

```json
{
  "model": "deepseek-v4-flash",
  "messages": [
    {
      "role": "system",
      "content": "You are {agentName}. {agentSystemPrompt}"
    },
    {
      "role": "user",
      "content": "Write a research proposal about climate change."
    }
  ],
  "stream": true,
  "max_tokens": 8192,
  "temperature": 0.7,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "read_file",
        "description": "Read a file from the project",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Relative path to the file"
            }
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "write_file",
        "description": "Write content to a file",
        "parameters": {
          "type": "object",
          "properties": {
            "path": { "type": "string" },
            "content": { "type": "string" }
          },
          "required": ["path", "content"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

### Response Stream (SSE)

Each SSE event:

```
data: {"choices":[{"delta":{"content":"The"},"index":0}]}

data: {"choices":[{"delta":{"content":" research"},"index":0}]}

data: {"choices":[{"delta":{"content":" proposal"},"index":0}]}

data: {"choices":[{"delta":{"content":" outlines"},"index":0}]}

...

data: {"choices":[{"delta":{},"finish_reason":"stop","index":0}]}

data: [DONE]
```

### Full Non-Streaming Response (for reference)

```json
{
  "id": "chatcmpl-123abc",
  "object": "chat.completion",
  "created": 1720000000,
  "model": "deepseek-v4-flash",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "The research proposal outlines..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 500,
    "total_tokens": 650
  }
}
```

### Response with Tool Calls (SSE Final Chunks)

```
data: {"choices":[{"delta":{"role":"assistant","content":null},"index":0}]}

data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"name":"read_file","arguments":""}}]},"index":0}]}

data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"arguments":"{\"path\":"}}]},"index":0}]}

data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"arguments":" \"src/main"}}]},"index":0}]}

data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"arguments":".dart\"}"}}]},"index":0}]}

data: {"choices":[{"delta":{},"finish_reason":"tool_calls","index":0}]}

data: [DONE]
```

### Parsed Tool Call (reassembled)

```json
{
  "id": "call_abc123",
  "type": "function",
  "function": {
    "name": "read_file",
    "arguments": "{\"path\": \"src/main.dart\"}"
  }
}
```

### Error Responses

**401 — Invalid API Key:**
```json
{
  "error": {
    "message": "Incorrect API key provided: sk-***xyz. You can find your API key at https://platform.openai.com/account/api-keys.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```
- **Client handling:** Show "Invalid API key" error state. Link to settings. Do NOT retry.

**429 — Rate Limited:**
```json
{
  "error": {
    "message": "Rate limit exceeded for requests. Retry after 30 seconds.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  },
  "headers": {
    "Retry-After": "30"
  }
}
```
- **Client handling:** Parse `Retry-After` header. Wait and auto-retry. Show countdown if > 10s.

**400 — Context Length Exceeded:**
```json
{
  "error": {
    "message": "This model's maximum context length is 65536 tokens. You requested 70000 tokens.",
    "type": "invalid_request_error",
    "param": "messages",
    "code": "context_length_exceeded"
  }
}
```
- **Client handling:** Truncate oldest messages. Retry with reduced context. Show "Conversation too long, oldest messages removed" notice.

**503 — Service Unavailable:**
```json
{
  "error": {
    "message": "The server is overloaded or not ready yet.",
    "type": "server_error",
    "param": null,
    "code": null
  }
}
```
- **Client handling:** Show "Service temporarily unavailable". Retry button with exponential backoff.

---

## 3. C-CM-002: Chat Completion (Non-Streaming)

### Description
Non-streaming variant for validation requests (API key test, small completions).

### Differences from C-CM-001

| Field | C-CM-001 | C-CM-002 |
|-------|----------|----------|
| `stream` | `true` | `false` (or omitted) |
| Response | SSE stream | Single JSON body |
| Timeout | 120s | 30s |

### Request

Same as C-CM-001 but with `stream: false` or omitted.

### Response

Single JSON body (see non-streaming response example in C-CM-001).

---

## 4. C-TOOL-001 through C-TOOL-046: Skill Tool Definitions

### 4.1 File Skills (C-TOOL-001 to C-TOOL-003)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-001 | `read_file` | Read a file from the project | `path: string` | `auto` |
| C-TOOL-002 | `write_file` | Write content to a file | `path: string, content: string` | `confirm` |
| C-TOOL-003 | `edit_file` | Edit specific lines in a file | `path: string, oldString: string, newString: string` | `confirm` |

**C-TOOL-001 Tool Definition:**
```json
{
  "type": "function",
  "function": {
    "name": "read_file",
    "description": "Read a file from the project and return its contents. Use this when you need to examine code, configuration, or documentation.",
    "parameters": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "description": "Relative path from the project root"
        }
      },
      "required": ["path"]
    }
  }
}
```

### 4.2 Search Skills (C-TOOL-004 to C-TOOL-005)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-004 | `search_code` | Search for text in project files | `query: string, path?: string` | `auto` |
| C-TOOL-005 | `list_files` | List files in a directory | `path: string` | `auto` |

### 4.3 Agent Skills (C-TOOL-006 to C-TOOL-009)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-006 | `switch_agent` | Switch to a different agent | `agentId: string` | `notify` |
| C-TOOL-007 | `get_tools` | List available tools for current agent | *(none)* | `auto` |
| C-TOOL-008 | `get_agent_info` | Get details about the current agent | `agentId: string` | `auto` |
| C-TOOL-009 | `ask_agent` | Delegate a sub-task to another agent | `agentId: string, task: string` | `notify` |

### 4.4 Search & Research Skills (C-TOOL-010 to C-TOOL-013)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-010 | `web_search` | Search the web for information | `query: string` | `notify` |
| C-TOOL-011 | `fetch_url` | Fetch content from a URL | `url: string` | `notify` |
| C-TOOL-012 | `literature_search` | Search academic papers | `query: string, limit?: int` | `notify` |
| C-TOOL-013 | `suggest_references` | Suggest citations for a topic | `topic: string, style?: string` | `auto` |

### 4.5 Git Skills (C-TOOL-014 to C-TOOL-018)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-014 | `git_status` | Check git repository status | `path?: string` | `auto` |
| C-TOOL-015 | `git_diff` | Show unstaged diff | `path?: string` | `auto` |
| C-TOOL-016 | `git_commit` | Commit staged changes | `message: string` | `confirm` |
| C-TOOL-017 | `git_push` | Push commits to remote | *(none)* | `confirm` |
| C-TOOL-018 | `git_log` | Show recent commit history | `limit?: int` | `auto` |

### 4.6 Document Skills (C-TOOL-019 to C-TOOL-021)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-019 | `apply_template` | Apply a document template | `templateId: string, documentId: string` | `notify` |
| C-TOOL-020 | `generate_toc` | Generate table of contents | `documentId: string` | `auto` |
| C-TOOL-021 | `manage_sections` | Reorganize document sections | `documentId: string, operations: array` | `confirm` |

### 4.7 Writing Skills (C-TOOL-022 to C-TOOL-024)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-022 | `check_grammar` | Check grammar and spelling | `text: string` | `auto` |
| C-TOOL-023 | `adjust_tone` | Adjust writing tone | `text: string, tone: string` | `auto` |
| C-TOOL-024 | `rewrite` | Rewrite text for clarity | `text: string, style?: string` | `auto` |

### 4.8 Humanizer Skills (C-TOOL-025 to C-TOOL-027)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-025 | `check_ai_score` | Estimate how likely text was AI-generated | `text: string` | `auto` |
| C-TOOL-026 | `humanize` | Rewrite text to reduce AI detection score | `text: string, targetScore?: int` | `notify` |
| C-TOOL-027 | `remove_ai_patterns` | Remove common AI writing patterns | `text: string` | `notify` |

### 4.9 Business Skills (C-TOOL-028 to C-TOOL-029)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-028 | `swot_analysis` | Generate SWOT analysis | `topic: string, context?: string` | `auto` |
| C-TOOL-029 | `create_timeline` | Create a project timeline | `project: string, tasks: array, startDate: string` | `auto` |

### 4.10 Terminal Skill (C-TOOL-030, Android Only)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-030 | `run_terminal` | Run a terminal command | `command: string, args: array` | `confirm` |

### 4.11 Document Structure Skills (C-TOOL-031 to C-TOOL-034)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-031 | `insert_figure` | Insert a figure placeholder with caption | `path: string, caption: string, ref?: string` | `notify` |
| C-TOOL-032 | `insert_table` | Insert a table with caption | `path: string, rows: int, cols: int, caption?: string` | `notify` |
| C-TOOL-033 | `insert_equation` | Insert a LaTeX equation | `path: string, latex: string` | `notify` |
| C-TOOL-034 | `generate_abstract` | Generate abstract from document content | `path: string, style?: string, length?: string` | `auto` |

### 4.12 Citation Skills (C-TOOL-035 to C-TOOL-038)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-035 | `insert_citation` | Insert a citation placeholder | `path: string, citationKey: string` | `notify` |
| C-TOOL-036 | `generate_bibliography` | Generate formatted bibliography | `path: string, style: string` | `auto` |
| C-TOOL-037 | `format_citation_style` | Convert inline citations to a style | `content: string, style: string` | `auto` |
| C-TOOL-038 | `extract_citations` | Extract all citations from text | `text: string` | `auto` |

### 4.13 Advanced Writing Skills (C-TOOL-039 to C-TOOL-042)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-039 | `simplify` | Simplify text to target reading level | `text: string, level?: string` | `auto` |
| C-TOOL-040 | `check_readability` | Score text readability (Flesch, Dale-Chall) | `text: string` | `auto` |
| C-TOOL-041 | `check_consistency` | Flag terminology, tense, and style inconsistencies | `text: string` | `auto` |
| C-TOOL-042 | `generate_executive_summary` | Summarize a long document to executive summary | `path: string, length?: string` | `auto` |

### 4.14 Advanced Humanizer Skills (C-TOOL-043 to C-TOOL-046)

| ID | Name | Description | Parameters | Approval |
|----|------|-------------|------------|----------|
| C-TOOL-043 | `humanize_academic` | Academic-flavored humanization (preserve formal style) | `text: string` | `notify` |
| C-TOOL-044 | `humanize_business` | Business-flavored humanization (conversational but professional) | `text: string` | `notify` |
| C-TOOL-045 | `add_personal_voice` | Inject personal voice markers (anecdotes, opinions) | `text: string, traits?: array` | `notify` |
| C-TOOL-046 | `vary_structure` | Vary sentence length and structure | `text: string` | `notify` |

---

## 5. C-DB-001 through C-DB-011: Database Access Contracts

### 5.1 Document DAO Contract

```dart
abstract class DocumentDaoContract {
  Future<List<Document>> recentDocuments({int limit = 20});
  Future<List<Document>> pinnedDocuments();
  Future<Document?> documentById(String id);
  Future<List<DocumentVersion>> versionsForDocument(String docId, {int limit = 100});
  Future<int> insertDocument(Document doc);
  Future<int> updateDocument(Document doc);
  Future<int> deleteDocument(String id);
  Future<int> insertVersion(DocumentVersion version);
  Future<int> deleteOldestVersions(String docId, int keepCount);
}
```

### 5.2 Chat DAO Contract

```dart
abstract class ChatDaoContract {
  Future<List<ChatSession>> recentSessions({int limit = 20});
  Future<ChatSession?> sessionById(String id);
  Future<List<ChatMessage>> messagesForSession(String sessionId);
  Future<int> insertSession(ChatSession session);
  Future<int> updateSession(ChatSession session);
  Future<int> deleteSession(String id);
  Future<int> insertMessage(ChatMessage message);
  Future<int> insertMessages(List<ChatMessage> messages); // batch insert
  Future<int> deleteMessagesForSession(String sessionId);
}
```

### 5.3 Usage DAO Contract

```dart
abstract class UsageDaoContract {
  Future<void> insertRecord(UsageRecord record);
  Future<UsageSummary> summaryForPeriod(DateTime start, DateTime end);
  Future<UsageSummary> monthToDate();
  Future<List<UsageByModel>> breakdownByModel(DateTime start, DateTime end);
  Future<List<UsageByTask>> breakdownByTask(DateTime start, DateTime end);
  Future<List<UsageByDay>> dailyUsage(DateTime start, DateTime end);
  Future<double> totalCostForPeriod(DateTime start, DateTime end);
  Future<int> totalTokensForPeriod(DateTime start, DateTime end);
}
```

### 5.4 Profile DAO Contract

```dart
abstract class ProfileDaoContract {
  Future<UserProfile?> defaultProfile();
  Future<UserProfile?> profileById(String id);
  Future<int> upsertProfile(UserProfile profile); // insert or update
  Future<List<TaskModelMapping>> mappingsForProfile(String profileId);
  Future<int> upsertMapping(TaskModelMapping mapping);
  Future<int> deleteMapping(String mappingId);
  Future<UsageAlert?> alertForProfile(String profileId);
  Future<int> upsertAlert(UsageAlert alert);
}
```

### 5.5 Repository DAO Contract

```dart
abstract class RepositoryDaoContract {
  Future<List<Repository>> allRepositories();
  Future<Repository?> repositoryById(String id);
  Future<Repository?> repositoryByPath(String localPath);
  Future<int> insertRepository(Repository repo);
  Future<int> updateRepository(Repository repo);
  Future<int> deleteRepository(String id);
}
```

---

## 6. C-EVENT-001 through C-EVENT-005: Event Contracts

Events emitted by services and consumed by UI via Riverpod state.

```dart
// C-EVENT-001: Usage threshold warning
class SoftCapWarningEvent {
  final double currentCost;
  final double threshold;
  final double percentage; // e.g., 0.85 for 85%
}

// C-EVENT-002: Hard cap blocking
class HardCapExceededEvent {
  final double currentCost;
  final double threshold;
}

// C-EVENT-003: Export completed
class ExportCompletedEvent {
  final String documentId;
  final String format;
  final String destination;
  final String? filePath; // local path if saved locally
}

// C-EVENT-004: Git operation completed
class GitOperationCompletedEvent {
  final String operation; // 'commit' | 'push' | 'pull' | 'clone'
  final bool success;
  final String? errorMessage;
  final int? commitCount;
}

// C-EVENT-005: Agent switch
class AgentSwitchedEvent {
  final String fromAgentId;
  final String toAgentId;
  final String sessionId;
}
```

---

## 7. C-FLOW-001: Agent Loop Contract

### Sequence Diagram (text)

```
User                  ChatPage              AgentEngine             AI Provider          SkillRegistry
  │                      │                      │                      │                    │
  │── sendMessage() ────→│                      │                      │                    │
  │                      │── execute() ────────→│                      │                    │
  │                      │                      │── classify() ──────→│(TaskRouter)        │
  │                      │                      │── selectAgent() ────│                     │
  │                      │                      │── selectModel() ────│                     │
  │                      │                      │                      │                    │
  │                      │                      │── POST /chat/completions ────────────────→│
  │                      │                      │←── SSE stream ───────────────────────────│
  │                      │←── tokens ──────────│                      │                    │
  │←── UI updates ──────│                      │                      │                    │
  │                      │                      │                      │                    │
  │                      │                      │finish_reason:        │                    │
  │                      │                      │  "tool_calls"        │                    │
  │                      │                      │                      │                    │
  │                      │                      │── parse tool calls ──│                    │
  │                      │                      │                      │                    │
  │                      │                      │── check approval ────│                    │
  │                      │                      │  "confirm"            │                    │
  │── ConfirmDialog ────│                      │                      │                    │
  │── approve() ────────→│                      │                      │                    │
  │                      │                      │── executeTool() ─────────────────────────→│
  │                      │                      │←── result ───────────────────────────────│
  │                      │                      │                      │                    │
  │                      │                      │── POST /chat/completions (with results) ─→│
  │                      │                      │←── SSE stream ───────────────────────────│
  │                      │                      │                      │                    │
  │                      │                      │finish_reason: "stop" │                    │
  │                      │                      │                      │                    │
  │                      │←── final response ──│                      │                    │
  │←── render complete ─│                      │                      │                    │
```

---

## 8. Contract Versioning

| Contract | Version | Last Updated |
|----------|---------|--------------|
| C-CM-001 | 1.0 | 2026-07-04 |
| C-CM-002 | 1.0 | 2026-07-04 |
| C-TOOL-001–027 | 1.0 | 2026-07-04 |
| C-TOOL-028–029 | 1.0 | 2026-07-04 |
| C-TOOL-030 | 1.0 | 2026-07-04 |
| C-TOOL-031–046 | 1.0 | 2026-07-04 |
| C-DB-001–011 | 1.0 | 2026-07-04 |
| C-EVENT-001–005 | 1.0 | 2026-07-04 |
| C-FLOW-001 | 1.0 | 2026-07-04 |

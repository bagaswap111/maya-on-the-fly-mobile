# System Logic: Task Router Pipeline

**Document:** SoT-4 Logic | **ID:** SL-006 | **Status:** Draft | **Related UC:** UC-001

## Purpose

Classify user messages into one of 13 task types and route them to the appropriate model (Custom mode) before the chat completion request is built.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| User message | Chat input | String | Raw user text |
| Conversation history | ChatSession messages | List<ChatMessage> | Recent messages for context |
| UserProfile.mode | Drift | Enum | Free or Custom |
| TaskModelMapping | Drift | Map<String, String> | Task type → model ID (only used in Custom mode) |
| Active agent | ChatSession | Enum | Currently selected agent |

## Processing Steps

### Step 1: Classify Task Type

Use keyword + pattern matching to classify the message (no external API call):

| Task Type | Keywords / Patterns |
|-----------|-------------------|
| `generate` | write, create, draft, compose, generate, produce |
| `edit` | edit, rewrite, revise, rephrase, improve, fix grammar |
| `summarize` | summarize, TL;DR, summary, key points, brief |
| `explain` | explain, what is, how does, why, describe, define |
| `code` | code, function, implement, debug, refactor class |
| `analyze` | analyze, compare, contrast, evaluate, assess |
| `research` | research, find, search, look up, sources, references |
| `plan` | plan, outline, steps, roadmap, strategy, timeline |
| `review` | review, critique, feedback, comment, check |
| `translate` | translate, convert language, in [language] |
| `brainstorm` | brainstorm, ideas, think of, suggest, propose |
| `format` | format, style, layout, organize, restructure |
| `general` | catch-all — everything else |

1. Tokenize user message into lowercase words
2. Score each task type based on keyword matches (weighted by recency in conversation)
3. For scored matches below confidence threshold (no keyword match): default to `general`
4. If multiple types have equal score: use active agent to disambiguate

### Step 2: Route Model (Custom Mode Only)
1. If mode == Free → use default model (single configured provider)
2. If mode == Custom:
   - Look up `TaskModelMapping[taskType]` in drift
   - If mapping exists → use mapped model
   - If no mapping → fall back to default model

### Step 3: Attach to Request
1. Return classified task type string
2. Return selected model (if Custom mode) or null (if Free mode)
3. Task type is consumed by the chat header badge
4. Model is consumed by the Chat Streaming Pipeline (SL-002)

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Task type | Chat UI (badge) + Agent Engine | Enum (13 types) | Classified task type |
| Model | Agent Engine | String | Model ID for API request |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| No keyword match | All scores = 0 | Default to `general` |
| Model not found in TaskModelMapping | Drift query returns null | Fall back to default model |
| Empty message | Message length = 0 | Return `general`, allow model to handle |

## Flow Diagram (text)

```
User message → Tokenize → Score task types (keyword matching)
                                    ↓
                          ┌──────────────────┐
                          │  Best match >    │──No──→ [general]
                          │  confidence?     │
                          └──────────────────┘
                                    ↓
                                  Yes
                                    ↓
                        Resolve task type
                                    ↓
                    ┌── Free mode → use default model
                    │
                    └── Custom mode → TaskModelMapping[taskType]
                                          ↓
                                   Model found? ──No──→ Use default model
                                          ↓
                                        Yes
                                          ↓
                              Return (taskType, model)
```

## Performance Constraints

- Classification must complete within 10ms (no external API calls)
- Keyword matching uses in-memory set lookups (O(n) where n = message word count)
- Disambiguation (when scores are equal) must complete within 2ms

# System Logic: Agent Engine Loop

**Document:** SoT-4 Logic | **ID:** SL-001 | **Status:** Draft | **Related UC:** UC-002

## Purpose

Orchestrate multi-turn agent interactions where the AI model calls tools, results are processed, and the loop continues until the model produces a final answer or the user stops it.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| ChatSession | Drift (ChatSession table) | Object | Session ID, mode, agent config |
| Messages | Drift (ChatMessage table) | List<ChatMessage> | Full conversation history |
| User prompt | Chat input | String | Current user message |
| Active agent | ChatSession.agentId | Enum | One of 13 agent personas |
| Tool definitions | SkillRegistry | List<ToolDefinition> | Available skills for the active agent |
| Approval levels | SkillRegistry | Map<String, ApprovalLevel> | Each skill's auto/notify/confirm setting |

## Processing Steps

### Step 1: Build Request
1. Load conversation history (last N messages up to context limit)
2. Prepend system prompt for active agent (from agent definitions)
3. Determine if tool definitions should be included (based on task type)
4. If custom mode: look up TaskModelMapping for model selection
5. Construct ChatCompletionRequest object

### Step 2: Send Request & Stream Response
1. Send POST to AI provider /chat/completions with `stream: true`
2. Parse SSE chunks as they arrive
3. Forward each content delta to UI via StreamController
4. Detect `finish_reason` in final chunk:
   - `stop` → proceed to end
   - `tool_calls` → proceed to Step 3
   - `length` → truncation — show "Response truncated" notice
   - `content_filter` → show content filter warning

### Step 3: Parse Tool Calls
1. Extract `tool_calls` array from response
2. For each tool call:
   - Parse function name → look up in SkillRegistry
   - Parse JSON arguments → validate required params
3. Build ToolCallMessage list

### Step 4: Execute Tools
1. For each tool call:
   - Check approval level:
     - `auto` → execute immediately
     - `notify` → execute and surface result in UI
     - `confirm` → pause loop, show confirmation dialog, wait for user response
   - If user denied: compose "User denied" result message
   - If user approved or auto: execute via ToolExecutor
   - Catch any exceptions → return error result
2. Format all results as ToolResultMessage list
3. Append to conversation history

### Step 5: Recursive Call
1. Send updated conversation (with tool results) back to AI provider
2. Repeat from Step 2

### Step 6: Completion
1. Detect `finish_reason: "stop"` in final response
2. Record final token usage from response usage field
3. Save all generated messages to drift
4. Update ChatSession.updatedAt
5. Emit `AgentCompleteEvent` to analytics

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Streaming text | Chat UI | Stream<String> | Token-by-token response |
| Tool call results | Conversation | List<ToolResultMessage> | Results appended to chat |
| Final response | Chat UI | String | Complete AI response |
| UsageRecord | Drift | Object | Token counts, cost, agent ID |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Network timeout | HTTP timeout > 30s | Retry 3× exponential backoff, then show error UI |
| API 401 | Response status code | Show "Invalid API key" error with link to settings |
| API 429 | Response status code | Parse Retry-After header, wait, retry |
| Tool execution exception | Dart try/catch | Return error as result to model |
| Unknown tool | SkillRegistry miss | Return "Tool not found" result to model |
| Context overflow | Token count > model limit | Truncate oldest messages, retry |

## State Machine

```
[Idle] → user sends message → [Streaming] → finish_reason="stop" → [Complete]
                                                  ↓
                                          finish_reason="tool_calls"
                                                  ↓
                                           [Parsing Tools]
                                                  ↓
                                           [Executing Tools]
                                                  ↓
                                         (results appended)
                                                  ↓
                                           [Streaming] (recursive)
                                                  ↓
                    user taps Stop → [Interrupted] → [Idle]
```

## Performance Constraints

- Tool execution must complete within 10 seconds
- Full loop must complete within 120 seconds
- Max 15 tool calls per loop cycle (safety limit)
- Max 5 recursive turns per user message

## Related Logic Files

| Logic ID | Name | Relationship |
|----------|------|-------------|
| SL-002 | Chat Streaming Pipeline | Sub-component of Step 2 |
| SL-006 | Task Router Pipeline | Pre-processing before Step 1 |
| SL-005 | Usage Tracking | Called in Step 6 |

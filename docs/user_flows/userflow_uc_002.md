# User Flow: Agent Loop with Tool Execution

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F004, F009 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-002 |
| Name | Agent Loop with Tool Execution |
| Actor | Any user (typically Programmer or Researcher) |
| Goal | Execute a multi-step task where the AI model calls tools, results are processed, and the model continues reasoning to produce a final result |
| Trigger | User sends a message that requires tool use (e.g., "Read this file and suggest edits") |
| Preconditions | - Chat session is active- One or more skills are registered in the SkillRegistry- Agent has tools enabled |

## Main Flow

1. User sends message that the Task Router classifies as requiring tool access
2. System sends API request with tool definitions for the active agent
3. Model responds with `tool_calls` in the response (content + function calls)
4. System displays model's text response as it streams
5. For each tool call:
   a. System checks skill approval level
   b. If `confirm`: System shows confirmation dialog with tool name and arguments
   c. User approves (or denies)
   d. System executes tool locally in Dart
   e. System formats result as tool response message
   f. System appends result to conversation
6. System sends updated conversation (with tool results) back to model
7. Model processes results and either:
   a. Responds with final answer → displayed to user
   b. Responds with more tool calls → repeat from step 4
8. Loop continues until model responds with `finish_reason: "stop"`
9. **Goal achieved:** Final AI response displayed with all intermediate tool results visible

## Alternative Flows

### Alt-1: User Denies Tool Execution
**Trigger:** Skill requires `confirm` approval and user taps "Deny"

1. Confirmation dialog shows tool name and arguments
2. User taps "Deny" instead of "Approve"
3. System sends result to model: "User denied execution of {tool_name}"
4. Model adapts response (e.g., describes what it would have done)
5. **Outcome:** Task continues without executing that particular tool

### Alt-2: User Stops Agent Loop
**Trigger:** User taps Stop button during active loop

1. Stop button becomes visible in chat header when loop starts
2. User taps Stop
3. Current API call is cancelled immediately
4. Pending tool results are discarded (not sent back to model)
5. Partial output generated so far is displayed in the conversation
6. "Generation stopped" notice appears
7. **Outcome:** User sees whatever the model generated before interruption, can continue with new prompt

### Alt-3: Orchestrator Multi-Step Task
**Trigger:** User sends high-level task like "Refactor this document"

1. Orchestrator generates sub-step plan
2. Step 1: Model reads the document (read_file tool)
3. Step 2: Model analyzes and proposes changes (text response)
4. Step 3: Model applies changes (edit_file tool)
5. Step 4: Model commits (git_commit tool)
6. **Outcome:** Multi-step task completed with all intermediate results shown

## Exception Flows

### Exc-1: Tool Execution Error
**Trigger:** Tool execution throws an exception

1. System catches exception from tool execution
2. System sends error message back to model: "Error executing {tool_name}: {error_message}"
3. Model can retry with corrected arguments or adapt response
4. **Outcome:** Model handles error gracefully

### Exc-2: Unknown Tool
**Trigger:** Model requests a tool that is not registered in SkillRegistry

1. System checks SkillRegistry — tool not found
2. System sends result to model: "Tool {name} not available. Available tools: {list}"
3. Model adapts its approach
4. **Outcome:** Model uses available tools instead

## Postconditions

- All tool results are visible in conversation history
- Files modified by tools reflect changes (write_file, edit_file)
- Git commits are created if git_commit was called
- Token usage includes all loop iterations

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-006 | Chat Conversation | Main flow — agent loop with tool execution |
| PAGE-002 | Document Editor | Tools can read/write documents |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| ChatMessage | Local DB (drift) | Create | Multiple messages per loop iteration |
| Document | File system + drift | Read/Write | Content modified by file tools |
| Git repo | git2dart | Read/Write | Modified by git skills |
| SkillRegistry | In-memory | Read | Tool definitions for API request |

## Acceptance Criteria

- [ ] Model correctly calls tools and processes results
- [ ] Confirmation dialog appears for tools with `confirm` level
- [ ] Stop button interrupts mid-loop and shows partial output
- [ ] User can deny tool execution and model adapts
- [ ] Orchestrator completes multi-step tasks
- [ ] Tool execution errors are returned to model gracefully

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-004.1 | Support multi-turn agent loop | Recurring API calls with tool results |
| FR-004.2 | Execute tools locally in Dart | ToolExecutor runs skills in Dart |
| FR-004.3 | Support OpenAI-compatible function calling | Tool definitions in API request |
| FR-004.4 | Display Stop button during loop | Chat header shows Stop during active execution |
| FR-004.5 | Stop cancels API call and discards tool results | HTTP request aborted, remaining tool calls skipped |
| FR-004.6 | Stop returns partial output | Partial response displayed before interruption |
| BR-004.1 | Destructive tools default to "confirm" | write_file, run_terminal show confirmation dialog |
| FR-009.1 | Support 26 tool functions in 5 categories | SkillRegistry with all 26 skills |
| FR-009.2 | Each skill has approval level | Each skill configured with auto/notify/confirm |

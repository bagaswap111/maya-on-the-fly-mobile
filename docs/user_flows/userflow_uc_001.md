# User Flow: AI Chat Completion

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F001, F002, F003 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-001 |
| Name | AI Chat Completion |
| Actor | Any user (Researcher, Student, Programmer, Business Owner) |
| Goal | Send a message to AI and receive a streaming response with appropriate agent and model routing |
| Trigger | User types message in chat input and taps Send |
| Preconditions | - App is open on Chat page- At least one AI provider is configured (Free mode auto-configures DeepSeek)- Internet connection is available |

## Main Flow

1. User types message in chat input field → System displays message in conversation thread
2. System classifies message into task type via Task Router → Task type badge appears in header
3. System selects agent and model based on mode (Free: single model, Custom: per-task mapping)
4. System sends chat completion request with streaming enabled
5. System displays typing indicator in chat header
6. Token-by-token response streams into conversation thread in real-time
7. System updates session token counter with each response chunk
8. System updates persistent usage records after completion
9. **Goal achieved:** User sees full AI response in conversation thread

## Alternative Flows

### Alt-1: Agent Switch During Conversation
**Trigger:** User taps agent selector in chat header mid-conversation

1. System shows agent picker dropdown with all 13 agents + current tool sets
2. User selects new agent
3. Chat header updates agent name and tool indicator
4. Next message uses new agent's tool set and system prompt
5. **Outcome:** Agent changes without losing conversation history

### Alt-2: Task Reclassification
**Trigger:** User taps task type badge and selects different task type

1. Task badge dropdown shows full task-type mapping table
2. User selects different task type
3. Badge updates to new task type
4. Next message uses model configured for new task type
5. **Outcome:** User can override automatic task classification

## Exception Flows

### Exc-1: Network Timeout
**Trigger:** Request to AI provider exceeds 30-second timeout

1. System detects timeout
2. Shows "Connection lost. Retrying..." toast notification
3. Auto-retries up to 3 times with exponential backoff (2s, 4s, 8s)
4a. **Success on retry:** Flow resumes from step 5
4b. **All retries fail:** Shows "Unable to reach provider. Check your connection." error state with retry button

### Exc-2: Invalid API Key
**Trigger:** Provider returns HTTP 401

1. System receives 401 response
2. Shows error state: "Invalid API key for {Provider}. Check your settings."
3. Error state includes link to settings page
4. **Outcome:** User navigates to settings to fix API key

### Exc-3: Rate Limited
**Trigger:** Provider returns HTTP 429

1. System receives 429 response
2. Shows "Rate limited by {Provider}. Waiting..." with countdown timer
3. Auto-retries after rate limit window (if Retry-After header present) or after 30s
4. **Outcome:** Request completes after rate limit resets

### Exc-4: Hard Cap Reached
**Trigger:** Usage tracking detects hard cap exceeded before API call

1. System checks UsageAlert before making API call
2. Shows blocking message: "Monthly usage cap of ${threshold} reached. AI calls paused."
3. Shows "Reset Cap" button and link to usage dashboard
4. **Outcome:** User resets cap or changes settings to continue

## Security Considerations

- API key retrieved from `flutter_secure_storage` at call time; never cached in memory beyond the HTTP request
- Certificate pinning verified before HTTPS handshake to `api.deepseek.com`
- Client-side rate limit checked before HTTP call (token bucket); request blocked if rate exceeded
- Bearer token injected in `Authorization` header only — never in URL query parameters
- Tool-call JSON from model output validated against UCIC schema; malformed tool calls rejected gracefully

## Postconditions

- AI response is appended to conversation thread
- Session token counter is updated
- UsageRecord is persisted to drift database
- ChatSession.updatedAt is updated

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-005 | Chat List | Entry point — user selects or creates chat |
| PAGE-006 | Chat Conversation | Main flow — message thread, agent selector, task badge, stop button, token counter |
| PAGE-007 | New Chat | Creates blank session |
| PAGE-018 | Model Manager | Provider/model configuration |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| ChatSession | Local DB (drift) | Read (existing) / Create (new) | Session ID and config |
| ChatMessage | Local DB (drift) | Create | User message + AI response |
| AIProvider | Local DB (drift) | Read | API key and base URL for HTTP call |
| UserProfile | Local DB (drift) | Read | Mode, model mappings |
| UsageRecord | Local DB (drift) | Create | Token counts from API response |
| TaskModelMapping | Local DB (drift) | Read | Custom mode per-task model assignment |

## Acceptance Criteria

- [ ] User sends message and sees streaming token-by-token response
- [ ] Task type badge accurately reflects detected intent
- [ ] Session token counter updates in real-time
- [ ] Agent switch preserves conversation history
- [ ] Network timeout shows toast and auto-retries
- [ ] Hard cap blocking shows clear message and reset option

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-001.1 | Stream AI responses token-by-token | SSE streaming implementation |
| FR-001.2 | Support conversation history | ChatMessage list per session |
| FR-001.3 | Allow context injection | Document content appended to system message |
| FR-001.4 | Display typing indicator | Chat header shows animated indicator during generation |
| FR-001.5 | Support stop/cancel | Stop button in chat header |
| FR-001.6 | Surface detected task type | Task type badge |
| FR-001.7 | Show active agent and tools | Agent selector with tool indicator |
| FR-001.8 | Display session token count | Token counter in chat header |
| FR-003.1 | Classify messages into 13 task types | Task Router classification |
| FR-003.2 | Display detected task type as badge | Task type badge |
| FR-003.3 | Route to configured model per task | Model selection per task type in Custom mode |

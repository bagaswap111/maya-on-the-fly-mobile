# System Logic: Chat Streaming Pipeline

**Document:** SoT-4 Logic | **ID:** SL-002 | **Status:** Draft | **Related UC:** UC-001

## Purpose

Handle the real-time streaming of AI chat completion responses from the provider API to the UI, managing SSE parsing, token counting, and error recovery.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| ChatCompletionRequest | Agent Engine | Object | Messages, model, tools, stream=true |
| AIProvider | Drift | Object | Base URL, API key |
| CancelToken | Agent Engine | CancellationToken | Signal to abort request |

## Processing Steps

### Step 1: HTTP Client Setup
1. Create http.Client with 30s timeout
2. Build POST request to `{baseUrl}/chat/completions`
3. Set headers: `Authorization: Bearer {apiKey}`, `Content-Type: application/json`
4. Set body: ChatCompletionRequest JSON with `stream: true`

### Step 2: Send Request
1. Send POST via http.Client.send (not .post — need raw stream)
2. Check initial response status:
   - 200 → proceed
   - 401 → throw ApiKeyException
   - 429 → parse headers, throw RateLimitException
   - 5xx → throw ServerException

### Step 3: Parse SSE Stream
1. Get response stream as ByteStream
2. Transform to LineSplitter
3. For each line:
   - Skip if empty or comment (starts with `: `)
   - Parse `data: {json}` prefix
   - If `data: [DONE]` → emit stream done
   - Parse JSON → extract delta content delta.choices[0].delta.content
   - Extract finish_reason if present
   - Extract usage if present (final chunk)
   - Forward content delta to output stream
   - Check CancelToken → if cancelled, close stream and abort

### Step 4: Handle Finish
1. On finish_reason:
   - `stop` → normal completion
   - `length` → emit truncation warning
   - `content_filter` → emit content filter notice
   - `tool_calls` → hand back to Agent Engine

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Content deltas | Chat UI | Stream<String> | Token-by-token response |
| Finish reason | Agent Engine | Enum | stop / length / content_filter / tool_calls |
| Usage data | Agent Engine | Usage | Tokens used (final chunk only) |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Invalid JSON in SSE | JSON decode exception | Skip malformed chunk, continue streaming |
| Connection reset | SocketException | Retry with backoff (3 attempts) |
| CancelToken triggered | Token.isCancelled | Abort HTTP request, close stream cleanly |

## Flow Diagram (text)

```
User prompt → Build Request → HTTP POST /chat/completions
                                    ↓
                              200? ──no──→ Error Handler
                                    ↓
                                  yes
                                    ↓
                            ByteStream → LineSplit → SSE Parser
                                    ↓
                            ┌──────────────────┐
                            │  for each chunk:  │────→ Emit delta → UI
                            │  check cancel     │
                            │  check done       │
                            └──────────────────┘
                                    ↓
                            Finish Reason → Agent Engine
```


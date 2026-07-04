# System Logic: Usage Tracking Pipeline

**Document:** SoT-4 Logic | **ID:** SL-005 | **Status:** Draft | **Related UC:** UC-006

## Purpose

Track AI API usage across all sessions, enforce hard and soft caps, and provide analytics data for the usage dashboard.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| Usage data | Chat completion response | Usage | Input tokens, output tokens, model |
| ChatSession | Agent Engine | Object | Session ID, agent ID |
| AIProvider | Drift | Object | Provider name, cost per token |
| UserProfile | Drift | Object | Hard cap, soft cap, alert threshold |
| Current period totals | Drift (aggregated) | UsageSummary | Month-to-date usage |

## Processing Steps

### Step 1: Calculate Cost
1. Read token counts from API response:
   - `inputTokens` = usage.prompt_tokens
   - `outputTokens` = usage.completion_tokens
   - `totalTokens` = inputTokens + outputTokens
2. Look up cost per token for the model from AIProvider:
   - `inputCost` = inputTokens × model.inputPricePerToken
   - `outputCost` = outputTokens × model.outputPricePerToken
   - `totalCost` = inputCost + outputCost

### Step 2: Persist UsageRecord
1. Create UsageRecord in drift:
   - `sessionId` → from ChatSession
   - `provider` → provider name
   - `model` → model used
   - `agent` → agent ID
   - `inputTokens`, `outputTokens` → from API
   - `inputCost`, `outputCost` → calculated
   - `createdAt` → DateTime.now()

### Step 3: Check Caps
1. Query aggregated usage for current month:
   - `SELECT SUM(totalTokens), SUM(totalCost) FROM UsageRecord WHERE createdAt >= startOfMonth`
2. Compare against UserProfile caps:
   - Hard cap exceeded → throw `HardCapExceededException`
   - Soft cap exceeded → emit `SoftCapWarningEvent`
   - Alert threshold (e.g., 80%) → emit `UsageAlertEvent`

### Step 4: Emit Events
1. If usage alerts triggered:
   - Emit `UsageUpdateEvent` with current totals → UI updates dashboard
   - If soft cap: show non-blocking notification "You've used {n}% of your monthly cap"
   - If hard cap: return blocking error to caller

### Step 5: Update Session Counter
1. Update in-memory session token counter (for chat header display)
2. The counter shows current session's total tokens

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| UsageRecord | Drift | Record | Persistent usage entry |
| Cap check result | Agent Engine | Enum | OK / SoftWarning / HardBlocked |
| UsageUpdateEvent | UI (analytics) | Event | Dashboard data refresh |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Hard cap exceeded | AggregateQuery > user Cap | Block AI call, show error with "Reset Cap" option |
| Database write failure | Drift InsertException | Retry once, then log to in-memory buffer |
| Negative token count | API response < 0 | Log warning, use 0 instead |

## Flow Diagram (text)

```
API Response arrives → Parse token counts
                              ↓
                    Calculate cost (tokens × price)
                              ↓
                    Persist UsageRecord to drift
                              ↓
                    Query month-to-date totals
                              ↓
                    Check against user caps
                         ├── Under threshold → OK
                         ├── Soft cap hit → Warning notification
                         └── Hard cap hit → Block AI calls
                              ↓
                    Update session token counter
                              ↓
                    Emit UsageUpdateEvent
```

## Related Logic Files

| Logic ID | Name | Relationship |
|----------|------|-------------|
| SL-002 | Chat Streaming | Provides token counts from API response |

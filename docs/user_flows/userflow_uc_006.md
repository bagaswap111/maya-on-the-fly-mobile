# User Flow: Model Configuration & Usage Tracking

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F008, NFR-001 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-006 |
| Name | Model Configuration & Usage Tracking |
| Actor | Any user (power users typically) |
| Goal | Configure AI provider connections, manage Free/Custom mode, map models to task types, set usage caps, and view token usage history |
| Trigger | User opens Model Manager from Settings or Chat header |
| Preconditions | - App is installed- User has API key(s) for at least one provider |

## Main Flow

1. User navigates to Model Manager page
2. System shows provider list with status indicators (configured / missing key / error)
3. User taps a provider (e.g., DeepSeek) to configure
4. System shows provider detail: API key field, base URL, model list
5. User enters API key → System validates key with test request (small chat completion)
6. Validation result: ✅ Active or ❌ Invalid — status indicator updates
7. User returns to provider list → all configured providers shown with "Active" badges
8. **Goal achieved:** AI provider configured and ready for use

## Alternative Flows

### Alt-1: Switch from Free to Custom Mode
**Trigger:** User taps Mode toggle on Model Manager

1. Current mode is Free (one model for all tasks, all agents/skills)
2. User toggles to Custom mode
3. System shows Task Model Mapping table: 13 task types × configured providers
4. Each row shows task type, current model assignment, and "Change" button
5. User taps a task type row
6. System shows model picker: available models from all configured providers
7. User selects model → mapping saved
8. **Outcome:** Custom mode enabled with per-task model routing

### Alt-2: Set Usage Cap
**Trigger:** User taps "Usage Caps" section

1. System shows current cap settings:
   - Monthly token cap: {current} tokens (or unlimited)
   - Monthly cost cap: ${current} (or unlimited)
   - Current period usage: {current} tokens / ${cost}
2. User edits cap value(s)
3. System validates (must be > 0 or "unlimited")
4. Cap saved to UsageAlert database
5. **Outcome:** Usage tracking enforces new caps

### Alt-3: View Usage History
**Trigger:** User taps "Usage History" section

1. System shows usage history list: recent sessions with date, tokens, cost
2. Charts tab: daily usage bar chart for last 30 days
3. Breakdown tab: usage by model, by agent, by conversation
4. User can filter by date range
5. **Outcome:** User sees detailed usage analytics

## Exception Flows

### Exc-1: API Key Validation Failure
**Trigger:** User enters invalid API key format or test request fails

1. If format invalid (not matching expected pattern): inline error on field
2. If test request fails: shows error response body
3. Options: "Edit Key" or "Cancel"
4. **Outcome:** User can correct the key

### Exc-2: DeepSeek Free Tier Exhausted
**Trigger:** Usage tracking shows free tier depleted (5M tokens used)

1. System calculates: used_tokens >= 5,000,000
2. Shows alert: "DeepSeek free tier exhausted. Add a paid API key or switch providers."
3. Links to provider settings
4. **Outcome:** User adds paid key or changes provider

## Postconditions

- AIProvider records are updated in drift
- TaskModelMapping table is updated (if custom mode)
- UsageAlert records are updated
- UsageHistory records reflect any new usage data

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-018 | Model Manager | Main configuration page |
| PAGE-019 | Provider Detail | Per-provider API key and model settings |
| PAGE-020 | Task Model Mapping | Per-task model routing (Custom mode) |
| PAGE-021 | Usage Analytics | Usage history, charts, and breakdowns |
| PAGE-022 | Settings | Entry point and mode toggle |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| AIProvider | Drift | Create/Read/Update | Provider config (key, base URL) |
| TaskModelMapping | Drift | Create/Read/Update | Custom mode routing table |
| UsageAlert | Drift | Create/Read/Update | Cap thresholds |
| UsageHistory | Drift | Read | Aggregated usage data |
| UsageRecord | Drift | Read | Raw session records |

## Acceptance Criteria

- [ ] User can add and validate API key for any provider
- [ ] Toggle between Free and Custom mode takes effect immediately
- [ ] Custom mode allows per-task model assignment
- [ ] Usage caps block AI calls when exceeded (with clear message)
- [ ] Usage history shows accurate daily breakdowns

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-008.1 | Manage multiple AI providers | Provider CRUD + validation |
| FR-008.2 | Free mode: one model for all | Single model for all tasks |
| FR-008.3 | Custom mode: per-task model | TaskModelMapping table |
| FR-008.4 | Override per conversation | Chat-level model selection |
| FR-008.5 | Monthly hard/soft caps | UsageAlert enforcement |
| FR-008.6 | Session token counter | Real-time in chat header |
| FR-008.7 | Usage analytics dashboard | Charts + breakdowns |
| NFR-001.1 | Track input + output tokens | UsageRecord per session |
| NFR-001.2 | Track cost per session | Cost calculation from token counts |
| NFR-001.3 | Export usage data as CSV | Export button in Usage Analytics |

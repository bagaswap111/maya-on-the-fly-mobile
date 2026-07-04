# User Flow: [Use Case Name]

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) | **Status:** Draft | **Last Updated:** [Date]

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-[ID] |
| Name | [Use case name — action-oriented, e.g., "User Login", "Create Sales Transaction"] |
| Actor | [Who performs this — specific role from SRS] |
| Goal | [What the actor wants to achieve — one clear sentence] |
| Trigger | [What event or action starts this use case] |
| Preconditions | [What must be true before this use case can begin] |

## Main Flow

*The "happy path" — the most common, successful scenario.*

1. [Actor action] → [System response]
2. [Actor action] → [System response]
3. [Actor action] → [System response]
4. ...
5. **Goal achieved:** [What success looks like]

## Alternative Flows

*Valid variations of the main flow that still lead to success.*

### Alt-1: [Alternative Name]
**Trigger:** [What causes this alternative path]

1. [Step]
2. [Step]
3. **Outcome:** [Result — still successful]

### Alt-2: [Alternative Name]
**Trigger:** [What causes this alternative path]

1. [Step]
2. **Outcome:** [Result]

## Exception Flows

*Error conditions and failure scenarios.*

### Exc-1: [Exception Name]
**Trigger:** [What error condition occurs]

1. [System detects condition]
2. [System response — error message, fallback, etc.]
3. **Outcome:** [What the user sees/experiences]

### Exc-2: [Exception Name]
**Trigger:** [What error condition occurs]

1. [System response]
2. **Outcome:** [Result]

## Postconditions

*What must be true after this use case completes (success or failure).*

- [Postcondition 1 — e.g., "User session is active"]
- [Postcondition 2 — e.g., "Transaction record is saved to database"]
- [Postcondition 3 — e.g., "Cart is cleared"]

## Related Pages

*Screens or pages involved in this use case. Reference IA (SoT #2).*

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-[ID] | [Name] | [e.g., "Entry point", "Confirmation screen"] |

## Data Used

*What data is created, read, updated, or deleted during this use case.*

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| [Entity name] | [Where it comes from] | Create / Read / Update / Delete | [Any special handling] |
| [Entity name] | [Where it comes from] | Create / Read / Update / Delete | [Any special handling] |

## Acceptance Criteria

*Testable conditions that must be met for this use case to be considered complete.*

- [ ] [Criterion 1 — specific, measurable, testable]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
- [ ] [Criterion 4]
- [ ] [Criterion 5]

## Traceability

*Link back to the SRS requirements this use case satisfies.*

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-[ID].X | [Requirement text from SRS] | [How this flow implements it] |
| FR-[ID].Y | [Requirement text from SRS] | [How this flow implements it] |

# Test Execution Sheet: [Product/Application Name]

**Document:** Execution Tracking | **Derived From:** docs/test_cases.md | **Status:** Draft | **Last Updated:** [Date]

> Records actual execution results against the test cases derived from the Sources of Truth. Failures are diagnosed as Implementation error vs Source-of-Truth error (see Revision Loop in SKILL.md).

## 1. Instructions

- Execute each TC from `docs/test_cases.md` and record the actual result and status.
- **Status values:** PASS / FAIL / N/A (blocked or out-of-scope for this run).
- On FAIL: record actual result, then triage — is the defect in the implementation (fix code) or in a Source of Truth (fix the artifact, re-validate downstream)?
- Keep TC IDs, scenarios, and expected results identical to `docs/test_cases.md`.

## 2. Feature F001: [Feature Name]

### 2.1 UC-001: [Use Case Name]

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F001-001 | [Scenario] | [Steps] | [Expected] | [Actual / blank pre-run] | [PASS/FAIL/N/A] | [e.g., Impl defect — fixed in commit X / SoT defect — UC revised] |
| TC-F001-002 | [Scenario] | [Steps] | [Expected] | [Actual] | [Status] | [Notes] |
| TC-F001-003 | [Scenario] | [Steps] | [Expected] | [Actual] | [Status] | [Notes] |

### 2.2 UC-002: [Use Case Name]

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F001-004 | [Scenario] | [Steps] | [Expected] | [Actual] | [Status] | [Notes] |

## 3. Feature F002: [Feature Name]

### 3.1 UC-004: [Use Case Name]

| TC ID | Test Scenario | Test Steps | Expected Result | Actual Result | Status | Notes |
|-------|---------------|------------|-----------------|---------------|--------|-------|
| TC-F002-001 | [Scenario] | [Steps] | [Expected] | [Actual] | [Status] | [Notes] |

## 4. Execution Summary

| Feature | Total TC | PASS | FAIL | N/A | Pass Rate |
|---------|----------|------|------|-----|-----------|
| F001 | [n] | [n] | [n] | [n] | [%] |
| F002 | [n] | [n] | [n] | [n] | [%] |
| **Total** | [n] | [n] | [n] | [n] | [%] |

### Defect Triage Summary

| TC ID | Suspected Source | Action Taken | Resolved? |
|-------|------------------|--------------|-----------|
| TC-F001-00X | Implementation | [Fixed code in commit X] | Yes / No |
| TC-F001-00X | Source of Truth (UC-00X) | [Revised User Flow → re-validated UCIC + tests] | Yes / No |

## 5. Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | [Date] | [Author] | Initial execution sheet |
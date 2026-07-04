# Test Plan: [Product/Application Name]

**Document:** Test Strategy | **Derived From:** SoT-4 (User Flows) + SoT-7 (UCIC) | **Status:** Draft | **Last Updated:** [Date]

> Test cases are derived from Sources of Truth (User Flows + UCIC), not from code. Tests should exist before implementation begins.

## 1. Introduction

### 1.1 Purpose
[What this test plan governs: scope, strategy, environment, entry/exit criteria for verifying the system against its Sources of Truth.]

### 1.2 Objectives
- [e.g., Verify each use case works per its User Flow]
- [e.g., Verify each endpoint conforms to its UCIC contract]
- [e.g., Verify frontend-backend integration has no mismatches]
- [e.g., Confirm acceptance criteria from User Flows are met]

### 1.3 References
- SRS: docs/srs.md
- User Flows: docs/user_flows/
- UCIC: docs/system_logics/
- Data Model: docs/data_model.md
- Test Cases: docs/test_cases.md
- Test Execution Sheet: docs/test_execution_sheet.md

## 2. Test Scope

### 2.1 In Scope

#### 2.1.1 Test Types Included
- Functional Testing (from User Flows)
- API / Contract Testing (from UCIC)
- Integration Testing (frontend ↔ backend ↔ database)
- User Acceptance Testing (from acceptance criteria)

### 2.2 Out of Scope
- [e.g., Performance/load testing — deferred]
- [e.g., Security penetration testing — separate engagement]

## 3. Test Strategy

### 3.1 Testing Levels

**Level 1 — Component Testing (Unit)**
- [Scope: individual functions/components in isolation]

**Level 2 — Integration Testing**
- [Scope: frontend ↔ API ↔ database wiring per UCIC]

**Level 3 — System Testing**
- [Scope: end-to-end use cases per User Flow]

**Level 4 — User Acceptance Testing (UAT)**
- [Scope: stakeholder validates acceptance criteria]

### 3.2 Testing Approach

**Functional Testing Approach**
- Positive cases: main flow completes, postconditions hold
- Negative cases: invalid input rejected with correct error per UCIC
- Exception cases: error/exception flows behave per User Flow

**Defect Management**
- Defects logged with: TC ID, expected vs actual, severity, suspected source (Implementation vs SoT)
- Source-of-Truth defects trigger the Revision Loop (fix the artifact, not the symptom)

## 4. Test Environment

### 4.1 Hardware Requirements
- [e.g., Developer workstation; no special hardware]

### 4.2 Software Requirements
| Component | Specification |
|-----------|---------------|
| Frontend testing | [e.g., browser matrix, Playwright] |
| Backend & API testing | [e.g., HTTP client, contract test runner] |
| Database | [e.g., PostgreSQL 15] |
| Runtime | [e.g., Node 20] |

### 4.3 Network Requirements
- [e.g., Local / LAN; no external dependencies]

### 4.4 Test Data Requirements
- [e.g., Seed users, products, known transactions]
- [e.g., Reset between runs / idempotent setup]

## 5. Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| [QA / Developer] | Author and execute test cases |
| [Product Owner] | UAT and acceptance sign-off |
| [AI assistant] | Generate test cases from SoT; execute; report |

## 6. Test Schedule

| Phase | Activity | Output |
|-------|----------|--------|
| 1 | Generate test cases from SoT | test_cases.md |
| 2 | Execute against implementation | test_execution_sheet.md |
| 3 | Triage failures (impl vs SoT) | defect log |
| 4 | UAT | acceptance record |

## 7. Entry & Exit Criteria

### 7.1 Entry Criteria
- [ ] Sources of Truth validated (SRS, User Flows, UCIC, Data Model)
- [ ] Test cases generated and reviewed
- [ ] Implementation deployable to test environment

### 7.2 Exit Criteria
- [ ] 100% of in-scope test cases executed
- [ ] All acceptance criteria pass (Acceptance Pass Rate target: 100%)
- [ ] No open Critical/High defects
- [ ] UAT signed off

### 7.3 Suspension Criteria
- [e.g., A blocking defect prevents >50% of cases from executing]
- [e.g., SoT defect discovered requiring artifact revision]

## 8. Test Deliverables
- Test plan (this document)
- Test cases: docs/test_cases.md
- Test execution sheet: docs/test_execution_sheet.md
- Defect log
- Acceptance record

## 9. Risk & Mitigation

| Risk | Mitigation |
|------|------------|
| [e.g., SoT defect found late] | Revision Loop — fix artifact, re-validate downstream |
| [e.g., Test data drift] | Seeded, resettable fixtures |
| [e.g., Flaky integration tests] | Isolate environment; deterministic data |

## 10. Approval

| Name | Role | Date | Signature |
|------|------|------|-----------|
| [Name] | [Product Owner] | [Date] | |

## 11. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial version |
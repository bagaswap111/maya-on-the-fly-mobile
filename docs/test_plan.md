# Test Plan: Maya on the Fly

**Document:** SoT-8 Test Strategy | **Derived From:** SoT-4 (User Flows) + SoT-7 (UCIC) | **Status:** Draft | **Last Updated:** 2026-07-04

> Test cases are derived from Sources of Truth (User Flows + UCIC), not from code. Tests should exist before implementation begins.

## 1. Introduction

### 1.1 Purpose
Verify that Maya on the Fly implements all 10 SRS features correctly per their user flows and acceptance criteria. Covers functional, integration, and contract testing for the Flutter mobile app.

### 1.2 Objectives
- Verify each of the 7 use cases (UC-001–UC-007) works per its User Flow
- Verify each API call conforms to its UCIC contract
- Verify frontend–database integration (drift) has no mismatches
- Confirm all acceptance criteria from user flows are met
- Validate error/exception flows for all failure modes

### 1.3 References
- SRS: ../architecture.md
- User Flows: ./user_flows/
- UCIC: ./ucic_contracts.md
- Data Model: ./data_model_detail.md
- Prototype: ./prototype.md
- Test Cases: ./test_cases.md
- Test Execution Sheet: ./test_execution_sheet.md

## 2. Test Scope

### 2.1 In Scope

#### 2.1.1 Test Types Included
- **Functional Testing** (from User Flows — 7 UCs)
- **API / Contract Testing** (from UCIC — chat completion, streaming, tool calls)
- **Integration Testing** (Flutter ↔ drift database ↔ AI provider HTTP)
- **User Acceptance Testing** (from acceptance criteria in each UC)
- **Usability Verification** (from heuristic evaluation in evaluation_prep.md)
- **Error & Exception Flow Testing** (from Exc flows in each UC)

#### 2.1.2 Features Covered

| Feature ID | Feature Name | Priority | Use Cases |
|------------|--------------|----------|-----------|
| F001 | AI Chat with Streaming | High | UC-001 |
| F002 | Multi-Agent System | High | UC-001, UC-002 |
| F003 | Task Router | High | UC-001 |
| F004 | Agent Loop & Tool Execution | High | UC-002 |
| F005 | Markdown Editor | High | UC-003 |
| F006 | Git Version Control | High | UC-005 |
| F007 | Export Engine | High | UC-004 |
| F008 | Model Manager | Medium | UC-006, UC-007 |
| F009 | Skills System | Medium | UC-002 |
| F010 | Chain of Truth Workflow | Medium | UC-003 (CoT) |

### 2.2 Out of Scope
- Performance / load testing — deferred to post-MVP
- Security penetration testing — separate engagement
- Unit-level widget testing — handled by Flutter test at implementation time
- Third-party cloud service reliability (iCloud, Google Drive API uptime)

## 3. Test Strategy

### 3.1 Testing Levels

**Level 1 — Unit Testing**
- Scope: Individual Dart functions, Riverpod providers, drift DAOs, and utility classes in isolation
- Tool: `flutter test` with `mocktail` for dependencies
- Location: `test/` alongside each feature module

**Level 2 — Integration Testing**
- Scope: Frontend ↔ drift database wiring per UCIC data contracts; frontend ↔ HTTP API (mocked)
- Tool: `flutter test` with in-memory drift (`@Database(inMemory)`) and mocked HTTP client
- Location: `test/integration/`

**Level 3 — System Testing**
- Scope: End-to-end use cases per User Flow (UC-001–UC-007)
- Tool: `flutter_test` with `IntegrationTestWidgetsFlutterBinding` and `patrol` for device-level flows
- Location: `test/e2e/`

**Level 4 — User Acceptance Testing (UAT)**
- Scope: Stakeholder validates acceptance criteria from each UC
- Method: Manual walkthrough of test cases with build artifacts

### 3.2 Testing Approach

**Functional Testing**
- Positive cases: main flow completes, postconditions hold, data persisted
- Negative cases: invalid input rejected with correct error per UCIC contract
- Exception cases: error/exception flows behave per User Flow Exc paths
- Boundary cases: empty documents, maximum-length messages, concurrent operations

**Contract Testing**
- Each HTTP request to AI provider verified against UCIC chat completion schema
- Each drift DAO operation verified against data_model_detail.md table definitions
- Each event (StreamMessage, ToolResult, ErrorEvent) verified against UCIC event contracts

**Defect Management**
- Defects logged with: TC ID, expected vs actual, severity, suspected source (Implementation vs SoT)
- Source-of-Truth defects trigger the Revision Loop: fix the artifact, not the symptom

## 4. Test Environment

### 4.1 Hardware Requirements
- macOS 13+ development workstation
- iOS 16+ simulator / Android API 33+ emulator
- Physical device for biometric and share-sheet testing

### 4.2 Software Requirements

| Component | Specification |
|-----------|---------------|
| Flutter SDK | 3.10.6+ |
| Dart | 3.0.6+ |
| Drift (in-memory) | Test databases |
| Mock HTTP | `mocktail` for HTTP client |
| AI Provider | Mock DeepSeek endpoint |
| Git | git2dart (libgit2 FFI, mocked in unit tests) |

### 4.3 Network Requirements
- Local / LAN for development
- Internet connection required for AI provider contract tests (mocked for unit/integration)

### 4.4 Test Data Requirements
- Seed documents (blank, short, long, with LaTeX, with images)
- Seed chat sessions (empty, with messages, with tool calls)
- Seed git repos (clean, dirty, with conflicts)
- Seed provider configs (valid key, invalid key, expired key)
- Reset database to baseline between test suites

## 5. Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| Developer | Author unit + integration tests; execute during development |
| QA | Author system tests; execute test execution sheet |
| Product Owner | UAT and acceptance sign-off |
| AI Assistant | Generate test cases from SoT; assist with execution |

## 6. Test Schedule

| Phase | Activity | Output |
|-------|----------|--------|
| 1 | Generate test cases from SoT | docs/test_cases.md |
| 2 | Set up Flutter test framework | test/ directory structure |
| 3 | Execute unit + integration tests (dev cycle) | test results |
| 4 | Execute system tests against build | docs/test_execution_sheet.md |
| 5 | Triage failures (impl vs SoT) | defect log |
| 6 | UAT | acceptance record |

## 7. Entry & Exit Criteria

### 7.1 Entry Criteria
- [x] Sources of Truth validated (SRS, User Flows, UCIC, Data Model) — **done**
- [ ] Test cases generated and reviewed — **in progress**
- [ ] Flutter project scaffolded with test directory
- [ ] Mock providers and test utilities created

### 7.2 Exit Criteria
- [ ] 100% of in-scope test cases executed
- [ ] All acceptance criteria pass (target: 100%)
- [ ] No open Critical/High defects
- [ ] UAT signed off

### 7.3 Suspension Criteria
- A blocking defect prevents >50% of cases from executing
- Source of Truth defect discovered requiring artifact revision

## 8. Test Deliverables
- Test plan (this document)
- Test cases: docs/test_cases.md
- Test execution sheet: docs/test_execution_sheet.md
- Flutter test source: test/ directory
- Defect log
- Acceptance record

## 9. Risk & Mitigation

| Risk | Mitigation |
|------|------------|
| SoT defect found late | Revision Loop — fix artifact, re-validate downstream |
| AI provider API changes | Mock HTTP layer; update UCIC contract on API change |
| Test data drift across runs | Seeded, resettable in-memory drift databases |
| Flaky integration tests | Isolate environment; deterministic mock data |

## 10. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-04 | Maya on the Fly | Initial version |
| 1.1 | 2026-07-04 | Maya on the Fly | Fixed architecture.md path, F008 scope (added UC-007), aligned F001 mapping |

# Test Cases: [Product/Application Name]

**Document:** Test Cases | **Derived From:** SoT-4 (User Flows) + SoT-7 (UCIC) | **Status:** Draft | **Last Updated:** [Date]

> Every test case traces to a Use Case (User Flow) and a Feature (SRS). Derive from the SoT — do not reverse-engineer from code.

## 1. Introduction

### 1.1 Purpose
[Provide testable, traceable cases that verify the implementation against the validated Sources of Truth.]

### 1.2 Scope
[Which features and use cases are covered. See the Test Case Index.]

### 1.3 Test Case Format

| Field | Description |
|-------|-------------|
| TC ID | Unique identifier: TC-[feature]-[seq], e.g., TC-F001-001 |
| Related UC | Use Case ID this case exercises (UC-00X) |
| Related Feature | SRS Feature ID (F00X) |
| Test Scenario | One-line description of what is being verified |
| Preconditions | State required before execution |
| Test Data | Specific inputs / seeded data |
| Test Steps | Ordered actions to perform |
| Expected Result | Observable outcome per User Flow / UCIC |
| Type | Positive / Negative / Exception |

## 2. Test Case Index

| TC ID | Feature | Use Case | Scenario | Type |
|-------|---------|----------|----------|------|
| TC-F001-001 | F001 | UC-001 | [Scenario] | Positive |
| TC-F001-002 | F001 | UC-001 | [Scenario] | Negative |
| TC-F001-003 | F001 | UC-001 | [Scenario] | Exception |
| TC-F002-001 | F002 | UC-004 | [Scenario] | Positive |

## 3. Test Cases

### 3.1 Feature F001: [Feature Name]

#### 3.1.1 UC-001: [Use Case Name]

**TC-F001-001: [Test Scenario]**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-001 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | [e.g., Cashier logs in with valid credentials] |
| Type | Positive |
| Preconditions | [e.g., User exists in DB; not logged in] |
| Test Data | [e.g., email: cashier@pos.dev, password: valid123] |
| Test Steps | 1. Navigate to /login  2. Enter email  3. Enter password  4. Click Login |
| Expected Result | [e.g., Redirect to /transaksi; session active] |

**TC-F001-002: [Test Scenario]**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-002 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | [e.g., Login rejected with wrong password] |
| Type | Negative |
| Preconditions | [e.g., User exists; not logged in] |
| Test Data | [e.g., email: valid, password: wrong] |
| Test Steps | [Steps] |
| Expected Result | [e.g., 401 response; "Invalid email or password" shown; password field cleared] |

**TC-F001-003: [Test Scenario]**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-003 |
| Related UC | UC-001 |
| Related Feature | F001 |
| Test Scenario | [e.g., Login when backend unreachable] |
| Type | Exception |
| Preconditions | [e.g., Backend down] |
| Test Data | [Data] |
| Test Steps | [Steps] |
| Expected Result | [e.g., "Connection lost" toast; auto-retry] |

#### 3.1.2 UC-002: [Use Case Name]

**TC-F001-004: [Test Scenario]**

| Field | Value |
|-------|-------|
| TC ID | TC-F001-004 |
| Related UC | UC-002 |
| Related Feature | F001 |
| Test Scenario | [Scenario] |
| Type | Positive |
| Preconditions | [State] |
| Test Data | [Data] |
| Test Steps | [Steps] |
| Expected Result | [Result] |

### 3.2 Feature F002: [Feature Name]

#### 3.2.1 UC-004: [Use Case Name]

**TC-F002-001: [Test Scenario]**

| Field | Value |
|-------|-------|
| TC ID | TC-F002-001 |
| Related UC | UC-004 |
| Related Feature | F002 |
| Test Scenario | [Scenario] |
| Type | Positive |
| Preconditions | [State] |
| Test Data | [Data] |
| Test Steps | [Steps] |
| Expected Result | [Result] |

## 4. Traceability Matrix

### 4.1 Test Case → Requirement

| Feature ID | Feature Name | TC IDs |
|------------|--------------|--------|
| F001 | [Name] | TC-F001-001 … TC-F001-003 |
| F002 | [Name] | TC-F002-001 |

### 4.2 Test Case → Use Case

| Use Case ID | Use Case Name | TC IDs |
|-------------|---------------|--------|
| UC-001 | [Name] | TC-F001-001 … TC-F001-003 |
| UC-002 | [Name] | TC-F001-004 |
| UC-004 | [Name] | TC-F002-001 |

### 4.3 Test Type Summary

| Type | Count |
|------|-------|
| Positive | [n] |
| Negative | [n] |
| Exception | [n] |
| **Total** | [n] |

## 5. Test Execution Notes

### 5.1 Test Environment
| Component | Specification |
|-----------|---------------|
| Browser | [e.g., Chrome 124] |
| Runtime | [e.g., Node 20] |
| Database | [e.g., PostgreSQL 15] |

### 5.2 Test Data Setup
- [e.g., Seed via scripts/seed.ts before each run]
- [e.g., Reset DB to baseline between suites]

### 5.3 Acronyms
| Acronym | Definition |
|---------|------------|
| TC | Test Case |
| UC | Use Case |
| UAT | User Acceptance Testing |

## 6. Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | [Date] | [Author] | Initial version |
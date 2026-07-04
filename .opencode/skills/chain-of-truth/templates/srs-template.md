# SRS: [Product/Application Name]

**Document Version:** v1.0 | **Status:** Draft | **Last Updated:** [Date] | **Author:** [Author]

## 1. Introduction

### 1.1 Purpose
[Why this SRS exists. What decisions it will guide. Who should use it.]

### 1.2 Scope
[What the product covers. What it explicitly does NOT cover.]

**In Scope:**
- [Item 1]
- [Item 2]

**Out of Scope:**
- [Item 1]
- [Item 2]

### 1.3 Stakeholders

| Stakeholder | Role | Involvement |
|-------------|------|-------------|
| [Name/Role] | [e.g., Project Sponsor] | [e.g., Approves final system] |
| [Name/Role] | [e.g., End User] | [e.g., Daily operator] |

### 1.4 Definitions

| Term | Definition |
|------|------------|
| [Term] | [Definition] |

### 1.5 References
- [Related documents, standards, or sources]

## 2. Product Overview

### 2.1 Product Summary
[One paragraph describing what the product is, who it serves, and its core value proposition.]

### 2.2 Business Goals
- [Goal 1 — measurable if possible]
- [Goal 2]

### 2.3 User Types / Roles

| Role | Description | Goals |
|------|-------------|-------|
| [Role name] | [Who they are] | [What they want to accomplish] |

### 2.4 Operating Environment
- **Frontend:** [Framework, browser support]
- **Backend:** [Runtime, framework]
- **Database:** [Type and version]
- **Deployment:** [Cloud/on-premise, platform]
- **Browser Support:** [List browsers and versions]
- **Mobile Support:** [Responsive? Native?]

### 2.5 Assumptions
- [Assumption 1 — things taken as true without proof]
- [Assumption 2]

### 2.6 Constraints
- [Technical constraint 1]
- [Business constraint 1]
- [Regulatory constraint 1]

## 3. System Features

### 3.1 F001: [Feature Name] (Priority: [High/Medium/Low])

**Description:** [What this feature does, in plain language.]

**Functional Requirements:**
- FR-001.1: [Specific, testable requirement]
- FR-001.2: [Specific, testable requirement]
- FR-001.3: [Specific, testable requirement]

**Business Rules:**
- BR-001.1: [Rule that must be enforced]
- BR-001.2: [Rule that must be enforced]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### 3.2 F002: [Feature Name] (Priority: [High/Medium/Low])

**Description:** [What this feature does.]

**Functional Requirements:**
- FR-002.1: [Requirement]
- FR-002.2: [Requirement]

**Business Rules:**
- BR-002.1: [Rule]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### 3.3 F003: [Feature Name] (Priority: [Medium/Low])
...

## 4. Data Requirements

### 4.1 Core Business Objects

| Object | Description | Owner | Lifecycle |
|--------|-------------|-------|-----------|
| [Object] | [What it represents] | [Who owns it] | [How it's created, modified, archived] |

### 4.2 Ownership Rules
- [Who can create, read, update, delete each object]

### 4.3 Data Retention Rules
- [How long each data type is kept]
- [Archiving and deletion policies]

### 4.4 Data Validation Rules
- [Field-level validation rules]
- [Cross-field validation rules]
- [Business-level validation rules]

## 5. External Interfaces

### 5.1 UI Requirements
- [General UI requirements: responsive, accessibility, language, etc.]

### 5.2 External Systems
- [Third-party services, APIs, or systems the product integrates with]

### 5.3 Communication Requirements
- [Protocols, data formats, authentication methods for external communication]

## 6. Non-Functional Requirements

### 6.1 Performance
- [Response time targets, throughput, concurrency]
- Example: "Main page load < 2 seconds"

### 6.2 Security
- [Authentication, authorization, data encryption, session management]
- Example: "Session tokens stored in HttpOnly Cookies"

### 6.3 Availability
- [Uptime targets, maintenance windows]
- Example: "99.5% uptime during operational hours"

### 6.4 Reliability
- [Data durability, fault tolerance, backup requirements]
- Example: "Must retain active cart data during temporary network failures"

### 6.5 Scalability
- [Expected growth, capacity planning]
- Example: "Must handle up to 10,000 transaction records/month"

### 6.6 Maintainability
- [Code standards, documentation requirements, modularity]

### 6.7 Usability
- [Learnability, efficiency, error tolerance]
- Example: "New user training time max 15 minutes"

## 7. Permissions and Access Control

| Role | Create | Read | Update | Delete | Special |
|------|--------|------|--------|--------|---------|
| [Role] | [Objects] | [Objects] | [Objects] | [Objects] | [Notes] |

## 8. Feature Inventory

| Feature ID | Feature Name | Priority | Dependencies | Status |
|------------|--------------|----------|--------------|--------|
| F001 | [Name] | High | None | Planned |
| F002 | [Name] | High | F001 | Planned |
| F003 | [Name] | Medium | F001 | Planned |

## 9. Open Questions

- [Question 1 — what still needs clarification?]
- [Question 2]

## 10. Future Considerations

- [Idea or requirement not yet in scope but likely needed later]
- [Potential expansion direction]

## 11. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial version |

---
name: chain-of-truth
description: >
  Chain of Truth (CoT) workflow for AI-assisted software development.
  Validated artifacts as the Source of Truth (SoT) — not prompts.
  7 phases: SRS → Product Structure (IA + Design System + User Flows) → HiFi Prototype →
  Data Model → UCIC → Implementation → Testing.
  Use when: building a new feature/application with AI, planning a project,
  reducing inconsistency in AI output, structuring requirements,
  or when the user mentions "chain of truth", "CoT", "source of truth", "validated artifacts".
  Reference: PDF (DOI 10.5281/zenodo.20767965) + https://faridsurya-dev.github.io/Vibe-Coding-Research
  Practice repo: https://github.com/faridsurya-dev/vibe_coding_simple_case
---

# Chain of Truth Skill

## Core Philosophy

AI optimizes **context**, not prompts. When context (validated artifacts) is reliable, prompts become simple. When context is unreliable, prompt engineering is endless.

**Prompt → code = fragile.** Requirements scattered across chat, AI interprets differently each session, context lost on new sessions.

**Validated artifact → code = traceable, consistent, reproducible.**

This is a fundamental shift: from prompt-driven development to Source-of-Truth-driven development.

```
Traditional vibe coding:
  Requirement → Prompt → AI → Prompt Revision → AI → More Prompts → AI
  (project knowledge scattered across conversations)

Chain of Truth:
  Requirement → Source of Truth → AI
  (SoT carries knowledge, prompts become execution instructions)
```

## 7 Design Requirements (from the academic paper)

| ID | Requirement |
|----|-------------|
| DR1 | Reduce direct prompt-to-code generation by requiring validated upstream artifacts before downstream generation |
| DR2 | Define staged Sources of Truth that authorize downstream work |
| DR3 | Include human validation before an artifact can become an official Source of Truth |
| DR4 | Support traceability from requirements to user flows, data models, integration contracts, implementation, and tests |
| DR5 | Provide a use-case-level integration contract (UCIC) to align frontend, backend, API behavior, and testing |
| DR6 | Support artifact-level revision when validation or testing reveals a defect |
| DR7 | Support reproducibility by making AI-generated artifacts dependent on explicit and validated context |

## 6 Design Principles (from the academic paper)

1. **Artifact-driven workflow** — development is governed by software artifacts rather than informal prompts
2. **Staged Source of Truth** — an artifact becomes authoritative only after validation
3. **Traceability-by-construction** — trace links are created when artifacts are produced, not recovered after implementation
4. **Human validation gate** — AI supports generation, but humans validate critical artifacts before downstream use
5. **Use-case-level integration contract** — frontend, backend, API, and tests are aligned through UCIC per use case
6. **Revision at artifact level** — downstream failures are traced back to the most appropriate source artifact before revision

## 7 Phases & Source of Truth Chain

```
SRS (SoT #1)
  ↓
IA (SoT #2) + Design System (SoT #3) + User Flows (SoT #4)  [parallel]
  ↓
HiFi Prototype (SoT #5)
  ↓
Data Model (SoT #6)  [from User Flows, NOT directly from SRS]
  ↓
UCIC (SoT #7)  [from User Flows + Data Model]
  ↓
Implementation  [Frontend: HiFi+UCIC, Backend: DataModel+UCIC]
  ↓
Testing  [from User Flows + UCIC, not from code]
```

## Phase Details

### Phase 1: SRS Development → SoT #1

*Reference: [Phase 1 — SRS Development](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-1-srs-development)*

SRS = Software Requirements Specification (IEEE 830 / ISO/IEC/IEEE 29148 standard).

**SRS vs PRD — they are NOT the same:**

| Aspect | PRD | SRS |
|--------|-----|-----|
| Focus | Product | Software System |
| Goal | Explain what to build and why | Explain in detail how system requirements are defined |
| Primary Audience | Product Manager, Business Stakeholder | Developer, Architect, QA, AI Coding Assistant |
| Main Content | Problem, Vision, User Needs, Success Metrics | Functional Requirements, Non-Functional Requirements, Business Rules, Constraints |
| Detail Level | Medium | High |
| Orientation | Business and Product | Engineering and Implementation |

PRD answers: "What product do we want to build and why?"
SRS answers: "What software requirements must be fulfilled to realize that product?"

**The role of SRS in development:**
- **Align understanding** — ensures all stakeholders share the same understanding of product goals, scope, user needs, and features
- **Reduce ambiguity** — turns implicit conversation-based requirements into explicit, documented specifications
- **Serve as development reference** — all downstream artifacts are built upon the validated SRS; AI and developers do not work from assumptions
- **Support traceability** — every User Flow, Data Model, API Contract, implementation, and test case can be traced back to its underlying requirement
- **Control change** — when requirements change, update the SRS first, then propagate changes to other artifacts systematically

**How to build an SRS (6 steps):**

1. **Understand the problem** — gather from: product vision, business goals, stakeholder interviews, user research, existing processes, technical constraints. Focus on: what problem? who are the users? what value? what constraints?

2. **Define scope** — determine: in-scope, out-of-scope, assumptions, constraints. Critical to prevent scope creep from the start.

3. **Identify actors and goals** — for each user type: who are they? what are their goals? what activities do they want to perform? Output: list of user roles and user goals.

4. **Define features** — each feature described as: name, description, functional requirements, business rules. Example: "Feature: Account Registration. Requirements: system must allow account creation, must verify email, must reject duplicate emails."

5. **Define non-functional requirements** — performance, security, availability, scalability, maintainability, usability. NFRs are often the source of problems if not defined from the start.

6. **Review and validate** — SRS is NOT a Source of Truth until validated. Validate for: correctness, completeness, scope alignment, no contradictions, implementability. Once approved by stakeholders → Validated SRS (SoT #1).

**SRS structure** (template: `templates/srs-template.md`):
1. Introduction (purpose, scope, stakeholders, definitions, references)
2. Product Overview (summary, user types, user goals, environment, assumptions, constraints)
3. System Features (Feature ID, Name, Description, Functional Requirements, Business Rules)
4. Data Requirements (core business objects, ownership, retention, validation)
5. External Interfaces (UI, external systems, communication)
6. Non-Functional Requirements (performance, security, availability, reliability, scalability, maintainability, usability)
7. Permissions and Access Control
8. Feature Inventory (list of all features + priority)
9. Open Questions
10. Future Considerations
11. Revision History

### Phase 2: Product Structure → SoT #2, #3, #4

*Reference: [Phase 2 — Product Structure Development](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-2-product-structure-development)*

Three parallel artifacts from the SRS, answering three critical questions:
- **What exists in the product?** → Information Architecture
- **How should the interface look and behave consistently?** → Design System
- **How do users achieve their goals within the system?** → User Flows

**Information Architecture (SoT #2):** Defines the information structure and product navigation. Output: sitemap, menu structure, page hierarchy, feature and module relationships. Answers: "What pages exist in the application?" Template: `templates/information-architecture-template.md`

**Design System (SoT #3):** Defines the visual language and interaction patterns used throughout the application. Output: color palette, typography, spacing system, grid system, UI components, interaction patterns, responsive guidelines. Answers: "How should the application look?" Template: `templates/design-system-template.md`

**User Flows (SoT #4):** Describes the steps users take to achieve a business goal. Each use case documented in a structured manner. Minimum content: Use Case ID, Actor, Goal, Trigger, Preconditions, Main Flow, Alternative Flow, Exception Flow, Postconditions, Related Pages, Acceptance Criteria. Answers: "How should the application behave?"

Template: `templates/user-flow-template.md`

**User Flows are critically important** — they become the main source for building Data Models and Use Case Integration Contracts in subsequent phases. User Flow quality determines the quality of the entire chain.

**Key principle of Phase 2:** The team's focus is not on creating designs or code, but on ensuring the product structure is correct. If the information structure, design patterns, and user flows have been validated, then design, implementation, and testing in subsequent phases can be done more consistently with fewer revisions.

### Phase 3: HiFi Prototype → SoT #5

*Reference: [Phase 3 — High-Fidelity Prototype Development](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-3-high-fidelity-prototype-development)*

From IA + Design System + User Flows. **No markdown template** — the HiFi Prototype is a build artifact (clickable/navigable UI), not a document. Build it directly in your prototype tool of choice, validated against IA + Design System + User Flows. The product concept begins to be realized into a visual representation that resembles the actual application.

**What is built:** page layout, page navigation, form inputs, UI components, state and system feedback, form validation, error messages, responsive behavior, user interactions.

**Why a prototype is important:** Many product errors originate not from code, but from incorrect process design and user experience. If problems are only discovered after implementation, the cost of fixing them is much higher. A HiFi Prototype allows the team to: validate user needs, validate business flows, test usability, get stakeholder feedback, reduce revisions during implementation.

**Prototype validation questions:**
- Are the user flows correct?
- Is the navigation easy to understand?
- Is the information displayed correctly?
- Are all acceptance criteria accommodated?
- Are there any unnecessary or confusing steps?

If problems are found → revise the User Flow first, then update the prototype. This maintains consistency between artifacts.

### Phase 4: Data Model → SoT #6

*Reference: [Phase 4 — Data Model Development](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-4-data-model-development)*

From User Flows (**NOT** directly from SRS). The user flow shows how data is created, read, updated, validated, and used in real business processes.

**Why after User Flow?** Traditional approaches often start design from the database first → data structures that do not truly reflect business processes. Chain of Truth uses the opposite approach: data is shaped based on process needs, not processes being forced to follow the database structure.

```
User Flow → Data Model
```

**What is built:** domain entities, business objects, attributes and data types, entity relationships, cardinality, validation rules, business constraints, lifecycle or state transitions, persistence requirements.

**Example:** If a User Flow has "User creates an order → System saves the order → User makes a payment → Order changes to Paid" → entities: User, Order, Payment, with their relationships and business rules.

**Validation:** can all User Flows be supported? any missing entities? are entity relationships correct? are business rules accommodated? is the data structure flexible enough?

**Output:** Validated Data Model (SoT #6). Used for: database design, backend implementation, API design, validation rules, business logic, integration contracts (UCIC). Template: `templates/data-model-template.md`

### Phase 5: UCIC → SoT #7

*Reference: [Phase 5 — UCIC Development](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-5-use-case-integration-contract-ucic-development)*

Use Case Integration Contract = an implementation contract at the use case level. Input: User Flows + Data Model. One UCIC per use case.

**Why UCIC is important:** In many projects, problems do not arise because of incorrect requirements, but because frontend and backend have different interpretations of the same requirement. The frontend expects a certain data format, while the backend returns a different format. UCIC eliminates these assumptions BEFORE implementation.

```
User Flow + Data Model → UCIC
```

If User Flow explains **what the user does**, and Data Model explains **what data the system uses**, then UCIC explains **how frontend, backend, API, and database work together to realize that use case.**

**Minimum UCIC content** (template: `templates/ucic-template.md`):
- Use Case Reference (ID, name, actor, related user flow)
- Related Screens (pages involved)
- Related Entities (data entities involved)
- Sequence Diagram (user → frontend → API → backend → database)
- API Contract (endpoint, HTTP method, auth, request payload, response payload, status codes)
- Data Mapping (UI fields ↔ request payload ↔ domain entities ↔ response payload)
- Validation Rules (required fields, formats, allowed values, business validations)
- Error Handling (expected error conditions & response behavior)

**Example — UC-001 Login:**
- User Flow: User enters email/password → System verifies → System returns token → User enters dashboard
- UCIC defines: Endpoint `POST /auth/login`, Request Body, Response Body, Error Response, Input Validation, Sequence Diagram, Mapping to User entity

**Without UCIC, problems emerge:** endpoints don't match UI needs, payload differs from expectations, status codes are inconsistent, error handling differs, integration issues discovered late.

**UCIC validation:** supports all steps in User Flow? uses correct Data Model? API Contract complete? Data Mapping clear? Error Handling defined? Frontend and backend have the same understanding?

### Phase 6: Implementation

*Reference: [Phase 6 — Implementation](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-6-implementation)*

Transforms all Sources of Truth into running software.

**Frontend:** from HiFi Prototype (SoT #5) + UCIC (SoT #7). Implements: pages and navigation, UI components, forms and validation, state management, API integration, error handling, user interactions.

**Backend:** from Data Model (SoT #6) + UCIC (SoT #7). Implements: business logic, database schema, API endpoints, authentication and authorization, validation rules, data processing, error responses.

**Integration:** from UCIC. Because frontend and backend use the same reference, risks of endpoint mismatch, payload mismatch, inconsistent status codes, and unsynchronized error handling are significantly reduced.

**AI's role:** AI can generate frontend code, backend code, database schema, API implementation, unit tests, code review, refactoring, technical documentation — but MUST use validated SoTs as context. AI does not generate code based on free prompts.

**If new requirements are discovered during implementation:** do NOT patch code directly. Trace the related source artifacts, fix them, re-validate, then update the implementation. This keeps code aligned with Sources of Truth and prevents undocumented changes.

### Phase 7: Testing → Release Candidate

*Reference: [Phase 7 — Testing and Validation](https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-7-testing-and-validation)*

Test cases are derived from Sources of Truth, not from code alone.

| Source of Truth | Used For |
|-----------------|----------|
| User Flows (SoT #4) | Functional Testing, User Journey Testing, Acceptance Testing |
| UCIC (SoT #7) | API Testing, Contract Testing, Integration Testing |
| HiFi Prototype (SoT #5) | UI Validation and User Acceptance Review |

**Types of testing:**
- **Functional Testing** — ensures each use case works according to User Flow (e.g., login succeeds, creating an order succeeds, canceling a transaction succeeds)
- **API Testing** — ensures endpoints work according to the contract defined in UCIC (e.g., request payload valid, response payload matches specification, status code correct, error response follows contract)
- **Integration Testing** — ensures frontend and backend can work together without integration issues (e.g., frontend form sends correct data, backend returns appropriate response, data stored correctly in database)
- **Acceptance Testing** — ensures the system meets acceptance criteria established in User Flows; usually performed by stakeholders or product owner

**When testing fails — diagnose the source:**

```
If Implementation is Wrong:
  Requirement correct → User Flow correct → UCIC correct → Implementation wrong
  → Fix the code

If Source of Truth is Wrong:
  Requirement correct → User Flow incomplete → UCIC becomes wrong → Implementation follows UCIC
  → Fix the User Flow, then update and re-validate derivative artifacts
```

**Output:** Validated System, Release Candidate, Test Results, Validation Records. Templates: `templates/test-plan-template.md`, `templates/test-cases-template.md`, `templates/test-execution-sheet-template.md`

## Revision Loop (Critical!)

Principle: **Fix the artifact that caused the defect, not just the symptom.**

```
Test fail
  ↓
Diagnose: implementation error or SoT error?
  ↓
Implementation error → fix code
SoT error:
  SRS wrong → revise SRS → revalidate downstream
  User Flow wrong → revise User Flow → update Data Model + UCIC + tests
  Data Model insufficient → revise Data Model → update UCIC + backend
  UCIC incomplete → revise UCIC → update frontend + backend + tests
```

## Traceability

**Minimum traceability paths:**
```
Requirement → User Flow → Data Model → UCIC → API → Test Case
Requirement → User Flow → HiFi Prototype → Frontend Component → UI Test
```

**Traceability relationships:**
- SRS → IA, SRS → Design System, SRS → User Flow
- User Flow → HiFi Prototype, User Flow → Data Model
- User Flow + Data Model → UCIC
- HiFi Prototype + UCIC → Frontend Implementation
- Data Model + UCIC → Backend Implementation
- User Flow + UCIC → Test Case

**Consistent IDs across:** requirements, use cases, screens, entities, UCICs. Use patterns like UC-001, FR-001, ENT-001, PAGE-001 for full traceability.

## Evaluation Metrics (from the academic paper)

| Construct | Metric | Definition |
|-----------|--------|------------|
| Requirement quality | Requirement Quality Score | Average expert rating for clarity, completeness, atomicity, verifiability |
| Forward traceability | Forward Trace Coverage | Percentage of requirements linked to design, implementation, and tests |
| Backward traceability | Backward Trace Resolution | Percentage of implementation and test artifacts traceable to requirements |
| Reproducibility | Session Reproducibility Index | Percentage of AI sessions with model, prompt, context, and artifact references recorded |
| Integration quality | Integration Mismatch Count | Number of frontend-backend mismatches per use case |
| Implementation quality | Acceptance Pass Rate | Percentage of acceptance criteria passed |
| Human effort | Verification Burden Score | Perceived effort required to verify AI outputs |
| Post-release quality | Escaped Defect Rate | Defects found after merge, release, or user validation |

## Risks and Limitations

- **Documentation overhead** — may be too heavy for very small projects
- **Superficial validation** — risk if validation becomes a formality; human participation must be substantive
- **User flow quality dependence** — poor user flows can propagate errors across the entire chain
- **Template and tool support** — requires templates, consistent IDs, and tool support to avoid burdensome artifact management
- **No completed empirical evidence yet** — the paper presents a conceptual workflow artifact and evaluation agenda, not completed empirical study

## Practical Implementation (Practice Case #1)

**Repo:** https://github.com/faridsurya-dev/vibe_coding_simple_case

**Application:** Web-Based Point of Sale (POS). Domain: Retail. User Role: Cashier.
**Features:** Login, Product browsing, Cart management, Checkout, Receipt printing, Add product, Stock monitoring, Daily sales report, Monthly sales report.
**IDE:** OpenCode | **Models:** Bigpickle, DeepSeek V4 Flash | **Strategy:** Single session

**Source of Truth artifacts used during implementation** (not SRS directly — only operational artifacts):
1. Information Architecture — pages, navigation hierarchy, routing structure
2. Design System — visual language, components, layout rules
3. User Flows — user interactions, main/alternative/exception flows
4. UCIC (System Logics) — system behavior, interaction contracts, application logic, API expectations

**Only 3 prompts for full implementation:**
```
Prompt 1: "Create a blank starter app using latest nextjs in 'pos_simple_[model_name]' folder."
Prompt 2: "Based on @docs/design_system.md and @docs/information_architecture.md, create the application's pages and navigations structure."
Prompt 3: "Implement the application's functionality in detail based on docs/user_flows/* and docs/system_logics/*, using dummy API calls where needed."
```

Notice what is missing from the prompts: no business requirements, no feature descriptions, no validation rules, no UI specifications, no application logic. Those details already exist inside the Source of Truth. The prompts merely instruct the AI to execute.

**Results:** 30 test cases, 100% passing frontend, 0 failures. Human intervention only for technical issues (file generation failures, temporary model access issues, connectivity interruptions). No additional prompts needed to explain features, business rules, workflows, or validation requirements.

**The same SoT was used across 4 different model implementations** (Bigpickle, Mimo V2.5, Nemotron, North Minicode) — demonstrating model interchangeability.

**3 Key Findings:**
1. **The biggest benefit was consistency, not speed.** Before CoT: requirements lived in conversations, context drift occurred frequently, feature implementations became inconsistent. After CoT: requirements lived in artifacts, implementation became traceable, context remained stable, AI behavior became more predictable.
2. **Prompts became smaller.** The real achievement was moving project knowledge out of prompts and into artifacts. Prompts became shorter, sessions became reproducible, models became interchangeable.
3. **Validation became objective.** Without SoT: "Does the application look correct?" (subjective). With SoT: "Does the implementation satisfy the test cases?" (objective).

## How to Use This Skill

### When starting a new project/feature:

**CRITICAL — Step 0: Generate ALL documentation first.** This is the most important step that is often skipped. After understanding the requirements, GENERATE ALL ARTIFACT DOCUMENTS completely:

```
docs/
  srs.md                        ← SoT #1
  information_architecture.md   ← SoT #2
  design_system.md              ← SoT #3
  user_flows/
    index.md                    ← registry: catalog (UC ID, name, file path, status),
    │                              requirement→user-flow mapping, page→user-flow mapping,
    │                              dependencies, revision history
    userflow_uc_001.md          ← SoT #4 (one file per use case)
    userflow_uc_002.md
    userflow_uc_003.md
    ...
  data_model.md                 ← SoT #6
  system_logics/                ← SoT #7 (UCIC, one per use case)
    index.md                    ← registry: catalog (UC ID, name, file path, status),
    │                              user-flow→system-logic mapping, API overview
    │                              (base URL, auth, common response format, status codes),
    │                              revision history
    sys_uc_001.md
    sys_uc_002.md
    sys_uc_003.md
    ...
  prompts.txt                   ← record of prompts used (execution instructions only)
  test_plan.md                  ← Testing strategy
  test_cases.md                 ← Derived from User Flows + UCIC
  test_execution_sheet.md       ← Execution tracking
```

**File naming convention (matches the practice repo):**
- User Flow: `userflow_uc_NNN.md` (e.g. `userflow_uc_001.md`)
- System Logic / UCIC: `sys_uc_NNN.md` (e.g. `sys_uc_001.md`)
- Registry: `index.md` in each subfolder, linking every UC to its file via relative path (e.g. `./userflow_uc_001.md`, `./sys_uc_001.md`)

**`index.md` registry sections** (one per subfolder, follow the practice repo exactly):
- User Flows `index.md`: Purpose → File Structure → User Flow Catalog (table: Use Case ID, Use Case Name, File Path, Status) → Requirement→User Flow Mapping → Page→User Flow Mapping → User Flow Dependencies → Revision History
- System Logics `index.md`: Purpose → File Structure → System Logic Catalog (table: Use Case ID, Use Case Name, File Path, Status) → User Flow→System Logic Mapping → API Overview (base URL, auth, common response format, HTTP status codes) → Revision History

**Documentation generation instructions:**

1. **Create the SRS first** (use `templates/srs-template.md`) — generate COMPLETELY, no placeholders. Every section must be filled with real content. The SRS must be detailed enough that an AI can read it and understand exactly what to build without asking questions.

2. **Validate the SRS** with stakeholders before proceeding.

3. **From the SRS, generate IA + Design System + User Flows** (use `templates/user-flow-template.md`) — generate COMPLETELY for every use case. Each User Flow must have: full main flow steps, at least 1-2 alternative flows, at least 1-2 exception flows, concrete acceptance criteria, data used table, traceability back to SRS requirements.

4. **Validate each artifact** before proceeding.

5. **Build the HiFi Prototype** (if the project has a UI) — from IA + Design System + User Flows.

6. **From User Flows, generate the Data Model** — COMPLETE with: all entities, all attributes with types, relationships with cardinality, validation rules, business constraints, SQL DDL if applicable, traceability back to User Flows.

7. **From User Flows + Data Model, generate UCIC per use case** (use `templates/ucic-template.md`) — COMPLETE with: sequence diagram, full API contract (endpoint, method, auth, request/response payloads, all status codes), data mapping table, validation rules table, error handling table.

8. **Generate test artifacts** — test plan, test cases (derived from User Flows + UCIC), test execution sheet.

9. **Implement** with minimal prompts — reference the docs, don't describe features. The prompts should only instruct execution, not contain requirements.

10. **Test** from the SoT — test cases should already exist before implementation begins.

**Generation principles:**
- Every document must be COMPLETE and SELF-CONTAINED. No "TODO", "will be filled later", or placeholders.
- An AI should be able to read any document and immediately implement without asking follow-up questions.
- Every use case MUST have both a User Flow and a UCIC.
- Consistent IDs across all documents (UC-001, FR-001, ENT-001, PAGE-001).
- Every artifact must include traceability references back to its source artifact.

### When revising:
- Do NOT patch code directly
- Trace back to the source artifact
- Revise the artifact, re-validate, then update downstream

## Pitfalls

- **Do NOT skip phases.** Each phase has dependencies. The Data Model comes from User Flows, not from the SRS.
- **Do NOT validate superficially.** Validation must be substantive, not a formality. Human participation is essential.
- **User Flow quality is critical.** A bad user flow = errors propagate across the entire chain. Invest time here.
- **Do NOT patch code when implementation fails.** Trace back to the source artifact. Fix the artifact, not just the symptom.
- **Consistent IDs.** Use UC-001, FR-001, ENT-001, PAGE-001, etc. for full traceability.
- **Do NOT generate half-finished documentation.** Every SoT document must be COMPLETE. Incomplete documents = unreliable context = endless prompt engineering.
- **Undocumented artifacts = features that will be inconsistent.** Every use case MUST have both a User Flow and a UCIC.
- **The SRS is NOT optional.** Skipping the SRS means skipping the foundation. All downstream artifacts lose their traceability anchor.

## References

- Paper: DOI 10.5281/zenodo.20767965 (Farid Suryanto & Muhammad Ibnu Athoillah, Universitas Ahmad Dahlan)
- Web documentation: https://faridsurya-dev.github.io/Vibe-Coding-Research
- Practice repo: https://github.com/faridsurya-dev/vibe_coding_simple_case
- Support the research: https://saweria.co/faridsurya

### Reference Documentation (English)

**Concept:**
- What is Chain of Truth: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/what-is-chain-of-truth
- Phase 1 — SRS Development: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-1-srs-development
- Phase 2 — Product Structure Development: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-2-product-structure-development
- Phase 3 — High-Fidelity Prototype Development: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-3-high-fidelity-prototype-development
- Phase 4 — Data Model Development: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-4-data-model-development
- Phase 5 — UCIC Development: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-5-use-case-integration-contract-ucic-development
- Phase 6 — Implementation: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-6-implementation
- Phase 7 — Testing and Validation: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/1-concept/phase-7-testing-and-validation

**Implementation:**
- Simple Case Experiment: https://faridsurya-dev.github.io/Vibe-Coding-Research/en/2-implementation/simple-case-experiment

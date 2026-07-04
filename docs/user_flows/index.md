# User Flows — Index

## Purpose

This directory contains all user flow definitions for Maya on the Fly. Each flow is derived from the SRS (architecture.md) and defines step-by-step interactions between the user and the system for a specific use case.

## File Structure

```
docs/user_flows/
  index.md                ← This file — registry
  userflow_uc_001.md      ← UC-001: AI Chat Completion
  userflow_uc_002.md      ← UC-002: Agent Loop with Tool Execution
  userflow_uc_003.md      ← UC-003: Document Management
  userflow_uc_004.md      ← UC-004: Document Export
  userflow_uc_005.md      ← UC-005: Git Operations
  userflow_uc_006.md      ← UC-006: Model Configuration & Usage Tracking
  userflow_uc_007.md      ← UC-007: Settings & Profile Management
```

## User Flow Catalog

| Use Case ID | Use Case Name | File Path | Status |
|-------------|---------------|-----------|--------|
| UC-001 | AI Chat Completion | ./userflow_uc_001.md | Draft |
| UC-002 | Agent Loop with Tool Execution | ./userflow_uc_002.md | Draft |
| UC-003 | Document Management | ./userflow_uc_003.md | Draft |
| UC-004 | Document Export | ./userflow_uc_004.md | Draft |
| UC-005 | Git Operations | ./userflow_uc_005.md | Draft |
| UC-006 | Model Configuration & Usage Tracking | ./userflow_uc_006.md | Draft |
| UC-007 | Settings & Profile Management | ./userflow_uc_007.md | Draft |

## Requirement → User Flow Mapping

| SRS Requirement | User Flow |
|-----------------|-----------|
| F001 (AI Chat with Streaming) | UC-001 |
| F002 (Multi-Agent System) | UC-001, UC-002 |
| F003 (Task Router) | UC-001 |
| F004 (Agent Loop & Tool Execution) | UC-002 |
| F005 (Markdown Editor) | UC-003 |
| F006 (Git Version Control) | UC-005 |
| F007 (Export Engine) | UC-004 |
| F008 (Model Manager) | UC-006, UC-007 |
| F009 (Skills System) | UC-002 |
| F010 (CoT Workflow Integration) | UC-003 |

## Page → User Flow Mapping

| Page | User Flows |
|------|------------|
| PAGE-001 (Home) | UC-003, UC-005 |
| PAGE-002 (Document Editor) | UC-003 |
| PAGE-006 (Chat Conversation) | UC-001, UC-002 |
| PAGE-008 (Git Repo List) | UC-005 |
| PAGE-013 (Export) | UC-004 |
| PAGE-018 (Model Manager) | UC-006, UC-007 |

## User Flow Dependencies

| Use Case | Depends On |
|----------|------------|
| UC-001 | None |
| UC-002 | UC-001 |
| UC-003 | None |
| UC-004 | UC-003 |
| UC-005 | None |
| UC-006 | UC-001 |
| UC-007 | UC-006 |

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-04 | Maya Team | Initial version |

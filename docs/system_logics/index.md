# System Logics — Index

## Purpose

This directory contains system-level logic definitions for Maya on the Fly — the backend processing sequences that power the user flows. Each system logic document describes a specific processing pipeline in terms of inputs, outputs, data flow, and error handling.

## File Structure

```
docs/system_logics/
  index.md                      ← This file — registry
  logic_agent_engine.md         ← Agent Engine loop (tool calling, skill execution)
  logic_chat_stream.md          ← Chat completion streaming pipeline
  logic_document_autosave.md    ← Document auto-save + versioning pipeline
  logic_export_pipeline.md      ← Export conversion pipeline (Isolate-based)
  logic_usage_tracking.md       ← Usage tracking + cap enforcement pipeline
  logic_task_router.md          ← Task classification + model routing pipeline
  logic_git_operations.md       ← Git operation pipeline (git2dart)
```

## Logic Catalog

| ID | Name | File Path | Status | Related UC |
|----|------|-----------|--------|------------|
| SL-001 | Agent Engine Loop | ./logic_agent_engine.md | Draft | UC-002 |
| SL-002 | Chat Streaming Pipeline | ./logic_chat_stream.md | Draft | UC-001 |
| SL-003 | Document Auto-Save Pipeline | ./logic_document_autosave.md | Draft | UC-003 |
| SL-004 | Export Pipeline | ./logic_export_pipeline.md | Draft | UC-004 |
| SL-005 | Usage Tracking Pipeline | ./logic_usage_tracking.md | Draft | UC-006 |
| SL-006 | Task Router Pipeline | ./logic_task_router.md | Draft | UC-001 |
| SL-007 | Git Operation Pipeline | ./logic_git_operations.md | Draft | UC-005 |

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-04 | Maya Team | Initial version |

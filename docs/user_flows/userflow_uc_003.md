# User Flow: Document Management

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F005, F010 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-003 |
| Name | Document Management |
| Actor | Any user |
| Goal | Create, edit, preview, save, and manage Markdown documents with auto-save and version snapshots |
| Trigger | User opens document from home screen or creates a new one |
| Preconditions | - App is installed- App sandbox storage is available |

## Main Flow

1. User opens app → Home screen shows recent documents list (last 20, sorted by last-modified)
2. User taps a recent document or taps "New Document" quick action
3. Editor page opens with document content loaded
4. User edits Markdown content in super_editor text area
5. System auto-saves content to local storage every 5 seconds
6. User can toggle preview pane (overlay on phone, side-by-side on tablet)
7. User can toggle between edit and preview modes
8. LaTeX math renders correctly in preview ($...$ inline, $$...$$ block)
9. **Goal achieved:** Document is edited, auto-saved, and ready for export or further editing

## Alternative Flows

### Alt-1: New Document from Chat
**Trigger:** User taps "New Doc" from within chat context

1. Chat session has an associated context document or generates content
2. User taps "Create Document from Chat" action
3. System creates new document with chat transcript or generated content as starting text
4. Editor opens with the new document
5. **Outcome:** Document created from AI chat content

### Alt-2: Revert to Previous Version
**Trigger:** User wants to undo auto-saved changes

1. User opens document menu → taps "Version History"
2. System shows list of auto-saved snapshots from DocumentVersion table
3. User selects a previous version
4. System shows confirmation dialog: "You have unsaved changes. Discard them?"
5. User taps "Discard" → System restores selected version content
6. User taps "Cancel" → No changes made
7. **Outcome:** Document reverted to selected snapshot

### Alt-3: Pin Document
**Trigger:** User wants to keep document at top of recent list

1. User long-presses document in recent list or opens document menu
2. Taps "Pin to Top"
3. Document.isPinned set to true
4. Document appears at top of recent list regardless of last-opened time
5. **Outcome:** Important documents stay accessible

## Exception Flows

### Exc-1: Storage Full
**Trigger:** Device storage is full when auto-save triggers

1. System catches file write exception
2. Shows warning toast: "Storage almost full. Document may not save."
3. Auto-save retries every 30 seconds instead of 5
4. **Outcome:** User is warned; app continues trying to save

### Exc-2: Document Deleted Externally
**Trigger:** Document file removed from sandbox by external process or user

1. System detects file missing when trying to open
2. Shows error state: "Document not found. It may have been deleted."
3. Offers option to remove from recent list or recreate
4. **Outcome:** User can clean up the reference

## Postconditions

- Document content is persisted to file system
- Document.updatedAt is updated
- Recent documents list refreshes with new ordering
- If in git repo: file is auto-staged (git add)

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-001 | Home | Recent documents list entry point |
| PAGE-002 | Document Editor | Main editing surface |
| PAGE-003 | New Document | Create blank document |
| PAGE-004 | Full Preview | Full-screen preview mode |
| PAGE-006 | Chat Conversation | Context source for Alt-1 |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| Document | File system + drift | Create/Read/Update | Content + metadata |
| DocumentVersion | Drift | Create | Auto-save snapshots every 5s |
| Repository | Drift | Read | Git association for auto-stage |

## Acceptance Criteria

- [ ] User can create, edit, and preview a Markdown document
- [ ] Auto-save persists content within 5 seconds of change
- [ ] LaTeX equations render in preview
- [ ] Recent documents list shows accurate timestamps and previews
- [ ] Discard confirmation prevents accidental data loss
- [ ] Version history shows auto-save snapshots
- [ ] Pin to top works across app restarts

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-005.1 | Provide rich-text Markdown editing | super_editor integration |
| FR-005.2 | Render live preview | flutter_markdown preview pane |
| FR-005.3 | Support LaTeX math rendering | flutter_markdown with LaTeX extension |
| FR-005.4 | Auto-save every 5 seconds | Timer-based auto-save |
| FR-005.5 | Side-by-side on tablet | LayoutBuilder split view |
| FR-005.6 | Toggleable preview on phone | Overlay panel |
| FR-005.7 | Discard confirmation | Confirmation dialog on revert |
| FR-005.8 | Recent documents list | Home screen document list |
| FR-005.9 | iPad keyboard shortcuts | Keyboard listener |
| FR-010.1 | Include CoT templates | Template browser in CoT Studio |
| FR-010.2 | Support artifact creation | Editor used for all document types |

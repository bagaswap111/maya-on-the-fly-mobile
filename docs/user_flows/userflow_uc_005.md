# User Flow: Git Operations

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F006 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-005 |
| Name | Git Operations |
| Actor | Programmer user |
| Goal | Perform Git version control operations on documents (init, stage, commit, diff, log, push, pull) using git2dart library |
| Trigger | User opens Git panel from editor or home screen |
| Preconditions | - App storage is accessible- git2dart library is initialized |

## Main Flow

1. User taps Git button → Git panel opens showing current repo status
2. System scans working directory for .git
3. If repo exists: show status — modified files, staged files, branch name, unpushed commits
4. System lists modified files with diff preview
5. User can tap individual files to view diff (side-by-side or unified)
6. User selects files to stage (checkbox per file)
7. User enters commit message in text field
8. User taps Commit button
9. System shows commit confirmation with file list + summary
10. User confirms → System executes commit via git2dart
11. Success toast: "Committed 1 file — {commit_message_short}"
12. **Goal achieved:** Changes committed to local Git repository

## Alternative Flows

### Alt-1: Initialize New Repo
**Trigger:** User taps "Init Repo" when no .git found

1. System shows confirmation: "Initialize a git repo in this directory?"
2. User confirms
3. System runs git2dart init
4. Success: Shows "Git repo initialized" with empty status
5. **Outcome:** Ready for version control

### Alt-2: Push to Remote
**Trigger:** User taps Push button after committing

1. System checks for remote "origin" URL
2. If no remote: shows "No remote configured. Add a remote URL?"
3. User enters remote URL → remote added
4. System shows push confirmation: branch + commit count
5. User confirms
6. System pushes via git2dart with credential callback
7. During push: progress indicator with "Pushing {n} commits..."
8. **Outcome:** Changes pushed to remote

### Alt-3: Pull from Remote
**Trigger:** User taps Pull button

1. System checks for remote "origin"
2. If remote exists: shows "Repository behind by {n} commits" (if known)
3. User taps Pull
4. During pull: progress indicator
5. **Outcome:** Local repo updated from remote

## Exception Flows

### Exc-1: Merge Conflict
**Trigger:** Pull results in merge conflicts

1. System detects conflict files from git2dart index
2. Shows conflict resolution screen listing conflicted files
3. Each file shows "ours" vs "theirs" diff
4. User selects resolution per file: Accept Ours, Accept Theirs, or Edit Manually
5. For manual edit: opens editor with conflict markers
6. After resolution: user marks conflict resolved
7. Commit merge
8. **Outcome:** Merge completed with user's resolution choices

### Exc-2: Authentication Failure
**Trigger:** Push or pull fails with credentials error

1. System receives auth failure from git2dart
2. Shows dialog: "Authentication required for {remote_url}"
3. Options: Enter Personal Access Token, Enter SSH Key Path (file picker), Cancel
4. After credential entry: retries operation
5. **Outcome:** Operation completes with valid credentials or cancelled

## Postconditions

- Git operations are recorded in local log
- Editor reflects any file state changes after operation
- Repo status panel refreshes

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-008 | Git Repo List | Repository list and status |
| PAGE-009 | Git Repo Detail | Per-repo status, branch, log |
| PAGE-010 | Git Commit | Commit creation with file staging |
| PAGE-011 | Git Diff | Diff viewer per file |
| PAGE-012 | Git Log | Commit history viewer |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| Repository | Drift | Create/Read/Update | Repo metadata |
| Git repo (working dir) | git2dart | Read/Write | All git operations |

## Acceptance Criteria

- [ ] User can init a new repo
- [ ] User can stage, commit, view diff, and view log
- [ ] User can push to and pull from remote
- [ ] Merge conflicts show resolution options
- [ ] Auth failure shows credential entry dialog
- [ ] Progress indicator shown during network operations

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-006.1 | Initialize new git repos | git2dart init |
| FR-006.2 | Stage, commit, branch, diff | Core git operations |
| FR-006.3 | Push and pull | Remote operations |
| FR-006.4 | Visual diff viewer | File-by-file diff display |
| FR-006.5 | Auto-stage on auto-save | Auto stage when repo active |
| FR-006.6 | Merge conflict resolution | Conflict resolution UI |
| FR-006.7 | Commit log viewer | Commit history display |

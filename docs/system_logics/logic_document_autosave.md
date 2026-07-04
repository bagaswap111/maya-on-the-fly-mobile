# System Logic: Document Auto-Save Pipeline

**Document:** SoT-4 Logic | **ID:** SL-003 | **Status:** Draft | **Related UC:** UC-003

## Purpose

Automatically persist document content to local storage at regular intervals and create version snapshots for recovery.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| Document | Editor Controller | Object | Current document ID, content, title |
| Timer tick | Timer (5s interval) | Event | Triggered every 5 seconds |
| Change flag | Editor Controller | Boolean | True when content has changed since last save |
| Repository (optional) | Drift | Object | Associated git repo for auto-stage |

## Processing Steps

### Step 1: Timer Tick
1. Timer fires every 5 seconds
2. Check `hasUnsavedChanges` flag
3. If false → skip (no work needed)
4. If true → proceed

### Step 2: Save to File System
1. Write Document.content to `{appDocDir}/documents/{documentId}.md`
2. Use dart:io `File.writeAsString` with `flush: true`
3. Handle WriteException:
   - Storage full → retry after 30s, show warning toast
   - Permission denied → show error, disable auto-save

### Step 3: Create Version Snapshot
1. Create DocumentVersion record:
   - `documentId` → current document
   - `content` → full content string
   - `versionNumber` → increment from last version
   - `createdAt` → DateTime.now()
2. Insert into drift DocumentVersion table
3. Limit: keep max 100 versions per document — delete oldest if exceeded

### Step 4: Update Document Metadata
1. Update Document row in drift:
   - `updatedAt` → DateTime.now()
   - `contentPreview` → first 200 chars of content
   - `wordCount` → content.split(/\s+/).length

### Step 5: Auto-Stage (if in Git Repo)
1. Check if document is inside a git repo (Repository.workingDir)
2. If yes: run `git add {relativeFilePath}` via git2dart
3. Silently handle errors (git not ready, file outside working tree)

### Step 6: Reset Change Flag
1. Set `hasUnsavedChanges = false`
2. Resume monitoring for changes

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Document file | App sandbox | File | Persisted Markdown content |
| DocumentVersion | Drift | Record | Version snapshot |
| Updated Document | Drift | Record | Updated metadata |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Storage full | WriteException (no space) | Retry 30s, show toast warning |
| File locked | WriteException (lock) | Retry after 1s, up to 3 attempts |
| git2dart error | GitException | Log silently, no user-facing error |

## Flow Diagram (text)

```
Timer (5s) → Check changed? → No → Skip
                    ↓
                  Yes
                    ↓
        Write content to file
                    ↓
      Create DocumentVersion snapshot
                    ↓
      Update Document metadata in drift
                    ↓
      If in git repo → git add (silent)
                    ↓
      Reset hasUnsavedChanges = false
```


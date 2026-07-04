# System Logic: Git Operation Pipeline

**Document:** SoT-4 Logic | **ID:** SL-007 | **Status:** Draft | **Related UC:** UC-005

## Purpose

Execute Git version control operations via git2dart (libgit2 FFI) for repository management, keeping the UI responsive by running network operations in the background and providing progress feedback.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| Operation type | Git panel | Enum (init/status/add/commit/diff/log/push/pull) | Requested operation |
| Target repo | Git panel | String | Repository path in app sandbox |
| Parameters | Git panel | Map | Varies by operation (files, message, remote URL) |
| Credentials | Secure storage | GitCredential | SSH key or PAT for remote operations |

## Processing Steps

### Step 1: Load Repository
1. Check if Repository record exists in drift for the working directory
2. If not: try git2dart `Repository.open(path)` at the working directory
3. If no .git found: return "Not a git repository" error
4. If found: load branch name, remote URL, recent commit into memory

### Step 2: Execute Operation

#### init
1. Call `Repository.init(path)` via git2dart
2. Create Repository record in drift

#### status
1. Call `Repository.status()` → get file status list
2. Categorize as: staged, unstaged modified, untracked
3. Return categorized list with file paths

#### add (stage)
1. For each file path: call `Index.add(path)`
2. Return updated status

#### commit
1. Create signature from UserProfile (name, email)
2. Call `Repository.commit(message, author, committer)`
3. Commit result → OID, summary

#### diff
1. Call `Repository.diff()` or `Diff.treeToWorkdir()`
2. Parse diff hunks and lines
3. Return structured DiffResult (file path, hunks, additions, deletions)

#### log
1. Call `Repository.walk()` → get commit list
2. For each commit: OID, author, message, timestamp, parents
3. Return list limited to page size (default 50)

#### push
1. Open remote `Repository.getRemote("origin")`
2. Set credentials callback
3. Push with `Remote.push(spec)` where spec is `refs/heads/{branch}`
4. Provide progress callback (sent objects / total objects)

#### pull
1. Fetch with `Remote.fetch()`
2. If fast-forward: `Repository.merge()` with ff only
3. If merge needed: `Repository.merge()` → conflict detection
4. Return list of conflicted files if merge failed

### Step 3: Handle Remote Credentials
1. Credential callback triggers when remote requires auth
2. Try stored credentials from flutter_secure_storage:
   - PAT (Personal Access Token) for HTTPS remotes
   - SSH key from file for SSH remotes
3. If stored credentials fail → show credential dialog to user
4. On success: cache credentials for session

### Step 4: Update Repository Metadata
1. After any mutating operation: update Repository record in drift
   - `lastCommitAt`, `lastCommitMessage`, `unpushedCount`

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Status result | Git panel | StatusResult | File statuses, branch, behind count |
| Diff result | Git panel | DiffResult | Per-file diffs with hunks |
| Commit result | Git panel | CommitResult | OID, message, timestamp |
| Log result | Git panel | List<CommitResult> | Commit history |
| Push/pull result | Git panel | ProgressResult | Success or conflict list |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Not a git repo | Repository.open fails | Offer to init |
| Auth failed | Credential callback rejected | Show credential dialog |
| Merge conflict | Merge produces conflicts | Show conflict resolution UI |
| Network timeout | Remote operation > 30s | Retry option with longer timeout |
| SSH key not found | File not found at SSH path | Show file picker to locate key |

## Flow Diagram (text)

```
User selects operation → Load Repository (git2dart)
                              ↓
                     ┌────────┴────────┐
                     │  Init │ Status  │
                     │  Add  │ Commit  │
                     │  Diff │ Log     │
                     │  Push │ Pull    │
                     └────────┬────────┘
                              ↓
                    ┌──────────────────┐
                    │  Remote op?      │──No──→ Execute locally
                    │                  │
                    │  Yes             │
                    │  ↓               │
                    │  Credentials     │
                    │  callback        │
                    └──────────────────┘
                              ↓
                    Update Repository metadata
                              ↓
                    Return result → UI refresh
```

## Performance Constraints

- Push/pull must execute within 60 seconds (with progress indication)
- Status must return within 500ms for repos with < 100 files
- Diff must load within 2s for files < 1000 lines
- Log must load within 1s for first 50 commits

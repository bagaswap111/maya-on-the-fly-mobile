# System Logic: Export Pipeline

**Document:** SoT-4 Logic | **ID:** SL-004 | **Status:** Draft | **Related UC:** UC-004

## Purpose

Convert Markdown documents to target formats (PDF, HTML, DOCX, TXT) in a background Dart Isolate to keep the UI responsive, supporting progress reporting and cancellation.

## Inputs

| Input | Source | Type | Description |
|-------|--------|------|-------------|
| Document content | Editor Controller | String | Full Markdown content |
| Target format | Export page | Enum (pdf/html/docx/txt) | Selected output format |
| Destination | Export page | Enum (local/share/icloud/gdrive) | Where to send the result |
| Document title | Document | String | Used for filename |
| CancelToken | Export page | CancellationToken | User cancellation signal |

## Processing Steps

### Step 1: Pre-Validation
1. Check document is non-empty (content.length > 0)
2. Check target format is supported (one of 4)
3. Check destination is supported
4. If any check fails → return early with validation error

### Step 2: Spawn Isolate
1. Create ReceivePort for communication
2. Spawn Isolate with:
   - Isolate entry point: `runExport`
   - Arguments: content, format, title, SendPort (progress updates)
   - Message: ReceivePort.sendPort (result callback)
3. Set up SendPort wrapper for progress updates

### Step 3: Isolate Processing
1. Parse Markdown into AST (markdown package)
2. Based on format:
   - **HTML**: Render AST to HTML string using custom renderer
   - **PDF**: Render HTML via `flutter_pdf` or `pdf` package → PDF bytes
   - **DOCX**: Convert through `docx` package → Uint8List
   - **TXT**: Strip Markdown syntax → plain text string
3. Send progress updates at each milestone:
   - `{phase: "parsing", progress: 0.0}`
   - `{phase: "converting", progress: 0.3}`
   - `{phase: "rendering", progress: 0.6}`
   - `{phase: "finalizing", progress: 0.9}`
   - `{phase: "done", progress: 1.0}`

### Step 4: Receive Result
1. Main isolate receives result from Isolate via ReceivePort
2. Check result type:
   - Success: contains format-specific output (String or Uint8List)
   - Error: contains exception information

### Step 5: Handle Destination
1. **Local Save**: Write to `{appDocDir}/exports/{title}.{ext}`
2. **Share**: Create temp file, trigger share_plus Share.shareXFiles
3. **iCloud**: Use `path_provider` iCloud container path
4. **Google Drive**: Upload via http client to Google Drive API
   - Check OAuth token validity
   - If expired → refresh token
   - Upload in chunks with progress tracking

### Step 6: Record Export
1. Create ExportRecord in drift:
   - `documentId`, `format`, `destination`, `fileSize`, `createdAt`
   - `success: true`

## Outputs

| Output | Destination | Type | Description |
|--------|-------------|------|-------------|
| Export file | Destination | File / Share | Converted document |
| Progress updates | UI (ProgressBar) | Stream<ExportProgress> | Phase + percentage |
| ExportRecord | Drift | Record | Export history entry |

## Error Handling

| Error | Detection | Recovery |
|-------|-----------|----------|
| Isolate crash | Isolate.kill or exit with error | Show error UI with "Conversion failed" |
| Unsupported format | Switch case default | Show "Format not supported" |
| Google Drive auth | OAuth token error | Fallback to local save |
| Large document timeout | Timer > 60s | Offer "Continue waiting" or "Cancel" |

## Flow Diagram (text)

```
User taps Export → Validate → Spawn Isolate
                                    ↓
                          ┌─────────────────┐
                          │ Parse Markdown   │  → 0%
                          │ Convert to fmt   │  → 30%
                          │ Render output    │  → 60%
                          │ Finalize         │  → 90%
                          └─────────────────┘
                                    ↓
                              Receive Result
                                    ↓
                          Handle Destination
                           ├─ Local Save
                           ├─ Share Sheet
                           ├─ iCloud Drive
                           └─ Google Drive
                                    ↓
                          Record Export → Done
```

## Performance Constraints

- DOCX conversion must complete within 15s for 100-page documents
- PDF rendering must complete within 30s for 100-page documents
- Isolate heap limit: 128 MB
- Progress updates must not exceed 100ms interval (UI throttle)

# User Flow: Document Export

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F007 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-004 |
| Name | Document Export |
| Actor | Any user |
| Goal | Convert a Markdown document to PDF, HTML, DOCX, or plain text and save/share to a destination |
| Trigger | User taps Export button from the editor toolbar |
| Preconditions | - Document is open in editor- Document has content (non-empty) |

## Main Flow

1. User taps Export button in editor toolbar
2. System navigates to Export page → Format Picker appears
3. User selects format: PDF, HTML, DOCX, or Plain Text
4. System shows Destination Picker with:
   - Local Save (save to app sandbox)
   - Share (system share menu)
   - iCloud Drive (iOS only)
   - Google Drive (requires OAuth)
5. User selects destination
6. System disables Export button, shows "Converting..."
7. System spawns Dart Isolate with document content + format
8. Isolate sends progress updates:
   - "Parsing Markdown..." (0%)
   - "Building layout..." (25%)
   - "Rendering pages..." (50-90%, varies by format)
   - "Done." (100%)
9. Progress bar updates in real-time with phase label
10. Conversion completes → result handed back to main isolate
11. Based on destination:
    - Local: Save to app sandbox with filename, show success toast
    - Share: Open platform share menu (iOS share sheet / Android share menu)
    - iCloud: Trigger iCloud upload via file picker
    - Google Drive: Upload via Google Drive API (OAuth)
12. Export button re-enabled
13. ExportRecord saved to database
14. **Goal achieved:** Document exported successfully to chosen format and destination

## Alternative Flows

### Alt-1: Back to Previous Step
**Trigger:** User taps Back button in Format Picker or Destination Picker

1. Format Picker: Back returns to editor (no changes made)
2. Destination Picker: Back returns to Format Picker (format selection preserved)
3. **Outcome:** User can change choices without starting over

### Alt-2: Cancel Export
**Trigger:** User taps Cancel (X) button in Format Picker, Destination Picker, or Progress screen

1. Format Picker: Cancel returns to editor, no changes
2. Destination Picker: Cancel returns to editor, no changes
3. Progress: Cancel aborts the Isolate, returns to editor
4. **Outcome:** Clean exit from export flow

### Alt-3: Google Drive — First Time Auth
**Trigger:** User selects Google Drive destination but not authenticated

1. System detects no valid Google Drive session
2. Opens OAuth 2.0 flow via google_sign_in
3. User logs in and grants permissions
4. Token stored for future use
5. Upload proceeds
6. **Outcome:** Authorized and exported

## Exception Flows

### Exc-1: Conversion Failure
**Trigger:** Isolate throws an exception during conversion

1. System catches error from Isolate
2. Shows error state with message: "Conversion failed: {reason}"
3. Export button re-enabled (user can retry)
4. **Outcome:** User can retry or choose different format

### Exc-2: Google Drive Upload Failure
**Trigger:** Upload to Google Drive fails (network, quota, or auth)

1. System detects upload error
2. Shows error state: "Upload to Google Drive failed. Saved locally instead."
3. File is saved to local sandbox as fallback
4. **Outcome:** User gets the file locally even if cloud upload fails

### Exc-3: Large Document Timeout
**Trigger:** Conversion exceeds 30 seconds

1. Progress bar continues showing latest known progress
2. After 30s: shows "Taking longer than expected..."
3. After 60s: shows option to "Continue waiting" or "Cancel"
4. **Outcome:** User can decide to wait or cancel

## Postconditions

- Export file exists at destination (local, cloud, or share sheet handled it)
- ExportRecord is persisted with format and destination
- Export button is re-enabled

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-013 | Export | Format picker entry |
| PAGE-014 | Export Format | Format selection |
| PAGE-015 | Export Destination | Destination selection |
| PAGE-016 | Export Progress | Conversion progress display |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| Document | File system + drift | Read | Content to convert |
| ExportRecord | Drift | Create | Export history entry |

## Acceptance Criteria

- [ ] All 4 formats (PDF, HTML, DOCX, TXT) produce valid output
- [ ] Progress bar shows phase labels during conversion
- [ ] Back button returns to previous step without side effects
- [ ] Cancel button exits flow cleanly
- [ ] Double-tap Export only triggers one conversion
- [ ] Conversion failure shows error and re-enables button
- [ ] Google Drive fallback saves locally on failure

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-007.1 | Export to HTML, PDF, DOCX, plain text | 4 format converters |
| FR-007.2 | Support local, share, iCloud, Google Drive | 4 destinations |
| FR-007.3 | Run conversion in Dart Isolate | Isolate.spawn for non-blocking export |
| FR-007.4 | Show progress bar with phase labels | SendPort progress updates |
| FR-007.5 | Back and Cancel at every step | Navigation buttons on all screens |
| FR-007.6 | Disable Export after first tap | Button state management |
| FR-007.7 | Re-enable Export on failure | Error recovery enables retry |

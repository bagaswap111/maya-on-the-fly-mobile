# User Flow: Settings & Profile Management

**Document:** SoT-4 | **Derived From:** SoT-1 (SRS) — F008 (secondary), NFR-003, NFR-004 | **Status:** Draft | **Last Updated:** 2026-07-04

## Use Case Information

| Field | Value |
|-------|-------|
| Use Case ID | UC-007 |
| Name | Settings & Profile Management |
| Actor | Any user |
| Goal | Manage app preferences including user profile, security, theme, editor settings, export defaults, keyboard shortcuts, and about info |
| Trigger | User taps Settings gear icon from any main screen |
| Preconditions | - App is installed- User profile may or may not exist |

## Main Flow

1. User taps gear icon → Settings page opens
2. System loads UserProfile from drift database (or creates default)
3. Settings page shows sectioned list:
   - Profile (name, avatar, default author info)
   - Appearance (theme, font size, code theme)
   - Editor (spell check, line numbers, tab size, export defaults)
   - Privacy & Security (local auth toggle, auto-lock timer)
   - Usage & Storage (database size, export cache)
   - Keyboard Shortcuts (iPad)
   - About (version, licenses, changelog)
4. User taps a section → corresponding detail page opens
5. User modifies settings → System auto-saves to drift UserProfile
6. Settings changes apply immediately in background
7. **Goal achieved:** App configured to user's preferences

## Alternative Flows

### Alt-1: Enable Local Authentication
**Trigger:** User toggles "Require Auth to Open App"

1. Switch toggles ON
2. System checks if device supports biometrics (Face ID/Touch ID or fingerprint)
3. If supported: System shows "Authenticate to enable" → OS biometric prompt
4. If success: auth enabled, preference saved
5. If biometric not available: system falls back to PIN code setup
6. User enters PIN (6 digits) → confirm PIN → saved
7. **Outcome:** App requires biometric or PIN on next launch

### Alt-2: Clear Export Cache
**Trigger:** User taps "Clear Export Cache" in Usage & Storage

1. System shows confirmation: "Delete {n} cached export files? ({size} MB)"
2. User confirms
3. System deletes all cached exports from app sandbox
4. Shows success: "Export cache cleared"
5. **Outcome:** Freed up storage space

### Alt-3: Set Export Defaults
**Trigger:** User taps Export Defaults in Editor section

1. System shows format picker + destination picker
2. User selects default format (e.g., PDF)
3. User selects default destination (e.g., Local Save)
4. System saves defaults to UserProfile.exportDefaults
5. **Outcome:** Export flow pre-selects user's preferred options

## Exception Flows

### Exc-1: Biometric Enrollment Missing
**Trigger:** User enables auth but no biometrics enrolled on device

1. System calls local_auth plugin → returns "no enrolled biometrics"
2. Shows dialog: "No fingerprints or Face ID enrolled. Set up in device Settings or use PIN."
3. Options: "Go to Settings" (opens OS settings), "Use PIN", "Cancel"
4. **Outcome:** User can choose another method or cancel

### Exc-2: Database Corrupt
**Trigger:** Settings page fails to load UserProfile from drift

1. System catches database read exception
2. Shows error: "Settings database issue. Restoring defaults."
3. System deletes and recreates drift database
4. All settings reset to defaults
5. **Outcome:** App recovers with default settings

## Postconditions

- UserProfile is updated in drift database
- Theme, font, and other UI preferences take effect immediately
- Keyboard shortcuts listener updates if changed
- Local auth is enabled/disabled

## Related Pages

| Page ID | Page Name | Role in This Flow |
|---------|-----------|-------------------|
| PAGE-022 | Settings | Main settings hub |
| PAGE-023 | Profile | User profile details |
| PAGE-024 | Appearance | Theme, font, code theme |
| PAGE-025 | Editor Settings | Spell check, line numbers, defaults |
| PAGE-026 | Privacy & Security | Local auth, auto-lock |
| PAGE-027 | Keyboard Shortcuts | iPad shortcut configuration |
| PAGE-028 | About | Version, licenses, changelog |

## Data Used

| Data / Entity | Source | Operation | Notes |
|---------------|--------|-----------|-------|
| UserProfile | Drift | Read/Write | All user preferences |
| Auth config | flutter_secure_storage | Read/Write | PIN hash, biometric flag |

## Acceptance Criteria

- [ ] All settings sections render correctly
- [ ] Changes auto-save immediately
- [ ] Local auth (biometric or PIN) works on app launch
- [ ] Export cache clearing frees storage
- [ ] Export defaults pre-populate the export flow
- [ ] Database corruption recovery restores defaults gracefully

## Traceability

| Requirement ID | Requirement Description | How This Flow Satisfies It |
|----------------|------------------------|---------------------------|
| FR-008.7 | Usage analytics dashboard | Partially (Usage & Storage section links) |
| NFR-003.2 | Sensitive data at rest encrypted via flutter_secure_storage | API keys and PIN stored securely |
| NFR-004.1 | Support light/dark theme | Appearance section |
| NFR-004.2 | Support system theme and manual override | Theme picker |
| NFR-004.3 | Configurable font size | Editor settings |
| NFR-004.4 | Configurable code block theme | Code theme picker |
| NFR-004.5 | All preferences persist across restarts | Drift UserProfile |

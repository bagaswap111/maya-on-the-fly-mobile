# Security Audit: Maya on the Fly

**Date:** 2026-07-04
**Scope:** Design-spec artifacts (architecture.md, approach.md, data_model_detail.md, prototype.md, DESIGN.md, ucic_contracts.md, user_flows/)
**Method:** Mobile Security Audit (8 domains) via `mobile-security-audit` skill
**Reference:** OWASP Mobile Top 10 (2024)

---

## Executive Summary

| Severity | Count |
|----------|-------|
| ✅ Pass | 0 |
| ⚠️ Minor | 0 |
| 🔴 Major | 7 |
| ❌ Critical | 1 |

**Critical Blocker (D6):** Zero platform-hardening configurations are specified — no FLAG_SECURE, no backup exclusion rules, no AndroidManifest/Info.plist security constraints, no debug-mode or root/jailbreak detection. Without these, the app cannot pass App Store / Play Store review and would leak sensitive data on rooted/jailbroken devices.

**Top Priority Actions:**
1. **D6 — Platform Hardening:** Add FLAG_SECURE to auth-related pages (PAGE-026, PAGE-018), configure `allowBackup=false` with exclusion rules, specify Keychain accessibility, add root/jailbreak detection for app-lock features.
2. **D1 — Data Storage:** Encrypt the drift database via sqlcipher with a passphrase derived from flutter_secure_storage + device ID.
3. **D2 — Communication Security:** Add certificate pinning for all AI provider endpoints and git remote hosts.

---

## Per-Domain Findings

### D1 — Data Storage: 🔴 Major

**What's done right:**
- API keys stored in `flutter_secure_storage` only (FR-008.4, C003, NFR-002.1, BR-DM-006) — never in drift, SharedPreferences, or source code (`architecture.md:262,329,1037`)
- Git PAT in `flutter_secure_storage` (BR-006.1, `architecture.md:225`)
- No plaintext secrets in logs, error messages, or network traces (NFR-002.3, `architecture.md:331,1581`)

**Gaps:**
- ❌ **Drift database is unencrypted** — documents, chat messages, usage data, and user profiles are stored in plain SQLite. Drift encryption via sqlcipher is not specified anywhere. (`OWASP M9 — Insecure Data Storage`)
- ❌ **No screenshot blocking** on sensitive pages (PAGE-026 Privacy & Security, PAGE-018 Provider Setup, PAGE-027 App Lock). No FLAG_SECURE usage documented. (`OWASP M6 — Inadequate Privacy Controls`)
- ⚠️ Export cache files — no policy for deletion after share or on app background.
- ⚠️ Clipboard clearing after pasting API keys — not specified.
- ⚠️ Crash report redaction — noted as "if implemented" but not definitive (`architecture.md:1584`).
- ⚠️ Backup exclusion for drift database and export files — not specified (iCloud/Google Drive could back up unencrypted data).

**Remediation:**
1. Add drift encryption via sqlcipher — passphrase derived from `flutter_secure_storage.read(key: 'db_passphrase')` + device ID.
2. Add `FLAG_SECURE` to PAGE-018, PAGE-026, PAGE-027, and any screen showing repository credentials.
3. Specify backup exclusion rules in AndroidManifest (`android:allowBackup="false"` or `fullBackupContent` with exclusion) and iOS Info.plist (`UIBackupExclusion` for export directory).

---

### D2 — Communication Security: 🔴 Major

**What's done right:**
- All AI API calls use HTTPS (NFR-002.4, `architecture.md:332,1564`)
- TLS 1.2+ enforced on all endpoints (`architecture.md:1564-1568`)
- API keys in Authorization header, not in URL query parameters (`architecture.md:1050-1053`)
- No plaintext HTTP endpoints defined anywhere

**Gaps:**
- ❌ **No certificate pinning** for any endpoint — DeepSeek API, GitHub, Google Drive, or any configured AI provider. The app relies entirely on platform-default trust stores, making it vulnerable to MITM attacks via compromised CA certificates. (`OWASP M5 — Insecure Communication`)
- ⚠️ No custom TLS configuration documented for the HTTP client.
- ⚠️ Provider `baseUrl` is user-configurable (`approach.md:327-328`) but no validation that it must be HTTPS is documented.
- ⚠️ Literature search APIs (Semantic Scholar, arXiv, CrossRef) and AI detection APIs (GPTZero, Originality.ai, Copyleaks) — HTTPS is assumed but not explicitly constrained.

**Remediation:**
1. Add certificate pinning for `api.deepseek.com`, `github.com`, `www.googleapis.com`, and any hardcoded provider endpoints using the `http` package's `BadCertificateCallback` or a pinning-aware HTTP client.
2. Validate configured provider `baseUrl` — reject non-HTTPS URLs at input time.
3. Document pinning strategy for user-added custom providers (at minimum enforce HTTPS + hostname verification).

---

### D3 — Authentication & Session Management: 🔴 Major

**What's done right:**
- Biometric gate required for git push (FR-006.3, NFR-002.2, `architecture.md:217,330`)
- Session tokens never persisted to disk (NFR-002.5, `architecture.md:333`)
- Biometric fallback to PIN when biometrics not enrolled (`architecture.md:1327`)
- Configurable auto-lock timer (PAGE-026, `architecture.md:718-725`)

**Gaps:**
- ❌ **PIN storage unspecified** — no details on whether the PIN is hashed, what algorithm (PBKDF2/Argon2?), or where it's stored. If stored plaintext in drift, this is a critical bypass vector. (`OWASP M3 — Insecure Authentication`)
- ❌ **App switcher/task manager protection** — not specified. When app lock is enabled, the app preview in the task switcher could expose sensitive content. (`OWASP M6 — Inadequate Privacy Controls`)
- ❌ **Biometric enrollment change handling** — if the user adds a new fingerprint/face after setting up app lock, there's no re-prompt for credentials. (`OWASP M3`)
- ❌ **Lock screen bypass prevention** — back button behavior, notification content, and app switcher at lock screen not addressed.
- ⚠️ Auto-lock timer defaults — no minimum enforced (e.g., "Never" option could leave app permanently unlocked).
- ⚠️ OAuth token refresh for Google Drive/iCloud — not specified.

**Remediation:**
1. Specify PIN hashing: PBKDF2 with 100k+ iterations, salt stored in `flutter_secure_storage`, hash stored in `flutter_secure_storage` (not drift).
2. Add `FLAG_SECURE` on lock screen (PAGE-027) and blur app preview when app is backgrounded.
3. Register for `local_auth` `onAuthenticationChanged` to detect biometric enrollment changes and force re-login.
4. Set auto-lock default to "Immediately" or "1 minute" — document minimum.

---

### D4 — Input Validation & Injection Prevention: 🔴 Major

**What's done right:**
- No `Process.run()` — iOS blocks it (C002, `architecture.md:70`), git2dart used instead (`approach.md:254`)
- File path traversal rejected in agent tools — documented validation (`flutter-security.md:200-208` pattern reference)
- Drift uses parameterized queries — no raw SQL concatenation (`flutter-security.md:55-68`)
- API responses validated against UCIC schema contracts (`ucic_contracts.md`)

**Gaps:**
- ❌ **No Markdown/HTML sanitization for preview pane** — user documents and AI-generated content rendered as Markdown could contain XSS vectors if the Markdown renderer allows raw HTML. (`OWASP M4 — Insufficient Input/Output Validation`)
- ❌ **No LaTeX sandboxing** — if LaTeX export is planned, `\write18`, `\input`, and file operations could lead to command execution or file disclosure.
- ❌ **No prompt injection defenses** — the agent loop treats model output as structured data (tool calls from JSON), but there's no documented handling for prompt injection, jailbreak attempts, or unexpected model output formats. (`OWASP M4`)
- ❌ **Export filename sanitization** — user-provided filenames for PDF/DOCX/HTML export may contain path separators or special characters.
- ⚠️ Git branch/commit message injection — git2dart is safer than CLI but no explicit sanitization documented for user-supplied commit messages or branch names.

**Remediation:**
1. Configure `flutter_markdown` with `extensionSet: const [md.ExtensionSet.gitHubFlavored]` and strip raw HTML tags via `html_unescape` or a Markdown sanitizer.
2. If LaTeX export is supported, spawn in a Dart Isolate with `\write18` disabled and block `\input` that reads outside the project directory.
3. Add a schema validator for agent tool-call JSON output — reject malformed calls gracefully; log and alert on suspicious patterns.
4. Sanitize export filenames: strip `/`, `\`, `..`, null bytes; limit to 255 chars.

---

### D5 — Cryptography: 🔴 Major

**What's done right:**
- No custom encryption implementations — `flutter_secure_storage` uses platform-native crypto (iOS Keychain kSecAttrAccessibleWhenUnlockedThisDeviceOnly, Android EncryptedSharedPreferences AES-256) (`architecture.md:1556`)
- Key storage in OS keychain/keystore — not in app-managed storage
- No deprecated algorithms (MD4, MD5, SHA1 for security) in any documented code

**Gaps:**
- ❌ **Drift database not encrypted** — same as D1 gap. All document content, chat history, and cached AI responses are stored in plain SQLite. (`OWASP M10 — Insufficient Cryptography`)
- ❌ **PIN hashing algorithm unspecified** — if PIN-based app lock stores a plain hash (SHA256 without salt) or plaintext, it's trivially reversible. (`OWASP M10`)
- ❌ **Key derivation not documented** — if the drift encryption passphrase is added later, there's no key derivation strategy (PBKDF2/Argon2) specified.
- ⚠️ Random number generation for security contexts — not explicitly specified to use `Random.secure()`.

**Remediation:**
1. Use `sqlcipher` with drift — passphrase stored in `flutter_secure_storage`, derived as `PBKDF2(deviceId + secureStorageKey, salt, 100000)`.
2. PIN hash: `PBKDF2(pin, salt, 100000)` with salt stored in `flutter_secure_storage` alongside the hash.
3. Add a note to use `dart:math` `Random.secure()` for all cryptographic nonces and salts.

---

### D6 — Platform Hardening: ❌ Critical

**What's done right:**
- iOS sandbox constraints respected — no shell/CLI spawning (C002, `architecture.md:70`)
- App sandboxed document directory (`approach.md:480`)
- Minimum OS versions: Android 8.0 (API 26), iOS 15.0 (`architecture.md:59-60`)
- iOS: NSFileProtectionComplete for document storage (`architecture.md:1558`)

**Gaps:**
- ❌ **No Android backup configuration** — `android:allowBackup` defaults to `true` in Android, which would back up the unencrypted drift database to Google Drive. (`OWASP M8 — Security Misconfiguration`, `OWASP M6 — Inadequate Privacy Controls`)
- ❌ **No FLAG_SECURE on any screen** — auth screens, API key entry, repository credentials are all capturable via screenshot/screen recording. (`OWASP M6`)
- ❌ **No root/jailbreak detection** for app-lock features — on a rooted device, the drift database is readable outside the app sandbox. (`OWASP M7 — Insufficient Binary Protections`)
- ❌ **No debug-mode detection** — release build must disable debug features and DevTools. (`OWASP M8`)
- ❌ **Android exported activities not constrained** — no specification that activities handling OAuth callbacks or deep links are non-exported or have permission checks. (`OWASP M8`)
- ❌ **iOS Keychain accessibility not explicitly set** — relies on `flutter_secure_storage` default, but should be explicitly `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (`flutter-security.md:14`). (`OWASP M8`)
- ❌ **iOS UIPasteboard clearing** — no mention of clearing clipboard after pasting API keys. (`OWASP M6`)
- ⚠️ **Android content:// URI exposure** — not addressed.
- ⚠️ **iOS iCloud entitlement scope** — not specified for Drive integration.

**Remediation:**
1. Android: set `android:allowBackup="false"` in `AndroidManifest.xml` (or use `fullBackupContent` with exclusion rules for drift DB).
2. Add `window.setFlags(FLAG_SECURE)` to PAGE-018, PAGE-026, PAGE-027 via `WidgetsBindingObserver`.
3. Add root/jailbreak detection using `jailbreak_utils` or `root_detector` package; prompt warning or block sensitive features on detected compromise.
4. Wrap platform-specific secure storage config in `configureFlutterSecureStorage` with `iOSOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device_only)`.

---

### D7 — Code & Binary Security: 🔴 Major

**What's done right:**
- User-facing error messages are generic — no stack traces or internal paths exposed (`architecture.md:1582`)
- Network error logging excludes request body content (`architecture.md:1583`)

**Gaps:**
- ❌ **No obfuscation specified** — release builds should use `--obfuscate --split-debug-info`. Without it, class/function names are readable, easing reverse engineering of the agent loop, tool definitions, and provider authentication flow. (`OWASP M7 — Insufficient Binary Protections`)
- ❌ **No dependency vulnerability scanning** — no mention of `dart pub outdated --security`, Dependabot, or any CVE monitoring for drift, git2dart, flutter_secure_storage, riverpod, or other critical dependencies. (`OWASP M2 — Inadequate Supply Chain Security`)
- ❌ **Debug/verbose logging not explicitly stripped** in release builds — no documented guard that `debugPrint` or custom logger levels are compiled out. (`OWASP M7`)
- ❌ **Source maps and DevTools** — no mention of excluding source maps from release builds or disabling DevTools access.
- ❌ **No dependency review** for transitive dependencies, unused permissions, or known CVEs across 30+ packages.

**Remediation:**
1. Add to build documentation: `flutter build ios --obfuscate --split-debug-info=symbols/` and `flutter build apk --obfuscate --split-debug-info=symbols/`.
2. Add `dart pub outdated --security` to CI pipeline; enable Dependabot security alerts for the GitHub repo.
3. Use a logger wrapper that compiles to no-op in release mode (`kReleaseMode ? null : debugPrint(...)`).
4. Add `--no-pub` DevTools disable for release builds.

---

### D8 — API & Integration Security: 🔴 Major

**What's done right:**
- API key configurable without app update — settings page (PAGE-018) allows key entry and validation on save (`architecture.md:1326`)
- Usage caps enforced client-side — hard cap before API call (FR-010.2, `architecture.md:273-275`)
- Git PAT stored in `flutter_secure_storage`, never in URL or commit history (`approach.md:479`)
- OAuth flows via `google_sign_in` + `flutter_appauth` — use system browser, not WebView
- API error codes mapped to user-friendly messages (401→"Invalid API key", 429→"Rate limited", etc.; `architecture.md:1166-1170`)

**Gaps:**
- ❌ **No client-side rate limiting** — only server-side 429 handling is documented. Without client-side throttling, rapid retries could exhaust API quotas or trigger provider bans. (`OWASP M1 — Improper Credential Usage` via abuse potential)
- ❌ **No provider base URL validation** — user-configurable `baseUrl` (`approach.md:327-328`) must be validated as HTTPS and checked for path-injection characters (e.g., `https://evil.com/../../steal`). (`OWASP M4`)
- ❌ **No OAuth redirect URI specification** — custom URL scheme or universal link for OAuth callback not documented. A wildcard or insecure redirect could allow token interception. (`OWASP M3`)
- ❌ **File upload/download size/content-type validation** — not specified for Git clone, export file operations, or document import.
- ⚠️ **OAuth token refresh** for Google Drive / iCloud — not documented how expired tokens are handled.
- ⚠️ **Multiple AI provider support** — each provider has different auth mechanisms (Bearer token, API key header); no documented normalization for adding custom providers.

**Remediation:**
1. Add client-side rate limiter — e.g., token bucket algorithm with configurable requests-per-minute per provider, stored in drift and checked before each API call.
2. Validate provider `baseUrl`: `Uri.tryParse` → must have `scheme == 'https'`, no path segments beyond allowed base path, reject IP addresses.
3. Specify OAuth redirect URI format: `mayaofthefly://oauth/callback` for custom scheme, with ASWebAuthenticationSession (iOS) / Chrome Custom Tabs (Android).
4. Add file size limits: reject documents > 50MB for AI processing, > 200MB for Git operations.

---

## Per-Feature Breakdown

| Feature | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 |
|---------|----|----|----|----|----|----|----|----|
| F001: AI Chat | ⚠️ | 🔴 | — | ⚠️ | ⚠️ | — | — | 🔴 |
| F002: AI Detector/Humanizer | ⚠️ | ⚠️ | — | ⚠️ | — | — | — | ⚠️ |
| F003: Document Editor | 🔴 | — | — | 🔴 | 🔴 | ⚠️ | — | ⚠️ |
| F004: Library/Document Mgmt | 🔴 | — | — | ⚠️ | 🔴 | 🔴 | — | — |
| F005: Git Integration | ⚠️ | 🔴 | 🔴 | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ |
| F006: Chat/Agent Interface | ⚠️ | 🔴 | — | 🔴 | — | — | — | 🔴 |
| F007: Export Engine | 🔴 | — | — | 🔴 | 🔴 | 🔴 | — | ⚠️ |
| F008: Provider/Settings | ⚠️ | 🔴 | 🔴 | ⚠️ | ⚠️ | 🔴 | — | 🔴 |
| F009: Agent/Skill System | — | ⚠️ | — | 🔴 | — | — | — | ⚠️ |
| F010: Usage Tracking | 🔴 | — | — | — | 🔴 | ⚠️ | — | ⚠️ |
| F011: App Lock/Auth | — | — | ❌ | — | 🔴 | ❌ | — | — |

**Legend:** 🔴 = Major, ❌ = Critical, ⚠️ = Minor (pre-implementation gap), ✅ = Pass, — = Not applicable

*Note: Scores reflect the **design specification** — most 🔴 findings are gaps in the spec that can be resolved before coding.*

---

## Remediation Roadmap

| Priority | Finding | Domain | Effort | Guidance |
|----------|---------|--------|--------|----------|
| P0 | Platform hardening: FLAG_SECURE, backup rules, Keychain accessibility, root detection | D6 | 3d | Reference: `flutter-security.md §Platform Hardening`, `owasp-mobile-top10.md M8` |
| P0 | Drift database encryption via sqlcipher | D1, D5 | 2d | Reference: `flutter-security.md §Drift Encryption` |
| P0 | Certificate pinning for all AI providers and Git remotes | D2 | 2d | Reference: `flutter-security.md §Network Requests` |
| P1 | PIN hashing and secure storage for app lock | D3, D5 | 1d | Reference: `flutter-security.md §Cryptography` |
| P1 | Markdown/HTML sanitization in preview pane | D4 | 1d | Reference: `owasp-mobile-top10.md M4` |
| P1 | Client-side rate limiting per provider | D8 | 1d | Reference: `flutter-security.md §Input Validation` |
| P1 | Provider base URL validation (HTTPS only) | D2, D8 | 0.5d | Reference: `flutter-security.md §URL Validation` |
| P1 | Code obfuscation flags in build docs and CI | D7 | 0.5d | Reference: `flutter-security.md §Code Obfuscation` |
| P2 | Export filename sanitization | D4 | 0.5d | Reference: `flutter-security.md §Input Validation Patterns` |
| P2 | Biometric enrollment change detection | D3 | 1d | Reference: `owasp-mobile-top10.md M3` |
| P2 | OAuth redirect URI specification | D8 | 0.5d | Reference: `flutter-security.md §Network Requests` |
| P2 | Dependency vulnerability scanning (CI) | D7 | 0.5d | Reference: `flutter-security.md §Dependency Management` |
| P3 | Clipboard clearing after API key paste | D1, D6 | 0.5d | Reference: `owasp-mobile-top10.md M6` |
| P3 | Crash report redaction policy | D1 | 0.5d | Reference: `flutter-security.md §Error Handling` |
| P3 | App switcher blur for auth screens | D3 | 0.5d | Reference: `android-security.md`, `ios-security.md` |
| P3 | Root/jailbreak detection for app lock | D6 | 1d | Reference: `owasp-mobile-top10.md M7` |
| P3 | LaTeX sandboxing (if supported) | D4 | 1d | Reference: `owasp-mobile-top10.md M4` |
| P3 | File import/export size and content-type limits | D8 | 0.5d | Reference: `flutter-security.md §Input Validation` |

---

## OWASP Mobile Top 10 Coverage

| OWASP ID | Category | Coverage Status |
|----------|----------|-----------------|
| M1 | Improper Credential Usage | ✅ Covered — keys/tokens in `flutter_secure_storage`, not in code |
| M2 | Inadequate Supply Chain Security | ❌ Not covered — no dep scanning, no obfuscation |
| M3 | Insecure Authentication/Authorization | ⚠️ Partial — biometric for push, but PIN storage and enrollment changes not specified |
| M4 | Insufficient Input/Output Validation | ⚠️ Partial — path traversal handled, but Markdown/LaTeX/prompt injection open |
| M5 | Insecure Communication | ⚠️ Partial — HTTPS enforced, but no certificate pinning |
| M6 | Inadequate Privacy Controls | ❌ Not covered — no FLAG_SECURE, no clipboard clearing, no backup exclusion |
| M7 | Insufficient Binary Protections | ❌ Not covered — no obfuscation, no debug-mode detection |
| M8 | Security Misconfiguration | ❌ Not covered — backup, exported activities, Keychain config unspecified |
| M9 | Insecure Data Storage | ⚠️ Partial — API keys secure, but drift DB unencrypted |
| M10 | Insufficient Cryptography | ⚠️ Partial — no custom crypto, but no drift encryption or key derivation |

---

## References

- `~/.agents/skills/mobile-security-audit/mobile/SKILL.md` — Audit framework with 8 security domains
- `~/.agents/skills/mobile-security-audit/references/owasp-mobile-top10.md` — OWASP Mobile Top 10 mappings
- `~/.agents/skills/mobile-security-audit/references/flutter-security.md` — Flutter/Dart-specific security checklist
- `~/.agents/skills/mobile-security-audit/references/ios-security.md` — iOS platform security reference
- `~/.agents/skills/mobile-security-audit/references/android-security.md` — Android platform security reference
- `architecture.md` §8 Security — Existing security architecture (lines 1555–1584)
- `data_model_detail.md` — drift schema (no encryption documented)

---
name: swift-security-pro
description: Use when handling sensitive data on iOS — Keychain storage, Data Protection, ATS/TLS, secrets management, and biometric (Face ID / Touch ID) authentication.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Security Pro

Protect user data and credentials. Default to the most secure option.

## When to use

- Storing tokens, passwords, or sensitive data.
- Reviewing networking, secrets handling, or auth.
- Adding biometric authentication.

Trigger: `/swift-security-pro`.

## Core principles

- Secrets go in the Keychain, never `UserDefaults` or plist.
- Never hard-code API keys/secrets in source.
- Keep App Transport Security on; require TLS.
- Use biometrics for gating access, not for storing the secret itself.

## Storing secrets

❌ UserDefaults — plaintext, backed up, readable
```swift
UserDefaults.standard.set(token, forKey: "authToken")
```
✅ Keychain
```swift
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "authToken",
    kSecValueData as String: Data(token.utf8),
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
]
SecItemDelete(query as CFDictionary)
SecItemAdd(query as CFDictionary, nil)
```
Use `...ThisDeviceOnly` accessibility so secrets don't migrate via backup.

## No hard-coded secrets

❌
```swift
let apiKey = "sk_live_abc123"   // shipped in the binary, easily extracted
```
✅
- Inject at build time (xcconfig / CI secret) or fetch from your backend.
- Never commit keys; add config files to `.gitignore`.
- Treat anything in the app bundle as public.

## Transport security

- Keep ATS enabled. Don't add `NSAllowsArbitraryLoads`.
- Use HTTPS everywhere; consider certificate pinning for high-value APIs via
  `URLSessionDelegate` `urlSession(_:didReceive:completionHandler:)`.

❌ Info.plist
```xml
<key>NSAppTransportSecurity</key><dict>
  <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```
✅ Leave ATS on; scope rare exceptions to a specific domain only.

## Data Protection

Mark sensitive files so they're encrypted at rest while locked:
```swift
try data.write(to: url, options: .completeFileProtection)
```

## Biometric auth

```swift
import LocalAuthentication
let ctx = LAContext()
var error: NSError?
if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    let ok = try await ctx.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Unlock your vault")
}
```
Biometrics gate access; the actual secret still lives in the Keychain (optionally with
`SecAccessControl` requiring biometry). Always provide a passcode fallback.

## Common mistakes checklist

- [ ] Tokens/passwords in `UserDefaults` or a plist.
- [ ] Hard-coded API keys/secrets in source or the bundle.
- [ ] `NSAllowsArbitraryLoads` / disabled ATS.
- [ ] Keychain items without `...ThisDeviceOnly` for non-syncable secrets.
- [ ] Logging tokens / PII to the console.
- [ ] Treating biometric success as the secret instead of gating Keychain access.

## Output format (when reviewing)

Per issue: file:line, the exposure, before/after fix. Lead with credential leaks and
plaintext storage.

# UX/UI Enhancement — Testing Guide

Implements [PROPOSAL_UI_UX_ENHANCEMENT.md](PROPOSAL_UI_UX_ENHANCEMENT.md).

---

## What Was Built

### 1. First-Launch Onboarding Flow

A modal window that walks new users through CodexBar on first launch.

**Three steps:**
1. **Welcome** — brief description of the app; choose "Guide me through setup" or "I know what I'm doing →"
2. **Provider Access** — scrollable cards for every enabled provider, each showing the provider icon, what data is read, and the access method (OAuth, Cookie, API Key, etc.)
3. **Summary** — checklist of configured providers; "Done" saves completion and closes the window

**Files added:**
- `Sources/CodexBar/OnboardingView.swift`
- `Sources/CodexBar/OnboardingWindowController.swift`
- `Sources/CodexBar/OnboardingProviderInfo.swift`

**Files modified:**
- `Sources/CodexBar/CodexbarApp.swift` — trigger in `applicationDidFinishLaunching`
- `Sources/CodexBar/SettingsStoreState.swift` — `hasCompletedOnboarding: Bool`
- `Sources/CodexBar/SettingsStore+Defaults.swift` — property accessor
- `Sources/CodexBar/SettingsStore.swift` — loaded from UserDefaults (defaults to `false`)

---

### 2. Data Transparency Fetch Indicator

A small pulsing dot appears in the menu bar beside each provider icon while CodexBar is actively fetching data. It disappears automatically when the fetch completes.

- In **merged-icon mode** a single dot appears for the combined icon
- Can be disabled in **Settings → General → Automation → Show fetch indicator**
- Dot pulses between 40 %–100 % opacity at 12 FPS using the existing `DisplayLinkDriver`

**Files added:**
- `Sources/CodexBar/StatusItemController+FetchingIndicator.swift`

**Files modified:**
- `Sources/CodexBar/StatusItemController.swift` — added `fetchingDotItems`, `dotAnimationDriver`, `dotAnimationPhase`; hooks into the store observation cycle
- `Sources/CodexBar/PreferencesGeneralPane.swift` — "Show fetch indicator" toggle
- `Sources/CodexBar/SettingsStoreState.swift` — `fetchingIndicatorEnabled: Bool`
- `Sources/CodexBar/SettingsStore+Defaults.swift` — property accessor (defaults to `true`)
- `Sources/CodexBar/SettingsStore.swift` — loaded from UserDefaults

---

## How to Build

```bash
# From the repo root on macOS
swift build
# Or open the Xcode project / Package.swift in Xcode and build normally
```

---

## Testing Checklist

### Onboarding

- [ ] **Fresh install — onboarding appears**
  ```bash
  defaults delete com.steipete.codexbar hasCompletedOnboarding
  ```
  Relaunch the app → welcome window should appear centered on screen.

- [ ] **"I know what I'm doing" path**
  Click the button → jumps directly to Summary → click "Done" → window closes → relaunch → onboarding does **not** appear again.

- [ ] **"Guide me through setup" path**
  Click → Provider Access screen shows a card for every enabled provider → scroll to confirm all are listed → click "Continue →" → Summary shows matching checkmarks → "Done" → relaunch → onboarding does **not** appear again.

- [ ] **Back navigation**
  On the Provider Access step, click "← Back" → returns to Welcome.

- [ ] **Re-trigger (for testing)**
  ```bash
  defaults delete com.steipete.codexbar hasCompletedOnboarding
  ```
  Relaunch → onboarding reappears.

- [ ] **All providers shown**
  Enable a few extra providers in Settings → Providers, reset `hasCompletedOnboarding`, relaunch → newly enabled providers appear in the onboarding cards.

---

### Fetch Indicator Dot

- [ ] **Dot appears during refresh**
  Open the menu → click "Refresh" (or wait for automatic refresh) → a small pulsing dot should appear in the menu bar beside the active provider icon while data is loading, then disappear.

- [ ] **Dot disabled via settings**
  Settings → General → uncheck "Show fetch indicator" → trigger a refresh → no dot appears.

- [ ] **Re-enable**
  Re-check "Show fetch indicator" → dot reappears on next refresh.

- [ ] **Merged icon mode**
  Settings → Display → enable "Merge icons" → trigger a refresh → single dot appears beside the merged icon.

- [ ] **Multiple providers**
  Enable two or more providers in separate icon mode → trigger a refresh → a dot appears next to each refreshing provider's icon separately.

---

## Known Limitations / Future Work

- Onboarding does not yet offer auth-method configuration (OAuth vs cookie vs manual); it is informational only. Full auth-method switching during onboarding can be added once provider login flows are unified.
- The dot `NSStatusItem` position in the menu bar is controlled by macOS and may not always land immediately adjacent to the provider icon; this is a system-level limitation.
- Localization support for onboarding strings is not yet implemented (future work per the proposal).

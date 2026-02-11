# Flutter Mobile Game Template — SKILLS.md (A–Z Production Contract)

> **IMPORTANT**: This is a **SKILLS** file (a development contract), **NOT** the Flutter project itself.
> - Do **NOT** run `flutter create` or add code files in this folder.
> - Do **NOT** paste huge source code here.
> - This document defines the **rules, architecture, screens, flows, SDK integrations, compliance constraints, and acceptance criteria** for a reusable Flutter mobile game template.

---

## 0) Goal, Confidence, and Decision Method

### 0.1 Goal
Build a **reusable Flutter mobile game template** that is:
- Feature-complete for a “simple” mobile game (menu → map/progression → play → results).
- Monetized with:
  - **AdMob** banner ads (non-gameplay screens)
  - **AdMob** rewarded ads (earn coins)
  - **RevenueCat** paywalls:
    - **Consumable coin packs**
    - **One-time remove ads** (non-consumable)
- Store-ready with **App Store / Google Play compliance-first** implementation.
- Stable, testable, scalable, and structured (A–Z expectations).

### 0.2 Confidence
**High** for architecture + compliance principles.
**Medium** for “single submission pass” guarantee because:
- Review decisions vary.
- Policy enforcement changes over time.
- You can still fail for metadata issues (screenshots, descriptions, age ratings, etc.).

This file is designed to maximize the probability of first-pass acceptance by eliminating common reject causes.

### 0.3 Scientific/rational method
1) Define immutable constraints (policy, UX, privacy).
2) Define app state machine (screen flows, monetization flows).
3) Define a layered architecture with strict boundaries.
4) Define error/fallback behavior for every SDK path.
5) Define measurable “Done” criteria.

---

## 1) Non‑Negotiable Principles (Hard Rules)

1) **No crashes. Ever.**
   - Ads/IAP SDK failures must degrade gracefully.

2) **No misleading monetization.**
   - Clear price, benefits, and what’s being purchased.
   - Clear “Not now / Continue” options.

3) **Restore purchases must work (iOS).**
   - Visible restore action.

4) **Single Source of Truth for entitlements and currency.**
   - Premium (ads removed) state comes from RevenueCat entitlement.
   - Coin balance changes only via CurrencyService.

5) **No business logic in Widgets.**
   - Widgets render state and forward user intents.

6) **Play screen performance prioritized.**
   - No banners inside play.
   - No heavy I/O on frame-critical code.

7) **Privacy & consent compliance.**
   - If you display personalized ads, handle consent requirements where applicable.
   - Use non-personalized ads by default if you are uncertain.

---

## 2) Product Definition

### 2.1 Core Screens (Must Exist)
1) **Boot / Splash**
2) **Onboarding Video** (first launch only)
3) **Paywall — Coins** (shown on cold start, always)
4) **Paywall — Remove Ads** (shown right after coin paywall, always)
5) **Main Menu / Home**
6) **Map / Progress**
7) **Play**
8) **Pause / Resume**
9) **Results — Score Summary**
10) **Results — New Record**
11) **Leaderboard**
12) **Shop** (spend coins)
13) **Settings**

### 2.2 Monetization Summary
- **RevenueCat**:
  - Consumable: coin packs
  - Non-consumable entitlement: remove ads
- **AdMob**:
  - Banner ads (non-gameplay)
  - Rewarded ads (earn coins)

### 2.3 Data/State Summary
- Persistent:
  - onboardingCompleted
  - premiumOwned (via RevenueCat entitlement; cached for UX)
  - coinBalance
  - inventory
  - progression
  - settings
  - session stats

---

## 3) App Start Flow (Strict State Machine)

### 3.1 Cold Start Flow (every cold start)
1) Boot
2) If onboardingCompleted == false → OnboardingVideo
3) Then ALWAYS:
   - PaywallCoins
   - PaywallRemoveAds
4) Then → MainMenu

### 3.2 First Launch vs Later Launch
- **First launch**: Boot → OnboardingVideo → PaywallCoins → PaywallRemoveAds → MainMenu
- **Later launches**: Boot → PaywallCoins → PaywallRemoveAds → MainMenu

### 3.3 Required UX behaviors
- On paywalls:
  - Show pricing clearly.
  - Provide “Continue / Not now” option.
  - Provide “Restore purchases”.
  - Show loading state while fetching offerings.
  - Do not block navigation forever (timeouts + fallback).

### 3.4 Anti-dark-pattern rule
No:
- Hidden close buttons.
- Forced waiting timers.
- Confusing copy like “Free” when it’s not.
- Prechecked traps.

---

## 4) Navigation Contract

### 4.1 Canonical Routes
- /boot
- /onboarding
- /paywall/coins
- /paywall/remove-ads
- /menu
- /map
- /play
- /pause
- /results/score
- /results/new-record
- /leaderboard
- /shop
- /settings

### 4.2 Allowed Navigation Graph
- boot → onboarding OR paywall/coins
- onboarding → paywall/coins
- paywall/coins → paywall/remove-ads
- paywall/remove-ads → menu

- menu ↔ map, leaderboard, shop, settings
- map → play
- play → pause → (resume → play) OR (quit → results)
- play → results
- results → menu OR map

### 4.3 Navigation Rules
- No circular “back stack traps”.
- Use explicit replaces for funnel steps (onboarding/paywalls) so users can’t bypass with back.
- Protect Play screen from accidental exit:
  - Confirm dialogs for quitting.

---

## 5) Architecture Contract (Clean & Scalable)

### 5.1 Layers (required)
**presentation/**
- screens/
- widgets/
- controllers/ (or viewmodels/)

**domain/**
- entities/
- usecases/
- repositories/ (interfaces)

**data/**
- repositories/ (implementations)
- datasources/
  - local/
  - sdk/ (admob/revenuecat)
  - remote/ (optional)

**core/**
- routing/
- error/
- logging/
- config/
- utils/
- localization/

### 5.2 Dependency Direction
presentation → domain → data
core may be used by all.
No reverse dependencies.

### 5.3 State Management (MANDATORY)

**Riverpod is mandatory.** Do not use mixed state management (no Bloc + Riverpod hybrids).

**Pattern:** Riverpod + immutable state via `Notifier`/`AsyncNotifier` (preferred) or `StateNotifier`.

Rules:
- UI Widgets read state via providers and send intents.
- All side effects (SDK calls, persistence, network) must go through services/usecases.
- Providers must be small, composable, and testable.

#### 5.3.1 Canonical Providers (fixed names)
These provider names are part of the contract and must remain stable across the template.

**Core app state**
- `appBootstrapProvider` — initializes services, loads cached state, triggers routing decisions
- `appSessionProvider` — app/session lifecycle, cold start detection

**Auth**
- `authProvider` — Firebase Auth user state (signed in / signed out)

**RevenueCat / Entitlements**
- `purchasesProvider` — RevenueCat client wrapper state
- `entitlementProvider` — derives `premium` entitlement state

**Ads**
- `adsGateProvider` — banner allowed? (depends on premium + screen policy)
- `bannerAdProvider` — banner load/show state
- `rewardedAdProvider` — rewarded ad state machine (idle/loading/ready/showing/completed/failed/cancelled)

**Economy**
- `coinBalanceProvider` — current coin balance
- `transactionsProvider` — rolling transaction log

**Progression & Inventory**
- `progressProvider` — map/progression/unlocks
- `inventoryProvider` — owned items

**Paywall flow**
- `paywallFlowProvider` — state machine for onboarding → coins paywall → remove ads paywall

**Settings**
- `settingsProvider` — language, audio, haptics, notifications

Provider rules:
- `entitlementProvider` is the only source of truth for premium state.
- `coinBalanceProvider` can be mutated only via CurrencyService operations.

---

### 5.4 Routing & Navigation (MANDATORY)

**GoRouter is approved and recommended.** It must enforce the funnel and provide native-feeling transitions.

Rules:
- Routes must match the canonical route paths defined in this document.
- The onboarding/paywall funnel must use `go()` / `replace` semantics so users cannot bypass steps via back.
- Protect Play screen from accidental back navigation.

#### 5.4.1 Native-feeling transitions (Smooth)
- Use platform-appropriate page transitions:
  - iOS: Cupertino-style transitions
  - Android: Material transitions

Contract:
- Menu ↔ Map/Shop/Leaderboard/Settings: fast, standard transitions
- Entering Play: emphasize (slightly stronger transition)
- Results/New Record: celebratory transition but lightweight

Performance rule:
- Transitions must not trigger expensive rebuilds; avoid heavy initialization during navigation.

---

### 5.5 Mandatory Services
- **AdsService**: banner + rewarded (AdMob)
- **PurchasesService**: RevenueCat offerings + purchase + restore
- **EntitlementService**: premium state derived from RevenueCat
- **CurrencyService**: coin balance + transaction log
- **InventoryService**: shop item ownership
- **ProgressService**: map progression/unlocks
- **LeaderboardService**: local + adapter to remote
- **SettingsService**: audio/haptics/lang/notifications
- **SessionService**: play session lifecycle + result assembly

### 5.5 Single Source of Truth
- `premiumOwned` MUST be derived from RevenueCat entitlement.
- `coinBalance` MUST be mutated only by CurrencyService.

---

## 6) SDK Integration Rules

### 6.0 SDK Choices (Fixed)
- **Authentication:** Google Sign-In via **Firebase Auth**
- **Backend foundation:** **Firebase** (Auth required; Firestore optional)
- **Purchases:** **RevenueCat**
- **Ads:** **Google Mobile Ads (AdMob)**

All architecture, flows, and compliance rules below assume these exact SDKs.


### 6.0 SDK Choices (Fixed)
- **Authentication:** Google Sign-In via **Firebase Auth**
- **Backend foundation:** **Firebase** (Auth required; other modules optional)
- **Purchases:** **RevenueCat**
- **Ads:** **Google Mobile Ads (AdMob)**

All architecture and flows in this document assume these choices.


### 6.1 RevenueCat (Required — Canonical Contract)

### 6.1.0 Dashboard Configuration (Required)

**Entitlements:**
- `premium` → removes banner ads

**Offerings:**
- `coins`
- `remove_ads`

**Products (exactly these logical tiers):**
- Consumables:
  - `coins_small`
  - `coins_medium`
  - `coins_large`
- Non-consumable:
  - `remove_ads`

> Product IDs in stores may include prefixes (e.g., `com.company.game.coins_small`) but logical mapping must remain stable forever.

---

### 6.1.1 Coin Pack Contract

| Pack | Coins | Purpose |
|-----|------|---------|
| Small | Configurable | Entry purchase |
| Medium | Configurable | Best value |
| Large | Configurable | Power users |

Rules:
- Coin amounts live in config, not UI.
- UI must explain where coins are used (shop, progression).

---

### 6.1.2 Remove Ads Contract

- Type: Non-consumable
- Entitlement: `premium`
- Effect:
  - Removes **all banner ads**
  - Rewarded ads remain optional

UI must state this clearly.

---

### 6.1.3 Restore Purchases

- Visible button on both paywalls.
- Must reconcile entitlements on app start.
- Must update UI immediately.

---


**Purpose:**
- Centralize IAP product configuration, purchases, entitlement management, and restore.

**Fixed business model (non-negotiable):**
1) **3 coin packs** (consumables) — exactly three tiers.
2) **Remove Ads** ("lifetime" one-time purchase) as a **non-consumable entitlement**.

> IMPORTANT wording rule: In UI copy, use “One-time purchase” / “Tek seferlik satın alma”.
> Avoid claiming “lifetime” unless it is truly perpetual and not subscription-based. If you use “lifetime” in marketing, ensure product is non-consumable and entitlement is permanent.

#### 6.1.1 Canonical identifiers (contract)
These identifiers must be consistent across code, RevenueCat dashboard, and store configuration.

- **Entitlement:** `premium`  (removes banner ads)
- **Offerings:**
  - `coins` (primary offering for consumables)
  - `remove_ads` (primary offering for remove ads)

- **Coin packs (exactly three):**
  - `coins_small`
  - `coins_medium`
  - `coins_large`

> The actual App Store / Play product IDs can vary (e.g., `com.company.game.coins_small`), but mapping must remain stable.

#### 6.1.2 Paywall sequence (hard requirement)
- **PaywallCoinsScreen** shows `coins` offering.
- On Continue/Not now/Purchase completion → **PaywallRemoveAdsScreen**.
- **PaywallRemoveAdsScreen** shows `remove_ads` offering.

If `premium` already owned:
- The remove-ads paywall must show “Already owned” state and a fast Continue.

#### 6.1.3 Purchase behaviors
- Offerings load:
  - Must use timeout + retry.
  - Must show loading skeleton and graceful fallback.

- Purchase flow must handle:
  - success
  - userCancelled
  - failure (network/SDK/store)

- Restore purchases:
  - Must be visible on BOTH paywalls (at minimum on remove-ads paywall).
  - Must show user-safe success/fail messaging.

#### 6.1.4 Granting coins (consumables)
- On successful purchase of a coin pack:
  1) Determine purchased pack tier.
  2) CurrencyService adds the correct coin amount.
  3) Write transaction log entry with source `iap_revenuecat`.

Coin amounts must be configured in a single config file, e.g.:
- small = X coins
- medium = Y coins
- large = Z coins

No hardcoded amounts in UI.

#### 6.1.5 Remove Ads effect
- `premium` entitlement removes **banner ads**.
- Rewarded ads remain optional and can still be shown as a choice to earn coins.
- AdsService must check entitlement before showing banners.

#### 6.1.6 Store compliance requirements
- Show localized prices from RevenueCat/store.
- Do not hide costs.
- Do not block user from proceeding without purchase (must allow “Continue/Not now”).
- Restore purchases must be present and working.

### 6.2 AdMob (Required)

**Ad types:**
- Banner
- Rewarded

**General rules:**
- Use test ad unit IDs in debug builds.
- Never show banner on Play.
- Never place banners over interactive elements.
- Rewarded ad: grant reward only on completion.
- Rewarded ads must be user-initiated.

**Ad Request Options:**
- Prefer non-personalized ads by default unless consent flow is implemented.
- Provide a compliance-friendly path for users to review privacy policy.

**Ad types:**
- Banner
- Rewarded

**General rules:**
- Use test ad unit IDs in debug.
- Never show banner on Play.
- Never place banners over interactive elements.
- Rewarded ad: grant reward only on completion.
- Rewarded ad should not require user to watch ad to continue core gameplay (avoid “gating progression” dark patterns). It should be optional.

**Ad Request Options:**
- Prefer non-personalized ads if consent handling is not implemented.
- Provide a compliance-friendly path for users to adjust ad personalization if applicable.

---

## 7) Monetization UX Specification

### 7.1 Banner Placement Policy
Allowed screens:
- Menu
- Map/Progress
- Shop
- Leaderboard
- Settings (optional)

Forbidden screens:
- Play
- Pause overlay
- Onboarding video
- Paywalls (default: off)
- Results (optional; recommended: off)

Placement rule:
- Reserve bottom safe area container.
- Content must not be covered.

### 7.2 Rewarded Ads Policy
Use cases:
- “Watch ad to earn X coins”
- “Watch ad to reroll / continue” (optional; be careful with fairness)

Constraints:
- Daily limit (configurable)
- Cooldown between claims
- Fail states:
  - Not loaded
  - Network error
  - Show failed
  - User closed early

Reward rule:
- Reward only after `onUserEarnedReward` (or SDK equivalent) event.

### 7.3 Paywall Copy Rules
- Must clearly say:
  - what user gets
  - price
  - that payment is handled by Apple/Google
- Remove Ads must specify what it removes:
  - Banners (yes)
  - Rewarded ads (no; still optional)

---

## 8) Game Loop & Screens (Detailed Requirements)

### 8.1 Boot / Splash
- Minimal duration.
- Initialize:
  - logging
  - local storage
  - localization
  - RevenueCat
  - AdMob (initialize lazily if possible)
  - load cached app state

### 8.2 Onboarding Video (first launch)
Requirements:
- Fullscreen background video.
- Controls hidden.
- Must have:
  - Skip button
  - Continue button
  - 2–4 slides overlay (optional)
- Must not crash if video fails:
  - fallback to static image

### 8.3 Paywall — Coins
- Display coin packs with localized prices.
- Show what coins are used for (shop items, progression, cosmetics).
- Provide:
  - Buy buttons
  - Continue / Not now
  - Restore purchases
  - Legal links: Terms / Privacy
- Must show loading skeleton while fetching offerings.

### 8.4 Paywall — Remove Ads
- Display remove ads product.
- Must clarify:
  - “Removes banner ads.”
  - “Rewarded ads remain optional.”
- Provide:
  - Buy
  - Continue / Not now
  - Restore purchases
  - Terms / Privacy

### 8.5 Main Menu
- Clear entry points:
  - Play
  - Map/Progress
  - Shop
  - Leaderboard
  - Settings
- Display:
  - coin balance
  - premium badge if owned
- Banner allowed.

### 8.6 Map / Progress
- Level/zone nodes.
- Locked/unlocked states.
- Progression rules controlled by ProgressService.
- Banner allowed.

### 8.7 Play
- No banners.
- Frame critical: minimize rebuilds.
- Pause button.
- SessionService controls:
  - start
  - end
  - compute result

### 8.8 Pause / Resume
- Resume
- Quit
- Settings shortcuts (sound)
- No banners.

### 8.9 Results — Score Summary
- Show score, coins earned (if any), next actions.
- New record detection: if true navigate to NewRecord screen.

### 8.10 Results — New Record
- Celebration animation (lightweight).
- Share button (optional).

### 8.11 Leaderboard
- Local leaderboard at minimum.
- Remote adapter optional.
- Banner allowed.

### 8.12 Shop
- Categories:
  - cosmetic
  - power-up
  - unlocks
- Each item:
  - id
  - nameKey
  - descriptionKey
  - priceCoins
  - ownershipType
- Purchase flow:
  - check coins → deduct → grant → persist
- Banner allowed.

### 8.13 Settings
Must include:
- Language
- Sound/music toggles
- Haptics
- Notifications (optional)
- Restore purchases
- Manage privacy/ads (link)
- Reset onboarding (debug-only)

---

## 9) Currency & Economy (Strict)

### 9.1 CurrencyService rules
- Only CurrencyService can mutate balance.
- Provide atomic operations:
  - addCoins(reason)
  - spendCoins(reason)
- Every operation creates a transaction entry:
  - id
  - timestamp
  - delta
  - reason
  - source (rewarded_ad / iap / gameplay / admin)

### 9.2 Reward Grants
- Rewarded ad grant:
  - awarded only on completion event
  - must be idempotent (avoid double grant on duplicate callbacks)

### 9.3 Economy tuning
- All coin rewards/prices stored in config.
- No magic numbers in UI.

---

## 10) Persistence & Storage (Offline-First)

### 10.1 Offline-first principle
The game must be fully playable offline.
- Core gameplay, progression, shop purchases (with coins), settings, and local leaderboard must work with no network.
- Online features degrade gracefully:
  - Global leaderboard becomes local-only
  - Cloud sync pauses and retries later

### 10.2 Required persisted keys
- schemaVersion
- onboardingCompleted
- cachedEntitlementPremium (cache only; reconcile with RevenueCat on start)
- coinBalance
- inventory
- progress
- settings
- transactionLog (rolling window)
- antiCheatSignals (rolling window)

### 10.3 Schema versioning
- Include schemaVersion.
- If schemaVersion changes:
  - migrate old data safely
  - never crash
  - if migration fails, fallback to safe defaults but preserve what you can

### 10.4 Data integrity
- Validate numeric ranges (coinBalance >= 0)
- Clamp corrupted values
- Reject impossible state transitions

---


### 10.1 Required persisted keys
- schemaVersion
- onboardingCompleted
- cachedEntitlementPremium
- coinBalance
- inventory
- progress
- settings
- transactionLog (rolling window)

### 10.2 Schema versioning
- If schemaVersion changes:
  - migrate old data safely
  - never crash
  - if migration fails, fallback to safe defaults but preserve what you can

### 10.3 Data integrity
- Validate numeric ranges (coinBalance >= 0)
- Clamp corrupted values

---

## 11) Localization & Accessibility

### 11.1 Localization rules
- No hardcoded strings.
- Use `en` and `tr` minimum.
- Use correct Turkish characters.

### 11.2 Accessibility rules
- Ensure tappable targets are large enough.
- Provide semantic labels for primary actions.
- Support text scaling without overflow.

---

## 12) Notifications & Permissions (Required)

### 12.1 Scope
- Use **push notifications** only if you need them (events, rewards, reminders).
- Use **local notifications** for offline-safe reminders.

### 12.2 Permission UX contract
- Never request notification permission at first frame.
- Permission request should happen after a clear user action (e.g., enabling a toggle in Settings) or after onboarding.
- Provide a Settings screen section:
  - Toggle: Notifications
  - Button: Open system notification settings

### 12.3 Offline behavior
- If offline, local notifications still work.
- Remote push delivery depends on network; app must not break.

---

## 13) Anti-Cheat & Anti-Abuse (Practical, Offline-Compatible)

> You cannot fully prevent cheating in a client-side offline game. You can only **reduce trivial abuse** and protect online surfaces.

### 13.1 Design goal
- Protect online leaderboard and monetization integrity.
- Make common “easy cheats” (memory edits, time jumps, replay callbacks) less effective.

### 13.2 Principles
- **Never trust the client** for online submissions.
- Prefer server-side checks for:
  - leaderboard scores
  - premium ownership (RevenueCat)

### 13.3 Client-side signals (best-effort)
The client must maintain a rolling set of anti-cheat signals:
- abnormal score delta per second
- impossible progression jumps
- time manipulation indicators (system time change, extreme session duration)
- repeated rewarded completion events in unrealistic cadence

Rules:
- Signals must never crash the game.
- Signals can:
  - disable online submissions temporarily
  - require re-login
  - reduce/deny optional rewards (rewarded coins) when clearly abusive

### 13.4 Leaderboard submission hardening (required)
- Leaderboard submissions must go through **server function** (`submitScore`).
- The server enforces:
  - authentication required
  - rate limiting
  - plausibility checks (score bounds, cadence, per-level caps)
  - write rules: user can only improve own best score

### 13.5 Rewarded ads anti-abuse (required)
- Reward granted only on completion event.
- Must be idempotent per impression (store an impression id / timestamp token).
- Cooldown + daily limit enforced locally.
- If abuse signals fire, rewarded coin grants can be suspended until next day or until network verification.

---

## 14) Monetization Integrity (Coins + Purchases)

### 14.1 Coin integrity
- Coin balance can only be mutated by CurrencyService.
- Every mutation creates a transaction log entry.
- On app start, validate:
  - coinBalance >= 0
  - recent transaction sequence is consistent
- If corruption detected:
  - clamp to safe values
  - flag antiCheatSignals

### 14.2 RevenueCat purchase integrity
- Premium state comes from RevenueCat entitlement (`premium`).
- Never store “premiumOwned=true” as a permanent local truth.
  - It may be cached for UX but must be reconciled on every app start.

### 14.3 Consumable coin packs
- Coins are granted only after RevenueCat confirms purchase success.
- Grant is logged and must be idempotent.
  - If the app restarts mid-grant, recovery must avoid double grant.

### 14.4 Restore purchases
- Restore must update entitlement and UI instantly.
- If restore fails, show retry and support link.

---

## 15) Error Handling & User Messaging

### 15.1 Error taxonomy
- NetworkError
- SdkError
- UserCancelled
- Timeout
- Unknown

### 15.2 UX rules
- Never show raw stack traces.
- Provide user-safe messages.
- Provide retry actions where appropriate.

### 15.3 SDK fallback requirements
- If RevenueCat offerings fail:
  - show fallback UI with retry + continue
- If AdMob fails:
  - hide ad placeholders
  - allow user to continue

---


### 12.1 Error taxonomy
- NetworkError
- SdkError
- UserCancelled
- Timeout
- Unknown

### 12.2 UX rules
- Never show raw stack traces.
- Provide user-safe messages.
- Provide retry actions where appropriate.

### 12.3 SDK fallback requirements
- If RevenueCat offerings fail:
  - show fallback UI with retry + continue
- If AdMob fails:
  - hide ad placeholders
  - allow user to continue

---

## 13) Performance Contract

### 13.1 Frame safety
- Play screen: no blocking IO, no heavy JSON parsing.
- Preload assets in non-critical screens.

### 13.2 Rebuild control
- Use selectors/providers carefully.
- Avoid rebuilding whole trees on coin changes.

---

## 14) App Store / Play Store Compliance Checklist (Anti-Reject Contract)

> This section exists **specifically** to reduce first-review rejection risk.
> It encodes the most common Apple App Store Review + Google Play Console rejection causes for mobile games with ads + IAP.

### 14.1 In-App Purchase (RevenueCat) – Critical Rules

**Apple & Google requirements:**
- All digital content must use in-app purchase (no external payments).
- Restore purchases must be present and functional (mandatory on iOS).
- Prices must be displayed using store-localized values.

**Hard rules enforced by this template:**
- Paywalls always show:
  - Price
  - What the user gets
  - Restore Purchases button
  - Continue / Not Now button
- No misleading wording:
  - ❌ “Free” when it’s not
  - ❌ “Trial” unless there is an actual trial
  - ❌ Hidden close buttons

**Terminology rule (important):**
- Use **“One-time purchase” / “Tek seferlik satın alma”** instead of “Lifetime” in UI copy.

---

### 14.2 Ads (AdMob) – Critical Rules

**Banner ads:**
- Must not be placed where accidental taps are likely.
- Must not overlap core gameplay or navigation controls.
- Must be removed immediately when `premium` entitlement is active.

**Rewarded ads:**
- Must be user-initiated.
- Must clearly state the reward **before** showing the ad.
- Reward is granted **only** after full completion event.
- Must not gate core gameplay progression (rewarded ads are optional boosts).

---

### 14.3 Authentication (Firebase + Google Sign-In)

**Rules to avoid rejection:**
- Login must not be mandatory unless core app functionality requires it.
- Game must be playable without sign-in.
- Login can be required for:
  - Leaderboards
  - Cloud save

**UI requirements:**
- Login prompt must clearly explain why sign-in is requested.
- Logout option must exist in Settings.

---

### 14.4 Privacy & Legal

**Must-have:**
- Privacy Policy URL (accessible from Settings and Paywalls).
- Terms of Service URL.
- Disclosure of:
  - Ads usage
  - Purchases
  - Analytics (if used)

**Ads privacy:**
- If personalized ads are enabled, user consent must be respected where required.
- If unsure, default to non-personalized ads.

---

### 14.5 Metadata & Store Listing Pitfalls

Common rejection causes **outside code**:
- Screenshots do not match actual gameplay.
- Paywall screenshots hide prices.
- Description claims features not present.
- Age rating mismatch (especially with ads + IAP).

This template assumes store metadata will be configured honestly and accurately.

---


> This section is **policy-minded** (common reject triggers). Always verify current policies, but these rules avoid the most frequent issues.

### 14.1 IAP compliance
- Must have restore purchases (iOS).
- Must not misrepresent pricing.
- Must not lock core functionality behind payment without clear messaging.

### 14.2 Ads compliance
- Ads must not mimic UI.
- Ads must not be placed where accidental taps are likely.
- Rewarded ads must be user-initiated.

### 14.3 Privacy
- Provide Privacy Policy link.
- Provide Terms link.
- If collecting identifiers for ads/analytics, disclose.

### 14.4 Kids / Age rating
- If targeting children, ad/IAP rules become stricter.
- Default design: target general audience.

---

## 15) Authentication & Firebase Requirements

### 15.1 Google Auth via Firebase (Required)

**Goal:**
- Provide a consistent identity for:
  - Leaderboard entries
  - Cloud save (optional future)
  - Fraud reduction (basic)

**Rules:**
- Use **Firebase Auth** with **Google Sign-In**.
- Provide a guest/anonymous mode ONLY if explicitly desired; default is Google sign-in.
- Sign-in must never hard-block the user from playing unless your game logic requires it.
  - If leaderboard requires login, allow play offline and prompt login when accessing leaderboard.

**UX contract:**
- Clear login button on Menu and Leaderboard.
- Clear logout in Settings.
- Handle token expiry silently and re-auth when needed.

**Error handling:**
- If Firebase is unavailable:
  - allow offline play
  - show local leaderboard

### 15.2 Data ownership
- Do not store sensitive personal data beyond what’s necessary.
- Store only:
  - user uid
  - display name (if available)
  - avatar URL (optional)

---

## 16) Build & Release Requirements

### 16.1 Flavors
- dev
- staging
- prod

### 16.2 Secrets
- Never commit API keys.
- Use env/config injection.

### 16.3 Crash reporting (recommended)
- Use a crash reporting tool in release builds.

---


### 15.1 Flavors
- dev
- staging
- prod

### 15.2 Secrets
- Never commit API keys.
- Use env/config injection.

### 15.3 Crash reporting (recommended)
- Use a crash reporting tool in release builds.

---

## 16) Testing Strategy & Definition of Done

### 16.1 Required UI states per screen
For each screen implement:
- loading
- success
- error
- empty (if applicable)

### 16.2 Monetization scenarios
- RevenueCat:
  - offerings load success/fail
  - purchase success
  - purchase cancelled
  - purchase failed
  - restore success/fail
- AdMob:
  - banner load success/fail
  - rewarded load success/fail
  - rewarded shown → reward granted
  - rewarded shown → closed early (no reward)

### 16.3 Done criteria (must pass)
- App start flow correct
- No banner on play
- Rewarded grants coins only after completion
- Premium removes banners
- Purchases restore works
- No crashes on airplane mode
- All text localized
- All screens navigable

---

## 17) Flutter Project Folder & File Structure (Canonical)

> This section defines the **exact folder map** expected when generating a Flutter project from this SKILLS contract.

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── economy_config.dart
│   │   └── ad_config.dart
│   ├── routing/
│   │   └── app_router.dart
│   ├── error/
│   │   └── app_error.dart
│   ├── logging/
│   │   └── logger.dart
│   ├── localization/
│   │   ├── l10n.dart
│   │   └── strings/
│   │       ├── en.json
│   │       └── tr.json
│   └── utils/
│       └── guards.dart
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   ├── firebase/
│   │   ├── revenuecat/
│   │   └── admob/
│   └── repositories/
│
├── presentation/
│   ├── controllers/
│   ├── screens/
│   │   ├── boot/
│   │   ├── onboarding/
│   │   ├── paywall/
│   │   ├── menu/
│   │   ├── map/
│   │   ├── play/
│   │   ├── pause/
│   │   ├── results/
│   │   ├── leaderboard/
│   │   ├── shop/
│   │   └── settings/
│   └── widgets/
│
└── services/
    ├── ads_service.dart
    ├── purchases_service.dart
    ├── currency_service.dart
    ├── inventory_service.dart
    ├── progress_service.dart
    ├── leaderboard_service.dart
    ├── session_service.dart
    └── auth_service.dart
```

Rules:
- No SDK calls outside `services/`.
- No business logic inside widgets.

---

## 18) Paywall UI Text — Store Safe Templates (TR / EN)

### 18.1 Coin Paywall (EN)
- Title: Get Coins
- Subtitle: Use coins to unlock items and progress faster
- CTA: Buy
- Secondary CTA: Continue
- Footer: One-time purchases. Payment handled by the app store.

### 18.2 Coin Paywall (TR)
- Başlık: Coin Satın Al
- Alt metin: Coin’leri mağazada harca ve daha hızlı ilerle
- CTA: Satın Al
- İkincil CTA: Devam Et
- Dipnot: Tek seferlik satın alma. Ödeme uygulama mağazası tarafından yapılır.

### 18.3 Remove Ads Paywall (EN)
- Title: Remove Ads
- Description: Removes all banner ads
- Note: Rewarded ads remain optional
- CTA: Buy
- Secondary CTA: Continue

### 18.4 Remove Ads Paywall (TR)
- Başlık: Reklamları Kaldır
- Açıklama: Tüm banner reklamları kaldırır
- Not: Ödüllü reklamlar isteğe bağlı olarak kalır
- CTA: Satın Al
- İkincil CTA: Devam Et

---

## 19) Rewarded Ad Economy Rules

- Cooldown: configurable (default 5 minutes)
- Daily limit: configurable (default 5 views)
- Reward formula: fixed coin amount per completion
- Grant only once per ad impression
- Log every grant in transaction log

---

## 20) DB & API Strategy (Recommended)

### 20.0 Firebase CLI — Mandatory Setup

All backend resources **must be created and managed via Firebase CLI**.
No manual console-only setup is allowed except where explicitly required by Google.

**Required tools:**
- Node.js (LTS)
- Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase --version
```

---

### 20.1 Firebase Project Initialization

Create and bind the project:

```bash
firebase projects:create your-game-id
firebase use your-game-id
firebase init
```

During `firebase init`, enable:
- Firestore
- Functions
- Authentication

Do NOT enable Hosting unless needed.

---

### 20.2 Authentication Setup (CLI + Console)

**Auth provider:** Google Sign-In

Steps:
1. Enable Authentication via CLI init.
2. In Firebase Console (one-time):
   - Enable Google provider
   - Set support email

Rules:
- No custom auth flows.
- UID from Firebase Auth is the **only** user identifier.

---

### 20.3 Firestore Data Model (Contract)

Collections:

```
users/{uid}
  - displayName
  - avatarUrl
  - createdAt

leaderboards/{seasonId}/entries/{uid}
  - score
  - updatedAt

seasons/{seasonId}
  - startAt
  - endAt
```

Rules:
- Client must NOT write leaderboard scores directly.
- Client may read leaderboard data.

---

### 20.4 Cloud Functions (API Layer)

Functions must be written in **TypeScript**.

Required functions:

```ts
submitScore(uid, score, metadata)
getLeaderboard(seasonId)
```

Rules:
- All writes to `leaderboards/*` go through functions.
- Validate:
  - auth token
  - rate limit
  - score plausibility

Deploy:

```bash
firebase deploy --only functions,firestore
```

---

### 20.5 Firestore Security Rules (High-Level)

Principles:
- Users can read public leaderboard data.
- Users can read/write **only their own user profile**.
- Leaderboard writes forbidden from client.

Rules must enforce:
- request.auth != null for protected reads
- deny writes to leaderboard paths

---

### 20.6 Local Development & Emulators

Use Firebase Emulator Suite for development:

```bash
firebase emulators:start
```

Emulators:
- Auth
- Firestore
- Functions

Flutter app must support emulator configuration via env flags.

---

### 20.7 Offline & Sync Rules

- Firestore reads cached where possible.
- Writes queued only via Functions when online.
- Retry with exponential backoff.

---



### 20.1 Online
- **Firestore** for leaderboard data and minimal user profile.
- **Cloud Functions** as API layer:
  - `submitScore`
  - `getLeaderboard`

### 20.2 Local
- Local DB (Isar or Drift) for:
  - progression
  - inventory
  - coin balance
  - settings
  - local leaderboard

### 20.3 Offline rules
- Game must function without network.
- Online sync retries with backoff.

---

## 21) Leaderboard Strategy

- Local leaderboard always available
- Firebase leaderboard requires login
- Offline fallback automatic
- Server-side submission validation required
- Sync on login

---


- Local leaderboard always available
- Firebase leaderboard requires login
- Offline fallback automatic
- Sync on login

---

## 21) Final Ship Checklist (Hard Gate)

- [ ] Onboarding video fallback works
- [ ] Paywalls always appear on cold start
- [ ] Restore purchases verified on real device
- [ ] Banner ads removed instantly after premium
- [ ] Rewarded ads never double-grant
- [ ] Login optional, leaderboard gated
- [ ] App playable offline
- [ ] All text localized (EN/TR)
- [ ] Privacy policy & terms reachable
- [ ] No crashes without internet

---


- [ ] Screen set complete (Boot, Onboarding Video, Paywall Coins, Paywall Remove Ads, Menu, Map, Play, Pause, Results, New Record, Leaderboard, Shop, Settings)
- [ ] RevenueCat integrated (offerings, purchase, restore, entitlement)
- [ ] AdMob integrated (banner + rewarded, test IDs in debug)
- [ ] Currency + transactions + shop integrated
- [ ] Persistence + schema migration
- [ ] Localization en/tr
- [ ] Privacy policy & terms links accessible
- [ ] Performance: play screen smooth
- [ ] Offline-safe behavior

---

## 18) Practical Store Submission — Final Checklist

### 18.1 App Store Connect (iOS)
- In-app purchases created and approved (coin packs + remove ads).
- RevenueCat products mapped correctly.
- App Review Information filled:
  - Demo account (if needed)
  - Notes explaining paywall flow
- Privacy policy URL added.

### 18.2 Google Play Console (Android)
- Managed products created (consumables + non-consumable).
- Data safety form completed.
- Ads declaration completed.

### 18.3 Before Upload (Hard Gate)
- Test on:
  - No internet
  - Slow internet
  - Logged in / logged out
  - Premium owned / not owned
- Verify:
  - Restore purchases works
  - Ads hide immediately after remove ads purchase
  - Rewarded ads never double-grant coins

---

**End of SKILLS.md**
 (Non-code)

Even with perfect code, rejections can happen due to:
- Missing privacy policy URL
- Incorrect age rating
- Misleading screenshots
- Metadata mismatches
- In-app purchase setup not complete in App Store Connect / Play Console

This template assumes you will complete store-side configuration correctly.

---

**End of SKILLS.md**



---

## 22) Game Brief (MANDATORY — Supplied Per Game)

> This section must be provided **together with this SKILLS.md** when generating a game.
> SKILLS.md defines **HOW** the system works. Game Brief defines **WHAT** the game is.

### GAME BRIEF TEMPLATE

- **Game Name:**
- **Core Loop (1 sentence):**
- **Win / Lose Conditions:**
- **Target Session Length (seconds):**
- **Controls:** (tap / swipe / drag / mixed)
- **Difficulty Curve:** (linear / exponential / adaptive)
- **Scoring Formula (explicit):**
- **Progression Model:** (levels / map / endless)
- **Shop Items:**
  - itemId | type (cosmetic / power-up / unlock) | coinPrice | effect
- **Coin Sources:**
  - gameplay reward
  - rewarded ad reward
- **Leaderboard:** (local / global / seasonal)
- **Audio / Haptics:** (on/off)
- **Art Direction Hint (non-binding):**

Rules:
- Ambiguous briefs will not be guessed.
- If something is not specified here, the safest default is used.

---

## 23) UI Extensibility Contract (UI Will Change)

### 23.1 UI is Disposable
- UI may be redesigned entirely without touching business logic.
- No game logic, monetization, auth, or persistence code inside UI widgets.

### 23.2 Screen Contract Pattern
Each screen must declare:
- **Inputs:** state it consumes
- **Outputs:** user intents/events

Screen behavior must remain stable even if visuals change.

### 23.3 Design System Requirement
- Single theme entry point
- Centralized colors, typography, spacing
- Reusable components (buttons, cards, dialogs)

### 23.4 Feature Flags
- leaderboardEnabled
- notificationsEnabled
- cloudSyncEnabled
- rewardedContinueEnabled

Flags control visibility only — logic must remain intact.

---

## 24) One-Shot Generation Guarantee

If the following are provided together:
1. This **SKILLS.md**
2. A completed **Game Brief**

Then the system must be able to:
- Generate a fully functional Flutter mobile game
- With ads, purchases, auth, backend, offline support
- Ready for iterative UI redesign without architectural refactor

---

**END OF SKILLS.md — FINAL**


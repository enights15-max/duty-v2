# Scarlet Editorial Closeout Plan

Date: `2026-04-02`
Owner: `Codex + product team`
Scope: `Flutter consumer app + Flutter professional surfaces + admin/pro web`
Goal: close the Scarlet Editorial migration in one controlled round, freeze the visual system, and move to the next project area without carrying theme drift.

## 1. Definition of Done
Scarlet can be considered closed when all of the following are true:

1. No legacy purple/dark theme hardcodes remain in active UI code, except approved third-party brand colors.
2. Consumer app passes light/dark QA on critical routes.
3. Professional mobile surfaces pass light/dark QA on critical routes.
4. Admin/professional web passes light-first QA on critical routes.
5. Shared components use theme tokens instead of screen-local palette decisions.
6. Semantic colors are applied consistently:
   - Brand: `Primary Scarlet`
   - Errors: `Danger`
   - Success: `Success`
   - Warnings: `Warning`
   - Info: `Info`
7. A final exception list exists for approved non-Scarlet colors.

## 2. Freeze Rules
These rules apply from the start of the closeout:

1. No new inline theme colors.
2. No screen-level palette reinvention.
3. No layout redesign unless a visual bug blocks closeout.
4. Third-party brand colors are allowed only for:
   - card brands
   - social networks
   - map/provider brands
   - explicit partner branding
5. Any remaining visual issue must be solved with:
   - tokens
   - semantic colors
   - spacing/contrast adjustments
   - component cleanup

## 3. Severity Model
Use this to triage findings before fixing anything.

### P0
- unreadable text
- broken contrast in key CTA
- invisible icons or labels
- theme regression causing interaction confusion
- light/dark mode that makes a critical screen unusable

### P1
- wrong semantic color in financial or safety-related flow
- major inconsistency in a high-traffic screen
- dialogs, snackbars, or alerts clearly using the retired palette
- broken component state hierarchy

### P2
- cosmetic inconsistency
- residual old color in a low-risk area
- non-critical mismatched border/background/text tone

### P3
- polish-only refinements
- aesthetic opportunity without current usability impact

## 4. Execution Strategy
We execute the closeout in four passes only.

### Pass A. Visual Audit
Output:
- one consolidated finding list
- each item tagged `P0-P3`
- each item mapped to screen/component

Rule:
- do not fix while auditing unless the issue is a trivial blocker to continue reviewing

### Pass B. Fix Batch
Output:
- one grouped implementation round
- fixes applied by surface family, not randomly

Rule:
- prefer token or component-level fixes before screen-level overrides

### Pass C. Validation
Output:
- `flutter analyze`
- `php artisan view:cache`
- manual screenshot pass on target surfaces

Rule:
- if validation fails, loop only on failing files; do not reopen the full scope

### Pass D. Freeze
Output:
- final decision log
- exception list
- closeout note

Rule:
- after freeze, Scarlet changes become backlog work, not open-ended polish

## 5. Screen Audit Checklist

### Consumer App
Audit all of these in `light` and `dark`:

1. Home
2. Search
3. Explore
4. Event Details
5. Checkout
6. Payment CC
7. Ticket Success
8. Wallet
9. Withdrawal
10. Blackmarket
11. Scanner
12. My Code
13. My Tickets
14. Ticket Details
15. Transfer flows
16. Reservations
17. Reservation Create
18. Reservation Details
19. Loyalty
20. Chat
21. Social Connections
22. Public User Profile
23. Artist Profile
24. Venue Profile
25. Organizer Profile
26. Discovery Directory

Checklist per screen:
- background and surface hierarchy
- primary CTA
- secondary CTA
- app bar / nav bar
- chips / pills / badges
- snackbars
- dialogs / bottom sheets
- empty state
- loading state
- error state
- semantic coloring on warnings/errors/success
- safe-area behavior in light/dark

### Auth + Identity
Audit in `light` and `dark`:

1. Login
2. Signup
3. Phone Login
4. OTP Verification
5. Phone Verification Link
6. Forgot Password
7. Email Setup
8. Complete Profile
9. User Type Selection
10. Auth Lock
11. Onboarding
12. Account Center
13. Account Verification
14. Identity Request
15. Profile Switcher

Checklist:
- hero/background gradient
- field states
- disabled buttons
- verification/error messaging
- warning and danger semantics
- confirmation dialogs

### Professional Mobile
Audit in `light` and `dark`:

1. Professional Dashboard
2. My Events
3. Professional Stats
4. Event Create/Edit
5. Event Tickets
6. Event Inventory
7. Collaborations
8. Withdrawal

Checklist:
- financial cards
- collaboration cards
- settlement/treasury states
- warning and hold messaging
- action buttons
- data-heavy panels

### Admin / Professional Web
Audit in `light-first`:

1. Admin Dashboard
2. Economy Dashboard
3. Fee Policies
4. Events Index
5. Event Edit
6. Reservations Index
7. Reservation Details
8. Booking Details
9. Withdraw create/edit/view
10. Withdraw form builder
11. Maintenance Mode
12. Professional web shell pages already themed

Checklist:
- nav/sidebar/header coherence
- table readability
- filter bars
- metric cards
- modal readability
- badge semantics
- form density and contrast

## 6. Component Audit Checklist
This pass is mandatory even if all screens look "fine".

### Buttons
- primary button
- outlined button
- text button
- destructive button
- disabled button

### Pills / Chips / Badges
- active
- inactive
- warning
- success
- danger
- info
- premium/highlight

### Feedback
- snackbar
- toast-like feedback
- inline validation
- alert box
- info banner
- warning banner
- danger banner

### Containers
- cards
- sheets
- dialogs
- modals
- empty states
- loaders
- skeletons

### Navigation
- bottom navbar
- app bars
- top tabs
- segmented controls
- profile/account switchers

### Data UI
- tables
- list tiles
- stats blocks
- financial summaries
- transaction rows

## 7. Approved Color Exceptions
These should remain allowed and not be "normalized away":

1. card brands:
   - Visa
   - AMEX
   - Mastercard
   - Discover
2. social brands:
   - Instagram
   - Facebook
   - TikTok
   - X/Twitter
   - LinkedIn
   - WhatsApp
   - Spotify
   - SoundCloud
   - YouTube
3. maps/provider accents when brand recognition matters
4. asset-native artwork inside event posters or user-uploaded media

Everything else should map back to theme tokens.

## 8. Exact Execution Order
This is the order recommended to minimize thrash.

### Step 1. Audit Consumer App
Focus first on:
- Event Details
- Checkout
- Wallet
- Blackmarket
- Scanner
- Tickets

### Step 2. Audit Auth + Identity
Focus on:
- Identity Request
- Account Center
- Verification
- Email Setup

### Step 3. Audit Professional Mobile
Focus on:
- Dashboard
- Event Inventory
- Collaborations
- Event Create/Edit

### Step 4. Audit Admin / Web
Focus on:
- Economy
- Fee Policies
- Events Index/Edit
- Reservations / Withdraw

### Step 5. Run Fix Batch
Apply fixes in this order:
- tokens
- shared components
- screen-specific fixes
- admin web polish

### Step 6. Validation
Required commands:

```bash
cd /Users/monkeyinteractive/DEV/v2/flutter/cliente_v2
flutter analyze
```

```bash
cd /Users/monkeyinteractive/DEV/v2
php artisan view:cache
```

### Step 7. Freeze
Record:
- final exceptions
- unresolved non-blockers
- next module selected

## 9. Deliverables
At the end of the closeout we should have:

1. this plan
2. one consolidated finding list
3. one grouped fix batch
4. one validation note
5. one freeze note with approved exceptions

## 10. Recommended Next Module After Scarlet
Once Scarlet is closed, move immediately to a higher-value product area.

Recommended next priority:

### Option A. Financial Operations
- settlement admin workflows
- treasury review tooling
- refund operations UX
- collaborator finance reporting

### Option B. Professional Operations
- event authoring refinement
- inventory ops
- collaboration admin
- treasury claim/admin approval flows

Recommendation:
- move to `Financial Operations` next, because the treasury/settlement foundation is already advanced and will benefit more from uninterrupted focus than continued theme polish.

## 11. Closeout Instruction
Do not keep Scarlet as an open-ended stream of small tweaks.

Use this rule:
- audit once
- fix once
- validate once
- freeze
- move on

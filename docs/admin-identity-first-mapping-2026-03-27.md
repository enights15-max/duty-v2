# Admin Mapping: Legacy Modules vs Identity-First

## Goal
Map each admin module to:
- source tables it reads/writes today
- canonical tables it should depend on long-term
- bridge layer currently used
- migration priority toward identity-first

## Executive Summary
The admin panel is hybrid today.

- `customers` remains a real first-class consumer account domain.
- `organizers`, `artists`, and `venues` still power many admin screens as legacy actor records.
- `identities` is the modern canonical layer for professional accounts.
- `identity_members` is the canonical ownership/membership layer.
- `ProfessionalCatalogBridgeService` is the main compatibility bridge between legacy actor IDs and professional identities.

## Canonical Direction
- Consumer account: `customers`
- Personal/professional account graph: `users` + `identities` + `identity_members`
- Professional financial layer: `identity_balances` + `identity_balance_transactions`
- Professional ownership of events: `events.owner_identity_id`, `events.venue_identity_id`

---

## Module Matrix

| Admin module | Main screens/routes | Source tables today | Canonical tables long-term | Current bridge/use of identities | Migration priority |
| --- | --- | --- | --- | --- | --- |
| Customers Management | `customer-management/*` | `customers`, `bookings`, `wishlists`, `wallets`, `ticket_transfers` | `customers` stays canonical for consumer domain; optional bridge to `users`/`identities(personal)` | Low identity coupling today | P3 |
| Organizer Management | `organizer-management/*` | `organizers`, `organizer_infos`, `events`, `transactions` | `identities(type=organizer)`, `identity_members`, `identity_balances`; legacy `organizers` as support table only | Yes: resolves organizer identity through `ProfessionalCatalogBridgeService`; already reads professional balance with identity context | P1 |
| Artist Management | `artist-management/*` | `artists` | `identities(type=artist)`, `identity_members`, `identity_balances` | Minimal today; mostly legacy CRUD | P1 |
| Venue Management | `venue-management/*` | `venues`, `events` | `identities(type=venue)`, `identity_members`, `identity_balances`, `events.venue_identity_id` | Minimal in management controller; stronger identity usage exists in venue runtime controllers | P1 |
| Identity Management | `identity-management/*` | `identities`, `identity_members`, `users` | `identities`, `identity_members`, `users` | This is already the canonical professional account module | Keep as central authority |
| Review Management | `review-management/*` | `reviews` plus actor references | `identities` for professional targets/ownership where possible | Partial/indirect | P2 |
| Withdraw Requests | `withdraw/withdraw-request` | `withdraws` plus legacy actor columns | `identities` + identity-linked withdraw actor resolution | Already has hybrid actor resolution in admin withdraw controller | P2 |
| Events (admin) | event management screens | `events`, `event_contents`, `tickets`, legacy `organizer_id`, legacy `venue_id` | `events.owner_identity_id`, `events.venue_identity_id`, `identities` | Already partially migrated; ownership bridge exists | P1 |

---

## Data Relationships

### Consumer side
- `customers` is still the operational consumer account table.
- App auth and many consumer actions still start from `customers`.
- In identity-aware flows, `customers` is often matched to `users` by email.

### Professional side
- `identities.owner_user_id -> users.id`
- `identity_members` assigns owner/admin/member access to the identity.
- Professional identities carry legacy linkage in `identities.meta.legacy_id` or `meta.id`.

### Legacy bridge
- `ProfessionalCatalogBridgeService::findIdentityForLegacy(type, legacyId)` maps:
  - organizer legacy row -> organizer identity
  - artist legacy row -> artist identity
  - venue legacy row -> venue identity

### Event ownership
- Organizer-owned events should resolve through `events.owner_identity_id`.
- Venue assignment should resolve through `events.venue_identity_id`.
- Legacy `organizer_id` and `venue_id` still exist as compatibility rails.

### Professional balances
- Consumer money: `wallets`, `wallet_transactions`
- Professional balances: `identity_balances`, `identity_balance_transactions`

---

## Screen-by-Screen Reading of the Admin

### 1. Customers Management
Files:
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/BackEnd/CustomerManagementController.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/customer/index.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/customer/details.blade.php`

Current role:
- This is not a professional account module.
- It manages the consumer record itself.
- Keep it separate from professional identity moderation.

Recommendation:
- Do not force this module into identity-first too early.
- Only add light visibility of linked `user` / personal identity when useful.

### 2. Organizer Management
Files:
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/BackEnd/Organizer/OrganizerManagementController.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/organizer/index.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/organizer/details.blade.php`

Current role:
- Still edits legacy organizer rows.
- Already resolves professional identity for balance and actor-aware finance.

Recommendation:
- First professional module to migrate harder.
- Evolve this into an operational view over the organizer identity, not the primary source of truth.

### 3. Artist Management
Files:
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/BackEnd/Organizer/ArtistManagementController.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/artist/index.blade.php`

Current role:
- Mostly plain legacy CRUD.
- Weak identity coupling compared with organizer.

Recommendation:
- Add identity badge/status/owner linkage first.
- Then shift edit flows toward identity-backed professional profile data.

### 4. Venue Management
Files:
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/BackEnd/Organizer/VenueManagementController.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/venue/index.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/venue/details.blade.php`

Current role:
- Legacy CRUD with event listing support.
- Canonical venue ownership in runtime is already moving toward identity.

Recommendation:
- Same treatment as artists.
- Bring identity relationship and status into the admin first, then migrate edit/ops flows.

### 5. Identity Management
Files:
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/BackEnd/IdentityManagementController.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/identity/index.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/end-user/identity/show.blade.php`

Current role:
- This is already the canonical admin surface for professional accounts.
- Handles moderation lifecycle:
  - approve
  - reject
  - request info
  - suspend
  - reactivate

Recommendation:
- Keep this as the center of truth for professional account state.
- Other legacy modules should increasingly become downstream views of this layer.

---

## Recommended Migration Order

### P1. Organizer / Artist / Venue Management
Why first:
- These are the legacy admin modules that overlap most directly with professional accounts.
- They create confusion if they disagree with `Identity Management`.
- Organizer is already partially bridged, so it is the lowest-friction starting point.

Recommended sequence:
1. Organizer Management
2. Artist Management
3. Venue Management

Concrete first changes:
- show linked identity ID / status / owner on index + details
- show moderation state from `identities`
- stop treating legacy row as the only truth for account state
- route balance and activity through identity-aware services where possible

### P2. Withdraw + Review + Event admin surfaces
Why second:
- These modules already touch professional actors but often through mixed legacy/canonical data.
- Once management screens are aligned, these become easier to normalize.

Concrete first changes:
- expose identity actor consistently in withdraw list/detail
- normalize review targets to professional identity where applicable
- keep event ownership centered on `owner_identity_id` / `venue_identity_id`

### P3. Customer Management refinement
Why later:
- Customer is not the same domain as a professional account.
- It should stay separate, with only optional cross-links to identity/user.

Concrete first changes:
- add linked user/personal identity visibility
- add linked professional profiles section in customer detail if helpful

---

## What “Identity-First Admin” Should Mean

For admin, identity-first should mean:
- professional account state is owned by `identities`
- ownership and access are owned by `identity_members`
- legacy actor tables are support/compatibility records, not the main authority
- screens may still display legacy fields, but moderation and account truth come from the identity layer

---

## Practical Rule of Thumb

When a screen answers:
- “Who is this professional account?” -> use `identities`
- “Who owns or manages it?” -> use `identity_members` / `users`
- “What old row is it linked to?” -> use `ProfessionalCatalogBridgeService`
- “What does the consumer account look like?” -> use `customers`

---

## Suggested Next Admin Refactor

If we want the next concrete admin move, the best one is:

1. Refactor Organizer Management index/details to display identity-first status and ownership.
2. Mirror that pattern into Artist Management and Venue Management.
3. Leave Identity Management as the moderation source of truth.

That would remove a lot of conceptual duplication without forcing a dangerous full rewrite.

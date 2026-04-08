# Scarlet Editorial Audit Findings

Date: `2026-04-02`
Phase: `Pass A - Visual Audit`
Scope reviewed:
- Flutter consumer app
- Flutter professional / identity surfaces
- admin / professional Blade views

This document is the consolidated finding list to drive the final Scarlet fix batch.

## Summary
Scarlet is now structurally in place and the legacy purple theme has been largely removed. The remaining work is no longer about palette direction. It is about:

1. finishing tokenization in a few high-visibility screens
2. removing dark-locked styling that blocks clean light mode behavior
3. normalizing semantic components on the web side

## Priority Findings

### P1. Venue and organizer public profiles are still dark-locked
Files:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/events/presentation/pages/venue_profile_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/events/presentation/pages/organizer_profile_page.dart`

Why it matters:
- these screens no longer use the old purple theme, but they still rely heavily on hardcoded `Colors.white`, `Colors.black`, alpha overlays, and locally defined surfaces
- that means they visually fit Scarlet in dark mode, but do not fully inherit light/dark behavior from the theme system

Impact:
- inconsistent visual language compared with the rest of the app
- higher risk of unreadable contrast if light mode is expected here later

Recommended fix:
- move text, borders, overlays, and card surfaces to `context.dutyTheme`
- keep only approved third-party brand colors and media overlays as exceptions

### P1. Identity request is functionally migrated but still uses many local color decisions
File:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/identity_request_page.dart`

Why it matters:
- the page already maps to Scarlet semantically, but it still contains many direct `Colors.white`, `Colors.black`, and local card/fill/border decisions
- because this is a long and dense authoring form, inconsistencies here multiply quickly across chips, upload cards, map panels, and field groups

Impact:
- this is one of the most important operational forms in the app
- visual inconsistency here undermines the “finished system” feeling more than smaller surfaces

Recommended fix:
- do a component-first pass inside this file:
  - inputs
  - helper text
  - upload cards
  - selection cards
  - modal overlays
  - bottom action bar

### P1. Reservations are still effectively dark-first, not theme-first
Files:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/shop/presentation/pages/reservations_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/shop/presentation/pages/reservation_create_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/shop/presentation/pages/reservation_details_page.dart`

Why it matters:
- these files now reference Scarlet colors, but still do so through local static constants like `_bg` and `_accent`
- they will look visually aligned in dark mode, but are not truly driven by theme tokens at runtime

Impact:
- inconsistent behavior against the rest of the consumer app
- higher maintenance cost if theme tokens are adjusted later

Recommended fix:
- replace local static color constants with `context.dutyTheme`
- only keep semantic accents where needed

### P1. Admin and professional web still rely on Bootstrap semantic classes outside the Scarlet component layer
Representative files found by scan:
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/contact.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/event/create.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/event/edit.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/artist/withdraw/create.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/organizer/withdraw/index.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/organizer/support_ticket/create.blade.php`
- plus many other `btn-success`, `btn-danger`, `alert-*`, and `badge-*` usages across Blade templates

Why it matters:
- the shared Scarlet light theme is loaded, but many pages still depend on framework defaults for:
  - buttons
  - alerts
  - badges
  - warnings
  - destructive states
- that causes the panel to feel “mostly Scarlet” instead of fully systematized

Impact:
- visual inconsistency in heavy operational pages
- support/admin surfaces may still read as mixed-brand

Recommended fix:
- create a final component normalization pass for web:
  - map `.btn-success`, `.btn-danger`, `.btn-warning`
  - map `.alert-*`
  - map `.badge-*`
  - ensure these classes inherit Scarlet semantic colors consistently

### P2. Some Flutter screens still use neutral hardcodes instead of theme neutrals
Representative files:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/account_center_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/account_verification_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/public_user_profile_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/artist_profile_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/events/presentation/pages/event_details_page.dart`

Why it matters:
- the old palette is gone, but many screens still use direct `Colors.white`, `Colors.white70`, `Colors.white54`, `Colors.black.withValues(...)`
- these are acceptable in some hero/media contexts, but too frequent in content/UI layers

Impact:
- small but visible inconsistency
- harder future maintenance if text hierarchy or contrast tokens evolve

Recommended fix:
- restrict hardcoded whites/blacks to:
  - image overlays
  - poster/media legibility
  - explicit visual art treatments
- everything else should map to:
  - `textPrimary`
  - `textSecondary`
  - `textMuted`
  - `border`
  - `surface`

### P2. Event Details still has a few old-style contrast decisions in secondary layers
File:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/events/presentation/pages/event_details_page.dart`

Why it matters:
- the primary flow is already Scarlet-aligned
- what remains are smaller secondary details:
  - white overlays
  - transparent surfaces
  - fallback messaging visuals

Impact:
- not a blocker, but this is a flagship screen and should read as the strongest reference implementation

Recommended fix:
- tighten contrast on secondary panels and button-disabled states
- ensure overlays use theme-aware neutral opacity where possible

## Approved Exceptions
These are not findings and should remain allowed:

1. card brand colors
2. social network brand colors
3. map/provider brand colors
4. user-uploaded posters/media
5. explicit media overlay treatments required for readability

## Recommended Fix Batch Order

### Batch 1. Flutter P1
1. `venue_profile_page.dart`
2. `organizer_profile_page.dart`
3. `identity_request_page.dart`
4. `reservation_create_page.dart`
5. `reservation_details_page.dart`
6. `reservations_page.dart`

### Batch 2. Flutter P2
1. `event_details_page.dart`
2. `account_center_page.dart`
3. `account_verification_page.dart`
4. `artist_profile_page.dart`
5. `public_user_profile_page.dart`

### Batch 3. Web semantic normalization
1. map Bootstrap semantic classes into Scarlet
2. confirm alerts, badges, and button variants visually match the token system
3. spot-check high-traffic admin pages after that normalization

## Exit Condition For Pass B
We can consider the final Scarlet fix batch complete when:

1. P1 findings above are resolved
2. P2 findings are reduced to approved exceptions only
3. `flutter analyze` remains clean
4. `php artisan view:cache` remains clean
5. manual screen review shows no obvious mixed-brand surfaces

## Recommendation
Do one grouped fix batch against the findings above and then freeze Scarlet. Do not continue with ad hoc visual touches after that batch unless they are blocking defects.

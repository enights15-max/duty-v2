# Scarlet Editorial Freeze Note

Date: `2026-04-02`
Status: `FROZEN`
Owner: `Codex + product team`

## Freeze decision

The Scarlet Editorial migration is considered closed for the current project phase.

We are explicitly stopping open-ended theme work here so the team can move to higher-value product and operations work.

## Final system baseline

### Brand
- `Primary Scarlet`: `#C1121F`
- `Primary Deep`: `#8A0F18`

### Dark foundations
- `Background`: `#100E14`
- `Surface`: `#18151D`
- `Surface alt`: `#211922`

### Light foundations
- `Background`: `#F6F2ED`
- `Surface`: `#FFFFFF`
- `Surface alt`: `#FAF1ED`

### Semantic colors
- `Success`: `#238A57`
- `Warning`: `#C68500`
- `Danger`: `#D32F2F`
- `Info`: `#4459E6`

## Approved exceptions

The following colors remain intentionally allowed:

1. Third-party brand colors
   - card brands
   - social networks
   - map/provider branding
2. User-uploaded media and event artwork
3. Black image overlays used strictly for readability on photo/video headers
4. Bootstrap semantic class names in Blade templates, provided they are visually remapped by the Scarlet partials

## Accepted non-blockers

These are accepted and should not reopen Scarlet by default:

1. Deep cosmetic refinements on low-traffic screens
2. Replacing every remaining neutral hardcode that does not create visible drift
3. Renaming legacy semantic CSS classes in old Blade templates

## Reopen policy

Scarlet should only be reopened if one of these is true:

1. a new screen launches without using tokens
2. a critical light/dark contrast issue appears
3. a financial or safety-related semantic color is misleading
4. a new design decision changes the brand direction materially

Otherwise, Scarlet changes go to backlog and should be bundled into a future dedicated visual pass.

## Recommended next module

Move to:
- `Financial Operations`

Priority areas:
1. settlement admin workflows
2. treasury review tooling
3. refund operations UX
4. collaborator finance reporting

## Closeout instruction

From this point forward:
- do not keep polishing Scarlet incrementally
- only patch regressions
- move product focus to the next operational module

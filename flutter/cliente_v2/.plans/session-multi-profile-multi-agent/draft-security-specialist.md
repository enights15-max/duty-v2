# Draft Plan - Security Specialist

## Summary
Implement a robust Role-Based Access Control (RBAC) system to ensure that only authorized profiles can perform sensitive actions like event creation and ticket management.

## Permission Matrix

| Action | Consumer | Artist | Organizer | Venue |
|--------|----------|--------|-----------|-------|
| Buy Tickets | Yes | Yes | Yes | Yes |
| Create Events | No | No | Yes | Yes |
| Manage Sales | No | No | Yes | Yes |
| Profile Personalization | Yes | Yes | Yes | Yes |
| Scan Tickets (Check-in) | No | No | Yes | Yes |

## Verification Logic
- **Event Creation**: On the backend, verify `current_profile_id` belongs to an entity of type `Organizer` or `Venue`.
- **Profile Switching**: Ensure the `user_id` of the requested `profile_id` matches the authenticated `JWT` token's `sub` field.
- **Roles**: Implement a `claims` system in the JWT or a frequent `user_info` check to synchronize permissions on the frontend.

## Secure Flow
1. User logs in.
2. Initial user data includes roles and owned profiles.
3. Profile switching requires a valid request that updates the `active_profile` state globally.
4. UI elements (like "New Event" button) are guarded by a `RoleGuard` widget.

## Risks & Alternatives
- **Risk**: Stale permissions if a user is demoted from an organization.
- **Fix**: Force profile re-sync or use short-lived tokens.

## Dependencies
- Needs **Architecture Specialist** to provide the `metadata` structure for storing role specific flags.
- Needs **Product/UI Specialist** to handle the "Unauthorized" UI states.

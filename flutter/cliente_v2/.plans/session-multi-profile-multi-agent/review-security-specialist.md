# Review - Security Specialist

## Reviewing draft-architecture-specialist.md
- **Strengths**: Data model separation (Identity vs Entity) is a best practice.
- **Concerns**: User Identity should have a master "Admin" flag or super-role, independent of individual profiles.
- **Alignment**: Aligned on `user_id` ownership of profiles.
- **Conflicts**: None.

## Reviewing draft-product-ui-specialist.md
- **Strengths**: "Switch Profile" workflow is very user-friendly.
- **Concerns**: Ensure that switching profiles is an "authenticated" action (maybe re-check password or bio-auth for high-risk profiles).
- **Alignment**: Aligned on themed Admin dashboards.
- **Conflicts**: None.

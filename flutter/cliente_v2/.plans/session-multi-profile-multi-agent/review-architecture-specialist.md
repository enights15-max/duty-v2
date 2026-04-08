# Review - Architecture Specialist

## Reviewing draft-product-ui-specialist.md
- **Strengths**: Clear distinction between personal and managed profiles. Visual indicators for "Admin Mode" are great.
- **Concerns**: Switching profiles shouldn't just be a UI refresh; the backend needs to respect the active profile in every request. We need a way to pass `X-Profile-ID` headers.
- **Alignment**: Perfectly aligned with the `activeProfileProvider` concept.
- **Conflicts**: None.

## Reviewing draft-security-specialist.md
- **Strengths**: Permission matrix is comprehensive. Verification logic for JWT claims is solid.
- **Concerns**: Need to ensure the `claims` in JWT don't make the token too large if a user has many profiles. Maybe a separate "Profile Info" endpoint is better.
- **Alignment**: Aligned with the need for backend-enforced permissions.
- **Conflicts**: None.

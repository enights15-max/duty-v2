# Refined Plan - Architecture Specialist

## Addressing Reviews
- **X-Profile-ID**: Every API request will now include an `X-Active-Profile-ID` header. The backend will use this to scope queries and authorize actions.
- **Profile Info Endpoint**: Instead of bloating the JWT, we will implement a `GET /auth/me` or `GET /profiles/active` endpoint that returns full metadata and permissions for the currently active profile.
- **Metadata Schemas**: We will define specific `ProfileMetadata` subclasses in Flutter to ensure type safety for different profile types (e.g., `VenueMetadata` with address/capacity).

## Final Data Model
- **User**: Global identity with `is_super_admin` flag.
- **Profile**: Specific identity with `type`, `metadata`, and `permissions` hash.

## Riverpod Final State
- `activeProfileProvider`: Read-only provider for current profile.
- `profileNotifierProvider`: Managed by `ProfileController` to handle switches and updates.

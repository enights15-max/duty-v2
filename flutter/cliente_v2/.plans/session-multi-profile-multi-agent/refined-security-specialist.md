# Refined Plan - Security Specialist

## Addressing Reviews
- **Master Admin Flag**: `User` model now includes `is_super_admin`. This role bypasses individual profile checks for troubleshooting.
- **Authenticated Switching**: Switching to a `Professional` profile for the first time in a session will trigger a Bio-auth (FaceID/Fingerprint) or Pin verification.
- **Token Handling**: Use Refresh Tokens effectively to ensure that a profile switch also refreshes the session context on the backend.

## Final Security Checks
- All sensitive operations (Sales, Check-ins) checked against both `user_id` and `active_profile_id`.
- Profile visibility is strictly controlled by `is_public` flag.

# Draft Plan - Architecture Specialist

## Summary
The goal is to create a flexible data structure that allows a single User to manage multiple Profiles (Consumer, Artist, Venue, Organizer).

## Data Models

### User (Identity)
- `id`: UUID
- `email`: String
- `name`: String
- `current_profile_id`: UUID (Foreign Key to Profiles)

### Profile (Entity)
- `id`: UUID
- `user_id`: UUID (Owner)
- `type`: Enum (Consumer, Artist, Venue, Organizer)
- `name`: String
- `bio`: String
- `metadata`: JSON (Profile-specific data like "genre" for Artists, "address" for Venues)
- `avatar_url`: String
- `is_public`: Boolean

## Approach

### 1. Multi-Profile Separation
For **Organizers** and **Venues**, the `User` account acts as the administrative layer. The `Profile` contains the public-facing information. A single `User` can own one or more `Profiles`.

### 2. State Management (Riverpod)
- `profilesProvider`: Fetches and stores the list of profiles owned by the current user.
- `activeProfileProvider`: Tracks which profile the user is currently using.
- `profileController`: Handles switching profiles and updating profile metadata.

### 3. API Structure
- `GET /profiles`: List current user's profiles.
- `POST /profiles`: Create a new profile (e.g., if a Consumer want to become an Artist).
- `PATCH /profiles/{id}`: Update profile data.
- `GET /profiles/{id}/dashboard`: Fetch administrative data (sales, attendees) - Only for Organizer/Venue.

## Risks & Alternatives
- **Risk**: Complexity in UI if too many profile switches are needed.
- **Alternative**: Keep profiles semi-linked where a user is always a "Consumer" but has optional "Professional" features enabled. (Decided against this for better separation).

## Dependencies
- Needs **Security Specialist** to define who can create what type of profile.
- Needs **Product/UI Specialist** to design the profile switcher.

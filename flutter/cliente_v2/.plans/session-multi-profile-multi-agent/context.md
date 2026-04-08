# Multi-Profile Planning Context

## Goal
Implement a multi-profile system where users can have different roles and entities (Consumer, Artist, Venue, Organizer).

## Requirements
- **Profiles**: User (Consumer), Artist, Venue, Organizer.
- **Permissions**: Only Organizer and Venue can create events and sell tickets.
- **Structure**:
    - **Organizer/Venue**: User account for administration + independent public profile for the entity.
    - **Artist**: Representation profile (can be the same as the user account).
    - **Consumer**: Profile linked to the user account.
- **UI/UX**: Needs a premium proposal for how this works in the app.

## Target Platform
Flutter mobile app.

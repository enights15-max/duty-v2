# Feature-based Architecture

This project follows a feature-first Clean Architecture approach.

## Structure
Each feature (e.g., `auth`, `events`, `shop`) has its own directory with:

- **data**: Repositories implementations, API sources, Models.
- **domain**: Entities, Repository Interfaces, Use Cases.
- **presentation**: Widgets, Pages, State Management (Providers/Blocs).

## Core
Shared code like API clients, specific widgets, and constants are in `lib/core`.

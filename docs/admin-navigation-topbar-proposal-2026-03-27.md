# Admin Navigation Proposal

Date: 2026-03-27

## Goal

Replace the current long admin menu with a modular navigation system that supports two layouts:

1. `Sidebar`
2. `Topbar`

Both layouts should share the same information architecture. Only the presentation changes.

## Design Principles

1. Keep top-level navigation short.
2. Group by business function, not by legacy table names.
3. Separate daily operations from CMS/system settings.
4. Make the new `identity-first` model visible in the information architecture.
5. Let each admin choose `Sidebar` or `Topbar`.

## Recommended Top-Level Navigation

### 1. Dashboard

- Dashboard

### 2. Operations

- Events
  - Add Event
  - All Events
  - Venue Events
  - Online Events
- Event Specs
  - Settings
  - Categories
  - Countries
  - States
  - Cities
- Bookings
  - All Bookings
  - Completed
  - Pending
  - Rejected
  - Report
- Reservations
  - All Reservations
  - Active
  - Completed
  - Expired
- Coupons
- Tax & Commission
- Booking Preferences
- Blackmarket
  - Listed Tickets
  - Settings
- Support
  - Settings
  - All Tickets
  - Pending
  - Open
  - Closed

### 3. People

- Customers
  - Registered Customers
  - Add Customer
- Professional Accounts
  - Professional Identities
  - Organizers
  - Artists
  - Venues
- Community
  - Reviews
  - Subscribers
- Wallets
  - Customer Wallets

## Note

Inside `People`, `Professional Accounts` should become the visual home of the professional model:

- Professional Identities
- Organizers
- Artists
- Venues

This keeps the admin aligned with the `identity-first` migration.

### 4. Finance

- Transactions
- Payouts
  - Payout Methods
  - Withdraw Requests
- Payments
  - Stripe

### 5. Growth

- Push Notifications
  - Settings
  - Send Notification
- Ads
  - Settings
  - Advertisements
- Popups
- Email Audience
  - Subscribers
  - Mail to Subscribers

### 6. Content

- Website Content
  - Hero Section
  - Section Titles
  - Event Features
  - How It Works
  - Partners
  - Testimonials
  - About Us
  - Section Hide/Show
- Footer
  - Content & Color
  - Quick Links
  - Contact Page
- Pages
  - Custom Pages
  - Menu Builder
- Blog
  - Categories
  - Blog Posts
- FAQ

### 7. System

- Settings
  - General Settings
  - Email Settings
    - Mail From Admin
    - Mail To Admin
    - Mail Templates
  - Breadcrumb
  - Page Headings
  - SEO
  - Maintenance Mode
  - Cookie Alert
  - Footer Logo
  - Social Medias
  - Plugins
- App
  - Mobile App Settings
  - PWA Settings
  - PWA Scanner Setting
  - Open PWA Scanner
- Admins
  - Role & Permissions
  - Registered Admins
- Languages
  - Language Management
  - Admin Language Keywords

## Topbar Behavior

The topbar should show only the top-level groups:

1. Dashboard
2. Operations
3. People
4. Finance
5. Growth
6. Content
7. System

Each item opens a dropdown or mega-menu.

## Recommended Topbar Layout

### Desktop

- Left:
  - Logo
  - Top-level navigation items
- Right:
  - Search
  - Quick create button
  - Layout switcher
  - Admin profile menu

### Mobile / Narrow widths

- Collapse topbar items into a single menu button
- Keep:
  - Logo
  - Search
  - Profile

## Sidebar Behavior

Sidebar should use the same module grouping as the topbar.

That means the sidebar should also be reorganized into:

1. Dashboard
2. Operations
3. People
4. Finance
5. Growth
6. Content
7. System

This is important.

If the sidebar keeps the old structure and the topbar uses the new structure, admins will feel like they are switching between two different products.

## Navigation Layout Switcher

### Placement

Recommended location:

- top-right admin menu

Label:

- `Navigation Layout`

Options:

- `Sidebar`
- `Topbar`

### Persistence

Recommended:

- save preference per admin user in database

Fallback:

- local storage for instant UI switching

## Suggested Implementation Phases

### Phase 1. Information Architecture

- Reorganize the current sidebar into the new module groups.
- Do not change behavior yet.

### Phase 2. Dual Navigation Support

- Support both:
  - `side navbar`
  - `top navbar`
- Render one or the other from the same navigation config.

### Phase 3. Admin Preference

- Add `navigation_layout` preference:
  - `sidebar`
  - `topbar`

### Phase 4. UI Polish

- Improve dropdowns / mega-menus
- Improve search
- Improve responsive behavior

## Recommended First Build Scope

For the first implementation, keep scope tight:

1. Reorganize current sidebar using the new groups
2. Add topbar skeleton with the same groups
3. Add layout switcher
4. Leave styling polish for the next pass

## Decision Summary

This proposal keeps the admin manageable by:

- reducing top-level noise
- grouping the product by operational domain
- making `Professional Identities` easier to find
- preparing the panel for both `Sidebar` and `Topbar` navigation

## Recommended Next Step

Implement the new grouped structure in:

- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/partials/side-navbar.blade.php`

and then create a parallel:

- `/Users/monkeyinteractive/DEV/v2/resources/views/backend/partials/top-navigation.blade.php`

using the same module tree.

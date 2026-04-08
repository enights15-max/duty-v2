# Refined Plan - Product/UI Specialist

## Addressing Reviews
- **Real-time Sync**: If a profile is switched or a permission revoked, the app will listen to a `permissionUpdateStream` (via Socket.io or polling) to show a "Permission Revoked" overlay.
- **Identity Indicator**: A persistent, subtle badge will be added to the bottom of the Screen or inside the AppBar showing `(Professional Mode: Entity Name)`.
- **Theming**: Professional mode will use a deeper `Dark Purple` theme to distinguish it from the `Consumer Blue/Purple` theme.

## Switcher UI
- A card-based switcher with haptic feedback.
- "Add Profile" button always visible to allow expansion.
- Preview of public profile before switching.

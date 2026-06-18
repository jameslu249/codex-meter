# Architecture

Codex Meter is a SwiftPM macOS app. It uses SwiftUI for the widget and settings UI, with small AppKit controllers for menu-bar and floating-panel behavior.

## Runtime Flow

1. `AppDelegate` starts the menu-bar app, creates the widget panel, creates the settings window, and starts auto-refresh.
2. `WidgetStore` owns observable app state and lightweight preferences.
3. `CodexAuthTokenReader` reads the local Codex auth file.
4. `UsageClient` calls the usage endpoint.
5. `RateLimitResetClient` calls the reset-credit endpoint.
6. `MeterWidgetView` renders Reset Bank, usage meters, Spark grouping, and controls.

For user-facing behavior, see [APP_FUNCTIONS.md](APP_FUNCTIONS.md).

## Key Files

```text
Sources/CodexMeter/App/AppDelegate.swift
Sources/CodexMeter/Controllers/WidgetWindowController.swift
Sources/CodexMeter/Stores/WidgetStore.swift
Sources/CodexMeter/Services/CodexAuthTokenReader.swift
Sources/CodexMeter/Services/UsageClient.swift
Sources/CodexMeter/Services/RateLimitResetClient.swift
Sources/CodexMeter/Models/UsageSnapshot.swift
Sources/CodexMeter/Views/MeterWidgetView.swift
Sources/CodexMeter/Views/SettingsView.swift
```

## Auth Boundary

The app reads:

```text
~/.codex/auth.json
```

It extracts the access token and keeps it in memory only for the request. Token handling should remain inside `CodexAuthTokenReader` and the endpoint clients.

Do not add logging around auth headers or raw auth-file contents.

## Endpoint Boundary

The app calls two ChatGPT backend endpoints:

```text
GET /backend-api/wham/usage
GET /backend-api/wham/rate-limit-reset-credits
```

These are not public API contracts. Decode defensively, keep optional fields optional, and show honest unavailable states when fields are absent.

## UI State

`WidgetStore` stores preferences in `UserDefaults`:

- selected color mood
- auto-refresh enabled
- refresh interval
- show/hide Spark meters
- meter style

All network refreshes flow through `WidgetStore.refresh()` so loading, errors, usage, and reset-credit state stay consistent.

## Meter Rules

Codex Meter displays remaining capacity:

- 90-100%: green
- 20-89%: amber
- 0-19%: red

The decorative color mood should not override depletion status colors.

Spark usage is grouped separately because it appears as a separate backend meter. Spark 5h can fall back to 100% when absent. Spark weekly should only render when a Spark secondary window is present.

## Window Behavior

The widget panel is borderless, floating, resizable, and resettable.

The top-right control with `arrow.up.right.square` resets the panel to the default size and top-right position. It is not an expand button.

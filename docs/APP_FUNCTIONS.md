# App Functions

This document explains what Codex Meter does at runtime and how each user-facing control should behave.

## Menu-Bar App

Codex Meter runs as a menu-bar utility, not a Dock app. The app uses `LSUIElement` so it stays out of the Dock and app switcher.

Expected behavior:

- left-click the menu-bar icon to show or hide the widget
- right-click or Control-click the icon to open the app menu
- keep the app running when the widget is hidden
- quit only when the user chooses Quit from the menu

## Floating Widget

The widget is a floating AppKit panel with a SwiftUI view inside it. It is designed to sit near the top-right corner of macOS, above normal windows.

Expected behavior:

- the panel can be dragged
- the panel can be resized
- closing or hiding the panel keeps the menu-bar app alive
- Reset Position and Size restores the default frame and top-right placement

## Header Buttons

The widget header contains three icon buttons:

- Refresh: calls the backend immediately and updates Reset Bank plus usage meters.
- Reset Position and Size: restores the widget to the default size and top-right position.
- Hide: hides the widget while leaving the menu-bar app running.

The reset-position button uses `arrow.up.right.square`. It is a placement reset, not an expand/fullscreen control.

## Reset Bank

Reset Bank shows the currently available reset credits returned by:

```text
GET https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

Each reset credit should show:

- reset number
- availability status
- granted date
- expiration date

Granted and expiration dates should remain visible near the top of the widget so users do not need to scroll to find them.

## Usage Remaining

Usage Remaining shows remaining capacity from:

```text
GET https://chatgpt.com/backend-api/wham/usage
```

Supported meters:

- Codex 5h
- Codex weekly
- Codex-Spark 5h
- Codex-Spark weekly

The app displays remaining capacity, not consumed capacity. For example, `97%` means 97% appears available.

## Codex-Spark Behavior

Codex-Spark meters are grouped separately from regular Codex usage because they represent a distinct backend usage bucket.

Expected behavior:

- Spark 5h should display as `100%` when the user enables Spark meters and the backend has not returned Spark usage yet.
- Spark weekly should display only when the backend returns a Spark weekly or secondary window.
- Spark meters should visually stand out from regular Codex meters.

## Meter Styles

Users can choose the meter presentation in Settings:

- Circular
- Bars
- Battery

All styles use the same underlying usage percentages and health colors.

## Health Colors

Codex Meter colors meters by remaining capacity:

- Green: 90-100%
- Amber: 20-89%
- Red: 0-19%

These colors should always describe usage health. Decorative color themes should not override them.

## Refresh Behavior

The app can refresh manually or automatically.

Manual refresh:

- widget Refresh button
- menu-bar Refresh Now item
- settings Refresh Now button

Automatic refresh:

- controlled by Settings
- uses the selected refresh interval
- keeps previous values visible while a refresh is in progress
- shows a readable error state if auth or networking fails

## Local Data

Codex Meter reads the Codex auth token from:

```text
~/.codex/auth.json
```

The token is kept in memory only for requests to ChatGPT backend endpoints. The app stores UI preferences in `UserDefaults`.

Do not log, display, persist, or include tokens in bug reports.

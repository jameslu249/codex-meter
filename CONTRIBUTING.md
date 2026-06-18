# Contributing To Codex Meter

Thanks for helping make Codex Meter calmer, safer, and more useful.

This project should stay small: native SwiftUI/AppKit, no analytics, no tracking, no account system, and no unnecessary dependencies.

## Before You Start

1. Open an issue for behavior changes or endpoint payload changes.
2. Keep auth and token handling private.
3. Avoid posting raw responses from private ChatGPT endpoints.
4. Prefer small pull requests with one clear purpose.

## Local Setup

```bash
swift build
./script/build_and_run.sh --verify
```

The app expects a local Codex auth file at:

```text
~/.codex/auth.json
```

If that file is missing or expired, the app should show a clear local-auth error state rather than crashing.

## Pull Request Checklist

- `swift build` passes.
- `./script/build_and_run.sh --verify` passes when you change app behavior.
- UI text remains readable in the default widget size.
- Menu-bar actions still work: show/hide, refresh, reset position and size, settings, quit.
- Tokens are never printed, logged, stored, or displayed.
- Documentation is updated for user-facing behavior changes.

## Design Principles

- Make the widget glanceable first.
- Keep reset-credit details visible without scrolling.
- Make Spark usage visually distinct from regular Codex usage.
- Use status colors for remaining capacity, not decorative theme colors.
- Prefer native macOS controls and system affordances.
- Keep cards at small radii and avoid nested-card clutter.

## Security Rules

Do not include any of these in issues, pull requests, screenshots, or test fixtures:

- `~/.codex/auth.json`
- access tokens
- cookies
- account ids
- raw private endpoint responses
- private usage history tied to a real account

If you need a fixture, create a minimal redacted JSON payload that preserves only the fields needed for the bug.

## Good First Issues

- Add launch-at-login support.
- Add keyboard shortcuts for refresh and show/hide.
- Add alternate corner placement.
- Improve VoiceOver labels and keyboard focus.
- Add unit tests for payload decoding.
- Add a signed and notarized release workflow.

## Release Work

Release changes should follow [docs/RELEASE.md](docs/RELEASE.md).

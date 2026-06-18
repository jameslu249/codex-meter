# Security

Please do not include access tokens, cookies, account ids, or private Codex auth files in issues or pull requests.

If you find a security problem, use GitHub private vulnerability reporting if it is enabled on the repository. If private reporting is not enabled yet, open a minimal public issue that says you need a private disclosure channel, but do not include exploit details or private account data.

Codex Meter depends on a local Codex auth file and unofficial ChatGPT backend endpoints. Treat both as implementation details that may change.

## Sensitive Data

Never post:

- `~/.codex/auth.json`
- access tokens
- cookies
- account ids
- raw private endpoint responses
- screenshots that reveal private usage or account details

## Maintainer Checklist

Before merging auth, networking, or endpoint decoding changes:

- confirm tokens are never logged
- confirm token values are held only in memory
- confirm new requests go only to intended ChatGPT domains
- confirm errors are helpful without leaking sensitive values

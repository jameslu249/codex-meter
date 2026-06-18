# Privacy

Codex Meter is designed as a local utility.

It reads `~/.codex/auth.json` to find the local Codex access token and sends that token only as an `Authorization: Bearer` header to these ChatGPT endpoints:

```text
https://chatgpt.com/backend-api/wham/usage
https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

Codex Meter does not:

- display tokens
- log tokens
- persist tokens
- send analytics
- use third-party SDKs
- make requests to non-ChatGPT domains

The app stores only lightweight UI preferences in `UserDefaults`, such as the selected color mood.

# swift-http-file

`.http` requests (VS Code REST Client / JetBrains HTTP Client format): `HTTPFile.request(atOffset:in:)`
reads the `###` block under a caret, `HTTPFileRequest.text` writes one, `HTTPFileRequest(curl:)`
converts a curl command (via swift-curl-parse, the one dependency).

- `Models/` — `HTTPFileRequest`, `HTTPFileHeader`: shapes only.
- `Core/` — `HTTPFile` (the reader).
- `Support/` — `RedirectPolicy`: which headers follow a request to the address a redirect names (a credential-shaped header — `Authorization`, `Cookie`, `Proxy-Authorization`, any name holding `key`, `token`, `secret` or `auth` — is dropped when the host, scheme or port changes), and `isCredentialShaped(_:)` for a host that is about to save a request in plain text.
  `HTTPRedirectGuard` is the `URLSession` delegate that applies it: `makeSession()` (ephemeral, guarded), `redirected(_:from:)` (clears the proposal's headers, then sets only the ones that may follow — assigning `allHTTPHeaderFields` merges).
- `Extensions/` — `HTTPFileRequest+Text` (the writer), `HTTPFileRequest+Curl` (the conversion).
- Offsets are UTF-16, a text view's.
- macOS 14, tools 6.2, Swift 6 language mode. Tests are mutation-verified.

Read `CONTRIBUTING.md` for the folder layout and the pull-request rules.

@CONTRIBUTING.md

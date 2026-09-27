# swift-http-file

`.http` requests (VS Code REST Client / JetBrains HTTP Client format): `HTTPFile.request(atOffset:in:)`
reads the `###` block under a caret, `HTTPFileRequest.text` writes one, `HTTPFileRequest(curl:)`
converts a curl command (via swift-curl-parse, the one dependency).

- `Models/` — `HTTPFileRequest`, `HTTPFileHeader`: shapes only.
- `Core/` — `HTTPFile` (the reader).
- `Extensions/` — `HTTPFileRequest+Text` (the writer), `HTTPFileRequest+Curl` (the conversion).
- Offsets are UTF-16, a text view's.
- macOS 14, tools 6.2, Swift 6 language mode. Tests are mutation-verified.

@CONTRIBUTING.md

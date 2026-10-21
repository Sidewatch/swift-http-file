# Swift HTTP File

Reads and writes `.http` requests — the plain-text format VS Code's REST Client and JetBrains' HTTP Client use — and turns a curl command into one.

## Features

- 📄 **Requests from a document** — `HTTPFile.request(atOffset:in:)` answers the request in the `###` block the caret is in
- ✍️ **Round trip** — `HTTPFileRequest.text` writes a request back as the same block
- 🌀 **curl in, request out** — `HTTPFileRequest(curl:)`: `-u` → `Authorization: Basic`, `-A` → `User-Agent`, `-b` → `Cookie`, `-F` → a `multipart/form-data` body; a header the command already set wins
- 🔐 **Redirects keep credentials home** — `RedirectPolicy.headers(for:from:to:)` answers the headers that may follow a request to the address a `3xx` names: when the host, scheme or port changes, `Authorization`, `Cookie`, `Proxy-Authorization` and any header whose name holds `key`, `token`, `secret` or `auth` are dropped (Foundation strips `Authorization` alone); `isCredentialShaped(_:)` is the same test for a client about to save a request in plain text
- 🪶 **One dependency** — [swift-curl-parse](https://github.com/arraypress/swift-curl-parse), for the curl parsing

## Requirements

- macOS 14+
- Swift 6.2+ (Swift 6 language mode)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Sidewatch/swift-http-file.git", from: "0.1.0")
]
```

## Usage

```swift
import HTTPFile

// The request in the `###` block the caret is in.
let request = HTTPFile.request(atOffset: caret, in: document)

// A curl command from an API's documentation, as a request block.
if let pasted = HTTPFileRequest(curl: "curl -u sk_test_123: https://api.stripe.com/v1/charges") {
    print(pasted.text)
    // ### GET api.stripe.com/v1/charges
    // GET https://api.stripe.com/v1/charges
    // Authorization: Basic c2tfdGVzdF8xMjM6
}

// In a URLSession redirect delegate: the headers that may follow a 302 to another host.
let kept = RedirectPolicy.headers(for: request.allHTTPHeaderFields ?? [:], from: request.url!, to: redirect.url!)

// Or use the delegate that applies it: an ephemeral session whose redirects never carry a
// credential-shaped header off its origin.
let session = HTTPRedirectGuard.makeSession()
```

```swift
// A request block, ready to send: every header (a repeated name too), no body on GET or HEAD.
if let request = HTTPFile.request(atOffset: caret, in: text)?.urlRequest { URLSession.shared.dataTask(with: request).resume() }
```

## For agents

Read `CONTRIBUTING.md` first: the folder layout and the PR rules. `swift test` is the whole
check, and a new test must fail before the change it covers. `AGENTS.md` carries a
module map (`CLAUDE.md` imports it).

## License

MIT — see [LICENSE](LICENSE).

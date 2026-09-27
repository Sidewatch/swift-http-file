# Swift HTTP File

Reads and writes `.http` requests — the plain-text format VS Code's REST Client and JetBrains' HTTP Client use — and turns a curl command into one.

## Features

- 📄 **Requests from a document** — `HTTPFile.request(atOffset:in:)` answers the request in the `###` block the caret is in
- ✍️ **Round trip** — `HTTPFileRequest.text` writes a request back as the same block
- 🌀 **curl in, request out** — `HTTPFileRequest(curl:)`: `-u` → `Authorization: Basic`, `-A` → `User-Agent`, `-b` → `Cookie`, `-F` → a `multipart/form-data` body; a header the command already set wins
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
```

## For agents

Read `CONTRIBUTING.md` first: the folder layout and the PR rules. `swift test` is the whole
check, and a new test must fail before the change it covers. `CLAUDE.md` / `AGENTS.md` carry a
module map.

## License

MIT — see [LICENSE](LICENSE).

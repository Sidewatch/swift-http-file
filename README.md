# swift-http-file

Reads and writes `.http` requests — the plain-text format VS Code's REST Client and JetBrains'
HTTP Client use — and turns a curl command into one.

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

A curl command's implicit parts become explicit headers: `-u` → `Authorization: Basic`, `-A` →
`User-Agent`, `-b` → `Cookie`, `-F` → a `multipart/form-data` body; a header the command already
set wins. Parsing is [swift-curl-parse](https://github.com/arraypress/swift-curl-parse).

macOS 14+, Swift 6. MIT licence.

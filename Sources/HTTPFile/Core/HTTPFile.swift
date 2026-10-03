//
//  HTTPFile.swift
//  HTTPFile
//
//  Reading the request under the caret out of a .http document.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// Reads `.http` documents: requests separated by `###` lines, each a `METHOD url` line, headers
/// until a blank line, then a body. `#` lines before the request line are comments.
public enum HTTPFile {
    /// The request in the `###` block that holds `offset` (UTF-16, a text view's caret), or nil
    /// when that block has no `METHOD url` line whose address has a scheme.
    public static func request(atOffset offset: Int, in text: String) -> HTTPFileRequest? {
        let lines = text.components(separatedBy: "\n")
        var caretLine = 0, position = 0
        for (i, line) in lines.enumerated() {
            let length = (line as NSString).length + 1
            caretLine = i
            if offset < position + length { break }
            position += length
        }
        var start = caretLine
        while start > 0, !lines[start].hasPrefix("###") { start -= 1 }
        let name: String? =
            lines[start].hasPrefix("###")
            ? String(lines[start].dropFirst(3)).trimmingCharacters(in: .whitespaces) : nil
        var end = caretLine + 1
        while end < lines.count, !lines[end].hasPrefix("###") { end += 1 }
        let block = Array(lines[start..<end])

        var i = 0
        while i < block.count, block[i].trimmingCharacters(in: .whitespaces).isEmpty || block[i].hasPrefix("#") { i += 1 }
        guard i < block.count else { return nil }
        // `METHOD URL` with an optional trailing `HTTP/1.1` (the form JetBrains and VS Code's REST
        // Client both write), which is the protocol version, not part of the address.
        var requestLine = block[i].split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        if requestLine.count == 3, requestLine[2].uppercased().hasPrefix("HTTP/") { requestLine.removeLast() }
        guard requestLine.count == 2 else { return nil }
        let url = requestLine[1]
        guard URL(string: url)?.scheme != nil else { return nil }
        i += 1
        var headers: [HTTPFileHeader] = []
        while i < block.count, !block[i].trimmingCharacters(in: .whitespaces).isEmpty {
            if let colon = block[i].firstIndex(of: ":") {
                headers.append(
                    HTTPFileHeader(
                        name: String(block[i][..<colon]).trimmingCharacters(in: .whitespaces),
                        value: String(block[i][block[i].index(after: colon)...]).trimmingCharacters(in: .whitespaces)))
            }
            i += 1
        }
        let body = block[min(i + 1, block.count)...].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return HTTPFileRequest(
            name: name?.isEmpty == true ? nil : name, method: requestLine[0].uppercased(),
            url: url, headers: headers, body: body)
    }
}

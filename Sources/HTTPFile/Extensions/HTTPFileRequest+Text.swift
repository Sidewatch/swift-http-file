//
//  HTTPFileRequest+Text.swift
//  HTTPFile
//
//  A request written back out as a .http block.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

public extension HTTPFileRequest {
    /// The request as a `.http` block: `### name` (when named), `METHOD url`, the headers, then a
    /// blank line and the body (when there is one). No trailing newline.
    var text: String {
        var lines: [String] = []
        if let name { lines.append("### \(name)") }
        lines.append("\(method) \(url)")
        lines += headers.map { "\($0.name): \($0.value)" }
        if !body.isEmpty { lines += ["", body] }
        return lines.joined(separator: "\n")
    }
}

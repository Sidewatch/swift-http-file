//
//  HTTPFileRequest.swift
//  HTTPFile
//
//  One request of a .http file: its name, method, address, headers and body.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// One request of a `.http` file (the VS Code / JetBrains format): the `### Name` above it, the
/// `METHOD url` line, the headers until a blank line, and the body after it.
public struct HTTPFileRequest: Equatable, Sendable {
    /// The `###` line's text, if the block has one.
    public var name: String?
    /// The method, upper-cased.
    public var method: String
    /// The address, as written.
    public var url: String
    /// The headers, in order.
    public var headers: [HTTPFileHeader]
    /// Everything after the blank line that ends the headers, trimmed; empty for none.
    public var body: String

    /// A request from its parts.
    public init(name: String? = nil, method: String, url: String, headers: [HTTPFileHeader] = [], body: String = "") {
        self.name = name
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

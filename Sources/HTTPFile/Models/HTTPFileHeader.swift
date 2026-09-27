//
//  HTTPFileHeader.swift
//  HTTPFile
//
//  One header line of a .http request.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// One `Name: value` header line of a `.http` request.
public struct HTTPFileHeader: Equatable, Sendable {
    /// The header's name, as written.
    public var name: String
    /// Its value, trimmed.
    public var value: String

    /// A header from its name and value.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

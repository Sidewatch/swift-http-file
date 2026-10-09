//
//  RedirectPolicy.swift
//  HTTPFile
//
//  Which headers follow a request across a redirect.
//
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// Which headers may follow a request to the address a redirect names.
///
/// A client that replays every header on a redirect hands the request's credentials to whoever
/// the first server points it at: a `302` from `api.example.com` to `attacker.example` carries the
/// `Cookie` and the `X-Api-Key`. Foundation's `URLSession` strips `Authorization` alone. So when
/// the redirect leaves the origin — another host, another scheme, another port — every
/// credential-shaped header is dropped and the rest follow; within the origin everything follows.
public enum RedirectPolicy {
    /// Header names that are a credential outright.
    public static let credentialHeaders: Set<String> = ["authorization", "cookie", "proxy-authorization"]

    /// Fragments that mark a header as credential-shaped: `X-Api-Key`, `X-Auth-Token`,
    /// `Client-Secret`, `X-Amz-Security-Token`.
    public static let credentialFragments = ["key", "token", "secret", "auth"]

    /// Whether `name` is a header a request should never hand to another origin, or save in
    /// plain text without saying so.
    public static func isCredentialShaped(_ name: String) -> Bool {
        let lower = name.lowercased()
        return credentialHeaders.contains(lower) || credentialFragments.contains { lower.contains($0) }
    }

    /// Whether a redirect from `from` to `to` leaves the origin: the scheme, host or port differ.
    public static func crossesOrigin(from: URL, to: URL) -> Bool {
        from.scheme?.lowercased() != to.scheme?.lowercased() || from.host?.lowercased() != to.host?.lowercased() || from.port != to.port
    }

    /// The headers of a request to `from` that may follow it to `to`.
    public static func headers(for headers: [HTTPFileHeader], from: URL, to: URL) -> [HTTPFileHeader] {
        guard crossesOrigin(from: from, to: to) else { return headers }
        return headers.filter { !isCredentialShaped($0.name) }
    }

    /// ``headers(for:from:to:)`` over the dictionary a `URLRequest` holds.
    public static func headers(for headers: [String: String], from: URL, to: URL) -> [String: String] {
        guard crossesOrigin(from: from, to: to) else { return headers }
        return headers.filter { !isCredentialShaped($0.key) }
    }
}

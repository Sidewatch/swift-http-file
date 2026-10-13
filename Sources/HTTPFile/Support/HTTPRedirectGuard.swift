//
//  HTTPRedirectGuard.swift
//  HTTPFile
//
//  The HTTP client's session delegate: a redirect is followed, a credential never follows it off its origin.
//
//  Created by David Sherlock on 10/10/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// The `URLSession` delegate behind the HTTP client. Foundation follows a redirect carrying every
/// header but `Authorization`, so a `302` to another host delivered the request's `Cookie` and
/// `X-Api-Key` to whoever the first server named. The redirect is still followed; the headers it
/// carries are `RedirectPolicy`'s answer — every credential-shaped one dropped when the scheme,
/// host or port changes. Off the main actor: the session calls back on its own queue.
public final class HTTPRedirectGuard: NSObject, URLSessionTaskDelegate, Sendable {
    /// A session over an ephemeral configuration — nothing cached or stored on disk — guarded by
    /// this delegate.
    public static func makeSession() -> URLSession {
        URLSession(configuration: .ephemeral, delegate: HTTPRedirectGuard(), delegateQueue: nil)
    }

    public func urlSession(
        _ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(Self.redirected(request, from: task.currentRequest ?? task.originalRequest))
    }

    /// `request` (the one Foundation proposes for the redirect) carrying only the headers of the
    /// request it replaces that `RedirectPolicy` lets follow.
    ///
    /// Every header on the proposal is cleared first: assigning `allHTTPHeaderFields` MERGES into
    /// the headers a request already has, so an assignment alone left the `Cookie` and
    /// `X-Api-Key` Foundation had copied onto the redirect in place.
    public static func redirected(_ request: URLRequest, from previous: URLRequest?) -> URLRequest {
        guard let from = previous?.url, let to = request.url else { return request }
        var next = request
        for name in (request.allHTTPHeaderFields ?? [:]).keys { next.setValue(nil, forHTTPHeaderField: name) }
        for (name, value) in RedirectPolicy.headers(for: previous?.allHTTPHeaderFields ?? [:], from: from, to: to) {
            next.setValue(value, forHTTPHeaderField: name)
        }
        return next
    }
}

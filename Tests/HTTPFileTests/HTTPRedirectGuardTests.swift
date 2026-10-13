//
//  HTTPRedirectGuardTests.swift
//  HTTPFileTests
//
//  The session delegate's redirect: the request Foundation proposes keeps only the headers
//  RedirectPolicy lets follow, and the session it builds stores nothing on disk.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import HTTPFile

final class HTTPRedirectGuardTests: XCTestCase {
    private func request(_ url: String, headers: [String: String] = [:]) -> URLRequest {
        var r = URLRequest(url: URL(string: url)!)
        r.allHTTPHeaderFields = headers
        return r
    }

    private let credentialed = [
        "Cookie": "session=abc", "X-Api-Key": "k", "Authorization": "Bearer t", "Accept": "application/json",
    ]

    func testARedirectToAnotherHostCarriesNoCredential() {
        let previous = request("https://api.example.com/v1", headers: credentialed)
        // Foundation's proposed request carries the old headers over; the guard replaces them.
        let proposed = request("https://attacker.example/collect", headers: credentialed)
        let next = HTTPRedirectGuard.redirected(proposed, from: previous)
        XCTAssertEqual(next.url?.host, "attacker.example", "the redirect is still followed")
        XCTAssertNil(next.value(forHTTPHeaderField: "Cookie"))
        XCTAssertNil(next.value(forHTTPHeaderField: "X-Api-Key"))
        XCTAssertNil(next.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(next.value(forHTTPHeaderField: "Accept"), "application/json", "a plain header follows")
    }

    func testARedirectOnTheSameOriginKeepsItsCredentials() {
        let previous = request("https://api.example.com/v1", headers: credentialed)
        let proposed = request("https://api.example.com/v2", headers: [:])
        let next = HTTPRedirectGuard.redirected(proposed, from: previous)
        XCTAssertEqual(next.value(forHTTPHeaderField: "Cookie"), "session=abc")
        XCTAssertEqual(next.value(forHTTPHeaderField: "X-Api-Key"), "k")
    }

    func testADowngradeToPlainHTTPDropsTheCredentials() {
        let previous = request("https://api.example.com/v1", headers: credentialed)
        let next = HTTPRedirectGuard.redirected(request("http://api.example.com/v1"), from: previous)
        XCTAssertNil(next.value(forHTTPHeaderField: "Cookie"), "the scheme changed, so the origin did")
    }

    func testWithNoPreviousRequestTheProposalStands() {
        let proposed = request("https://elsewhere.example/", headers: ["X-Trace": "1"])
        XCTAssertEqual(HTTPRedirectGuard.redirected(proposed, from: nil), proposed)
    }

    func testTheSessionIsEphemeralAndGuarded() {
        let session = HTTPRedirectGuard.makeSession()
        XCTAssertTrue(session.delegate is HTTPRedirectGuard)
        XCTAssertEqual(session.configuration.urlCache?.diskCapacity ?? 0, 0, "an ephemeral session writes no cache to disk")
    }
}

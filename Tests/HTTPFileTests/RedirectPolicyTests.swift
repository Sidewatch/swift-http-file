//
//  RedirectPolicyTests.swift
//  HTTPFileTests
//
//  A redirect to another origin never carries a credential.
//
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import HTTPFile

final class RedirectPolicyTests: XCTestCase {
    private let headers = [
        HTTPFileHeader(name: "Authorization", value: "Bearer sk_live_1"),
        HTTPFileHeader(name: "Cookie", value: "session=abc"),
        HTTPFileHeader(name: "Proxy-Authorization", value: "Basic x"),
        HTTPFileHeader(name: "X-Api-Key", value: "k"),
        HTTPFileHeader(name: "X-Auth-Token", value: "t"),
        HTTPFileHeader(name: "Client-Secret", value: "s"),
        HTTPFileHeader(name: "Content-Type", value: "application/json"),
        HTTPFileHeader(name: "Accept", value: "*/*"),
        HTTPFileHeader(name: "User-Agent", value: "Sidewatch"),
    ]
    private let api = URL(string: "https://api.example.com/v1/charges")!

    func testACrossHostRedirectDropsEveryCredentialShapedHeader() {
        let kept = RedirectPolicy.headers(for: headers, from: api, to: URL(string: "https://attacker.example/collect")!)
        XCTAssertEqual(kept.map(\.name), ["Content-Type", "Accept", "User-Agent"])
    }

    func testASameOriginRedirectKeepsEverything() {
        let kept = RedirectPolicy.headers(for: headers, from: api, to: URL(string: "https://API.example.com/v2/charges")!)
        XCTAssertEqual(kept, headers, "the host compares without case")
    }

    func testASchemeOrPortChangeIsAnotherOrigin() {
        XCTAssertTrue(RedirectPolicy.crossesOrigin(from: api, to: URL(string: "http://api.example.com/v1/charges")!), "a downgrade")
        XCTAssertTrue(RedirectPolicy.crossesOrigin(from: api, to: URL(string: "https://api.example.com:8443/v1")!))
        XCTAssertFalse(RedirectPolicy.crossesOrigin(from: api, to: URL(string: "https://api.example.com/elsewhere")!))
    }

    func testTheDictionaryFormAgrees() {
        let request = ["Authorization": "x", "X-Request-Id": "7", "Keep-Alive": "timeout=5"]
        let kept = RedirectPolicy.headers(for: request, from: api, to: URL(string: "https://other.example/")!)
        XCTAssertEqual(kept, ["X-Request-Id": "7", "Keep-Alive": "timeout=5"], "an id and a connection hint are not credentials")
    }

    func testCredentialShapeByNameFragment() {
        for name in ["authorization", "Cookie", "x-api-key", "X-AUTH-TOKEN", "Idempotency-Key", "X-Amz-Security-Token", "WWW-Authenticate"]
        {
            XCTAssertTrue(RedirectPolicy.isCredentialShaped(name), name)
        }
        for name in ["Content-Type", "Accept-Encoding", "User-Agent", "If-None-Match", "Keep-Alive", "X-Request-Id"] {
            XCTAssertFalse(RedirectPolicy.isCredentialShaped(name), name)
        }
    }
}

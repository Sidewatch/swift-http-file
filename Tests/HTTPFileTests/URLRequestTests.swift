//
//  URLRequestTests.swift
//  HTTPFileTests
//
//  A request block as the URLRequest that sends it.
//
//  Created by David Sherlock on 10/21/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import HTTPFile

/// `HTTPFileRequest.urlRequest`.
final class URLRequestTests: XCTestCase {
    func testEveryHeaderIsSentARepeatedNameIncluded() throws {
        let request = HTTPFileRequest(
            method: "POST", url: "https://example.com/api",
            headers: [
                HTTPFileHeader(name: "Accept", value: "application/json"), HTTPFileHeader(name: "Accept", value: "text/plain"),
                HTTPFileHeader(name: "", value: "dropped"),
            ], body: "{\"a\":1}")
        let sent = try XCTUnwrap(request.urlRequest)
        XCTAssertEqual(sent.httpMethod, "POST")
        XCTAssertEqual(sent.value(forHTTPHeaderField: "Accept"), "application/json,text/plain", "both Accept lines")
        XCTAssertEqual(sent.allHTTPHeaderFields?.count, 1, "the nameless header is dropped")
        XCTAssertEqual(sent.httpBody, Data("{\"a\":1}".utf8))
    }

    func testGetAndHeadSendNoBodyAndABadAddressIsNil() {
        XCTAssertNil(HTTPFileRequest(method: "GET", url: "https://example.com", body: "ignored").urlRequest?.httpBody)
        XCTAssertNil(HTTPFileRequest(method: "HEAD", url: "https://example.com", body: "ignored").urlRequest?.httpBody)
        XCTAssertNil(HTTPFileRequest(method: "GET", url: "").urlRequest)
    }
}

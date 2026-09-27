//
//  HTTPFileTests.swift
//  HTTPFileTests
//
//  Reading the request under the caret, writing a request out, and converting curl.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import HTTPFile

final class HTTPFileTests: XCTestCase {
    private let document = """
        ### Cat fact
        GET https://catfact.ninja/fact

        ### POST some JSON
        # a comment before the request line
        POST https://httpbin.org/post
        Content-Type: application/json
        X-Trace: a:b

        { "hello": "world" }
        """

    func testTheRequestIsTheBlockTheCaretIsIn() throws {
        let first = try XCTUnwrap(HTTPFile.request(atOffset: 3, in: document))
        XCTAssertEqual(first, HTTPFileRequest(name: "Cat fact", method: "GET", url: "https://catfact.ninja/fact"))
        let caret = (document as NSString).range(of: "hello").location
        let second = try XCTUnwrap(HTTPFile.request(atOffset: caret, in: document))
        XCTAssertEqual(second.name, "POST some JSON")
        XCTAssertEqual(second.method, "POST")
        XCTAssertEqual(
            second.headers,
            [
                HTTPFileHeader(name: "Content-Type", value: "application/json"),
                HTTPFileHeader(name: "X-Trace", value: "a:b"),
            ], "a value keeps its own colons")
        XCTAssertEqual(second.body, #"{ "hello": "world" }"#)
    }

    func testABlockWithoutAnAddressIsNoRequest() {
        XCTAssertNil(HTTPFile.request(atOffset: 0, in: "### Empty\n# only a comment"))
        XCTAssertNil(HTTPFile.request(atOffset: 0, in: "GET not-a-url"), "an address needs a scheme")
        XCTAssertEqual(HTTPFile.request(atOffset: 0, in: "get https://a.test")?.method, "GET", "the method is upper-cased")
    }

    func testARequestWritesBackAsTheSameBlock() throws {
        let caret = (document as NSString).range(of: "hello").location
        let request = try XCTUnwrap(HTTPFile.request(atOffset: caret, in: document))
        let round = try XCTUnwrap(HTTPFile.request(atOffset: 0, in: request.text))
        XCTAssertEqual(round, request)
        XCTAssertEqual(HTTPFileRequest(method: "GET", url: "https://a.test").text, "GET https://a.test", "no name, no body, no blank line")
    }

    func testACurlCommandBecomesARequest() throws {
        let command = #"curl -X POST 'https://api.example.com/v1/users?page=2' -H 'Content-Type: application/json' -d '{"name":"Ada"}'"#
        let request = try XCTUnwrap(HTTPFileRequest(curl: command))
        XCTAssertEqual(
            request.text,
            """
            ### POST api.example.com/v1/users
            POST https://api.example.com/v1/users?page=2
            Content-Type: application/json

            {"name":"Ada"}
            """)
    }

    func testCurlsImplicitHeadersBecomeExplicit() throws {
        let request = try XCTUnwrap(HTTPFileRequest(curl: "curl -u sk_test_123: -A probe/1 -b 'a=1' example.com/ping"))
        XCTAssertEqual(request.url, "http://example.com/ping", "curl's default scheme")
        XCTAssertEqual(
            request.headers,
            [
                HTTPFileHeader(name: "Authorization", value: "Basic " + Data("sk_test_123:".utf8).base64EncodedString()),
                HTTPFileHeader(name: "User-Agent", value: "probe/1"),
                HTTPFileHeader(name: "Cookie", value: "a=1"),
            ])
        let own = try XCTUnwrap(HTTPFileRequest(curl: "curl -A probe/1 -H 'user-agent: mine' https://a.test"))
        XCTAssertEqual(own.headers, [HTTPFileHeader(name: "user-agent", value: "mine")], "a header the command set wins")
    }

    func testAFormBecomesAMultipartBody() throws {
        let request = try XCTUnwrap(HTTPFileRequest(curl: "curl -F name=Ada -F photo=@me.jpg https://a.test/up"))
        let b = HTTPFileRequest.formBoundary
        XCTAssertEqual(request.method, "POST")
        XCTAssertEqual(request.headers, [HTTPFileHeader(name: "Content-Type", value: "multipart/form-data; boundary=\(b)")])
        XCTAssertEqual(
            request.body,
            "--\(b)\nContent-Disposition: form-data; name=\"name\"\n\nAda\n--\(b)\nContent-Disposition: form-data; name=\"photo\"\n\n@me.jpg\n--\(b)--"
        )
    }

    func testTextThatIsNotCurlIsNoRequest() {
        XCTAssertNil(HTTPFileRequest(curl: "GET https://a.test"))
        XCTAssertNil(HTTPFileRequest(curl: "curl"), "curl with no address")
    }
}

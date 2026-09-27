//
//  HTTPFileRequest+Curl.swift
//  HTTPFile
//
//  A curl command line as a .http request.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation
import CurlParse

public extension HTTPFileRequest {
    /// The boundary a converted `-F` form is written with.
    static let formBoundary = "SidewatchFormBoundary"

    /// The request a curl command describes, or nil when `command` is not one.
    ///
    /// What curl would have sent becomes explicit: `-u` an `Authorization: Basic` header, `-A`
    /// a `User-Agent`, `-b` a `Cookie`, and `-F` fields a `multipart/form-data` body — each only
    /// when the command did not already set that header. An address without a scheme gets
    /// curl's own default, `http://`. The name is the method and the address without its
    /// scheme or query, so the block reads the way the command did.
    init?(curl command: String) {
        guard let curl = try? CurlParse.parse(command) else { return nil }
        let url = curl.url.contains("://") ? curl.url : "http://" + curl.url
        var headers = curl.headers.map { HTTPFileHeader(name: $0.name, value: $0.value) }
        func add(_ name: String, _ value: String?) {
            guard let value, !headers.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { return }
            headers.append(HTTPFileHeader(name: name, value: value))
        }
        if let user = curl.user {
            add("Authorization", "Basic " + Data("\(user):\(curl.password ?? "")".utf8).base64EncodedString())
        }
        add("User-Agent", curl.userAgent)
        add("Cookie", curl.cookies)
        var body = curl.body ?? ""
        if !curl.formFields.isEmpty {
            add("Content-Type", "multipart/form-data; boundary=\(Self.formBoundary)")
            body = curl.formFields.map {
                "--\(Self.formBoundary)\nContent-Disposition: form-data; name=\"\($0.name)\"\n\n\($0.value)"
            }.joined(separator: "\n") + "\n--\(Self.formBoundary)--"
        }
        let bare = url.components(separatedBy: "://").last?.components(separatedBy: "?").first ?? url
        self.init(name: "\(curl.method) \(bare)", method: curl.method, url: url, headers: headers, body: body)
    }
}

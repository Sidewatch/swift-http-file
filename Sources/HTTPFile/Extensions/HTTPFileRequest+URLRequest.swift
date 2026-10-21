//
//  HTTPFileRequest+URLRequest.swift
//  HTTPFile
//
//  A request block as the `URLRequest` that sends it.
//
//  Created by David Sherlock on 10/21/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

public extension HTTPFileRequest {
    /// The request ready to send, or nil when its address is not a URL. Every header is sent, a name
    /// written twice included (`URLRequest` joins their values with commas, as HTTP allows); a header
    /// with no name is dropped. The body goes with any method but GET and HEAD.
    var urlRequest: URLRequest? {
        guard let address = URL(string: url) else { return nil }
        var request = URLRequest(url: address)
        request.httpMethod = method
        for header in headers where !header.name.isEmpty {
            request.addValue(header.value, forHTTPHeaderField: header.name)
        }
        if !["GET", "HEAD"].contains(method), !body.isEmpty { request.httpBody = Data(body.utf8) }
        return request
    }
}

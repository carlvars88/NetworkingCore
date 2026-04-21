import Foundation

/// Abstracts the HTTP layer. Conforming types own request execution,
/// authentication, certificate pinning, and retry — callers work only
/// with URLRequest and a decode closure.
public protocol HTTPTransport: AnyObject, Sendable {
    var monitor: (any HTTPTransportMonitor)? { get }

    func performRequest<T: Sendable>(
        request: URLRequest,
        decode: @Sendable (Data, HTTPURLResponse) throws -> T
    ) async throws -> T
}

public extension HTTPTransport {
    var monitor: (any HTTPTransportMonitor)? { nil }

    func performRequest(request: URLRequest) async throws -> String {
        try await performRequest(request: request) { data, _ in
            String(decoding: data, as: UTF8.self)
        }
    }

    func performRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try await performRequest(request: request) { data, response in (data, response) }
    }

    func performRequest<T: Decodable & Sendable>(request: URLRequest) async throws -> T {
        try await performRequest(request: request) { data, _ in
            try JSONDecoder().decode(T.self, from: data)
        }
    }
}

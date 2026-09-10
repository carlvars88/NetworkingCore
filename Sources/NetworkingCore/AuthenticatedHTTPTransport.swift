/// An `HTTPTransport` that attaches credentials to every request it sends,
/// via `performAuthenticatedRequest` rather than the plain `performRequest`
/// inherited from `HTTPTransport`. Conforming types are expected to inject
/// authentication (e.g. a bearer token) before dispatching — callers using
/// `performAuthenticatedRequest` don't need to encode credentials on the
/// request or endpoint themselves.

import Foundation

public protocol AuthenticatedHTTPTransport: HTTPTransport {
    func performAuthenticatedRequest<T: Sendable>(
        request: URLRequest,
        decode: @Sendable (Data, HTTPURLResponse) throws -> T
    ) async throws -> T
}

import Foundation
import NetworkingCore

/// A configurable test double for ``HTTPTransport``.
///
/// Supply a `handler` closure to control every response:
/// ```swift
/// let transport = MockHTTPTransport { _ in (jsonData, okResponse) }
/// ```
/// Or use the convenience initialisers for the common cases.
public final class MockHTTPTransport: HTTPTransport {
    public typealias Handler = @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    public let monitor: (any HTTPTransportMonitor)?
    public private(set) var recordedRequests: [URLRequest] = []

    private let handler: Handler

    public init(
        monitor: (any HTTPTransportMonitor)? = nil,
        handler: @escaping Handler
    ) {
        self.monitor = monitor
        self.handler = handler
    }

    /// Always returns `data` paired with a 200 OK response.
    public convenience init(
        data: Data,
        url: URL = URL(string: "https://mock.local")!,
        monitor: (any HTTPTransportMonitor)? = nil
    ) {
        let response = HTTPURLResponse(
            url: url, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        self.init(monitor: monitor, handler: { _ in (data, response) })
    }

    /// Always throws `error`, regardless of the request.
    public convenience init(
        error: any Error,
        monitor: (any HTTPTransportMonitor)? = nil
    ) {
        self.init(monitor: monitor, handler: { _ in throw error })
    }

    public func performRequest<T: Sendable>(
        request: URLRequest,
        decode: @Sendable (Data, HTTPURLResponse) throws -> T
    ) async throws -> T {
        recordedRequests.append(request)
        monitor?.willSend(request)
        do {
            let (data, response) = try await handler(request)
            monitor?.didReceive(response, data: data, for: request)
            return try decode(data, response)
        } catch {
            monitor?.didFail(with: error, for: request)
            throw error
        }
    }
}

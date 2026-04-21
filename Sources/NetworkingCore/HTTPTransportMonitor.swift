import Foundation

/// Observability hook for an ``HTTPTransport``.
///
/// Implement only the methods you need — all have no-op defaults.
/// Inject a monitor at transport construction time; the transport calls
/// it at each stage of the request lifecycle.
public protocol HTTPTransportMonitor: Sendable {
    func willSend(_ request: URLRequest)
    func didReceive(_ response: HTTPURLResponse, data: Data, for request: URLRequest)
    func didFail(with error: any Error, for request: URLRequest)
}

public extension HTTPTransportMonitor {
    func willSend(_ request: URLRequest) {}
    func didReceive(_ response: HTTPURLResponse, data: Data, for request: URLRequest) {}
    func didFail(with error: any Error, for request: URLRequest) {}
}

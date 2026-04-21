/// Marks an error as originating from the transport layer, distinct from
/// domain or decoding errors. Callers can catch at this boundary without
/// knowing the concrete error type of any specific transport implementation.
///
/// ```swift
/// do {
///     try await transport.performRequest(request: request)
/// } catch let error as any TransportError {
///     // transport-level failure
/// } catch {
///     // domain or decoding error
/// }
/// ```
public protocol TransportError: Error, Sendable {}

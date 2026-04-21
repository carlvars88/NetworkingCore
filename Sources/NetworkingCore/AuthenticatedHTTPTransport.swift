/// Marks a transport as carrying valid authentication credentials.
///
/// There are no additional method requirements — the guarantee is structural:
/// only types constructed with a credential provider can conform, so passing
/// an unauthenticated transport where this protocol is required is a compile
/// error.
public protocol AuthenticatedHTTPTransport: HTTPTransport {}

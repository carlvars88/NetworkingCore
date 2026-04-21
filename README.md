# NetworkingCore

A protocol-only Swift package that defines the transport boundary shared across all networking packages and applications.

`NetworkingCore` has **zero dependencies**. It defines contracts — not implementations. Concrete transport implementations (Alamofire, URLSession, mocks) live in the packages and apps that depend on it.

---

## Requirements

- Swift 5.9+
- iOS 16+ / macOS 13+

---

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/carlvars88/NetworkingCore.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [.product(name: "NetworkingCore", package: "NetworkingCore")]
    ),
    // For test targets:
    .testTarget(
        name: "YourTargetTests",
        dependencies: [
            .product(name: "NetworkingCore",              package: "NetworkingCore"),
            .product(name: "NetworkingCoreTestUtilities", package: "NetworkingCore"),
        ]
    ),
]
```

---

## Products

| Product | Use |
|---|---|
| `NetworkingCore` | Protocol definitions — add to all targets that need the transport boundary |
| `NetworkingCoreTestUtilities` | `MockHTTPTransport` test double — add to test targets only |

---

## Protocols

### `HTTPTransport`

The core contract. Conforming types own request execution, authentication, certificate pinning, and retry. Callers work only with `URLRequest` and a decode closure.

```swift
let result: MyModel = try await transport.performRequest(request: request)
```

Convenience overloads are provided for `String`, `(Data, HTTPURLResponse)`, and any `Decodable`.

### `AuthenticatedHTTPTransport`

A marker protocol that refines `HTTPTransport`. The guarantee is structural — only types constructed with a credential provider can conform. Passing an unauthenticated transport where this is required is a compile error.

```swift
func fetchCards(transport: any AuthenticatedHTTPTransport) async throws -> [Card] { ... }
```

### `TransportError`

Marks an error as originating from the transport layer, distinct from domain or decoding errors.

```swift
do {
    try await transport.performRequest(request: request)
} catch let error as any TransportError {
    // transport-level failure
} catch {
    // domain or decoding error
}
```

### `HTTPTransportMonitor`

An observability hook injected at transport construction time. All methods have no-op defaults — implement only what you need.

```swift
struct ConsoleMonitor: HTTPTransportMonitor {
    func willSend(_ request: URLRequest) {
        print("→ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    }
    func didReceive(_ response: HTTPURLResponse, data: Data, for request: URLRequest) {
        print("← \(response.statusCode)")
    }
    func didFail(with error: any Error, for request: URLRequest) {
        print("✗ \(error)")
    }
}
```

---

## Testing

`NetworkingCoreTestUtilities` provides `MockHTTPTransport` — a configurable test double that records every request it receives.

```swift
// Return canned JSON
let transport = MockHTTPTransport(data: jsonData)

// Always throw an error
let transport = MockHTTPTransport(error: URLError(.notConnectedToInternet))

// Full control
let transport = MockHTTPTransport { request in
    (Data("ok".utf8), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
}

// Assert what was sent
XCTAssertEqual(transport.recordedRequests.count, 1)
XCTAssertEqual(transport.recordedRequests.first?.url, expectedURL)
```

---

## Dependency graph

```
NetworkingCore          ← zero dependencies
      ↑
SessionManager          ← token exchange
SmartEndpoints          ← request building
      ↑
App                     ← concrete transport implementation
```

---

## License

MIT

import XCTest
import NetworkingCore
import NetworkingCoreTestUtilities

final class MockHTTPTransportTests: XCTestCase {
    private let url = URL(string: "https://mock.local")!
    private var request: URLRequest { URLRequest(url: url) }

    func testDecodableConvenienceOverload() async throws {
        struct Payload: Decodable, Sendable { let value: Int }
        let transport = MockHTTPTransport(data: #"{"value":42}"#.data(using: .utf8)!)

        let result: Payload = try await transport.performRequest(request: request)

        XCTAssertEqual(result.value, 42)
    }

    func testStringConvenienceOverload() async throws {
        let transport = MockHTTPTransport(data: Data("hello".utf8))

        let result: String = try await transport.performRequest(request: request)

        XCTAssertEqual(result, "hello")
    }

    func testRawDataOverload() async throws {
        let expected = Data([0x01, 0x02])
        let transport = MockHTTPTransport(data: expected)

        let (data, response) = try await transport.performRequest(request: request)

        XCTAssertEqual(data, expected)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testErrorInit() async {
        struct Boom: Error {}
        let transport = MockHTTPTransport(error: Boom())

        do {
            let _: String = try await transport.performRequest(request: request)
            XCTFail("expected throw")
        } catch {
            XCTAssertTrue(error is Boom)
        }
    }

    func testCustomHandler() async throws {
        let expectedStatus = 404
        let response = HTTPURLResponse(
            url: url, statusCode: expectedStatus, httpVersion: nil, headerFields: nil
        )!
        let transport = MockHTTPTransport { _ in (Data(), response) }

        let (_, http) = try await transport.performRequest(request: request)

        XCTAssertEqual(http.statusCode, expectedStatus)
    }

    func testRecordsRequests() async throws {
        let transport = MockHTTPTransport(data: Data())

        _ = try await transport.performRequest(request: request) as (Data, HTTPURLResponse)
        _ = try await transport.performRequest(request: request) as (Data, HTTPURLResponse)

        XCTAssertEqual(transport.recordedRequests.count, 2)
        XCTAssertEqual(transport.recordedRequests.first?.url, url)
    }

    func testMonitorCallbacks() async throws {
        final class SpyMonitor: HTTPTransportMonitor, @unchecked Sendable {
            var sentCount    = 0
            var receivedCount = 0
            var failedCount  = 0
            func willSend(_ request: URLRequest) { sentCount += 1 }
            func didReceive(_ response: HTTPURLResponse, data: Data, for request: URLRequest) { receivedCount += 1 }
            func didFail(with error: any Error, for request: URLRequest) { failedCount += 1 }
        }

        let spy = SpyMonitor()
        let transport = MockHTTPTransport(data: Data("ok".utf8), monitor: spy)

        let _: String = try await transport.performRequest(request: request)

        XCTAssertEqual(spy.sentCount,     1)
        XCTAssertEqual(spy.receivedCount, 1)
        XCTAssertEqual(spy.failedCount,   0)
    }
}

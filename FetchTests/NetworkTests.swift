import XCTest
@testable import Fetch

class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService! // System Under Test: NetworkService
    var session: URLSession! // Mock URLSession using MockURLProtocol

    override func setUp() {
        super.setUp()
        // Set up a mock URL session configuration using MockURLProtocol
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        // Initialize NetworkService with the mock session
        sut = NetworkService(session: session)
    }

    override func tearDown() {
        // Clean up after each test
        sut = nil
        session = nil
        // Reset mock values to avoid test contamination
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        super.tearDown()
    }

    // Test case: Successful data fetch and decoding of MockItem
    func testFetchSuccess() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch completes")
        
        // Mock JSON response data
        let mockData = """
        {
            "id": 1,
            "name": "Test Item"
        }
        """.data(using: .utf8)!
        MockURLProtocol.mockData = mockData

        // Perform the fetch
        sut.fetch(from: "https://api.example.com") { (result: Result<MockItem, Error>) in
            // Verify the fetched result is successful and matches the mock data
            switch result {
            case .success(let item):
                XCTAssertEqual(item.id, 1) // Check if item ID matches
                XCTAssertEqual(item.name, "Test Item") // Check if item name matches
            case .failure:
                XCTFail("Expected success, got failure") // Fail if the result is not successful
            }
            expectation.fulfill()
        }

        // Wait for async fetch to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Invalid URL scenario
    func testFetchInvalidURL() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch completes with error")

        // Attempt to fetch using an invalid URL (empty string)
        sut.fetch(from: "") { (result: Result<MockItem, Error>) in
            // Verify that the result is a failure due to invalid URL
            switch result {
            case .success:
                XCTFail("Expected failure, got success") // Fail if result is success
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.invalidURL) // Check if error matches NetworkError.invalidURL
            }
            expectation.fulfill()
        }

        // Wait for async fetch to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: No data returned by the server
    func testFetchNoData() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch completes with no data error")
        
        // No data provided by the mock
        MockURLProtocol.mockData = nil

        // Perform the fetch
        sut.fetch(from: "https://api.example.com") { (result: Result<MockItem, Error>) in
            // Verify that the result is a failure due to no data
            switch result {
            case .success:
                XCTFail("Expected failure, got success") // Fail if result is success
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.noData) // Check if error matches NetworkError.noData
            }
            expectation.fulfill()
        }

        // Wait for async fetch to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Simulate a network error during the fetch
    func testFetchNetworkError() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch completes with network error")
        
        // Mock a network error
        let mockError = NSError(domain: "com.example", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        MockURLProtocol.mockError = mockError

        // Perform the fetch
        sut.fetch(from: "https://api.example.com") { (result: Result<MockItem, Error>) in
            // Verify that the result is a failure with the correct network error
            switch result {
            case .success:
                XCTFail("Expected failure, got success") // Fail if result is success
            case .failure(let error):
                XCTAssertEqual((error as NSError).domain, mockError.domain) // Check if error domain matches
                XCTAssertEqual((error as NSError).code, mockError.code) // Check if error code matches
            }
            expectation.fulfill()
        }

        // Wait for async fetch to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Simulate a decoding error due to invalid JSON
    func testFetchDecodingError() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch completes with decoding error")
        
        // Mock invalid JSON data
        let invalidData = "Invalid JSON".data(using: .utf8)!
        MockURLProtocol.mockData = invalidData

        // Perform the fetch
        sut.fetch(from: "https://api.example.com") { (result: Result<MockItem, Error>) in
            // Verify that the result is a failure due to decoding error
            switch result {
            case .success:
                XCTFail("Expected failure, got success") // Fail if result is success
            case .failure(let error):
                XCTAssertTrue(error is DecodingError) // Check if error is of type DecodingError
            }
            expectation.fulfill()
        }

        // Wait for async fetch to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

// MARK: - Helper Types

// Model representing mock data to be used in the tests
struct MockItem: Codable {
    let id: Int
    let name: String
}

// Mock URL protocol to intercept network requests during tests
class MockURLProtocol: URLProtocol {
    // Static variables to hold mock responses, data, and errors
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?

    // Always handle incoming requests
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // Return the same request for canonicalization
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Start loading the mock response, data, or error
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            // If mock error exists, simulate a failure
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse {
                // If mock response exists, simulate receiving the response
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.mockData {
                // If mock data exists, simulate loading the data
                client?.urlProtocol(self, didLoad: data)
            }
        }
        // Finish loading after handling the mock response
        client?.urlProtocolDidFinishLoading(self)
    }

    // Stop loading (required but not used in mock)
    override func stopLoading() {}
}

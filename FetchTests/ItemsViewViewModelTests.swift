import XCTest
@testable import Fetch
import SwiftUI

// Unit tests for the ItemsViewViewModel class
class ItemsViewViewModelTests: XCTestCase {
    var sut: ItemsViewViewModel! // System Under Test: ItemsViewViewModel
    var mockNetworkService: MockNetworkService! // Mock version of the network service

    override func setUp() {
        super.setUp()
        // Initialize mock network service and the view model with it
        mockNetworkService = MockNetworkService()
        sut = ItemsViewViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        // Clean up resources after each test
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // Test case: Successfully fetch items and group them by listId
    func testFetchItemsSuccess() {
        // Expectation for asynchronous behavior
        let expectation = self.expectation(description: "Fetch items completes")
        
        // Mocked items returned by the network service
        let mockItems = [
            Item(id: 1, listId: 1, name: "Item 1"),
            Item(id: 2, listId: 1, name: "Item 2"),
            Item(id: 3, listId: 2, name: "Item 3"),
            Item(id: 4, listId: 2, name: "Item 4") // Added another item for listId 2
        ]
        // Simulate successful network fetch with the mock data
        mockNetworkService.mockResult = .success(mockItems)

        // ViewModel fetches items
        sut.fetchItems()

        // Verify groupedItems and errorMessage after async fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.groupedItems.count, 2) // Two groups (listId 1 and 2)
            XCTAssertEqual(self.sut.groupedItems[1]?.count, 2) // Two items in listId 1
            XCTAssertEqual(self.sut.groupedItems[2]?.count, 2) // Two items in listId 2
            XCTAssertNil(self.sut.errorMessage) // No error
            expectation.fulfill()
        }

        // Wait for the async behavior to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Network failure scenario
    func testFetchItemsFailure() {
        // Expectation for asynchronous behavior and mock error
        let expectation = self.expectation(description: "Fetch items fails")
        let mockError = NSError(domain: "com.example", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        // Simulate network failure with the mock error
        mockNetworkService.mockResult = .failure(mockError)

        // ViewModel fetches items
        sut.fetchItems()

        // Verify that errorMessage is set and groupedItems is empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.errorMessage, "Error fetching data: Network error") // Error message is set
            XCTAssertTrue(self.sut.groupedItems.isEmpty) // No items grouped
            expectation.fulfill()
        }

        // Wait for the async behavior to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Manually process items and verify the result
    func testProcessItems() {
        // A set of items to process
        let expectation = self.expectation(description: "Process items completes")
        let items = [
            Item(id: 1, listId: 2, name: "Item 1"),
            Item(id: 2, listId: 1, name: "Item 2"),
            Item(id: 3, listId: 2, name: "Item 3"),
            Item(id: 4, listId: 1, name: ""),    // Empty name, should be filtered out
            Item(id: 5, listId: 3, name: nil)    // Nil name, should be filtered out
        ]

        // ViewModel processes the items
        sut.processItems(items)

        // Verify the grouped result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.groupedItems.count, 2) // Two valid listIds (1 and 2)
            XCTAssertEqual(self.sut.groupedItems[1]?.count, 1) // One valid item in listId 1
            XCTAssertEqual(self.sut.groupedItems[2]?.count, 2) // Two valid items in listId 2
            XCTAssertEqual(self.sut.groupedItems[1]?.first?.name, "Item 2") // Item in listId 1 is "Item 2"
            XCTAssertEqual(self.sut.groupedItems[2]?.first?.name, "Item 1") // First item in listId 2 is "Item 1"
            XCTAssertEqual(self.sut.groupedItems[2]?.last?.name, "Item 3") // Last item in listId 2 is "Item 3"
            expectation.fulfill()
        }
        
        // Wait for the async behavior to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // Test case: Verify correct color is returned for listId
    func testColorForListId() {
        // A predefined set of pastel colors
        let pastelColors: [Color] = [
            Color(red: 255 / 255, green: 209 / 255, blue: 178 / 255),  // Pastel Orange
            Color(red: 255 / 255, green: 253 / 255, blue: 208 / 255),  // Cream
            Color(red: 249 / 255, green: 213 / 255, blue: 211 / 255),  // Pastel Coral
            Color(red: 253 / 255, green: 203 / 255, blue: 186 / 255)   // Pastel Peach
        ]

        // Loop through a range of listIds and verify color cycling
        for i in 0..<10 {
            let color = sut.colorForListId(i)
            XCTAssertEqual(color, pastelColors[i % pastelColors.count]) // Verify color cycling
        }
    }
}

// MARK: - Helper Types

// Mock implementation of the NetworkService used for testing
class MockNetworkService: NetworkService {
    var mockResult: Result<[Item], Error>? // Store a mock result (success or failure)

    // Override the fetch method to return the mock result
    override func fetch<T>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        guard let mockResult = mockResult as? Result<T, Error> else {
            fatalError("Unexpected type in mock result")
        }
        completion(mockResult) // Return the mock result via the completion handler
    }
}

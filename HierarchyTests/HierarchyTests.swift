//
//  HierarchyTests.swift
//  HierarchyTests
//
//  Created by macbook on 29.10.2024.
//
import XCTest
@testable import Hierarchy

final class HierarchyViewModelTests: XCTestCase {

    // MARK: - Helper Functions

    // Helper function to decode `Item` from JSON data
    private func createItemFromJSON(jsonString: String) -> Item? {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try? decoder.decode(Item.self, from: jsonData)
    }

    // MARK: - Tests

    func testLoadItems() async throws {
        // Given
        let viewModel = HierarchyViewModel()

        // When
        await viewModel.loadItems()

        // Then
        XCTAssertFalse(viewModel.items.isEmpty, "Items should not be empty after loading.")
    }

    func testToggleExpand() {
        // Given
        let jsonString = """
        {
            "data": { "Name": "Test Item" },
            "children": {}
        }
        """
        guard let item = createItemFromJSON(jsonString: jsonString) else {
            XCTFail("Failed to decode item from JSON")
            return
        }

        let viewModel = HierarchyViewModel()
        viewModel.items = [item]

        // When
        viewModel.toggleExpand(for: item)

        // Then
        XCTAssertTrue(viewModel.expandedItems.contains(item.id.uuidString), "Item should be expanded.")

        // When
        viewModel.toggleExpand(for: item)

        // Then
        XCTAssertFalse(viewModel.expandedItems.contains(item.id.uuidString), "Item should be collapsed.")
    }

    func testDeleteItem() {
        // Given
        let jsonString = """
        {
            "data": { "Name": "Test Item" },
            "children": {
                "child1": { "records": [] }
            }
        }
        """
        guard let item = createItemFromJSON(jsonString: jsonString) else {
            XCTFail("Failed to decode item from JSON")
            return
        }

        let viewModel = HierarchyViewModel()
        viewModel.items = [item]

        // When
        viewModel.deleteItem(item)

        // Then
        XCTAssertTrue(viewModel.items.isEmpty, "Item should have been correctly deleted.")
    }
}

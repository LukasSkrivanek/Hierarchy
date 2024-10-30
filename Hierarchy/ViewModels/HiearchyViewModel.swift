//
//  ContentView.swift
//  Hierarchy
//
//  Created by macbook on 18.10.2024.
//
import Foundation

class HierarchyViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var expandedItems: Set<String> = []
    
    init() {
        Task {
            await loadItems()
        }
    }
}

// MARK: - Load Items
extension HierarchyViewModel {
    func loadItems() async {
        guard let url = Bundle.main.url(forResource: "example-data", withExtension: "json") else {
            print("File 'example-data.json' not found")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedItems = try decoder.decode([Item].self, from: data)
            await MainActor.run {
                self.items = decodedItems
            }
        } catch {
            print("Error loading data: \(error)")
        }
    }
}

// MARK: - Toggle
extension HierarchyViewModel {
    func toggleExpand(for item: Item, parentId: String? = nil) {
        let uniqueId = parentId != nil ? "\(parentId!)-\(item.id.uuidString)" : item.id.uuidString

        if expandedItems.contains(uniqueId) {
            expandedItems.remove(uniqueId)
        } else {
            expandedItems.insert(uniqueId)
        }
    }
}

// MARK: - Delete Items
extension HierarchyViewModel {
    func deleteItem(_ item: Item, parentId: String? = nil) {
        print("Deleting item: \(item.id), parentId: \(String(describing: parentId))")
        
        // If the item has children, delete them recursively
        if case .dictionary(let childDict) = item.children {
            for (_, childItems) in childDict {
                for child in childItems.records {
                    deleteItem(child, parentId: item.id.uuidString)
                }
            }
        }

        // Try to find the parent and remove the item from the child list
        if let parentId = parentId {
            removeItemFromParent(item: item, parentId: parentId)
        } else {
            // If parentId is nil, it's a root item
            items.removeAll(where: { $0.id == item.id })
        }
    }

    private func removeItemFromParent(item: Item, parentId: String) {
        // Find the parent item in the hierarchy
        if var parentItem = findItem(by: parentId, in: &items) {
            if case .dictionary(var childDict) = parentItem.children {
                for key in childDict.keys {
                    if var childItems = childDict[key] {
                        // Find and remove the item from the children
                        if let index = childItems.records.firstIndex(where: { $0.id == item.id }) {
                            childItems.records.remove(at: index)
                            print("Removed item \(item.id) from parent \(parentId)")

                            // If there are no more children, remove the key
                            if childItems.records.isEmpty {
                                childDict.removeValue(forKey: key)
                            } else {
                                childDict[key] = childItems
                            }

                            // Update the parent item with the new list of children
                            parentItem.children = .dictionary(childDict)
                            updateItem(parentItem)
                            break
                        }
                    }
                }
            }
        }
    }

    private func findItem(by id: String, in items: inout [Item]) -> Item? {
        // Find the item in the hierarchy by ID, including nested items
        for index in items.indices {
            if items[index].id.uuidString == id {
                return items[index]
            }
            // Searching among the item's children
            if case .dictionary(let childDict) = items[index].children {
                for (_, var childItems) in childDict {
                    for childIndex in childItems.records.indices {
                        let child = childItems.records[childIndex]
                        if child.id.uuidString == id {
                            return child
                        }
                        if let found = findItem(by: id, in: &childItems.records) {
                            return found
                        }
                    }
                }
            }
        }
        return nil
    }

    private func updateItem(_ updatedItem: Item) {
        // Update the item in the main list
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
        } else {
            // If it's a deeper level, update it recursively
            updateNestedItem(updatedItem, in: &items)
        }
    }

    private func updateNestedItem(_ updatedItem: Item, in items: inout [Item]) {
        // Recursive update of the item in nested lists
        for index in items.indices {
            if case .dictionary(var childDict) = items[index].children {
                for key in childDict.keys {
                    if var childItems = childDict[key] {
                        if let childIndex = childItems.records.firstIndex(where: { $0.id == updatedItem.id }) {
                            childItems.records[childIndex] = updatedItem
                            childDict[key] = childItems
                            items[index].children = .dictionary(childDict)
                            return
                        }
                        updateNestedItem(updatedItem, in: &childItems.records)
                    }
                }
            }
        }
    }
}

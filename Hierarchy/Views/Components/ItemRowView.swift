//
//  ItemRowView.swift
//  Hierarchy
//
//  Created by macbook on 19.10.2024.
//
import SwiftUI

struct ItemRowView: View {
    @ObservedObject var viewModel: HierarchyViewModel
    let item: Item
    var parentId: String?
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(itemDisplayName)
                    .font(.headline)
                Spacer()
                if case .dictionary(let childDict) = item.children, !childDict.isEmpty {
                    expandButton
                }
                deleteButton
            }
            .padding()
            if viewModel.expandedItems.contains(item.id.uuidString) {
                expandedChildrenView
            }
            
        }
    }
    
    private var itemDisplayName: String {
        item.data["Name"] ?? item.data["ID"] ?? item.data["Nemesis ID"] ?? item.data["Secrete Code"] ?? "Unknown"
    }
    
    private var expandButton: some View {
        Button(action: {
            viewModel.toggleExpand(for: item, parentId: parentId)
        }) {
            if case .dictionary(let childDict) = item.children, !childDict.isEmpty {
                withAnimation {
                    Button(action: {
                        viewModel.toggleExpand(for: item)
                    }) {
                        Image(systemName: viewModel.expandedItems.contains(item.id.uuidString) ? "chevron.down" : "chevron.right")
                        
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.deleteItem(item, parentId: parentId ?? nil)
        }) {
            Image(systemName: "trash")
        }
        .foregroundColor(.red)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var expandedChildrenView: some View {
        Group {
            switch item.children {
            case .dictionary(let childDict):
                let sortedKeys = Array(childDict.keys).sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let childItems = childDict[key]?.records {
                        ForEach(childItems, id: \.id) { childItem in
                            ItemRowView(viewModel: viewModel, item: childItem, parentId: item.id.uuidString)
                                .padding(.leading)
                        }
                    }
                }
            case .empty:
                EmptyView()
            }
        }
    }
    
}

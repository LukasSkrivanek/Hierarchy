//
//  HiearchyView.swift
//  Hierarchy
//
//  Created by macbook on 19.10.2024.
//
import SwiftUI

struct HierarchyListView: View {
    @StateObject private var viewModel = HierarchyViewModel()
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                ItemRowView(viewModel: viewModel, item: item)
            }
        }
    }
}

//
//  ItemsView.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/4/24.
//

import SwiftUI

struct ItemsView: View {
    @StateObject var viewModel = ItemsViewViewModel()
    
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color(red: 244 / 255, green: 235 / 255, blue: 217 / 255) // Beige background
                        .ignoresSafeArea()
                    List {
                        // Iterate through each group of items by listId
                        ForEach(viewModel.groupedItems.keys.sorted(), id: \.self) { listId in
                            Section(header: Text("List ID \(listId)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255))){
                                    
                                // Subheader for "name" and "id"
                                HStack {
                                    Text("Name")
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("ID")
                                        .font(.subheadline)
                                        .bold()
                                }
                                
                                // List the items for this listId
                                ForEach(viewModel.groupedItems[listId] ?? [], id: \.id) { item in
                                    HStack {
                                        Text(item.name ?? "null")
                                        Spacer()
                                        Text("\(item.id)")
                                    }
                                    
                                }
                            }
                                .listRowBackground(viewModel.colorForListId(listId).opacity(0.5))
                    }

                }
                .navigationTitle("Items")
                .scrollContentBackground(.hidden) // Ignore default background
                .toolbarBackground(Color(red: 244 / 255, green: 235 / 255, blue: 217 / 255), for: .navigationBar)
                .onAppear {
                    viewModel.fetchItems()
                }
            }
        }
    }
}

#Preview {
    ItemsView()
}

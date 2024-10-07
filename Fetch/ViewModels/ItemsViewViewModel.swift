//
//  ItemsViewViewModel.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/4/24.
//
// Fetch data from API endpoint at this address: https://fetch-hiring.s3.amazonaws.com/hiring.json
// And process the data.

import Foundation
import SwiftUI

class ItemsViewViewModel: ObservableObject {
    // Dictionary to hold items grouped by listId
    @Published var groupedItems: [Int: [Item]] = [:]
    @Published var errorMessage: String?
    
    // Define API URL as constant in view model
    private let apiUrl: String = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
    private var networkService: NetworkService
    
    // Initialize Network Service using dependency injection
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
     
    // Fetch data using networkService
    func fetchItems() {
        // Clear previous error message before new request
        self.errorMessage = nil
        
        // Use NetworkService to fetch items
        networkService.fetch(from: apiUrl) { [weak self] (result: Result<[Item], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedItems):
                    self?.processItems(fetchedItems)
                case .failure(let error):
                    self?.errorMessage = "Error fetching data: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func processItems(_ items: [Item]) {
        let filteredSortedItems = items
            .filter { $0.name != nil && !$0.name!.isEmpty } // Filter out blank or null names
            .sorted {
                if $0.listId == $1.listId {
                    return $0.name! < $1.name! // Sort by name if the listId is equal
                }
                return $0.listId < $1.listId // sort by ListID otherwise
            }
        // Group the items by listID (key = listId, value = Item)
        let grouped = Dictionary(grouping: filteredSortedItems) { $0.listId }
        
        // Update groupedItems on main thread
        DispatchQueue.main.async {
            self.groupedItems = grouped
        }
    }
                
    // Determine a new color for each group by listID. Will cycle through the colors in order to handle addition of new listIds
    func colorForListId(_ listId: Int) -> Color {
            let pastelColors: [Color] = [
                Color(red: 255 / 255, green: 209 / 255, blue: 178 / 255),  // Pastel Orange
                Color(red: 255 / 255, green: 253 / 255, blue: 208 / 255), // Cream
                Color(red: 249 / 255, green: 213 / 255, blue: 211 / 255), // Pastel coral
                Color(red: 253 / 255, green: 203 / 255, blue: 186 / 255) // Pastel peach
            ]
        return pastelColors[listId % pastelColors.count]  // Cycle through the colors
        }
}


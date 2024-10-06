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
        
    func fetchItems() {
        // Clear previous error message before new request
        self.errorMessage = nil
        
        // Access API URL and return early if error occurred
        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        // API Call (don't care about response) (weak self to protect from memory leak) in a paused state
        let task  = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            // Ensure we have data and return if error occurred
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error fetching data, please try again later."
                }
                return
            }
            
            // Convert to JSON
            do {
                let fetchedItems = try JSONDecoder().decode([Item].self, from: data)
                
                // Filter and sort items
                let filteredSortedItems = fetchedItems
                    .filter { $0.name != nil && !$0.name!.isEmpty } // Filter out blank or null names
                    .sorted {
                        if $0.listId == $1.listId {
                            return $0.name! < $1.name! // Sort by name if the listId is equal
                        }
                        return $0.listId < $1.listId // sort by ListID otherwise
                    }
                
                // Group the items by listID (key = listId, value = Item)
                let grouped = Dictionary(grouping: filteredSortedItems) { $0.listId }
                
                // Update the items on the main thread (can crash if on background thread)
                DispatchQueue.main.async {
                    self?.groupedItems = grouped
                }
            }
            catch {
                // Return early if error occurs
                DispatchQueue.main.async {
                    self?.errorMessage = "Error processing data, please try again later."
                }
                return
            }
        }
        // Start the network request
        task.resume()
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


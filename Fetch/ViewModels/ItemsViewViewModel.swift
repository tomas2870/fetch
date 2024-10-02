//
//  ItemsViewViewModel.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/4/24.
//
// Fetch data from API endpoint at this address: https://fetch-hiring.s3.amazonaws.com/hiring.json
import Foundation
import SwiftUI

class ItemsViewViewModel: ObservableObject {
    // Dictionary to hold items grouped by listId. Able to update itself when new items added
    @Published var groupedItems: [Int: [Item]] = [:]
        
    func fetchItems() {
        // Access API URL and return if error occurred
        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else {
            return
        }
        
        // Perform API Call (don't care about response)
        let task  = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            // Ensure we have data and return if error occurred
            guard let data = data, error == nil else {
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
                
                // Group the items by listID
                let grouped = Dictionary(grouping: filteredSortedItems) { $0.listId }
                
                // Update the items
                DispatchQueue.main.async {
                    self?.groupedItems = grouped
                }
            }
            catch {
                // Handle error
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    // Determine a new color for each group by listID. Will cycle through these 4 colors in order to handle adding new listIds
    func colorForListId(_ listId: Int) -> Color {
            let pastelColors: [Color] = [
                Color(red: 255 / 255, green: 209 / 255, blue: 178 / 255),     // Pastel Orange
                Color(red: 255 / 255, green: 253 / 255, blue: 208 / 255), // Cream
                Color(red: 249 / 255, green: 213 / 255, blue: 211 / 255), // Pastel coral
                Color(red: 253 / 255, green: 203 / 255, blue: 186 / 255) // Pastel peach
            ]
            return pastelColors[listId % pastelColors.count]  // Cycle through the four colors
        }
}


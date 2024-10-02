//
//  Item.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/4/24.
//
import Foundation

struct Item: Decodable, Identifiable {
    let id: Int
    let listId: Int
    // Can be a string or null, so optional string value. 
    let name: String?
}
